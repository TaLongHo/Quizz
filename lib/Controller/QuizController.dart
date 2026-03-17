import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Models/Lesson.dart';

class Quizcontroller {
  final LessonRepo _lessonRepo = LessonRepo();

  Future<Map<String, List<Lesson>>> getCategorizedLessonsAdmin() async {
    List<Lesson> allLessons = await _lessonRepo.getAllLessonsAdmin();
    // Phân loại
    List<Lesson> quizLessons =
    allLessons.where((l) => l.type == 'abc').toList();

    List<Lesson> fillLessons =
    allLessons.where((l) => l.type == 'fill').toList();

    return {
      'quiz': quizLessons,
      'fill': fillLessons,
    };
  }
  }