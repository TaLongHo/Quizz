import 'package:flutter/material.dart';
import '../Controller/UserManagementController.dart';
import '../Models/Lesson.dart';
import '../Models/User.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  final VoidCallback onBlockChanged;

  const UserDetailScreen({
    super.key,
    required this.user,
    required this.onBlockChanged,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final UserManagementController _controller = UserManagementController();

  late User _user;
  List<Lesson> _lessons = [];
  bool _isLoadingLessons = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final lessons = await _controller.getLessonsByUser(_user.id!);
    setState(() {
      _lessons = lessons;
      _isLoadingLessons = false;
    });
  }

  Future<void> _toggleBlock() async {
    final isBlocking = _user.isActive == 1;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isBlocking ? Icons.block_rounded : Icons.lock_open_rounded,
              color: isBlocking ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 10),
            Text(isBlocking ? 'Khóa tài khoản' : 'Mở khóa tài khoản'),
          ],
        ),
        content: Text(
          isBlocking
              ? 'Bạn có chắc muốn KHÓA tài khoản "${_user.displayName}"?\n\nUser này sẽ không thể đăng nhập.'
              : 'Bạn có chắc muốn MỞ KHÓA tài khoản "${_user.displayName}"?',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocking ? Colors.red : Colors.green,
              shape: const StadiumBorder(),
            ),
            child: Text(
              isBlocking ? 'KHÓA' : 'MỞ KHÓA',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    bool success = isBlocking
        ? await _controller.blockUser(_user.id!)
        : await _controller.unblockUser(_user.id!);

    if (success && mounted) {
      setState(() {
        _user = User(
          id: _user.id,
          username: _user.username,
          password: _user.password,
          displayName: _user.displayName,
          role: _user.role,
          gender: _user.gender,
          birthday: _user.birthday,
          streakCount: _user.streakCount,
          lastStudyDate: _user.lastStudyDate,
          remindTime: _user.remindTime,
          isActive: isBlocking ? 0 : 1,
        );
      });

      widget.onBlockChanged();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBlocking
              ? '🔒 Đã khóa tài khoản ${_user.displayName}'
              : '🔓 Đã mở khóa ${_user.displayName}'),
          backgroundColor:
          isBlocking ? Colors.red[700] : Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = _user.isActive == 0;
    final Color themeColor =
    isBlocked ? Colors.red[800]! : Colors.blue[900]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_user.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Nút Block / Unblock trên AppBar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _toggleBlock,
              icon: Icon(
                isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                isBlocked ? 'Mở khóa' : 'Khóa',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header Avatar ──────────────────────────────────────────
            _buildHeader(themeColor, isBlocked),

            const SizedBox(height: 20),

            // ── Status Banner (nếu bị block) ───────────────────────────
            if (isBlocked)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Tài khoản này đang bị khóa',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ── Thông tin cơ bản ───────────────────────────────────────
            _buildInfoCard(),

            const SizedBox(height: 16),

            // ── Thống kê ──────────────────────────────────────────────
            _buildStatsCard(),

            const SizedBox(height: 16),

            // ── Danh sách bài học ─────────────────────────────────────
            _buildLessonsSection(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color themeColor, bool isBlocked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, top: 20),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius:
        const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white24,
                child: Text(
                  _user.displayName.isNotEmpty
                      ? _user.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36),
                ),
              ),
              if (isBlocked)
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block,
                      color: Colors.white, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _user.displayName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '@${_user.username}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _controller.getRankTitle(_user.streakCount),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Thông tin cơ bản', Icons.info_outline),
            _buildInfoRow(Icons.cake_outlined, 'Ngày sinh', _user.birthday.isEmpty ? 'Chưa cập nhật' : _user.birthday),
            _buildInfoRow(
                Icons.wc_outlined, 'Giới tính', _controller.getGenderText(_user.gender)),
            _buildInfoRow(Icons.notifications_outlined, 'Nhắc nhở',
                _user.remindTime),
            _buildInfoRow(
                Icons.shield_outlined,
                'Trạng thái',
                _user.isActive == 1 ? 'Đang hoạt động' : 'Bị khóa',
                valueColor:
                _user.isActive == 1 ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Thống kê học tập', Icons.bar_chart_rounded),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  _buildStatBox('${_user.streakCount}',
                      'Ngày liên tiếp', Colors.orangeAccent, Icons.local_fire_department),
                  const SizedBox(width: 12),
                  _buildStatBox(
                    _user.lastStudyDate ?? '—',
                    'Học lần cuối',
                    Colors.blue,
                    Icons.calendar_today_outlined,
                    isSmallText: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Bài học đã tạo (${_lessons.length})',
              Icons.menu_book_rounded,
            ),
            if (_isLoadingLessons)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_lessons.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text('Chưa có bài học nào',
                          style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: _lessons.length,
                itemBuilder: (context, index) {
                  final lesson = _lessons[index];
                  final isQuiz = lesson.type == 'quiz';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isQuiz ? Colors.blue : Colors.green)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isQuiz
                                ? Icons.quiz_outlined
                                : Icons.text_fields_rounded,
                            color: isQuiz ? Colors.blue : Colors.green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              Text(
                                isQuiz ? 'Trắc nghiệm' : 'Điền từ',
                                style: TextStyle(
                                    color: isQuiz
                                        ? Colors.blue[700]
                                        : Colors.green[700],
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '#${lesson.id}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[900], size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color, IconData icon,
      {bool isSmallText = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallText ? 13 : 22,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}