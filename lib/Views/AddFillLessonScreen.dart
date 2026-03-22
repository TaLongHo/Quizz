import 'package:flutter/material.dart';
import '../Models/User.dart';
import '../Models/Question.dart'; // Đảm bảo đã import model Question
import '../Controller/AddLessonController.dart';
import '../Service/ThemeService.dart';

class AddFillLessonScreen extends StatefulWidget {
  final User user;
  const AddFillLessonScreen({super.key, required this.user});

  @override
  State<AddFillLessonScreen> createState() => _AddFillLessonScreenState();
}

class _AddFillLessonScreenState extends State<AddFillLessonScreen> {
  final _controller = AddLessonController();
  final _titleController = TextEditingController();
  final _qController = TextEditingController();
  final _aController = TextEditingController();

  int? _editingIndex; // Theo dõi đang sửa câu nào

  void _addOrUpdateQuestion() {
    if (_qController.text.isEmpty || _aController.text.isEmpty) return;

    setState(() {
      if (_editingIndex != null) {
        // Cập nhật câu cũ
        _controller.tempQuestions[_editingIndex!] = Question(
          lessonId: 0,
          content: _qController.text.trim(),
          answer: _aController.text.trim(),
          options: "",
        );
        _editingIndex = null;
      } else {
        // Thêm câu mới
        _controller.addQuestionToTemp(
          content: _qController.text.trim(),
          answer: _aController.text.trim(),
          options: "",
        );
      }
      _qController.clear();
      _aController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã cập nhật danh sách tạm"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Hàm đổ dữ liệu ngược lại Form để sửa
  void _editQuestion(int index) {
    final q = _controller.tempQuestions[index];
    setState(() {
      _editingIndex = index;
      _qController.text = q.content;
      _aController.text = q.answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark;
    final theme = Theme.of(context);
    final brandGradient = isDark
        ? [const Color(0xFF1A237E), const Color(0xFF4A148C)]
        : [const Color(0xFF0D47A1), const Color(0xFF6A1B9A)];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Tạo bộ Điền Từ", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: brandGradient))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              controller: _titleController,
              label: "Tên học phần",
              hint: "Ví dụ: Từ vựng Unit 1",
              icon: Icons.edit_note,
              isDark: isDark,
            ),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_motion, color: isDark ? Colors.blue[300] : Colors.blue[900], size: 20),
                    const SizedBox(width: 8),
                    Text("Số câu hiện có: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                    Text(
                      "${_controller.tempQuestions.length}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.orange[300] : Colors.orange[800]),
                    ),
                  ],
                ),
                if (_editingIndex != null)
                  TextButton(
                    onPressed: () => setState(() { _editingIndex = null; _qController.clear(); _aController.clear(); }),
                    child: const Text("Hủy sửa", style: TextStyle(color: Colors.red)),
                  )
              ],
            ),
            const Divider(height: 30, thickness: 1),

            // Card nhập liệu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.blue[50]!),
              ),
              child: Column(
                children: [
                  _buildInputField(
                    controller: _qController,
                    label: "Câu hỏi hoặc từ cần điền",
                    hint: "Nhập nội dung...",
                    icon: Icons.help_outline,
                    isDark: isDark,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 15),
                  _buildInputField(
                    controller: _aController,
                    label: "Đáp án chính xác",
                    hint: "Đáp án đúng duy nhất",
                    icon: Icons.check_circle_outline,
                    isDark: isDark,
                    accentColor: Colors.orangeAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: _editingIndex == null ? "THÊM CÂU" : "CẬP NHẬT",
                    icon: _editingIndex == null ? Icons.add_rounded : Icons.edit_rounded,
                    color: isDark ? const Color(0xFF3949AB) : const Color(0xFF0D47A1),
                    onPressed: _addOrUpdateQuestion,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionButton(
                    label: "HOÀN TẤT",
                    icon: Icons.done_all_rounded,
                    color: Colors.green[700]!,
                    onPressed: () async {
                      bool success = await _controller.saveToDatabase(
                          _titleController.text,
                          widget.user.id!,
                          type: 'fill'
                      );
                      if (success) {
                        if (mounted) {
                          // Trả về true để báo hiệu cho màn hình trước đó biết cần load lại dữ liệu
                          Navigator.pop(context, true);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text("DANH SÁCH CÂU ĐÃ THÊM:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 15),

            // --- PHẦN HIỂN THỊ DANH SÁCH CÂU HỎI TẠM THỜI ---
            _controller.tempQuestions.isEmpty
                ? Center(child: Text("Chưa có câu hỏi nào", style: TextStyle(color: isDark ? Colors.white24 : Colors.grey[400])))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _controller.tempQuestions.length,
              itemBuilder: (context, index) {
                final q = _controller.tempQuestions[index];
                return Card(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Text("${index + 1}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(q.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text("Đáp án: ${q.answer}", style: const TextStyle(color: Colors.green, fontSize: 13)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20), onPressed: () => _editQuestion(index)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => setState(() => _controller.tempQuestions.removeAt(index))),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 50), // Khoảng đệm dưới cùng
          ],
        ),
      ),
    );
  }

  // Widget helpers (giữ nguyên của ní)
  Widget _buildInputField({required TextEditingController controller, required String label, required String hint, required IconData icon, required bool isDark, Color? accentColor, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        labelStyle: TextStyle(color: accentColor ?? (isDark ? Colors.blue[200] : Colors.blue[900])),
        prefixIcon: Icon(icon, color: accentColor ?? (isDark ? Colors.white30 : Colors.grey)),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: accentColor ?? Colors.blue, width: 1.5)),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    );
  }
}