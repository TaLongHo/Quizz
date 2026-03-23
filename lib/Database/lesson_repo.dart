import '../Models/Lesson.dart';
import '../Models/Question.dart';
import 'db_core.dart';

class LessonRepo {
  final dbCore = DbCore.instance;

  // ─── LESSON ───────────────────────────────────────────────────────────────

  Future<void> saveCompleteLesson(
      Lesson lesson, List<Question> questions) async {
    final db = await dbCore.database;
    await db.transaction((txn) async {
      int lessonId = await txn.insert('lessons', lesson.toMap());
      for (var q in questions) {
        var qMap = q.toMap();
        qMap['lesson_id'] = lessonId;
        await txn.insert('questions', qMap);
      }
    });
  }

  Future<List<Lesson>> getAllLessons(int userId) async {
    final db = await dbCore.database;
    final maps = await db.query(
      'lessons',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return maps.map((e) => Lesson.fromMap(e)).toList();
  }

  Future<List<Lesson>> getAllLessonsAdmin() async {
    final db = await dbCore.database;
    final maps = await db.query('lessons', orderBy: 'id DESC');
    return maps.map((e) => Lesson.fromMap(e)).toList();
  }

  Future<void> deleteLesson(int lessonId) async {
    final db = await dbCore.database;
    await db.delete('lessons', where: 'id = ?', whereArgs: [lessonId]);
  }

  // ─── QUESTION ─────────────────────────────────────────────────────────────

  Future<List<Question>> getQuestionsByLesson(int lessonId) async {
    final db = await dbCore.database;
    final maps = await db.query(
      'questions',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return maps.map((e) => Question.fromMap(e)).toList();
  }

  Future<int> addQuestion(Question question) async {
    final db = await dbCore.database;
    return await db.insert('questions', question.toMap());
  }

  Future<bool> updateQuestion(Question question) async {
    final db = await dbCore.database;
    final result = await db.update(
      'questions',
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
    return result > 0;
  }

  Future<bool> deleteQuestion(int questionId) async {
    final db = await dbCore.database;
    final result = await db.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [questionId],
    );
    return result > 0;
  }

  // Đếm số lesson theo type (quiz/fill)
  Future<Map<String, int>> getLessonTypeCount() async {
    final db = await dbCore.database;
    final result = await db.rawQuery('''
    SELECT type, COUNT(*) as count
    FROM lessons
    GROUP BY type
  ''');
    final map = <String, int>{};
    for (var row in result) {
      map[row['type'] as String] = (row['count'] as int?) ?? 0;
    }
    return map;
  }
}