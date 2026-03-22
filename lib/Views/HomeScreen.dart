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

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    _initTestData();
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
                        Text(_controller.getGreeting(),
                            style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        Text(currentUser.displayName,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        User? newUser = await _controller.navigateToProfile(context, currentUser);
                        if (newUser != null) {
                          setState(() {
                            currentUser = newUser;
                          });
                        }
                      },
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () => _controller.showStreakCalendar(
                      context,
                      currentUser,
                          (updatedUser) {
                        setState(() {
                          currentUser = updatedUser;
                        });
                      }
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 30),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${currentUser.streakCount} Ngày liên tiếp",
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const Text(
                              "Chạm để xem lịch sử học",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.calendar_month, color: Colors.white70, size: 20),
                      ],
                    ),
                  ),
                ),
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
                  Text("Hành động nhanh",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () async {
                      await _controller.navigateToAddLesson(context, currentUser, _refreshData);
                      _refreshData();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue[50],
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Icon(Icons.add_box_rounded, color: isDark ? Colors.blue[300] : Colors.blue[800], size: 30),
                          ),
                          const SizedBox(width: 20),
                          // --- ĐÃ XÓA TỪ KHÓA CONST Ở ĐÂY ĐỂ FIX LỖI ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Thêm học phần mới",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87)),
                              Text("Tạo chủ đề học tập của riêng bạn",
                                  style: TextStyle(color: isDark ? Colors.white60 : Colors.grey)),
                            ],
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white30 : Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Text("Học phần của bạn",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87)),
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
                            tabs: const [
                              Tab(text: "Trắc nghiệm"),
                              Tab(text: "Điền từ"),
                            ],
                          ),
                          Expanded(
                            child: FutureBuilder<Map<String, List<Lesson>>>(
                              key: _refreshKey,
                              future: _controller.getCategorizedLessons(widget.user.id!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                final quizList = snapshot.data?['quiz'] ?? [];
                                final fillList = snapshot.data?['fill'] ?? [];

                                return TabBarView(
                                  children: [
                                    _buildLessonList(quizList, "Chưa có bộ trắc nghiệm nào"),
                                    _buildLessonList(fillList, "Chưa có bộ điền từ nào"),
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

  // --- HÀM BUILD LESSON LIST ĐÃ ĐƯỢC TỐI ƯU DARK MODE ---
  Widget _buildLessonList(List<Lesson> lessons, String emptyMessage) {
    bool isDark = ThemeService.isDark;

    if (lessons.isEmpty) {
      return Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];

        return Dismissible(
          key: Key(lesson.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).cardColor, // Đổi màu nền dialog
                title: Text("Xác nhận xóa", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                content: Text("Bạn có chắc chắn muốn xóa bộ '${lesson.title}' không?", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("HỦY")),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("XÓA", style: TextStyle(color: Colors.red))
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) async {
            bool success = await _controller.deleteLesson(lesson.id!);
            if (success) {
              _refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã xóa học phần")),
              );
            }
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            elevation: 0,
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              // Thêm viền nhẹ khi ở Dark Mode để tách Card ra khỏi nền
              side: isDark
                  ? BorderSide(color: Colors.white.withOpacity(0.1), width: 1)
                  : const BorderSide(color: Colors.transparent), // Thay BorderSide.none
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isDark
                    ? (lesson.type == 'quiz' ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1))
                    : (lesson.type == 'quiz' ? Colors.blue[50] : Colors.green[50]),
                child: Icon(
                  lesson.type == 'quiz' ? Icons.quiz_outlined : Icons.text_fields_outlined,
                  color: isDark
                      ? (lesson.type == 'quiz' ? Colors.blue[300] : Colors.green[300])
                      : (lesson.type == 'quiz' ? Colors.blue[800] : Colors.green[800]),
                ),
              ),
              title: Text(lesson.title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              subtitle: Text("Loại: ${lesson.type == 'quiz' ? 'Trắc nghiệm' : 'Điền từ'}",
                  style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
              trailing: Icon(Icons.arrow_right, color: isDark ? Colors.white30 : Colors.grey),
              onTap: () {
                if (lesson.type == 'fill') {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => FillLessonDetailScreen(lesson: lesson),
                  ));
                } else {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => LessonDetailScreen(lesson: lesson),
                  ));
                }
              },
            ),
          ),
        );
      },
    );
  }
}