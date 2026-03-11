import 'package:quizz/Models/User.dart';
import 'db_core.dart';

class UserRepo {
  final dbCore = DbCore.instance;

  // Hàm kiểm tra đăng nhập
  Future<User?> login(String username, String password) async {
    final db = await dbCore.database;

    // Truy vấn tìm user khớp cả username và password
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null; // Trả về null nếu không tìm thấy
  }

  // Hàm đăng ký (để bạn test tạo tài khoản mới)
  Future<int> register(User user) async {
    final db = await dbCore.database;
    return await db.insert('users', user.toMap());
  }
}