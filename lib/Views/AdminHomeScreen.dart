import 'package:flutter/material.dart';
import 'package:quizz/Views/AdminStatsScreen.dart';
import '../Database/lesson_repo.dart';
import '../Database/user_repo.dart';
import '../Models/User.dart';
import 'AddLessonAdminScreen.dart';
import 'LoginScreen.dart';
import 'ManageQuizScreen.dart';

class AdminHomeScreen extends StatefulWidget {
  final User user;
  final String token;

  const AdminHomeScreen({super.key, required this.user, required this.token});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final UserRepo _userRepo = UserRepo();
  final LessonRepo _lessonRepo = LessonRepo();

  int _totalUsers = 0;
  int _totalLessons = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    // Lấy tổng users (role = 'user', không tính admin)
    final users = await _userRepo.getLeaderboard(limit: 9999);
    // Lấy tất cả lessons
    final lessons = await _lessonRepo.getAllLessonsAdmin();

    if (mounted) {
      setState(() {
        _totalUsers = users.length;
        _totalLessons = lessons.length;
        _loadingStats = false;
      });
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Đăng xuất"),
        content: const Text(
            "Bạn có chắc muốn thoát khỏi phiên làm việc quản trị không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("HỦY", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text("ĐĂNG XUẤT",
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: const Text("ADMIN DASHBOARD",
            style:
            TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => _handleLogout(context),
            tooltip: "Đăng xuất",
          ),
          const Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(Icons.person, size: 20, color: Color(0xFF64748B))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 25),

            const Text("Hệ thống tổng quan",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B))),
            const SizedBox(height: 15),

            // ── Stat row với data thật ──
            _loadingStats
                ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ))
                : Row(
              children: [
                _buildStatItem(
                  "Học viên",
                  '$_totalUsers',
                  Icons.people_alt_rounded,
                  Colors.blue,
                  sub: 'user',
                ),
                const SizedBox(width: 15),
                _buildStatItem(
                  "Học phần",
                  '$_totalLessons',
                  Icons.menu_book_rounded,
                  Colors.orange,
                  sub: 'trắc nghiệm + điền từ',
                ),
              ],
            ),

            const SizedBox(height: 25),
            const Text("Quản lý dữ liệu",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B))),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildAdminMenu(
                  icon: Icons.manage_accounts,
                  title: "Người dùng",
                  sub: "Quản lý & Phân quyền",
                  color: const Color(0xFF6366F1),
                  onTap: () {},
                ),
                _buildAdminMenu(
                  icon: Icons.category,
                  title: "Học phần",
                  sub: "Duyệt bộ câu hỏi",
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageQuizScreen()),
                    );
                  },
                ),
                _buildAdminMenu(
                  icon: Icons.analytics,
                  title: "Báo cáo",
                  sub: "Thống kê học tập",
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminStatsScreen()),
                    ).then((_) => _loadStats()); // refresh khi quay lại
                  },
                ),
                _buildAdminMenu(
                  icon: Icons.settings,
                  title: "Hệ thống",
                  sub: "Cấu hình ứng dụng",
                  color: const Color(0xFF64748B),
                  onTap: () {},
                ),
                _buildAdminMenu(
                  icon: Icons.add,
                  title: "Thêm học phần",
                  sub: "Thêm học phần mới",
                  color: const Color(0xFF64748B),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const AddLessonAdminScreen()),
                    ).then((_) => _loadStats()); // refresh sau khi thêm
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Xin chào, Quản trị viên",
                      style:
                      TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(widget.user.displayName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.verified_user,
                  color: Colors.blueAccent, size: 40),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10)),
            child: const Text("Phiên làm việc: JWT Verified",
                style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          )
        ],
      ),
    );
  }

  // Thêm tham số sub để hiện mô tả nhỏ bên dưới số
  Widget _buildStatItem(String title, String value, IconData icon, Color color,
      {String sub = ''}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 15),
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B))),
            Text(title,
                style:
                const TextStyle(color: Colors.grey, fontSize: 14)),
            if (sub.isNotEmpty)
              Text(sub,
                  style: const TextStyle(
                      color: Color(0xFFB0BEC5), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenu(
      {required IconData icon,
        required String title,
        required String sub,
        required Color color,
        VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02), blurRadius: 10)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(sub,
                textAlign: TextAlign.center,
                style:
                const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}