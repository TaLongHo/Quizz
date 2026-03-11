import 'package:flutter/material.dart';
import '../Models/User.dart';
import '../Controller/AddLessonController.dart';

class AddFillLessonScreen extends StatefulWidget {
  final User user;
  const AddFillLessonScreen({super.key, required this.user});

  @override
  State<AddFillLessonScreen> createState() => _AddFillLessonScreenState();
}

class _AddFillLessonScreenState extends State<AddFillLessonScreen> {
  final _controller = AddLessonController();
  final _titleController = TextEditingController();
  final _qController = TextEditingController(); // Câu hỏi
  final _aController = TextEditingController(); // Đáp án đúng duy nhất

  void _addQuestion() {
    if (_qController.text.isEmpty || _aController.text.isEmpty) return;

    setState(() {
      _controller.addQuestionToTemp(
        content: _qController.text,
        answer: _aController.text,
        options: "", // Điền từ thì không cần options (các đáp án gây nhiễu)
      );
      _qController.clear();
      _aController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo bộ Điền Từ"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tên học phần"),
            ),
            const SizedBox(height: 30),

            // UI Nhập liệu điền từ
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  TextField(controller: _qController, decoration: const InputDecoration(labelText: "Câu hỏi hoặc từ cần điền")),
                  TextField(controller: _aController, decoration: const InputDecoration(labelText: "Đáp án chính xác")),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text("Đã thêm: ${_controller.tempQuestions.length} câu"),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addQuestion,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
                    child: const Text("THÊM CÂU"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // TRUYỀN THÊM: type: 'fill'
                      bool success = await _controller.saveToDatabase(
                          _titleController.text,
                          widget.user.id!,
                          type: 'fill'
                      );

                      if (success) {
                        if (mounted) Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lỗi! Vui lòng kiểm tra lại dữ liệu.")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                    child: const Text("HOÀN TẤT"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}