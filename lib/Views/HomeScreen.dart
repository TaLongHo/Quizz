import 'package:flutter/material.dart';
import 'package:quizz/Database/study_log_repo.dart';
import 'package:quizz/Database/user_repo.dart';
import 'package:quizz/Service/ThemeService.dart';
import 'package:quizz/Views/LessonDetailScreen.dart';
import 'package:quizz/Views/LeaderboardScreen.dart';
import '../Models/User.dart';
import '../Models/Lesson.dart';
import '../Controller/HomeController.dart';
import 'FillLessonDetailScreen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final String token;
  const HomeScreen({super.key, required this.user, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final HomeController _controller = HomeController();
  final UserRepo _userRepo = UserRepo();
  late User currentUser;
  Key _refreshKey = UniqueKey();

  // Main tab controller (Của tôi / Khám phá)
  late TabController _mainTabController;

  // Biến quản lý tìm kiếm
  String _searchQuery = "";
  String _exploreSearchQuery = "";

  final PageController _quizPageController = PageController();
  final PageController _fillPageController = PageController();

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    _mainTabController = TabController(length: 2, vsync: this);
    _mainTabController.addListener(() => setState(() {}));
    _userRepo.seedMockUsers();
  }

  @override
  void dispose() {
    _quizPageController.dispose();
    _fillPageController.dispose();
    _mainTabController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  void _navigateToLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeaderboardScreen(currentUser: currentUser)),
    );
  }

  // isOwner mặc định true cho tab "Của tôi", truyền rõ khi từ tab "Khám phá"
  void _navigateToDetail(Lesson lesson, {bool isOwner = true}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => lesson.type == 'fill'
            ? FillLessonDetailScreen(lesson: lesson, isOwner: isOwner)
            : LessonDetailScreen(lesson: lesson, isOwner: isOwner),
      ),
    ).then((_) => _refreshData());
  }

  List<List<Lesson>> _chunkLessons(List<Lesson> lessons, int size) {
    List<List<Lesson>> chunks = [];
    for (var i = 0; i < lessons.length; i += size) {
      chunks.add(lessons.sublist(i, i + size > lessons.length ? lessons.length : i + size));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeService.isDark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // 1. Header Section
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                colors: isDark
                    ? [const Color(0xFF1A237E), const Color(0xFF4A148C)]
                    : [Colors.blue[900]!, Colors.purple[800]!],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_controller.getGreeting(), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        Text(currentUser.displayName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        User? newUser = await _controller.navigateToProfile(context, currentUser);
                        if (newUser != null) setState(() => currentUser = newUser);
                      },
                      child: const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStreakCard(),
                const SizedBox(height: 15),

                // Main Tab Bar (Của tôi / Khám phá)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _mainTabController,
                    indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.blue[900],
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_outline, size: 16), SizedBox(width: 6), Text("Của tôi")])),
                      Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.explore_outlined, size: 16), SizedBox(width: 6), Text("Khám phá")])),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Nội dung chính
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                _buildMyLessonsTab(theme, isDark),
                _buildExploreTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // TAB 1: HỌC PHẦN CỦA TÔI
  // ========================
  Widget _buildMyLessonsTab(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hành động nhanh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 15),
          _buildQuickAction(theme, isDark),
          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Học phần của bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              if (_searchQuery.isNotEmpty)
                IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: () => setState(() => _searchQuery = "")),
            ],
          ),
          const SizedBox(height: 10),
          _buildSearchBar(isDark, _searchQuery, (v) => setState(() => _searchQuery = v)),
          const SizedBox(height: 10),

          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: isDark ? Colors.blue[300] : Colors.blue[900],
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: isDark ? Colors.blue[300] : Colors.blue[900],
                    tabs: const [Tab(text: "Trắc nghiệm"), Tab(text: "Điền từ")],
                  ),
                  Expanded(
                    child: FutureBuilder<Map<String, List<Lesson>>>(
                      key: _refreshKey,
                      future: _controller.getCategorizedLessons(widget.user.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        final rawQuizList = snapshot.data?['quiz'] ?? [];
                        final rawFillList = snapshot.data?['fill'] ?? [];
                        final quizList = rawQuizList.where((l) => l.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                        final fillList = rawFillList.where((l) => l.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                        return TabBarView(
                          children: [
                            _buildLessonPageList(quizList, _searchQuery.isEmpty ? "Chưa có bộ trắc nghiệm nào" : "Không tìm thấy kết quả", _quizPageController),
                            _buildLessonPageList(fillList, _searchQuery.isEmpty ? "Chưa có bộ điền từ nào" : "Không tìm thấy kết quả", _fillPageController),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // TAB 2: KHÁM PHÁ (ALL LESSONS)
  // ========================
  Widget _buildExploreTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tất cả học phần", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Icon(Icons.public, size: 14, color: isDark ? Colors.blue[300] : Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text("Toàn bộ", style: TextStyle(fontSize: 12, color: isDark ? Colors.blue[300] : Colors.blue[700], fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSearchBar(isDark, _exploreSearchQuery, (v) => setState(() => _exploreSearchQuery = v), hint: "Tìm kiếm học phần..."),
          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<List<Lesson>>(
              key: _refreshKey,
              future: _controller.getAllLessonsAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 10),
                    const Text("Lỗi tải dữ liệu", style: TextStyle(color: Colors.grey)),
                  ]));
                }
                final allLessons = snapshot.data ?? [];
                final filtered = allLessons.where((l) => l.title.toLowerCase().contains(_exploreSearchQuery.toLowerCase())).toList();
                if (filtered.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.search_off, size: 52, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(_exploreSearchQuery.isEmpty ? "Chưa có học phần nào" : "Không tìm thấy kết quả", style: const TextStyle(color: Colors.grey)),
                  ]));
                }
                final quizCount = filtered.where((l) => l.type == 'quiz').length;
                final fillCount = filtered.where((l) => l.type == 'fill').length;
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildStatChip(icon: Icons.quiz_outlined, label: "$quizCount Trắc nghiệm", color: Colors.blue, isDark: isDark),
                        const SizedBox(width: 8),
                        _buildStatChip(icon: Icons.text_fields_outlined, label: "$fillCount Điền từ", color: Colors.green, isDark: isDark),
                        const Spacer(),
                        Text("${filtered.length} học phần", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _buildExploreLessonCard(filtered[index], isDark),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildExploreLessonCard(Lesson lesson, bool isDark) {
    final isOwner = lesson.userId == currentUser.id;
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: lesson.type == 'quiz' ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
          child: Icon(lesson.type == 'quiz' ? Icons.quiz_outlined : Icons.text_fields_outlined,
              color: lesson.type == 'quiz' ? Colors.blue : Colors.green),
        ),
        title: Row(
          children: [
            Expanded(child: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold))),
            if (isOwner)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text("Của tôi", style: TextStyle(fontSize: 10, color: isDark ? Colors.blue[300] : Colors.blue[700], fontWeight: FontWeight.w500)),
              ),
          ],
        ),
        subtitle: Text(lesson.type == 'quiz' ? "Trắc nghiệm" : "Điền từ", style: const TextStyle(fontSize: 12)),
        // Chỉ owner mới thấy nút more_vert, người khác chỉ thấy arrow
        trailing: isOwner
            ? IconButton(icon: const Icon(Icons.more_vert, size: 20), onPressed: () => _showLessonOptions(lesson))
            : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () => _navigateToDetail(lesson, isOwner: isOwner),
      ),
    );
  }

  // ========================
  // SHARED WIDGETS
  // ========================

  Widget _buildSearchBar(bool isDark, String currentValue, ValueChanged<String> onChanged, {String hint = "Tìm tên học phần..."}) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: currentValue.isNotEmpty
              ? IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.grey), onPressed: () => onChanged(""))
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildLessonPageList(List<Lesson> allLessons, String emptyMessage, PageController pageController) {
    bool isDark = ThemeService.isDark;
    if (allLessons.isEmpty) return Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)));
    List<List<Lesson>> pages = _chunkLessons(allLessons, 3);
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemCount: pages.length,
            itemBuilder: (context, pageIndex) => ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pages[pageIndex].length,
              // Tab "Của tôi" → isOwner luôn true
              itemBuilder: (context, index) => _buildLessonCard(pages[pageIndex][index], isDark),
            ),
          ),
        ),
        if (pages.length > 1) _buildPageIndicator(pages.length, pageController, isDark),
      ],
    );
  }

  Widget _buildLessonCard(Lesson lesson, bool isDark) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: lesson.type == 'quiz' ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
          child: Icon(lesson.type == 'quiz' ? Icons.quiz_outlined : Icons.text_fields_outlined,
              color: lesson.type == 'quiz' ? Colors.blue : Colors.green),
        ),
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(lesson.type == 'quiz' ? "Trắc nghiệm" : "Điền từ", style: const TextStyle(fontSize: 12)),
        trailing: IconButton(icon: const Icon(Icons.more_vert, size: 20), onPressed: () => _showLessonOptions(lesson)),
        onTap: () => _navigateToDetail(lesson, isOwner: true),
      ),
    );
  }

  void _showLessonOptions(Lesson lesson) {
    bool isDark = ThemeService.isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          ListTile(
            leading: const Icon(Icons.edit_note_rounded, color: Colors.blue),
            title: Text("Chỉnh sửa học phần", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () { Navigator.pop(context); _navigateToDetail(lesson, isOwner: true); },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text("Xóa học phần này", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            onTap: () { Navigator.pop(context); _confirmDelete(lesson); },
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  void _confirmDelete(Lesson lesson) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Xác nhận xóa"),
        content: Text("Dữ liệu bộ '${lesson.title}' sẽ biến mất vĩnh viễn?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("HỦY")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("XÓA", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _controller.deleteLesson(lesson.id!);
      _refreshData();
    }
  }

  Widget _buildPageIndicator(int count, PageController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          int page = controller.hasClients ? controller.page?.round() ?? 0 : 0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8, width: i == page ? 22 : 8,
              decoration: BoxDecoration(
                color: i == page ? (isDark ? Colors.blue[300] : Colors.blue[900]) : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            )),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () => _controller.navigateToAddLesson(context, currentUser, _refreshData),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.add_box_rounded, color: Colors.blue, size: 30)),
            const SizedBox(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Thêm học phần mới", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              Text("Tạo chủ đề học tập của riêng bạn", style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 13)),
            ]),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _controller.showStreakCalendar(context, currentUser, (u) => setState(() => currentUser = u)),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 30),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${currentUser.streakCount} Ngày liên tiếp", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text("Xem lịch học tập", style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 30, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 10)),
          GestureDetector(
            onTap: _navigateToLeaderboard,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.leaderboard_rounded, color: Colors.orangeAccent, size: 20),
                  SizedBox(width: 5),
                  Text("Hạng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}