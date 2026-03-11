import 'package:flutter/material.dart';
import '../Models/Lesson.dart';
import '../Models/Question.dart';
import '../Database/lesson_repo.dart';

class AddLessonController {
  final LessonRepo _repo = LessonRepo();

  // Danh sách lưu tạm các câu hỏi người dùng vừa nhập
  List<Question> tempQuestions = [];

  void addQuestionToTemp({
    required String content,
    required String answer,
    required String options,
  }) {
    tempQuestions.add(Question(
      lessonId: 0, // Sẽ được gán lại khi lưu vào DB
      content: content,
      answer: answer,
      options: options,
    ));
  }

  Future<bool> saveToDatabase(String title, int userId, {String type = 'abc'}) async {
    if (title.isEmpty || tempQuestions.isEmpty) return false;

    try {
      Lesson newLesson = Lesson(
        userId: userId,
        title: title,
        type: type, // Loại trắc nghiệm
      );

      await _repo.saveCompleteLesson(newLesson, tempQuestions);
      return true;
    } catch (e) {
      return false;
    }
  }
}