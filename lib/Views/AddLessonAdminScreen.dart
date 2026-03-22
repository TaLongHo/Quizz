import 'package:flutter/material.dart';
import '../Controller/AddLessonAdminController.dart';

class AddLessonAdminScreen extends StatefulWidget {
  const AddLessonAdminScreen({super.key});

  @override
  State<AddLessonAdminScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonAdminScreen> {
  final _controller = AddLessonAdminController();
  final _titleController = TextEditingController();

  // UI label — việc map sang DB type do Controller xử lý
  String _currentType = 'Trắc nghiệm';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // ─── Dialog import script ────────────────────────────────────────────────
  void _openImportDialog() {
    final scriptController = TextEditingController();
    final isVocab = _currentType == 'Từ vựng';

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
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isVocab
                    ? "Định dạng: Từ tiếng Anh | Nghĩa tiếng Việt\nVí dụ:\nApple | Quả táo\nWorld | Thế giới"
                    : "Định dạng: Câu hỏi | Đáp án đúng | Lựa chọn 1, Lựa chọn 2, ...\nVí dụ:\n1+1=? | 2 | 1, 2, 3, 4",
                style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: scriptController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: isVocab
                    ? "Hello | Xin chào\nWorld | Thế giới"
                    : "1+1=? | 2 | 1, 2, 3, 4\nViệt Nam thủ đô là gì? | Hà Nội | Hà Nội, TP.HCM, Đà Nẵng",
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
            onPressed: () {
              setState(() {
                // ✅ Gọi đúng hàm duy nhất, truyền isVocabulary
                _controller.parseScript(
                  scriptController.text,
                  isVocabulary: isVocab,
                );
              });
              Navigator.pop(context);
            },
            child: const Text("Tự động tạo"),
          ),
        ],
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Thiết kế học phần",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _openImportDialog,
            icon: const Icon(Icons.add_box_rounded, color: Colors.blue),
            tooltip: "Import câu hỏi",
          ),
          IconButton(
            onPressed: () => setState(() => _controller.tempQuestions.clear()),
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
            tooltip: "Xóa tất cả",
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
                Text(
                  "DANH SÁCH CÂU HỎI TẠM",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
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
          final isSelected = _currentType == type;
          return GestureDetector(
            onTap: () {
              if (_currentType != type) {
                // Cảnh báo nếu đang có dữ liệu khi đổi loại
                if (_controller.tempQuestions.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Đổi loại học phần?"),
                      content: const Text(
                        "Danh sách câu hỏi hiện tại sẽ bị xóa khi bạn đổi loại. Tiếp tục?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Hủy"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentType = type;
                              _controller.tempQuestions.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Đổi"),
                        ),
                      ],
                    ),
                  );
                } else {
                  setState(() => _currentType = type);
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                ),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
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
            const Text(
              "Chưa có dữ liệu, hãy nhấn Import",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _controller.tempQuestions.length,
      itemBuilder: (context, index) {
        final q = _controller.tempQuestions[index];

        // Options lưu dạng 'A|B|C' → hiển thị dạng 'A, B, C'
        final displayOptions = q.options?.replaceAll('|', ', ');
        // Chỉ hiển thị options nếu có và khác answer
        final showOptions = displayOptions != null &&
            displayOptions.isNotEmpty &&
            displayOptions != q.answer;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade50,
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              q.content,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💡 Đáp án: ${q.answer}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (showOptions)
                    Text(
                      "📎 Lựa chọn: $displayOptions",
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: () => setState(
                    () => _controller.tempQuestions.removeAt(index),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSaveButton() {
    final count = _controller.tempQuestions.length;
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
          if (_titleController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Vui lòng nhập tiêu đề!")),
            );
            return;
          }
          if (_controller.tempQuestions.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Vui lòng import ít nhất 1 câu hỏi!")),
            );
            return;
          }

          // ✅ Truyền uiType — Controller tự map sang DB type
          final ok = await _controller.saveToDatabase(
            _titleController.text,
            1, // userId admin, thay bằng giá trị thực tế
            uiType: _currentType,
          );

          if (ok && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Học phần đã được lưu!")),
            );
            Navigator.pop(context);
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Lỗi! Vui lòng thử lại.")),
            );
          }
        },
        child: Text(
          count > 0
              ? "XUẤT BẢN HỌC PHẦN ($count câu hỏi)"
              : "XUẤT BẢN HỌC PHẦN",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}