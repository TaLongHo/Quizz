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
}