class Question {
  final int? id;
  final int lessonId;
  final String content;
  final String answer;
  final String? options; // Ví dụ: "A|B|C|D"

  Question({
    this.id,
    required this.lessonId,
    required this.content,
    required this.answer,
    this.options,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      lessonId: map['lesson_id'],
      content: map['content'],
      answer: map['answer'],
      options: map['options'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'content': content,
      'answer': answer,
      'options': options,
    };
  }

  // Hàm hỗ trợ tách chuỗi "A|B|C|D" thành danh sách List<String>
  List<String> get optionsList => options?.split('|') ?? [];
}