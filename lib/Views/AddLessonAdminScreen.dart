import 'package:flutter/material.dart';
import '../Controller/AddLessonController.dart';

class AddLessonAdminScreen extends StatefulWidget {
  const AddLessonAdminScreen({super.key});

  @override
  State<AddLessonAdminScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonAdminScreen> {
  final _controller = AddLessonController();
  final _titleController = TextEditingController();
  String _currentType = 'Trắc nghiệm'; // Loại mặc định

  void _openImportDialog() {
    TextEditingController scriptController = TextEditingController();
    bool isVocab = _currentType == 'Từ vựng';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Import $_currentType"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10)),
              child: Text(
                isVocab
                    ? "Định dạng: Từ tiếng Anh | Nghĩa tiếng Việt\nVí dụ: Apple | Quả táo"
                    : "Định dạng: Câu hỏi | Đáp án đúng | Lựa chọn 1, 2...\nVí dụ: 1+1=? | 2 | 1, 2, 3",
                style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: scriptController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: isVocab ? "Hello | Xin chào\nWorld | Thế giới" : "Câu hỏi | Đáp án...",
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
            onPressed: () {
              setState(() {
                _controller.parseRawVocalScript(scriptController.text, isVocabulary: isVocab);
              });
              Navigator.pop(context);
            },
            child: const Text("Tự động tạo"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Màu nền sáng thanh lịch
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Thiết kế học phần", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: _openImportDialog, icon: const Icon(Icons.add_box_rounded, color: Colors.blue)),
          IconButton(
            onPressed: () => setState(() => _controller.tempQuestions.clear()),
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderSection(),
          _buildTypeSelector(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.list_alt, size: 20, color: Colors.grey),
                SizedBox(width: 8),
                Text("DANH SÁCH CÂU HỎI TẠM", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          Expanded(child: _buildQuestionList()),
        ],
      ),
      bottomNavigationBar: _buildBottomSaveButton(),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: "Tiêu đề học phần",
          labelStyle: const TextStyle(color: Colors.deepPurple),
          filled: true,
          fillColor: Colors.deepPurple.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.edit_note, color: Colors.deepPurple),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['Trắc nghiệm', 'Từ vựng'].map((type) {
          bool isSelected = _currentType == type;
          return GestureDetector(
            onTap: () => setState(() => _currentType = type),
            child: Container(

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
              ),
              child: Text(
                type,
                style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuestionList() {
    if (_controller.tempQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text("Chưa có dữ liệu, hãy nhấn Import", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _controller.tempQuestions.length,
      itemBuilder: (context, index) {
        final q = _controller.tempQuestions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade50,
              child: Text("${index + 1}", style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            ),
            title: Text(q.content, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("💡 Đáp án: ${q.answer}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                  if ((q.options ?? "").isNotEmpty && q.options != q.answer)
                    Text("📎 Lựa chọn: ${q.options}", style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: () => setState(() => _controller.tempQuestions.removeAt(index)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
        onPressed: () async {
          if (_titleController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tiêu đề!")));
            return;
          }
          bool ok = await _controller.saveToDatabase(_titleController.text, 1, type: _currentType);
          if (ok && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Học phần đã được lưu!")));
            Navigator.pop(context);
          }
        },
        child: const Text("XUẤT BẢN HỌC PHẦN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}