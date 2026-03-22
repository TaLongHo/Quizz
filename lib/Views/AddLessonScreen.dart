import 'package:flutter/material.dart';
import '../Models/User.dart';
import '../Models/Question.dart'; // Đảm bảo có import model này
import '../Controller/AddLessonController.dart';
import '../Service/ThemeService.dart';

class AddLessonScreen extends StatefulWidget {
  final User user;
  const AddLessonScreen({super.key, required this.user});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _controller = AddLessonController();
  final _titleController = TextEditingController();

  final _qController = TextEditingController();
  final _a1Controller = TextEditingController();
  final _a2Controller = TextEditingController();
  final _a3Controller = TextEditingController();
  final _a4Controller = TextEditingController();

  int? _editingIndex; // Biến để theo dõi đang sửa câu nào

  void _addOrUpdateQuestion() {
    if (_qController.text.isEmpty || _a1Controller.text.isEmpty) return;

    setState(() {
      String options = "${_a1Controller.text}|${_a2Controller.text}|${_a3Controller.text}|${_a4Controller.text}";

      if (_editingIndex != null) {
        // Nếu đang sửa: Cập nhật câu hỏi tại vị trí index
        _controller.tempQuestions[_editingIndex!] = Question(
          lessonId: 0,
          content: _qController.text,
          answer: _a1Controller.text,
          options: options,
        );
        _editingIndex = null;
      } else {
        // Nếu thêm mới
        _controller.addQuestionToTemp(
          content: _qController.text,
          answer: _a1Controller.text,
          options: options,
        );
      }

      _clearFields();
    });
  }

  void _editQuestion(int index) {
    final q = _controller.tempQuestions[index];
    List<String> opts = q.options?.split('|') ?? ["", "", "", ""];
    setState(() {
      _editingIndex = index;
      _qController.text = q.content;
      _a1Controller.text = q.answer;
      _a2Controller.text = opts.length > 1 ? opts[1] : "";
      _a3Controller.text = opts.length > 2 ? opts[2] : "";
      _a4Controller.text = opts.length > 3 ? opts[3] : "";
    });
  }

  void _clearFields() {
    _qController.clear();
    _a1Controller.clear();
    _a2Controller.clear();
    _a3Controller.clear();
    _a4Controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark;
    final brandGradient = isDark
        ? [const Color(0xFF1A237E), const Color(0xFF4A148C)]
        : [const Color(0xFF0D47A1), const Color(0xFF6A1B9A)];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Thêm học phần Trắc nghiệm", style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: brandGradient))),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInputField(controller: _titleController, label: "Tên học phần", icon: Icons.book, isDark: isDark),
                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.list_alt, color: isDark ? Colors.blue[300] : Colors.blue[900]),
                          const SizedBox(width: 10),
                          Text("Số câu hiện có: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                          Text("${_controller.tempQuestions.length}", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.orange[300] : Colors.orange[900])),
                        ],
                      ),
                      if (_editingIndex != null)
                        TextButton(onPressed: () => setState(() { _editingIndex = null; _clearFields(); }), child: const Text("Hủy sửa"))
                    ],
                  ),
                  const Divider(height: 30),

                  _buildQuestionCard(isDark),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildButton(_editingIndex == null ? "THÊM CÂU" : "CẬP NHẬT", Icons.add, isDark ? Colors.blue[700]! : Colors.blue[900]!, _addOrUpdateQuestion)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildButton("LƯU TẤT CẢ", Icons.save, Colors.green[700]!, () async {
                        bool success = await _controller.saveToDatabase(_titleController.text, widget.user.id!);
                        if (success) Navigator.pop(context, true); // Trả về true để HomeScreen biết cần load lại
                      })),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Align(alignment: Alignment.centerLeft, child: Text("Danh sách câu hỏi vừa thêm:", style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),

                  // Hiển thị danh sách các câu đã thêm
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controller.tempQuestions.length,
                    itemBuilder: (context, index) {
                      final q = _controller.tempQuestions[index];
                      return Card(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(q.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                          subtitle: Text("Đáp án: ${q.answer}", style: const TextStyle(color: Colors.green, fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.orange), onPressed: () => _editQuestion(index)),
                              IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => setState(() => _controller.tempQuestions.removeAt(index))),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Giữ nguyên các hàm _buildQuestionCard, _buildInputField, _buildButton của ní...
  Widget _buildQuestionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInputField(controller: _qController, label: "Nội dung câu hỏi", icon: Icons.help_outline, isDark: isDark, maxLines: 2),
          const SizedBox(height: 20),
          _buildInputField(controller: _a1Controller, label: "Đáp án ĐÚNG", icon: Icons.check_circle, isDark: isDark, accentColor: Colors.green),
          const SizedBox(height: 12),
          _buildInputField(controller: _a2Controller, label: "Đáp án sai 1", icon: Icons.cancel, isDark: isDark, accentColor: Colors.redAccent),
          const SizedBox(height: 12),
          _buildInputField(controller: _a3Controller, label: "Đáp án sai 2", icon: Icons.cancel, isDark: isDark, accentColor: Colors.redAccent),
          const SizedBox(height: 12),
          _buildInputField(controller: _a4Controller, label: "Đáp án sai 3", icon: Icons.cancel, isDark: isDark, accentColor: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, required bool isDark, Color? accentColor, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accentColor ?? (isDark ? Colors.blue[200] : Colors.blue[900])),
        prefixIcon: Icon(icon, color: accentColor ?? (isDark ? Colors.white30 : Colors.grey)),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentColor ?? Colors.blue)),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }
}