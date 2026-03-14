import 'package:flutter/material.dart';
import 'package:quizz/Views/LessonDetailScreen.dart';
import '../Models/User.dart';
import '../Models/Lesson.dart';
import '../Controller/HomeController.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = HomeController();
  late User currentUser;

  // Key này cực kỳ quan trọng để "ép" FutureBuilder tải lại dữ liệu
  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    // 2. Gán giá trị ban đầu từ widget truyền vào
    currentUser = widget.user;
  }

  // Hàm này sẽ được gọi ngay sau khi đóng màn hình thêm học phần
  void _refreshData() {
    setState(() {
      _refreshKey = UniqueKey(); // Tạo key mới làm FutureBuilder nhận diện có sự thay đổi
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // 1. Header Section
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                colors: [Colors.blue[900]!, Colors.purple[800]!],
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
                        // 3. Đợi kết quả trả về từ ProfileScreen
                        User? newUser = await _controller.navigateToProfile(context, currentUser);

                        // 4. Nếu có dữ liệu mới thì cập nhật giao diện ngay
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 30),
                      const SizedBox(width: 10),
                      Text(
                        "${currentUser.streakCount} Ngày liên tiếp",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
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
                  const Text("Hành động nhanh",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 20),

                  // Nút Thêm bộ câu hỏi
                  GestureDetector(
                    onTap: () async {
                      // Đợi người dùng thực hiện xong thao tác ở màn hình thêm/popup
                      await _controller.navigateToAddLesson(context, widget.user);

                      // Khi Navigator.pop thực hiện ở màn hình kia, dòng này sẽ chạy ngay lập tức
                      _refreshData();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(15)),
                            child: Icon(Icons.add_box_rounded, color: Colors.blue[800], size: 30),
                          ),
                          const SizedBox(width: 20),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Thêm bộ câu hỏi mới", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Tạo chủ đề học tập của riêng bạn", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text("Học phần của bạn",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 10),

                  // TabBar phân loại học phần
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: Colors.blue[900],
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue[900],
                            tabs: const [
                              Tab(text: "Trắc nghiệm"),
                              Tab(text: "Điền từ"),
                            ],
                          ),
                          Expanded(
                            child: FutureBuilder<Map<String, List<Lesson>>>(
                              key: _refreshKey, // Thêm key để nó tự động rebuild
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

  // Widget hiển thị danh sách Card bài học
  Widget _buildLessonList(List<Lesson> lessons, String emptyMessage) {
    if (lessons.isEmpty) {
      return Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];

        return Dismissible(
          key: Key(lesson.id.toString()), // Key duy nhất theo ID học phần
          direction: DismissDirection.endToStart, // Vuốt từ phải sang trái
          confirmDismiss: (direction) async {
            // Hiện hộp thoại xác nhận trước khi xóa
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Xác nhận xóa"),
                content: Text("Bạn có chắc chắn muốn xóa bộ '${lesson.title}' không?"),
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
              _refreshData(); // Load lại danh sách ngay lập tức
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
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: lesson.type == 'abc' ? Colors.blue[50] : Colors.green[50],
                child: Icon(
                  lesson.type == 'abc' ? Icons.quiz_outlined : Icons.text_fields_outlined,
                  color: lesson.type == 'abc' ? Colors.blue[800] : Colors.green[800],
                ),
              ),
              title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Loại: ${lesson.type == 'abc' ? 'Trắc nghiệm' : 'Điền từ'}"),
              trailing: const Icon(Icons.arrow_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonDetailScreen(lesson: lesson),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}