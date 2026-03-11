class Lesson {
  final int? id;
  final int userId;
  final String title;
  final String type; // 'abc' hoặc 'fill'
  final String? createdAt;

  Lesson({
    this.id,
    required this.userId,
    required this.title,
    required this.type,
    this.createdAt,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      type: map['type'] ?? 'abc',
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'type': type,
      // 'created_at' thường để DB tự sinh
    };
  }
}