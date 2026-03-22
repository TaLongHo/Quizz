import 'package:intl/intl.dart';
import 'package:quizz/Models/User.dart';
import 'db_core.dart';

class UserRepo {
  final dbCore = DbCore.instance;

  // Hàm kiểm tra đăng nhập
  Future<User?> login(String username, String password) async {
    final db = await dbCore.database;

    // Truy vấn tìm user khớp cả username và password
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null; // Trả về null nếu không tìm thấy
  }

  // Hàm đăng ký (để bạn test tạo tài khoản mới)
  Future<int> register(User user) async {
    final db = await dbCore.database;
    return await db.insert('users', user.toMap());
  }

  Future<bool> updateUser(User user) async {
    final db = await dbCore.database;
    try {
      int result = await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return result > 0;
    } catch (e) {
      print("Lỗi update DB: $e");
      return false;
    }
  }

  Future<User?> getUserById(int id) async {
    final db = await dbCore.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateStudyProgress(int userId, double score) async {
    final db = await dbCore.database;
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    // 1. Lấy thông tin User hiện tại để kiểm tra ngày học cuối cùng
    final List<Map<String, dynamic>> userMap = await db.query(
      'users',
      columns: ['streak_count', 'last_study_date'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (userMap.isEmpty) return;

    int currentStreak = userMap.first['streak_count'] ?? 0;
    String? lastStudyDateStr = userMap.first['last_study_date'];

    // 2. Kiểm tra xem hôm nay đã học chưa (để tránh cộng streak 2 lần/ngày)
    final List<Map<String, dynamic>> existingLog = await db.query(
      'study_logs',
      where: 'user_id = ? AND study_date = ?',
      whereArgs: [userId, todayStr],
    );

    // Nếu hôm nay chưa có log học tập, chúng ta mới xử lý tính Streak
    if (existingLog.isEmpty) {
      int newStreak = 1; // Mặc định là 1 nếu là lần đầu hoặc bị mất chuỗi

      if (lastStudyDateStr != null) {
        DateTime lastDate = DateFormat('yyyy-MM-dd').parse(lastStudyDateStr);
        DateTime todayDate = DateFormat('yyyy-MM-dd').parse(todayStr);

        // Tính khoảng cách ngày
        int difference = todayDate.difference(lastDate).inDays;

        if (difference == 1) {
          // TH1: Học liên tiếp (Hôm qua học, nay học) -> Tăng streak
          newStreak = currentStreak + 1;
        } else if (difference == 0) {
          // TH2: Đã học trong ngày rồi (Logic này an tâm vì đã check existingLog ở trên)
          newStreak = currentStreak;
        } else {
          // TH3: Nghỉ quá 1 ngày (Mất chuỗi) -> Reset về 1
          newStreak = 1;
        }
      }

      // 3. Thực hiện cập nhật DB trong một Transaction để đảm bảo an toàn dữ liệu
      await db.transaction((txn) async {
        // Ghi log bài học hôm nay
        await txn.insert('study_logs', {
          'user_id': userId,
          'study_date': todayStr,
          'score': score,
        });

        // Cập nhật User với Streak mới và ngày học mới nhất
        await txn.update(
          'users',
          {
            'streak_count': newStreak,
            'last_study_date': todayStr,
          },
          where: 'id = ?',
          whereArgs: [userId],
        );
      });

      print("🔥 Streak updated: $newStreak (Diff from last: $lastStudyDateStr)");
    } else {
      // Nếu hôm nay đã học rồi, chỉ cập nhật lại log điểm nếu điểm mới cao hơn (tùy chọn)
      print("✅ Hôm nay đã nhận Streak rồi, không cộng thêm.");
    }
  }
}