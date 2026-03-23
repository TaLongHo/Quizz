import 'package:sqflite/sqflite.dart';

import 'db_core.dart';

class StudyLogRepo {
  final dbCore = DbCore.instance;

  // Trong UserRepo.dart hoặc StudyLogRepo.dart
  Future<List<String>> getStudyDates(int userId) async {
    final db = await dbCore.database;
    // Lấy danh sách ngày (định dạng YYYY-MM-DD) của user đó
    final List<Map<String, dynamic>> maps = await db.query(
      'study_logs',
      columns: ['study_date'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) => maps[i]['study_date'].toString());
  }

  Future<Map<int, int>> getStudyHourDistribution() async {
    final db = await dbCore.database;

    // Cộng 7 tiếng để đổi UTC → giờ Việt Nam
    final result = await db.rawQuery('''
    SELECT CAST(strftime('%H', datetime(created_at, '+7 hours')) AS INTEGER) as hour,
           COUNT(*) as count
    FROM lessons
    GROUP BY hour
    ORDER BY hour ASC
  ''');

    final map = <int, int>{};
    for (var row in result) {
      final h = (row['hour'] as int?) ?? 0;
      map[h] = (row['count'] as int?) ?? 0;
    }

    // Nếu không có data thực, trả về mock data để chart không trống
    if (map.isEmpty) {
      return {
        7: 1, 8: 2, 9: 3, 12: 2, 13: 1,
        17: 2, 18: 4, 19: 8, 20: 12, 21: 9, 22: 5,
      };
    }

    return map;
  }

// Đếm hoạt động 7 ngày (số user học mỗi ngày)
  Future<Map<String, int>> getDailyActiveUsers() async {
    final db = await dbCore.database;
    final result = await db.rawQuery('''
    SELECT study_date, COUNT(DISTINCT user_id) as count
    FROM study_logs
    WHERE study_date >= date('now', '-6 days')
    GROUP BY study_date
    ORDER BY study_date ASC
  ''');
    final map = <String, int>{};
    for (var row in result) {
      map[row['study_date'] as String] = (row['count'] as int?) ?? 0;
    }
    return map;
  }
}