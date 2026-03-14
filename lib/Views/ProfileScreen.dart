import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/User.dart';
import '../Controller/ProfileController.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = ProfileController();
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, StateSetter setModalState) async {
    DateTime initialDate = DateTime.tryParse(currentUser.birthday) ?? DateTime(2000, 1, 1);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue[900]!),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setModalState(() {
        // Định dạng lại thành YYYY-MM-DD để lưu vào Database
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // HÀM HIỂN THỊ FORM CHỈNH SỬA
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: currentUser.displayName);
    final birthdayController = TextEditingController(text: currentUser.birthday);
    int selectedGender = currentUser.gender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 25, right: 25, top: 25
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Chỉnh sửa hồ sơ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // 1. Nhập Tên
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Tên hiển thị",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 15),

              // 2. Chọn Ngày sinh
              TextField(
                controller: birthdayController,
                readOnly: true, // Không cho nhập tay, chỉ cho chọn từ lịch
                onTap: () => _selectDate(context, birthdayController, setModalState),
                decoration: const InputDecoration(
                  labelText: "Ngày sinh",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake_outlined),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Chọn Giới tính
              const Align(alignment: Alignment.centerLeft, child: Text("Giới tính:", style: TextStyle(fontWeight: FontWeight.bold))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildGenderOption(0, "Nam", selectedGender, (v) => setModalState(() => selectedGender = v!)),
                  _buildGenderOption(1, "Nữ", selectedGender, (v) => setModalState(() => selectedGender = v!)),
                  _buildGenderOption(2, "Khác", selectedGender, (v) => setModalState(() => selectedGender = v!)),
                ],
              ),
              const SizedBox(height: 25),

              // NÚT LƯU
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    User updatedUser = User(
                      id: currentUser.id,
                      username: currentUser.username,
                      password: currentUser.password,
                      displayName: nameController.text,
                      gender: selectedGender,
                      birthday: birthdayController.text, // Cập nhật ngày sinh mới
                      role: currentUser.role,
                      streakCount: currentUser.streakCount,
                      remindTime: currentUser.remindTime,
                    );

                    bool success = await _controller.updateUserInfo(updatedUser);
                    if (success) {
                      setState(() => currentUser = updatedUser);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("LƯU THAY ĐỔI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, currentUser), // QUAN TRỌNG: Trả dữ liệu mới về Home
        ),
        actions: [
          IconButton(onPressed: _showEditProfileDialog, icon: const Icon(Icons.edit_square))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: "Thông tin cơ bản",
                    items: [
                      _buildInfoItem(Icons.cake, "Ngày sinh", currentUser.birthday),
                      _buildInfoItem(Icons.wc, "Giới tính", _controller.getGenderText(currentUser.gender)),
                      _buildInfoItem(Icons.badge, "Chức vụ", currentUser.role.toUpperCase()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    title: "Học tập",
                    items: [
                      _buildInfoItem(Icons.local_fire_department, "Streak hiện tại", "${currentUser.streakCount} ngày", color: Colors.orange),
                      _buildInfoItem(Icons.notifications_active, "Nhắc nhở học", currentUser.remindTime),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Nút Đăng xuất
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Các Widget con giữ nguyên logic nhưng dùng biến currentUser ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 40),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const CircleAvatar(radius: 55, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 70, color: Colors.white)),
          const SizedBox(height: 15),
          Text(currentUser.displayName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("@${currentUser.username}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(left: 20, top: 15, bottom: 5), child: Text(title, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 14))),
        ...items,
      ]),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {Color color = Colors.blue}) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
      title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      trailing: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _controller.logout(context),
        icon: const Icon(Icons.logout),
        label: const Text("ĐĂNG XUẤT", style: TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red[700], padding: const EdgeInsets.symmetric(vertical: 15), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.red[100]!))),
      ),
    );
  }

  Widget _buildGenderOption(int value, String label, int groupValue, ValueChanged<int?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(value: value, groupValue: groupValue, onChanged: onChanged),
        Text(label),
      ],
    );
  }
}