import 'package:flutter/material.dart';
import 'package:quizz/Database/study_log_repo.dart';
import 'package:quizz/Service/ThemeService.dart';
import 'package:quizz/Views/LessonDetailScreen.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = HomeController();
  late User currentUser;
  Key _refreshKey = UniqueKey();

  final PageController _quizPageController = PageController();
  final PageController _fillPageController = PageController();

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    _initTestData();
  }

  @override
  void dispose() {
    _quizPageController.dispose();
    _fillPageController.dispose();
    super.dispose();
  }

  Future<void> _initTestData() async {
    final StudyLogRepo _logRepo = StudyLogRepo();
    await _logRepo.insertTestStreak(currentUser.id!);
    setState(() {
      currentUser = User(
        id: currentUser.id,
        username: currentUser.username,
        password: currentUser.password,
        displayName: currentUser.displayName,
        gender: currentUser.gender,
        birthday: currentUser.birthday,
        streakCount: 6,
        lastStudyDate: '2026-03-23',
      );
    });
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  // Hàm điều hướng dùng chung cho cả Card và Menu Edit
  void _navigateToDetail(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => lesson.type == 'fill'
            ? FillLessonDetailScreen(lesson: lesson)
            : LessonDetailScreen(lesson: lesson),
      ),
    ).then((_) => _refreshData()); // Refresh dữ liệu khi quay lại nếu có thay đổi
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
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
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
                const SizedBox(height: 25),
                _buildStreakCard(),
              ],
            ),
          ),

          // 2. Nội dung chính
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hành động nhanh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 20),
                  _buildQuickAction(theme, isDark),
                  const SizedBox(height: 30),
                  Text("Học phần của bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
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
                                final quizList = snapshot.data?['quiz'] ?? [];
                                final fillList = snapshot.data?['fill'] ?? [];
                                return TabBarView(
                                  children: [
                                    _buildLessonPageList(quizList, "Chưa có bộ trắc nghiệm nào", _quizPageController),
                                    _buildLessonPageList(fillList, "Chưa có bộ điền từ nào", _fillPageController),
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
            ),
          ),
        ],
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
            itemBuilder: (context, pageIndex) {
              return ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pages[pageIndex].length,
                itemBuilder: (context, index) => _buildLessonCard(pages[pageIndex][index], isDark),
              );
            },
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
          child: Icon(
            lesson.type == 'quiz' ? Icons.quiz_outlined : Icons.text_fields_outlined,
            color: lesson.type == 'quiz' ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(lesson.type == 'quiz' ? "Trắc nghiệm" : "Điền từ", style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: () => _showLessonOptions(lesson),
        ),
        onTap: () => _navigateToDetail(lesson),
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
            onTap: () {
              Navigator.pop(context);
              _navigateToDetail(lesson);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text("Xóa học phần này", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(lesson);
            },
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
              decoration: BoxDecoration(color: i == page ? (isDark ? Colors.blue[300] : Colors.blue[900]) : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
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
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: isDark ? Border.all(color: Colors.white10) : null),
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
    return GestureDetector(
      onTap: () => _controller.showStreakCalendar(context, currentUser, (u) => setState(() => currentUser = u)),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 30),
          const SizedBox(width: 10),
          Text("${currentUser.streakCount} Ngày liên tiếp", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.calendar_month, color: Colors.white70),
        ]),
      ),
    );
  }
}