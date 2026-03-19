import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controller/AuthController.dart';
import '../Models/User.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController(); // Thêm controller mới
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();

  int _selectedGender = 0;
  DateTime? _selectedDate;

  // 1. Validate Họ tên
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) return "Vui lòng nhập họ tên";
    RegExp nameRegExp = RegExp(r"^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ\s]+$");
    if (!nameRegExp.hasMatch(value)) return "Tên không hợp lệ";
    if (!value.trim().contains(" ")) return "Vui lòng nhập đầy đủ họ và tên";
    return null;
  }

  // 2. Validate Tuổi
  String? _validateAge(String? value) {
    if (_selectedDate == null) return "Vui lòng chọn ngày sinh";
    int age = DateTime.now().year - _selectedDate!.year;
    if (age < 10 || age > 100) return "Tuổi phải từ 10 đến 100";
    return null;
  }

  // 3. Logic kiểm tra nhập lại mật khẩu
  String? _validateConfirmPass(String? value) {
    if (value == null || value.isEmpty) return "Vui lòng nhập lại mật khẩu";
    if (value != _passController.text) return "Mật khẩu nhập lại không khớp";
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010),
      firstDate: DateTime(1926),
      lastDate: DateTime(2016),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple[800]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      User newUser = User(
        username: _userController.text.trim(),
        password: _passController.text,
        displayName: _nameController.text.trim(),
        gender: _selectedGender,
        birthday: _birthController.text,
        role: 'user',
      );

      String? error = await _authController.handleRegister(newUser);

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công!')),
        );
        Navigator.pop(context, {'user': newUser.username, 'pass': newUser.password});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[900]!, Colors.purple[800]!, Colors.black],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_add_alt_1, color: Colors.white, size: 70),
                          const SizedBox(height: 10),
                          const Text("TẠO TÀI KHOẢN",
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 30),

                          _buildField(_nameController, "Họ và tên", Icons.badge, validator: _validateFullName),
                          const SizedBox(height: 15),
                          _buildField(_userController, "Username", Icons.person, validator: (v) => v!.length < 3 ? "Tối thiểu 3 ký tự" : null),
                          const SizedBox(height: 15),

                          // Ô Mật khẩu chính
                          _buildField(_passController, "Password", Icons.lock, isPass: true,
                              validator: (v) => v!.length != 6 ? "Phải đúng 6 ký tự" : null),
                          const SizedBox(height: 15),

                          // Ô NHẬP LẠI MẬT KHẨU
                          _buildField(_confirmPassController, "Confirm Password", Icons.lock_reset, isPass: true,
                              validator: _validateConfirmPass),
                          const SizedBox(height: 15),

                          TextFormField(
                            controller: _birthController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputStyle("Ngày sinh", Icons.cake),
                            validator: _validateAge,
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              const Text("Giới tính: ", style: TextStyle(color: Colors.white, fontSize: 16)),
                              Radio(value: 0, groupValue: _selectedGender, onChanged: (v) => setState(() => _selectedGender = v as int), activeColor: Colors.white),
                              const Text("Nam", style: TextStyle(color: Colors.white)),
                              Radio(value: 1, groupValue: _selectedGender, onChanged: (v) => setState(() => _selectedGender = v as int), activeColor: Colors.white),
                              const Text("Nữ", style: TextStyle(color: Colors.white)),
                            ],
                          ),

                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.purple[900],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                              ),
                              onPressed: _handleRegister,
                              child: const Text("ĐĂNG KÝ NGAY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Đã có tài khoản? Đăng nhập", style: TextStyle(color: Colors.white70))
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool isPass = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: _inputStyle(hint, icon),
      validator: validator,
    );
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      errorStyle: const TextStyle(color: Colors.orangeAccent),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white70, width: 1),
      ),
    );
  }
}