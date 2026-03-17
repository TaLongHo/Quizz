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
  // HÀM QUAN TRỌNG: Parse script hàng loạt
  void parseRawScript(String rawText) {
    // Tách văn bản thành từng dòng
    List<String> lines = rawText.split('\n');

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      // Định dạng mong muốn: Câu hỏi | Đáp án đúng | Lựa chọn 1, Lựa chọn 2
      // Hoặc đơn giản: Câu hỏi | Đáp án đúng
      List<String> parts = line.split('|');

      if (parts.length >= 2) {
        String content = parts[0].trim();
        String answer = parts[1].trim();
        String options = parts.length > 2 ? parts[2].trim() : "";

        // Nếu không có options, tự tạo options từ answer để tránh lỗi UI
        if (options.isEmpty) options = answer;

        addQuestionToTemp(content: content, answer: answer, options: options);
      }
    }
  }

  Future<bool> saveAllToDatabase(String title, int userId, {String type = 'mixed'}) async {
    if (title.isEmpty || tempQuestions.isEmpty) return false;
    try {
      Lesson newLesson = Lesson(userId: userId, title: title, type: type);
      await _repo.saveCompleteLesson(newLesson, tempQuestions);
      tempQuestions.clear(); // Xóa tạm sau khi lưu thành công
      return true;
    } catch (e) {
      return false;
    }
  }
  // lib/Controllers/add_lesson_controller.dart

  // Thêm tham số {bool isVocabulary = false} vào đây
  void parseRawVocalScript(String rawText, {bool isVocabulary = false}) {
    List<String> lines = rawText.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      List<String> parts = line.split('|');

      if (isVocabulary) {
        // Logic cho từ vựng
        if (parts.length >= 2) {
          addQuestionToTemp(
            content: parts[0].trim(),
            answer: parts[1].trim(),
            options: "",
          );
        }
      } else {
        // Logic cho trắc nghiệm
        if (parts.length >= 2) {
          addQuestionToTemp(
            content: parts[0].trim(),
            answer: parts[1].trim(),
            options: parts.length > 2 ? parts[2].trim() : parts[1].trim(),
          );
        }
      }
    }
  }
}