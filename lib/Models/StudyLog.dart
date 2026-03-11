class StudyLog {
  final int? id;
  final int userId;
  final String studyDate; // Định dạng: YYYY-MM-DD
  final double? score;    // Điểm số hoặc % hoàn thành

  StudyLog({
    this.id,
    required this.userId,
    required this.studyDate,
    this.score,
  });

  // Chuyển từ Map (Database) sang Object (Dart)
  factory StudyLog.fromMap(Map<String, dynamic> map) {
    return StudyLog(
      id: map['id'],
      userId: map['user_id'],
      studyDate: map['study_date'],
      score: map['score']?.toDouble(),
    );
  }

  // Chuyển từ Object (Dart) sang Map (Để lưu vào Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'study_date': studyDate,
      'score': score,
    };
  }
}