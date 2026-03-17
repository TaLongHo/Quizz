import 'package:flutter/material.dart';
import '../Database/lesson_repo.dart';
import '../Models/Lesson.dart';
import '../Models/Question.dart';

class AdminFillLessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const AdminFillLessonDetailScreen({super.key, required this.lesson});

  @override
  State<AdminFillLessonDetailScreen> createState() =>
      _AdminFillLessonDetailScreenState();
}

class _AdminFillLessonDetailScreenState
    extends State<AdminFillLessonDetailScreen> {
  final LessonRepo _repo = LessonRepo();
  Key _refreshKey = UniqueKey();

  void _refreshData() => setState(() => _refreshKey = UniqueKey());

  // ─── MÀU CHỦ ĐẠO ─────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF2E7D32); // green[800]
  static const Color _accent = Color(0xFF43A047);  // green[600]
  static const Color _bg = Color(0xFFF1F8E9);

  // ═══════════════════════════════════════════════════════════════════════════
  // XÓA TOÀN BỘ HỌC PHẦN
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _deleteLesson() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Xóa học phần'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            children: [
              const TextSpan(text: 'Bạn có chắc muốn xóa toàn bộ học phần\n'),
              TextSpan(
                text: '"${widget.lesson.title}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                  text:
                  '?\n\nTất cả câu hỏi bên trong cũng sẽ bị xóa vĩnh viễn.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
            const Text('HỦY', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('XÓA TOÀN BỘ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _repo.deleteLesson(widget.lesson.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa học phần "${widget.lesson.title}"'),
          backgroundColor: Colors.red[700],
        ),
      );
      // Trả kết quả true về ManageQuizScreen để reload danh sách
      Navigator.pop(context, true);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SỬA CÂU HỎI
  // ═══════════════════════════════════════════════════════════════════════════
  void _showEditDialog(Question q) {
    final qCtrl = TextEditingController(text: q.content);
    final aCtrl = TextEditingController(text: q.answer);

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
            // ── Tiêu đề ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                  Icon(Icons.edit_note, color: _primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sửa câu hỏi Điền Từ',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'ID: ${q.id}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const Divider(height: 24),

            // ── Câu hỏi ──
            const Text('Câu hỏi / Từ cần điền',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: qCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung câu hỏi...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: _accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Đáp án ──
            const Text('Đáp án chính xác',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: aCtrl,
              decoration: InputDecoration(
                hintText: 'Nhập đáp án...',
                filled: true,
                fillColor: Colors.green[50],
                prefixIcon: const Icon(Icons.check_circle_outline,
                    color: _accent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: _accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Nút lưu ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final newQ = qCtrl.text.trim();
                  final newA = aCtrl.text.trim();

                  if (newQ.isEmpty || newA.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Vui lòng nhập đầy đủ câu hỏi và đáp án!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final updated = Question(
                    id: q.id,
                    lessonId: q.lessonId,
                    content: newQ,
                    answer: newA,
                    options: q.options ?? '',
                  );
                  await _repo.updateQuestion(updated);

                  if (ctx.mounted) Navigator.pop(ctx);
                  _refreshData();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Đã cập nhật câu hỏi!'),
                        backgroundColor: _accent,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'LƯU THAY ĐỔI',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: FutureBuilder<List<Question>>(
        key: _refreshKey,
        future: _repo.getQuestionsByLesson(widget.lesson.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi tải dữ liệu'));
          }

          final questions = snapshot.data ?? [];

          return Column(
            children: [
              _buildInfoBanner(questions.length),
              Expanded(
                child: questions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (ctx, i) =>
                      _buildQuestionCard(i + 1, questions[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primary,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.lesson.title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          const Text(
            'Điền Từ  •  Quản trị',
            style: TextStyle(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
      actions: [
        // Nút XÓA HỌC PHẦN
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (value) {
            if (value == 'delete_lesson') _deleteLesson();
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'delete_lesson',
              child: Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red, size: 20),
                  SizedBox(width: 10),
                  Text('Xóa toàn bộ học phần',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── BANNER THÔNG TIN ─────────────────────────────────────────────────────
  Widget _buildInfoBanner(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _primary,
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tổng câu hỏi
          _buildStat(Icons.quiz_outlined, '$count', 'câu hỏi'),
          const SizedBox(width: 24),
          _buildStat(Icons.text_fields, 'Fill', 'loại'),
          const Spacer(),
          // Badge ID
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID: ${widget.lesson.id}',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Học phần này chưa có câu hỏi nào',
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ─── CARD CÂU HỎI ────────────────────────────────────────────────────────
  Widget _buildQuestionCard(int number, Question q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(width: 5, color: _accent),

              // Nội dung
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge số câu
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.green[200]!),
                            ),
                            child: Text(
                              'Câu $number',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _primary,
                              ),
                            ),
                          ),

                          // Nút Sửa
                          TextButton.icon(
                            onPressed: () => _showEditDialog(q),
                            icon: Icon(Icons.edit_outlined,
                                size: 16, color: Colors.blue[700]),
                            label: Text(
                              'Sửa',
                              style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── Nội dung câu hỏi ──
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
                        child: Divider(
                            height: 1, color: Color(0xFFF0F0F0)),
                      ),

                      // ── Đáp án ──
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: _accent, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Đáp án: ',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              q.answer,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _primary,
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
    );
  }
}