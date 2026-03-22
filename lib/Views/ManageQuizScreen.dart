import 'package:flutter/material.dart';
import 'package:quizz/Controller/QuizController.dart';
import 'package:quizz/Models/Lesson.dart';
import 'package:quizz/Views/AdminFillLessonDetailScreen.dart';
import 'package:quizz/Views/LessonDetailsScreenAdmin.dart';

class ManageQuizScreen extends StatefulWidget {
  const ManageQuizScreen({super.key});

  @override
  State<ManageQuizScreen> createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuizScreen> {
  final Quizcontroller _controller = Quizcontroller();
  final TextEditingController _searchController = TextEditingController();

  Key _refreshKey = UniqueKey();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() => setState(() => _refreshKey = UniqueKey());

  // Lọc danh sách theo query — chạy phía client, không cần query DB lại
  List<Lesson> _filterLessons(List<Lesson> lessons) {
    if (_searchQuery.isEmpty) return lessons;
    final q = _searchQuery.toLowerCase();
    return lessons
        .where((l) => l.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'Quản lý câu hỏi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            // Tăng chiều cao để chứa cả TabBar + SearchBar
            preferredSize: const Size.fromHeight(130),
            child: Column(
              children: [
                // ── Search bar ──────────────────────────────────────────
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.trim()),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm học phần...',
                      hintStyle:
                      const TextStyle(color: Colors.white54, fontSize: 14),
                      prefixIcon:
                      const Icon(Icons.search, color: Colors.white70),
                      // Nút xóa — chỉ hiện khi đang gõ
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white70, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // ── Tab bar ─────────────────────────────────────────────
                const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(icon: Icon(Icons.quiz_outlined), text: 'Trắc nghiệm'),
                    Tab(icon: Icon(Icons.text_fields), text: 'Điền từ'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: FutureBuilder<Map<String, List<Lesson>>>(
          key: _refreshKey,
          future: _controller.getCategorizedLessonsAdmin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Lỗi tải dữ liệu'));
            }

            final data = snapshot.data ?? {};

            // Áp dụng filter sau khi đã có data
            final quizLessons = _filterLessons(data['quiz'] ?? []);
            final fillLessons = _filterLessons(data['fill'] ?? []);

            return TabBarView(
              children: [
                _buildLessonList(
                  lessons: quizLessons,
                  type: 'quiz',
                  emptyMessage: _searchQuery.isEmpty
                      ? 'Chưa có bộ trắc nghiệm nào'
                      : 'Không tìm thấy kết quả cho "$_searchQuery"',
                ),
                _buildLessonList(
                  lessons: fillLessons,
                  type: 'fill',
                  emptyMessage: _searchQuery.isEmpty
                      ? 'Chưa có bộ điền từ nào'
                      : 'Không tìm thấy kết quả cho "$_searchQuery"',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── DANH SÁCH HỌC PHẦN ──────────────────────────────────────────────────
  Widget _buildLessonList({
    required List<Lesson> lessons,
    required String type,
    required String emptyMessage,
  }) {
    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              // Nếu đang search → icon tìm kiếm, ngược lại icon mặc định
              _searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : type == 'fill'
                  ? Icons.text_fields
                  : Icons.quiz_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final Color themeColor =
    type == 'fill' ? Colors.green[700]! : Colors.blue[900]!;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return _buildLessonCard(lessons[index], themeColor);
      },
    );
  }

  // ─── CARD HỌC PHẦN ───────────────────────────────────────────────────────
  Widget _buildLessonCard(Lesson lesson, Color color) {
    final isFill = lesson.type == 'fill';

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
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isFill ? Icons.text_fields : Icons.quiz_outlined,
            color: color,
            size: 24,
          ),
        ),
        title: _searchQuery.isNotEmpty
        // Highlight chữ khớp với query khi đang search
            ? _buildHighlightedTitle(lesson.title, _searchQuery)
            : Text(
          lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          'ID: ${lesson.id}  •  ${isFill ? "Điền từ" : "Trắc nghiệm"}',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        trailing:
        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: () async {
          final deleted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => isFill
                  ? AdminFillLessonDetailScreen(lesson: lesson)
                  : LessonDetailsScreenAdmin(lesson: lesson),
            ),
          );
          if (deleted == true) _refreshData();
        },
      ),
    );
  }

  // Highlight phần text khớp với query (không phân biệt hoa/thường)
  Widget _buildHighlightedTitle(String title, String query) {
    final lowerTitle = title.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerTitle.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(title,
          style:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87),
        children: [
          if (matchIndex > 0)
            TextSpan(text: title.substring(0, matchIndex)),
          // Phần khớp → nền vàng
          TextSpan(
            text: title.substring(matchIndex, matchIndex + query.length),
            style: TextStyle(
              backgroundColor: Colors.amber.shade200,
              color: Colors.black,
            ),
          ),
          if (matchIndex + query.length < title.length)
            TextSpan(
                text: title.substring(matchIndex + query.length)),
        ],
      ),
    );
  }
}