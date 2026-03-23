import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbCore {
  static final DbCore instance = DbCore._init();
  static Database? _database;

  DbCore._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz_app_v4.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // ⬆️ Tăng lên 2 để chạy onUpgrade
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  // ─── MIGRATION: Thêm cột is_active vào DB cũ ─────────────────────────────
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE users ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
      );
    }
  }

  Future _createDB(Database db, int version) async {
    // 1. Bảng Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        display_name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user',
        gender INTEGER,
        birthday TEXT,
        streak_count INTEGER DEFAULT 0,
        last_study_date TEXT,
        remind_time TEXT DEFAULT '20:00',
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 2. Bảng Lessons
    await db.execute('''
      CREATE TABLE lessons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 3. Bảng Questions
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        answer TEXT NOT NULL,
        options TEXT,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE
      )
    ''');

    // 4. Bảng StudyLogs
    await db.execute('''
      CREATE TABLE study_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        study_date TEXT NOT NULL,
        score REAL,
        UNIQUE(user_id, study_date),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await _seedData(db);
  }

  Future _seedData(Database db) async {
    // ════════════════════════════════════════════
    // 1. USERS
    // ════════════════════════════════════════════
    await db.insert('users', {
      'username': 'admin',
      'password': '123',
      'display_name': 'Quản Trị Viên',
      'role': 'admin',
      'gender': 0,
      'birthday': '1990-01-01',
      'streak_count': 0,
      'remind_time': '08:00',
    });

    // 10 học viên với streak đa dạng
    final List<Map<String, dynamic>> users = [
      {
        'username': 'anhnv',
        'display_name': 'Nguyễn Văn Anh',
        'gender': 0,
        'birthday': '2001-03-15',
        'streak_count': 52,
        'last_study_date': '2026-03-23',
        'remind_time': '20:00',
      },
      {
        'username': 'user1',
        'display_name': 'Nguyễn Văn User',
        'gender': 0,
        'birthday': '2001-03-15',
        'streak_count': 52,
        'last_study_date': '2026-03-23',
        'remind_time': '20:00',
      },
      {
        'username': 'linhtt',
        'display_name': 'Trần Thị Linh',
        'gender': 1,
        'birthday': '2002-07-22',
        'streak_count': 38,
        'last_study_date': '2026-03-23',
        'remind_time': '21:00',
      },
      {
        'username': 'duclh',
        'display_name': 'Lê Hoàng Đức',
        'gender': 0,
        'birthday': '2000-11-05',
        'streak_count': 31,
        'last_study_date': '2026-03-22',
        'remind_time': '19:30',
      },
      {
        'username': 'maipd',
        'display_name': 'Phạm Duy Mai',
        'gender': 1,
        'birthday': '2003-01-30',
        'streak_count': 24,
        'last_study_date': '2026-03-23',
        'remind_time': '20:00',
      },
      {
        'username': 'hungbt',
        'display_name': 'Bùi Thanh Hùng',
        'gender': 0,
        'birthday': '2001-09-18',
        'streak_count': 17,
        'last_study_date': '2026-03-21',
        'remind_time': '20:30',
      },
      {
        'username': 'thuynh',
        'display_name': 'Nguyễn Hải Thùy',
        'gender': 1,
        'birthday': '2004-04-12',
        'streak_count': 12,
        'last_study_date': '2026-03-23',
        'remind_time': '21:00',
      },
      {
        'username': 'kietvq',
        'display_name': 'Vũ Quốc Kiệt',
        'gender': 0,
        'birthday': '2002-06-08',
        'streak_count': 8,
        'last_study_date': '2026-03-20',
        'remind_time': '19:00',
      },
      {
        'username': 'lanpth',
        'display_name': 'Phan Thị Hồng Lan',
        'gender': 1,
        'birthday': '2003-12-25',
        'streak_count': 5,
        'last_study_date': '2026-03-23',
        'remind_time': '20:00',
      },
      {
        'username': 'namtq',
        'display_name': 'Trần Quốc Nam',
        'gender': 0,
        'birthday': '2001-08-14',
        'streak_count': 3,
        'last_study_date': '2026-03-22',
        'remind_time': '20:00',
      },
      {
        'username': 'tranglt',
        'display_name': 'Lê Thị Trang',
        'gender': 1,
        'birthday': '2004-02-28',
        'streak_count': 1,
        'last_study_date': '2026-03-23',
        'remind_time': '20:00',
      },
    ];

    final List<int> userIds = [];
    for (var u in users) {
      final id = await db.insert('users', {
        ...u,
        'password': '123',
        'role': 'user',
      });
      userIds.add(id);
    }

    // ════════════════════════════════════════════
    // 2. LESSONS — quiz và fill đa dạng chủ đề
    // ════════════════════════════════════════════
    final lessonsData = [
      // user 0 — Nguyễn Văn Anh (streak 52)
      {
        'user_index': 0,
        'title': 'Từ vựng chủ đề gia đình',
        'type': 'quiz',
        'created_at': '2026-03-10 08:30:00'
      },
      {
        'user_index': 0,
        'title': 'Động từ bất quy tắc',
        'type': 'fill',
        'created_at': '2026-03-12 09:00:00'
      },
      {
        'user_index': 0,
        'title': 'Thì hiện tại đơn',
        'type': 'quiz',
        'created_at': '2026-03-15 20:15:00'
      },

      // user 1 — Trần Thị Linh (streak 38)
      {
        'user_index': 1,
        'title': 'Từ vựng chủ đề du lịch',
        'type': 'quiz',
        'created_at': '2026-03-11 21:00:00'
      },
      {
        'user_index': 1,
        'title': 'Giới từ chỉ vị trí',
        'type': 'fill',
        'created_at': '2026-03-14 20:30:00'
      },

      // user 2 — Lê Hoàng Đức (streak 31)
      {
        'user_index': 2,
        'title': 'Từ vựng chủ đề công nghệ',
        'type': 'quiz',
        'created_at': '2026-03-08 19:45:00'
      },
      {
        'user_index': 2,
        'title': 'Câu điều kiện loại 1',
        'type': 'fill',
        'created_at': '2026-03-16 21:10:00'
      },

      // user 3 — Phạm Duy Mai (streak 24)
      {
        'user_index': 3,
        'title': 'Từ vựng chủ đề thể thao',
        'type': 'quiz',
        'created_at': '2026-03-13 20:00:00'
      },
      {
        'user_index': 3,
        'title': 'Mạo từ a/an/the',
        'type': 'fill',
        'created_at': '2026-03-18 19:30:00'
      },

      // user 4 — Bùi Thanh Hùng (streak 17)
      {
        'user_index': 4,
        'title': 'Từ vựng chủ đề ẩm thực',
        'type': 'quiz',
        'created_at': '2026-03-09 08:00:00'
      },

      // user 5 — Nguyễn Hải Thùy (streak 12)
      {
        'user_index': 5,
        'title': 'Từ vựng chủ đề trường học',
        'type': 'quiz',
        'created_at': '2026-03-17 20:45:00'
      },
      {
        'user_index': 5,
        'title': 'So sánh hơn và nhất',
        'type': 'fill',
        'created_at': '2026-03-19 21:00:00'
      },

      // user 6 — Vũ Quốc Kiệt (streak 8)
      {
        'user_index': 6,
        'title': 'Từ vựng chủ đề sức khỏe',
        'type': 'fill',
        'created_at': '2026-03-20 19:00:00'
      },

      // user 7 — Phan Thị Hồng Lan (streak 5)
      {
        'user_index': 7,
        'title': 'Từ vựng chủ đề màu sắc',
        'type': 'quiz',
        'created_at': '2026-03-21 20:00:00'
      },

      // user 8 — Trần Quốc Nam (streak 3)
      {
        'user_index': 8,
        'title': 'Từ vựng chủ đề số đếm',
        'type': 'fill',
        'created_at': '2026-03-22 20:30:00'
      },

      // user 9 — Lê Thị Trang (streak 1)
      {
        'user_index': 9,
        'title': 'Bảng chữ cái tiếng Anh',
        'type': 'quiz',
        'created_at': '2026-03-23 19:00:00'
      },
    ];

    final List<int> lessonIds = [];
    for (var l in lessonsData) {
      final id = await db.insert('lessons', {
        'user_id': userIds[l['user_index'] as int],
        'title': l['title'],
        'type': l['type'],
        'created_at': l['created_at'],
      });
      lessonIds.add(id);
    }

    // ════════════════════════════════════════════
    // 3. QUESTIONS
    // ════════════════════════════════════════════

    // Lesson 0 — Từ vựng gia đình (quiz)
    final qs0 = [
      {
        'content': 'Father nghĩa là gì?',
        'answer': 'Bố',
        'options': 'Bố|Mẹ|Anh|Em'
      },
      {
        'content': 'Mother nghĩa là gì?',
        'answer': 'Mẹ',
        'options': 'Bố|Mẹ|Chị|Em'
      },
      {
        'content': 'Sister nghĩa là gì?',
        'answer': 'Chị/Em gái',
        'options': 'Anh/Em trai|Chị/Em gái|Bố|Ông'
      },
      {
        'content': 'Grandfather nghĩa là gì?',
        'answer': 'Ông',
        'options': 'Bà|Ông|Cô|Chú'
      },
    ];

    // Lesson 1 — Động từ bất quy tắc (fill)
    final qs1 = [
      {
        'content': 'Quá khứ của "go" là gì?',
        'answer': 'went',
        'options': 'went|goed|gone'
      },
      {
        'content': 'Quá khứ của "eat" là gì?',
        'answer': 'ate',
        'options': 'eated|ate|eaten'
      },
      {
        'content': 'Quá khứ của "have" là gì?',
        'answer': 'had',
        'options': 'haved|has|had'
      },
      {
        'content': 'Quá khứ của "run" là gì?',
        'answer': 'ran',
        'options': 'runned|ran|run'
      },
    ];

    // Lesson 2 — Thì hiện tại đơn (quiz)
    final qs2 = [
      {
        'content': 'He ___ to school every day.',
        'answer': 'goes',
        'options': 'go|goes|going|gone'
      },
      {
        'content': 'They ___ English well.',
        'answer': 'speak',
        'options': 'speaks|speak|speaking|spoken'
      },
      {
        'content': 'She ___ coffee every morning.',
        'answer': 'drinks',
        'options': 'drink|drinks|drinking|drank'
      },
    ];

    // Lesson 3 — Từ vựng du lịch (quiz)
    final qs3 = [
      {
        'content': 'Airport nghĩa là gì?',
        'answer': 'Sân bay',
        'options': 'Ga tàu|Sân bay|Bến xe|Bến cảng'
      },
      {
        'content': 'Passport nghĩa là gì?',
        'answer': 'Hộ chiếu',
        'options': 'Vé tàu|Bản đồ|Hộ chiếu|Visa'
      },
      {
        'content': 'Hotel nghĩa là gì?',
        'answer': 'Khách sạn',
        'options': 'Nhà hàng|Khách sạn|Siêu thị|Bệnh viện'
      },
    ];

    // Lesson 4 — Giới từ vị trí (fill)
    final qs4 = [
      {
        'content': 'The book is ___ the table. (trên)',
        'answer': 'on',
        'options': 'on|in|under|behind'
      },
      {
        'content': 'The cat is ___ the box. (trong)',
        'answer': 'in',
        'options': 'on|in|under|next to'
      },
      {
        'content': 'The dog is ___ the chair. (dưới)',
        'answer': 'under',
        'options': 'on|in|under|above'
      },
    ];

    // Lesson 5 — Từ vựng công nghệ (quiz)
    final qs5 = [
      {
        'content': 'Smartphone nghĩa là gì?',
        'answer': 'Điện thoại thông minh',
        'options': 'Máy tính|Điện thoại thông minh|Máy in|Loa'
      },
      {
        'content': 'Download nghĩa là gì?',
        'answer': 'Tải xuống',
        'options': 'Tải lên|Tải xuống|Xóa|Lưu'
      },
      {
        'content': 'Password nghĩa là gì?',
        'answer': 'Mật khẩu',
        'options': 'Tên đăng nhập|Mật khẩu|Email|Số điện thoại'
      },
    ];

    // Lesson 6 — Câu điều kiện loại 1 (fill)
    final qs6 = [
      {
        'content': 'If it rains, I ___ stay home.',
        'answer': 'will',
        'options': 'will|would|can|should'
      },
      {
        'content': 'If she studies hard, she ___ pass.',
        'answer': 'will',
        'options': 'will|would|might|could'
      },
    ];

    // Lesson 7 — Thể thao (quiz)
    final qs7 = [
      {
        'content': 'Football nghĩa là gì?',
        'answer': 'Bóng đá',
        'options': 'Bóng rổ|Bóng đá|Bóng chuyền|Cầu lông'
      },
      {
        'content': 'Swimming nghĩa là gì?',
        'answer': 'Bơi lội',
        'options': 'Chạy bộ|Đạp xe|Bơi lội|Nhảy cao'
      },
      {
        'content': 'Tennis nghĩa là gì?',
        'answer': 'Quần vợt',
        'options': 'Cầu lông|Bóng bàn|Quần vợt|Golf'
      },
    ];

    // Lesson 8 — Mạo từ (fill)
    final qs8 = [
      {
        'content': '___ apple a day keeps the doctor away.',
        'answer': 'An',
        'options': 'A|An|The|—'
      },
      {
        'content': 'She is ___ engineer.',
        'answer': 'an',
        'options': 'a|an|the|—'
      },
      {
        'content': '___ sun rises in the east.',
        'answer': 'The',
        'options': 'A|An|The|—'
      },
    ];

    // Lesson 9 — Ẩm thực (quiz)
    final qs9 = [
      {
        'content': 'Rice nghĩa là gì?',
        'answer': 'Cơm/Gạo',
        'options': 'Bánh mì|Cơm/Gạo|Mì|Cháo'
      },
      {
        'content': 'Noodle nghĩa là gì?',
        'answer': 'Mì',
        'options': 'Cơm|Bánh|Mì|Phở'
      },
    ];

    // Lesson 10 — Trường học (quiz)
    final qs10 = [
      {
        'content': 'Classroom nghĩa là gì?',
        'answer': 'Lớp học',
        'options': 'Thư viện|Lớp học|Sân trường|Phòng lab'
      },
      {
        'content': 'Teacher nghĩa là gì?',
        'answer': 'Giáo viên',
        'options': 'Học sinh|Giáo viên|Hiệu trưởng|Bảo vệ'
      },
      {
        'content': 'Homework nghĩa là gì?',
        'answer': 'Bài tập về nhà',
        'options': 'Bài kiểm tra|Bài tập trên lớp|Bài tập về nhà|Dự án'
      },
    ];

    // Lesson 11 — So sánh (fill)
    final qs11 = [
      {
        'content': 'She is ___ than her sister. (tall)',
        'answer': 'taller',
        'options': 'tall|taller|tallest|more tall'
      },
      {
        'content': 'This is the ___ book I have read. (good)',
        'answer': 'best',
        'options': 'good|better|best|most good'
      },
    ];

    // Lesson 12 — Sức khỏe (fill)
    final qs12 = [
      {
        'content': 'Doctor nghĩa là gì?',
        'answer': 'Bác sĩ',
        'options': 'Bác sĩ|Y tá|Dược sĩ|Bệnh nhân'
      },
      {
        'content': 'Hospital nghĩa là gì?',
        'answer': 'Bệnh viện',
        'options': 'Phòng khám|Nhà thuốc|Bệnh viện|Trạm y tế'
      },
    ];

    // Lesson 13 — Màu sắc (quiz)
    final qs13 = [
      {
        'content': 'Red nghĩa là gì?',
        'answer': 'Đỏ',
        'options': 'Xanh|Đỏ|Vàng|Trắng'
      },
      {
        'content': 'Blue nghĩa là gì?',
        'answer': 'Xanh dương',
        'options': 'Xanh dương|Xanh lá|Tím|Cam'
      },
      {
        'content': 'Yellow nghĩa là gì?',
        'answer': 'Vàng',
        'options': 'Đỏ|Cam|Vàng|Nâu'
      },
    ];

    // Lesson 14 — Số đếm (fill)
    final qs14 = [
      {
        'content': 'Số 15 viết bằng tiếng Anh là?',
        'answer': 'fifteen',
        'options': 'fourteen|fifteen|sixteen|fifty'
      },
      {
        'content': 'Số 100 viết bằng tiếng Anh là?',
        'answer': 'one hundred',
        'options': 'one thousand|one hundred|ten|one million'
      },
    ];

    // Lesson 15 — Bảng chữ cái (quiz)
    final qs15 = [
      {
        'content': 'Chữ cái thứ 5 trong bảng chữ cái tiếng Anh là?',
        'answer': 'E',
        'options': 'D|E|F|G'
      },
      {
        'content': 'Bảng chữ cái tiếng Anh có bao nhiêu chữ cái?',
        'answer': '26',
        'options': '24|25|26|27'
      },
    ];

    final allQuestions = [
      qs0, qs1, qs2, qs3, qs4, qs5, qs6,
      qs7, qs8, qs9, qs10, qs11, qs12, qs13, qs14, qs15,
    ];

    for (int i = 0; i < allQuestions.length && i < lessonIds.length; i++) {
      for (var q in allQuestions[i]) {
        await db.insert('questions', {
          'lesson_id': lessonIds[i],
          'content': q['content'],
          'answer': q['answer'],
          'options': q['options'],
        });
      }
    }

    // ════════════════════════════════════════════
// 4. STUDY LOGS — tạo đúng số ngày = streak_count
//    để lịch hiển thị chính xác
// ════════════════════════════════════════════

// Mỗi user có streak bao nhiêu ngày thì tạo đủ bấy nhiêu ngày liên tiếp
// tính ngược từ ngày last_study_date
    final streakMap = {
      userIds[0]: {'streak': 52, 'lastDate': '2026-03-23'}, // Nguyễn Văn Anh
      userIds[1]: {'streak': 52, 'lastDate': '2026-03-23'}, // Nguyễn Văn User
      userIds[2]: {'streak': 38, 'lastDate': '2026-03-23'}, // Trần Thị Linh
      userIds[3]: {'streak': 31, 'lastDate': '2026-03-22'}, // Lê Hoàng Đức
      userIds[4]: {'streak': 24, 'lastDate': '2026-03-23'}, // Phạm Duy Mai
      userIds[5]: {'streak': 17, 'lastDate': '2026-03-21'}, // Bùi Thanh Hùng
      userIds[6]: {'streak': 12, 'lastDate': '2026-03-23'}, // Nguyễn Hải Thùy
      userIds[7]: {'streak': 8, 'lastDate': '2026-03-20'}, // Vũ Quốc Kiệt
      userIds[8]: {'streak': 5, 'lastDate': '2026-03-23'}, // Phan Thị Hồng Lan
      userIds[9]: {'streak': 3, 'lastDate': '2026-03-22'}, // Trần Quốc Nam
      userIds[10]: {'streak': 1, 'lastDate': '2026-03-23'}, // Lê Thị Trang
    };

    final scores = [9.5, 8.0, 7.5, 9.0, 8.5, 6.5, 7.0, 8.0, 9.5, 6.0,
      7.5, 8.5, 9.0, 7.0, 8.0, 6.5, 9.5, 8.0, 7.0, 8.5];
    int scoreIdx = 0;

    for (var entry in streakMap.entries) {
      final userId = entry.key;
      final streak = entry.value['streak'] as int;
      final lastDateStr = entry.value['lastDate'] as String;

      // Parse ngày cuối cùng học
      final parts = lastDateStr.split('-');
      final lastDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      // Tạo đủ 'streak' ngày liên tiếp tính ngược từ lastDate
      for (int i = 0; i < streak; i++) {
        final date = lastDate.subtract(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day
            .toString().padLeft(2, '0')}';

        try {
          await db.insert('study_logs', {
            'user_id': userId,
            'study_date': dateStr,
            'score': scores[scoreIdx % scores.length],
          });
          scoreIdx++;
        } catch (_) {
          // Bỏ qua nếu trùng UNIQUE constraint
        }
      }
    }
  }
}