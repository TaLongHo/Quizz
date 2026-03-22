import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbCore {
  static final DbCore instance = DbCore._init();
  static Database? _database;

  DbCore._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz_app_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Bảng Users (Full: Role, Gender, Birthday)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        display_name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user', -- 'admin' hoặc 'user'
        gender INTEGER,                    -- 0: Nam, 1: Nữ, 2: Khác
        birthday TEXT,                     -- YYYY-MM-DD
        streak_count INTEGER DEFAULT 0,
        last_study_date TEXT,      
        remind_time TEXT DEFAULT '20:00'
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

    // 4. Bảng StudyLogs (Lịch học)
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
    // 1. Users
    int adminId = await db.insert('users', {
      'username': 'admin',
      'password': '123',
      'display_name': 'Quản Trị Viên',
      'role': 'admin',
      'gender': 0,
      'birthday': '1995-01-01',
    });

    int userId = await db.insert('users', {
      'username': 'user1',
      'password': '123',
      'display_name': 'Nguyễn Văn User',
      'role': 'user',
      'gender': 1,
      'birthday': '2004-05-20',
    });

    // 2. Lessons (⚠️ sửa type)
    int lesson1Id = await db.insert('lessons', {
      'user_id': userId,
      'title': 'Bài 1: Trắc nghiệm cơ bản',
      'type': 'quiz', // ✅
    });

    int lesson2Id = await db.insert('lessons', {
      'user_id': userId,
      'title': 'Bài 2: Điền từ cơ bản',
      'type': 'fill', // ✅
    });

    // 3. Questions - Lesson 1
    await db.insert('questions', {
      'lesson_id': lesson1Id, // ✅ đúng
      'content': 'Apple nghĩa là gì?',
      'answer': 'Táo',
      'options': 'Táo|Cam|Chuối|Nho'
    });

    await db.insert('questions', {
      'lesson_id': lesson1Id,
      'content': 'Dog nghĩa là gì?',
      'answer': 'Chó',
      'options': 'Mèo|Chó|Cá|Chim'
    });

    // 4. Questions - Lesson 2
    await db.insert('questions', {
      'lesson_id': lesson2Id, // ✅ đúng
      'content': 'Chọn dạng đúng của "to be" với I',
      'answer': 'am',
      'options': 'is|am|are'
    });

    await db.insert('questions', {
      'lesson_id': lesson2Id,
      'content': 'He ___ a student.',
      'answer': 'is',
      'options': 'am|is|are'
    });
  }
}