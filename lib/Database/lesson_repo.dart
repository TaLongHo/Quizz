import '../Models/Lesson.dart';
import '../Models/Question.dart'; // Đảm bảo bạn đã có file này
import 'db_core.dart';

class LessonRepo {
  final dbCore = DbCore.instance;

  Future<void> saveCompleteLesson(Lesson lesson, List<Question> questions) async {
    final db = await dbCore.database;

    // Dùng Transaction để đảm bảo nếu lưu câu hỏi lỗi thì học phần cũng không được tạo
    await db.transaction((txn) async {
      // 1. Lưu Lesson
      int lessonId = await txn.insert('lessons', lesson.toMap());

      // 2. Lưu danh sách Question
      for (var q in questions) {
        // Gán lessonId vừa tạo cho từng câu hỏi
        var qMap = q.toMap();
        qMap['lesson_id'] = lessonId;
        await txn.insert('questions', qMap);
      }
    });
  }

  // Lấy toàn bộ danh sách học phần của User
  Future<List<Lesson>> getAllLessons(int userId) async {
    final db = await dbCore.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC', // Hiện học phần mới nhất lên đầu
    );

    return List.generate(maps.length, (i) => Lesson.fromMap(maps[i]));
  }

  // Trong class LessonRepo
  Future<void> deleteLesson(int lessonId) async {
    final db = await dbCore.database;
    // Xóa học phần (Nếu bạn thiết lập ON DELETE CASCADE thì các câu hỏi sẽ tự mất theo)
    await db.delete(
      'lessons',
      where: 'id = ?',
      whereArgs: [lessonId],
    );
  }

  Future<List<Question>> getQuestionsByLesson(int lessonId) async {
    final db = await dbCore.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );

    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }
}