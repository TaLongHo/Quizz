import 'package:flutter/material.dart';
import '../Models/User.dart';
import '../Controller/AddLessonController.dart';

class AddLessonScreen extends StatefulWidget {
  final User user;
  const AddLessonScreen({super.key, required this.user});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _controller = AddLessonController();
  final _titleController = TextEditingController();

  // 5 ô nhập liệu
  final _qController = TextEditingController();
  final _a1Controller = TextEditingController();
  final _a2Controller = TextEditingController();
  final _a3Controller = TextEditingController();
  final _a4Controller = TextEditingController();

  void _addQuestion() {
    if (_qController.text.isEmpty || _a1Controller.text.isEmpty) return;

    setState(() {
      // Gộp 4 đáp án thành chuỗi "A|B|C|D" để lưu vào DB
      String options = "${_a1Controller.text}|${_a2Controller.text}|${_a3Controller.text}|${_a4Controller.text}";

      _controller.addQuestionToTemp(
        content: _qController.text,
        answer: _a1Controller.text, // Mặc định ô đầu là đáp án đúng
        options: options,
      );

      // Xóa trống các ô để nhập câu tiếp theo
      _qController.clear();
      _a1Controller.clear();
      _a2Controller.clear();
      _a3Controller.clear();
      _a4Controller.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã thêm câu hỏi vào danh sách tạm")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm học phần Trắc nghiệm"),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue[900]!, Colors.purple[800]!])),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tên học phần (Ví dụ: Tiếng Anh)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 2),
            Text("Số câu hỏi hiện có: ${_controller.tempQuestions.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Cụm 5 ô nhập
            _buildQuestionInput(),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addQuestion,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("THÊM CÂU HỎI"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      bool success = await _controller.saveToDatabase(_titleController.text, widget.user.id!);
                      if (success) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("LƯU TẤT CẢ"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput() {
    return Column(
      children: [
        TextField(controller: _qController, decoration: const InputDecoration(labelText: "Nội dung câu hỏi")),
        TextField(controller: _a1Controller, decoration: const InputDecoration(labelText: "Đáp án ĐÚNG")),
        TextField(controller: _a2Controller, decoration: const InputDecoration(labelText: "Đáp án sai 1")),
        TextField(controller: _a3Controller, decoration: const InputDecoration(labelText: "Đáp án sai 2")),
        TextField(controller: _a4Controller, decoration: const InputDecoration(labelText: "Đáp án sai 3")),
      ],
    );
  }
}