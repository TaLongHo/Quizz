import 'package:flutter/material.dart';
import 'package:quizz/Database/user_repo.dart';
import 'package:quizz/Models/User.dart';
import 'package:quizz/Service/AuthService.dart';
import 'package:quizz/Service/SessionService.dart';
import 'package:quizz/Service/ThemeService.dart';
import 'package:quizz/Views/AdminHomeScreen.dart';
import 'package:quizz/Views/HomeScreen.dart';
import 'package:quizz/Views/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();

  // 1. Kiểm tra xem máy có lưu session không
  final session = await SessionService.getSession();
  User? currentUser;
  String? currentToken;

  if (session != null) {
    String token = session['token'];

    // 2. Dùng AuthService của bạn để kiểm tra Token
    if (AuthService.isTokenValid(token)) {
      // Nếu token còn hạn, đi lấy dữ liệu User từ DB
      currentUser = await UserRepo().getUserById(session['userId']);
      currentToken = token;
    } else {
      // Nếu token hết hạn, xóa luôn session cũ bắt đăng nhập lại
      await SessionService.clearSession();
    }
  }

  runApp(MyApp(initialUser: currentUser, token: currentToken));
}

class MyApp extends StatelessWidget {
  final User? initialUser;
  final String? token;
  const MyApp({super.key, this.initialUser, this.token});

  @override
  Widget build(BuildContext context) {
    // 2. Lắng nghe thay đổi theme tại đây
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode, // Chế độ hiện tại

          // Theme Sáng (Light Mode)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Xám trắng dịu mắt
            cardColor: Colors.white,
            primaryColor: const Color(0xFF0D47A1), // Blue 900
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1),
              primary: const Color(0xFF0D47A1),
              secondary: Colors.purple[800]!,
            ),
          ),

// Theme Tối (Dark Mode "Xịn")
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F111A), // Xanh đen sâu, không phải đen thui
            cardColor: const Color(0xFF1A1D2E), // Card sáng hơn nền một chút để tạo khối
            primaryColor: const Color(0xFF42A5F5), // Blue sáng hơn để nổi bật trên nền tối
            colorScheme: const ColorScheme.dark(
              surface: Color(0xFF1A1D2E),
              primary: Color(0xFF64B5F6),
              secondary: Color(0xFFCE93D8),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1A1D2E),
              elevation: 0,
            ),
          ),

          home: initialUser == null
              ? const LoginScreen()
              : (initialUser!.role == 'admin'
              ? AdminHomeScreen(user: initialUser!, token: token!)
              : HomeScreen(user: initialUser!, token: token!)),
        );
      },
    );
  }
}

