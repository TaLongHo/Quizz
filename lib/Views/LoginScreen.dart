import 'package:flutter/material.dart';
import 'package:quizz/Service/SessionService.dart';
import 'package:quizz/Views/AdminHomeScreen.dart';
import 'package:quizz/Views/RegisterScreen.dart';
import '../Controller/AuthController.dart';
import '../Models/User.dart';
import '../Service/AuthService.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _isLoading = false;

  void _handleLogin() async {
    String username = _userController.text.trim();
    String password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnack('Vui lòng nhập đầy đủ thông tin!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = await _authController.handleLogin(username, password);

      if (user != null) {
        String token = AuthService.generateToken(user);
        await SessionService.saveSession(user.id!, token);

        if (!mounted) return;

        if (user.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AdminHomeScreen(user: user, token: token)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(user: user, token: token)),
          );
        }
      } else {
        _showSnack('Sai tài khoản hoặc mật khẩu!');
      }
    } catch (e) {
      if (e.toString() == 'BLOCKED') {
        // ✅ Hiển thị thông báo tài khoản bị khóa rõ ràng
        _showBlockedDialog();
      } else {
        _showSnack('Lỗi đăng nhập, vui lòng thử lại!');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showBlockedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.block_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            const Text('Tài khoản bị khóa',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Tài khoản của bạn đã bị quản trị viên khóa.\n\nVui lòng liên hệ hỗ trợ để được mở khóa.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: const StadiumBorder(),
            ),
            child: const Text('Đã hiểu',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.blue[900]!, Colors.purple[800]!, Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 80),
              const SizedBox(height: 20),
              const Text("Quizz",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _userController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Tên Đăng Nhập",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.person, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Mật Khẩu",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple[900],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Text("Đăng Nhập",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                  if (result != null && result is Map) {
                    setState(() {
                      _userController.text = result['user'];
                      _passController.text = result['pass'];
                    });
                  }
                },
                child: RichText(
                  text: const TextSpan(
                    text: "Chưa có tài khoản? ",
                    style: TextStyle(color: Colors.white70),
                    children: [
                      TextSpan(
                        text: "Đăng ký ngay",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}