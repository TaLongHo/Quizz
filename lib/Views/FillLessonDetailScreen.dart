import 'package:flutter/material.dart';
import '../Database/lesson_repo.dart';
import '../Models/Lesson.dart';
import '../Models/Question.dart';

class FillLessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  const FillLessonDetailScreen({super.key, required this.lesson});

  @override
  State<FillLessonDetailScreen> createState() => _FillLessonDetailScreenState();
}

class _FillLessonDetailScreenState extends State<FillLessonDetailScreen> {
  final LessonRepo _repo = LessonRepo();
  Key _refreshKey = UniqueKey();

  void _refreshData() {
    setState(() => _refreshKey = UniqueKey());
  }

  // ─── DIALOG THÊM / SỬA ────────────────────────────────────────────────────
  void _showQuestionDialog({Question? existing}) {
    final qCtrl = TextEditingController(text: existing?.content ?? '');
    final aCtrl = TextEditingController(text: existing?.answer ?? '');
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Row(
              children: [
                Icon(
                  isEdit ? Icons.edit_note : Icons.add_circle_outline,
                  color: Colors.green[700],
                ),
                const SizedBox(width: 8),
                Text(
                  isEdit ? 'Sửa câu hỏi' : 'Thêm câu hỏi mới',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ô nhập câu hỏi
            TextField(
              controller: qCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Câu hỏi / Từ cần điền',
                hintText: 'Nhập nội dung câu hỏi...',
                prefixIcon: const Icon(Icons.help_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ô nhập đáp án
            TextField(
              controller: aCtrl,
              decoration: InputDecoration(
                labelText: 'Đáp án chính xác',
                hintText: 'Nhập đáp án...',
                prefixIcon: const Icon(Icons.check_circle_outline,
                    color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nút lưu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final q = qCtrl.text.trim();
                  final a = aCtrl.text.trim();
                  if (q.isEmpty || a.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập đầy đủ câu hỏi và đáp án!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  if (isEdit) {
                    // CẬP NHẬT
                    final updated = Question(
                      id: existing.id,
                      lessonId: existing.lessonId,
                      content: q,
                      answer: a,
                      options: '',
                    );
                    await _repo.updateQuestion(updated);
                  } else {
                    // THÊM MỚI
                    final newQ = Question(
                      lessonId: widget.lesson.id!,
                      content: q,
                      answer: a,
                      options: '',
                    );
                    await _repo.addQuestion(newQ);
                  }

                  if (ctx.mounted) Navigator.pop(ctx);
                  _refreshData();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit
                            ? 'Đã cập nhật câu hỏi!'
                            : 'Đã thêm câu hỏi mới!'),
                        backgroundColor: Colors.green[700],
                      ),
                    );
                  }
                },
                icon: Icon(isEdit ? Icons.save : Icons.add),
                label: Text(
                  isEdit ? 'LƯU THAY ĐỔI' : 'THÊM CÂU HỎI',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── XÁC NHẬN XÓA ─────────────────────────────────────────────────────────
  Future<bool?> _confirmDelete(Question q) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xóa câu hỏi'),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn xóa câu hỏi:\n"${q.content}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('XÓA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson.title,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Điền từ',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          // Nút thêm nhanh trên AppBar
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            tooltip: 'Thêm câu hỏi',
            onPressed: () => _showQuestionDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<Question>>(
        key: _refreshKey,
        future: _repo.getQuestionsByLesson(widget.lesson.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Banner tổng số câu hỏi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                color: Colors.green[700],
                child: Text(
                  '${questions.length} câu hỏi — Vuốt trái để xóa',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (ctx, index) {
                    final q = questions[index];
                    return _buildQuestionCard(index + 1, q);
                  },
                ),
              ),
            ],
          );
        },
      ),

      // FAB thêm câu hỏi
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuestionDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm câu hỏi'),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  // ─── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có câu hỏi nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút bên dưới để thêm câu hỏi đầu tiên',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showQuestionDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm câu hỏi đầu tiên'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD CÂU HỎI ─────────────────────────────────────────────────────────
  Widget _buildQuestionCard(int number, Question q) {
    return Dismissible(
      key: Key('fill_q_${q.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(q),
      onDismissed: (_) async {
        await _repo.deleteQuestion(q.id!);
        _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa câu hỏi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Xóa', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thanh màu trái
                Container(
                  width: 6,
                  color: Colors.green[600],
                ),

                // Nội dung
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: số câu + nút sửa/xóa
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Câu $number',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                // Nút sửa
                                IconButton(
                                  icon: Icon(Icons.edit_outlined,
                                      color: Colors.blue[600], size: 20),
                                  tooltip: 'Sửa câu hỏi',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 36, minHeight: 36),
                                  onPressed: () =>
                                      _showQuestionDialog(existing: q),
                                ),
                                // Nút xóa
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: Colors.red[400], size: 20),
                                  tooltip: 'Xóa câu hỏi',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 36, minHeight: 36),
                                  onPressed: () async {
                                    final confirm = await _confirmDelete(q);
                                    if (confirm == true) {
                                      await _repo.deleteQuestion(q.id!);
                                      _refreshData();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Đã xóa câu hỏi'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Nội dung câu hỏi
                        Text(
                          q.content,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ),

                        // Đáp án
                        Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green[600], size: 16),
                            const SizedBox(width: 6),
                            const Text(
                              'Đáp án: ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                q.answer,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}