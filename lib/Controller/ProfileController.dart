import 'package:flutter/material.dart';
import 'package:quizz/Database/user_repo.dart';
import 'package:quizz/Models/User.dart';
import '../Views/LoginScreen.dart';

class ProfileController {
  final UserRepo _userRepo = UserRepo();

  Future<bool> updateUserInfo(User updatedUser) async {
    try {
      return await _userRepo.updateUser(updatedUser);
    } catch (e) {
      debugPrint("Lỗi cập nhật Profile: $e");
      return false;
    }
  }
  // Hàm đăng xuất: Xóa sạch các màn hình trước đó và quay về Login
  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  // Hàm chuyển đổi giới hạn từ số sang chữ
  String getGenderText(int gender) {
    switch (gender) {
      case 0: return "Nam";
      case 1: return "Nữ";
      default: return "Khác";
    }
  }
}