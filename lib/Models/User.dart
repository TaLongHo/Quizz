class User {
  final int? id;
  final String username;
  final String password;
  final String displayName;
  final String role; // 'admin' hoặc 'user'
  final int gender; // 0: Nam, 1: Nữ, 2: Khác
  final String birthday;
  final int streakCount;
  final String? lastStudyDate;
  final String remindTime;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.displayName,
    this.role = 'user',
    required this.gender,
    required this.birthday,
    this.streakCount = 0,
    this.lastStudyDate,
    this.remindTime = '20:00',
  });

  // Chuyển từ Map (Database) sang Object (Dart)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      displayName: map['display_name'],
      role: map['role'],
      gender: map['gender'],
      birthday: map['birthday'],
      streakCount: map['streak_count'],
      lastStudyDate: map['last_study_date'],
      remindTime: map['remind_time'],
    );
  }

  // Chuyển từ Object (Dart) sang Map (Để lưu vào Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'display_name': displayName,
      'role': role,
      'gender': gender,
      'birthday': birthday,
      'streak_count': streakCount,
      'last_study_date': lastStudyDate,
      'remind_time': remindTime,
    };
  }
}