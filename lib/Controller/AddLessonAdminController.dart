import '../Database/lesson_repo.dart';
import '../Models/Lesson.dart';
import '../Models/Question.dart';


class AddLessonAdminController {
  final LessonRepo _repo = LessonRepo();

  // Danh sách lưu tạm các câu hỏi người dùng vừa nhập
  List<Question> tempQuestions = [];

  // ─── Map từ label UI sang type trong DB ──────────────────────────────────
  // DB chỉ chấp nhận: 'quiz' | 'fill'
  static const Map<String, String> typeToDb = {
    'Trắc nghiệm': 'quiz',
    'Từ vựng': 'fill',
  };

  // Dùng để hiển thị lại label UI từ type DB (nếu cần)
  static const Map<String, String> typeToLabel = {
    'quiz': 'Trắc nghiệm',
    'fill': 'Từ vựng',
  };

  // ─── Thêm câu hỏi vào danh sách tạm ─────────────────────────────────────
  void _addQuestion({
    required String content,
    required String answer,
    String? options, // null = từ vựng, 'A|B|C' = trắc nghiệm
  }) {
    tempQuestions.add(Question(
      lessonId: 0, // Sẽ được gán lại khi lưu vào DB (trong transaction)
      content: content,
      answer: answer,
      options: options,
    ));
  }

  // ─── Parse script hàng loạt ───────────────────────────────────────────────
  // Định dạng trắc nghiệm: Câu hỏi | Đáp án đúng | Lựa chọn 1, Lựa chọn 2, ...
  // Định dạng từ vựng:     Từ tiếng Anh | Nghĩa tiếng Việt
  //
  // Options trong DB lưu dạng pipe: 'Táo|Cam|Chuối|Nho'
  // Script người dùng nhập dạng dấu phẩy: 'Táo, Cam, Chuối, Nho'
  // → hàm này tự động chuyển đổi
  void parseScript(String rawText, {bool isVocabulary = false}) {
    final lines = rawText.split('\n');

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final parts = line.split('|').map((s) => s.trim()).toList();
      if (parts.length < 2) continue; // Bỏ qua dòng không đúng định dạng

      final content = parts[0];
      final answer = parts[1];

      if (isVocabulary) {
        // Từ vựng: chỉ cần content + answer, không cần options
        _addQuestion(
          content: content,
          answer: answer,
          options: null,
        );
      } else {
        // Trắc nghiệm: options là phần thứ 3 (dấu phẩy), convert sang pipe
        String? options;
        if (parts.length > 2 && parts[2].isNotEmpty) {
          // Người dùng nhập: "Táo, Cam, Chuối" → DB lưu: "Táo|Cam|Chuối"
          // Đảm bảo đáp án đúng luôn nằm trong options
          final rawOptions = parts[2]
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

          // Thêm answer vào options nếu chưa có
          if (!rawOptions.contains(answer)) {
            rawOptions.add(answer);
          }

          options = rawOptions.join('|');
        } else {
          // Không có options → tự tạo từ answer để tránh lỗi UI
          options = answer;
        }

        _addQuestion(
          content: content,
          answer: answer,
          options: options,
        );
      }
    }
  }

  // ─── Lưu vào database ─────────────────────────────────────────────────────
  Future<bool> saveToDatabase(
      String title,
      int userId, {
        required String uiType, // Nhận type dạng UI: 'Trắc nghiệm' | 'Từ vựng'
      }) async {
    if (title.trim().isEmpty || tempQuestions.isEmpty) return false;

    // Map từ label UI sang giá trị DB
    final dbType = typeToDb[uiType] ?? 'quiz';

    try {
      final newLesson = Lesson(
        userId: userId,
        title: title.trim(),
        type: dbType, // ✅ Luôn lưu đúng format DB: 'quiz' | 'fill'
      );

      await _repo.saveCompleteLesson(newLesson, tempQuestions);
      tempQuestions.clear(); // Dọn sạch sau khi lưu thành công
      return true;
    } catch (e) {
      return false;
    }
  }
}