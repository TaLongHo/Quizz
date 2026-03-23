import 'package:intl/intl.dart';
import 'package:quizz/Models/User.dart';
import 'db_core.dart';

class UserRepo {
  final dbCore = DbCore.instance;

  // ─── ĐĂNG NHẬP: Chỉ cho phép user có is_active = 1 ──────────────────────
  Future<User?> login(String username, String password) async {
    final db = await dbCore.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ? AND is_active = 1',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // ─── KIỂM TRA USER BỊ BLOCK (để hiển thị thông báo rõ hơn) ──────────────
  Future<bool> isUserBlocked(String username) async {
    final db = await dbCore.database;
    final maps = await db.query(
      'users',
      columns: ['is_active'],
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return (maps.first['is_active'] ?? 1) == 0;
    }
    return false;
  }

  // ─── ĐĂNG KÝ ─────────────────────────────────────────────────────────────
  Future<int> register(User user) async {
    final db = await dbCore.database;
    return await db.insert('users', user.toMap());
  }

  // ─── CẬP NHẬT THÔNG TIN USER ─────────────────────────────────────────────
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

  // ─── LẤY USER THEO ID ────────────────────────────────────────────────────
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

  // ─── [ADMIN] LẤY TẤT CẢ USER (kể cả bị block) ───────────────────────────
  Future<List<User>> getAllUsers() async {
    final db = await dbCore.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['user'],
      orderBy: 'display_name ASC',
    );
    return maps.map((e) => User.fromMap(e)).toList();
  }

  // ─── [ADMIN] BLOCK USER (xóa mềm: is_active = 0) ────────────────────────
  Future<bool> blockUser(int userId) async {
    final db = await dbCore.database;
    final result = await db.update(
      'users',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result > 0;
  }

  // ─── [ADMIN] UNBLOCK USER (is_active = 1) ────────────────────────────────
  Future<bool> unblockUser(int userId) async {
    final db = await dbCore.database;
    final result = await db.update(
      'users',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result > 0;
  }

  // ─── LEADERBOARD (chỉ user active) ───────────────────────────────────────
  Future<List<User>> getLeaderboard({int limit = 50}) async {
    final db = await dbCore.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ? AND is_active = 1',
      whereArgs: ['user'],
      orderBy: 'streak_count DESC, display_name ASC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // ─── UPDATE STREAK ────────────────────────────────────────────────────────
  Future<void> updateStudyProgress(int userId, double score) async {
    final db = await dbCore.database;
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final List<Map<String, dynamic>> userMap = await db.query(
      'users',
      columns: ['streak_count', 'last_study_date'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (userMap.isEmpty) return;

    int currentStreak = userMap.first['streak_count'] ?? 0;
    String? lastStudyDateStr = userMap.first['last_study_date'];

    final List<Map<String, dynamic>> existingLog = await db.query(
      'study_logs',
      where: 'user_id = ? AND study_date = ?',
      whereArgs: [userId, todayStr],
    );

    if (existingLog.isEmpty) {
      int newStreak = 1;

      if (lastStudyDateStr != null) {
        DateTime lastDate = DateFormat('yyyy-MM-dd').parse(lastStudyDateStr);
        DateTime todayDate = DateFormat('yyyy-MM-dd').parse(todayStr);
        int difference = todayDate.difference(lastDate).inDays;

        if (difference == 1) {
          newStreak = currentStreak + 1;
        } else if (difference == 0) {
          newStreak = currentStreak;
        } else {
          newStreak = 1;
        }
      }

      await db.transaction((txn) async {
        await txn.insert('study_logs', {
          'user_id': userId,
          'study_date': todayStr,
          'score': score,
        });
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
    }
  }

  // ─── SEED MOCK DATA ───────────────────────────────────────────────────────
  Future<void> seedMockUsers() async {
    final db = await dbCore.database;
    final List<Map<String, dynamic>> existingUsers = await db.query('users');

    if (existingUsers.length < 5) {
      List<Map<String, dynamic>> mockData = [
        {
          'username': 'nguyenvana',
          'password': '123',
          'display_name': 'Nguyễn Văn A',
          'streak_count': 45,
          'role': 'user',
          'last_study_date': '2026-03-22',
          'gender': 0,
          'birthday': '2000-01-01',
          'remind_time': '20:00',
          'is_active': 1,
        },
        {
          'username': 'tranthib',
          'password': '123',
          'display_name': 'Trần Thị B',
          'streak_count': 32,
          'role': 'user',
          'last_study_date': '2026-03-23',
          'gender': 1,
          'birthday': '2000-01-01',
          'remind_time': '20:00',
          'is_active': 1,
        },
        {
          'username': 'lehoangc',
          'password': '123',
          'display_name': 'Lê Hoàng C',
          'streak_count': 28,
          'role': 'user',
          'last_study_date': '2026-03-21',
          'gender': 0,
          'birthday': '2000-01-01',
          'remind_time': '20:00',
          'is_active': 1,
        },
        {
          'username': 'phamduyd',
          'password': '123',
          'display_name': 'Phạm Duy D',
          'streak_count': 15,
          'role': 'user',
          'last_study_date': '2026-03-23',
          'gender': 0,
          'birthday': '2000-01-01',
          'remind_time': '20:00',
          'is_active': 1,
        },
        {
          'username': 'hoangthie',
          'password': '123',
          'display_name': 'Hoàng Thị E',
          'streak_count': 7,
          'role': 'user',
          'last_study_date': '2026-03-20',
          'gender': 1,
          'birthday': '2000-01-01',
          'remind_time': '20:00',
          'is_active': 1,
        },
      ];

      for (var user in mockData) {
        await db.insert('users', user);
      }
    }
  }
}