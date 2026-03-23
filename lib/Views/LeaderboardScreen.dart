import 'package:flutter/material.dart';
import '../Controller/LeaderboardController.dart';
import '../Models/User.dart';
import '../Service/ThemeService.dart';

class LeaderboardScreen extends StatelessWidget {
  final User currentUser;
  LeaderboardScreen({super.key, required this.currentUser});

  final LeaderboardController _controller = LeaderboardController();

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Bảng Xếp Hạng", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<User>>(
        future: _controller.getLeaderboardData(),
        builder: (context, snapshot) {
          // 1. Kiểm tra trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Kiểm tra lỗi hoặc dữ liệu null/rỗng
          if (snapshot.hasError) {
            return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Không thể tải dữ liệu"));
          }

          // 3. Lọc dữ liệu an toàn (Chỉ lấy role 'user')
          final List<User> topUsers = snapshot.data!
              .where((u) => u.role == 'user')
              .toList();

          if (topUsers.isEmpty) {
            return const Center(child: Text("Chưa có học viên nào tham gia"));
          }

          return Column(
            children: [
              // 1. Phần Top 3 (Bục vinh quang)
              _buildPodium(topUsers.take(3).toList(), isDark),

              // 2. Danh sách từ hạng 4 trở đi
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    itemCount: topUsers.length > 3 ? topUsers.length - 3 : 0,
                    itemBuilder: (context, index) {
                      final user = topUsers[index + 3];
                      return _buildRankItem(index + 4, user, isDark);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Các Widget phụ giữ nguyên logic của ông nhưng bọc thêm kiểm tra ---

  Widget _buildPodium(List<User> top3, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top3.length > 1) _buildPodiumItem(top3[1], 2, 70, Colors.grey[400]!, isDark),
          if (top3.isNotEmpty) _buildPodiumItem(top3[0], 1, 90, Colors.amber, isDark),
          if (top3.length > 2) _buildPodiumItem(top3[2], 3, 60, Colors.brown[400]!, isDark),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(User user, int rank, double size, Color color, bool isDark) {
    return Column(
      children: [
        if (rank == 1) const Icon(Icons.workspace_premium, color: Colors.amber, size: 30),
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(radius: (size / 2) + 4, backgroundColor: color),
            CircleAvatar(
              radius: size / 2,
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              child: const Icon(Icons.person, size: 40, color: Colors.grey),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                child: Text("#$rank", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("${user.streakCount} 🔥", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRankItem(int rank, User user, bool isDark) {
    bool isMe = user.id == currentUser.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue.withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50]),
        borderRadius: BorderRadius.circular(15),
        border: isMe ? Border.all(color: Colors.blueAccent.withOpacity(0.5)) : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(rank.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          const CircleAvatar(radius: 20, child: Icon(Icons.person, size: 20)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.w500)),
                Text(_controller.getRankTitle(user.streakCount), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text("${user.streakCount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 4),
          const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 20),
        ],
      ),
    );
  }
}