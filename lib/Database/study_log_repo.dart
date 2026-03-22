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

  Future<void> insertTestStreak(int userId) async {
    final db = await DbCore.instance.database;

    // Danh sách 5 ngày liên tiếp tính đến 22/03/2026
    List<String> testDates = [
      '2026-03-18',
      '2026-03-19',
      '2026-03-20',
      '2026-03-21',
      '2026-03-22',
      '2026-03-23',
    ];

    for (String date in testDates) {
      await db.insert('study_logs', {
        'user_id': userId,
        'study_date': date,
        'score': 100.0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Cập nhật User
    await db.update('users',
        {'streak_count': 6, 'last_study_date': '2026-03-23'},
        where: 'id = ?',
        whereArgs: [userId]
    );

    print("Đã chèn dữ liệu test thành công!");
  }
}