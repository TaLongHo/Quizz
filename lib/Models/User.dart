class User {
  final int? id;
  final String username;
  final String password;
  final String displayName;
  final String role;
  final int gender;
  final String birthday;
  final int streakCount;
  final String? lastStudyDate;
  final String remindTime;
  final int isActive; // ✅ MỚI: 1 = active, 0 = blocked

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
    this.isActive = 1, // Mặc định active
  });

  // Tiện ích: kiểm tra nhanh
  bool get isBlocked => isActive == 0;

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      displayName: map['display_name'],
      role: map['role'] ?? 'user',
      gender: map['gender'] ?? 0,
      birthday: map['birthday'] ?? '',
      streakCount: map['streak_count'] ?? 0,
      lastStudyDate: map['last_study_date'],
      remindTime: map['remind_time'] ?? '20:00',
      isActive: map['is_active'] ?? 1, // ✅ Đọc từ DB, default = 1
    );
  }

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
      'is_active': isActive, // ✅ Ghi vào DB
    };
  }
}