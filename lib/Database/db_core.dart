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
    // Tài khoản Admin mẫu
    await db.insert('users', {
      'username': 'admin',
      'password': '123',
      'display_name': 'Quản Trị Viên',
      'role': 'admin',
      'gender': 0,
      'birthday': '1995-01-01',
      'streak_count': 0
    });

    // Tài khoản User mẫu
    await db.insert('users', {
      'username': 'user1',
      'password': '123',
      'display_name': 'Nguyễn Văn User',
      'role': 'user',
      'gender': 1,
      'birthday': '2004-05-20',
      'streak_count': 2,
      'last_study_date': '2026-03-10'
    });
  }
}