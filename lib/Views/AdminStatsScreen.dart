import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quizz/Controller/AdminStatsController.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});
  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  final _controller = AdminStatsController();
  AdminStatsData? _data;
  bool _loading = true;

  static const _bg = Color(0xFFF8FAFC);
  static const _dark = Color(0xFF1E293B);
  static const _muted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);

  static const _greenRamp = [
    Color(0xFFC0DD97), Color(0xFF97C459), Color(0xFF639922),
    Color(0xFF3B6D11), Color(0xFF27500A), Color(0xFF173404),
    Color(0xFF0F4A02), Color(0xFF0A3201),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _controller.loadAll();
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _dark,
        title: const Text('Thống kê & Báo cáo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          setState(() => _loading = true);
          await _load();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricRow(),
              const SizedBox(height: 20),
              _buildSectionLabel('Xếp hạng học viên theo streak'),
              const SizedBox(height: 12),
              _buildStreakChart(),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('Hoạt động 7 ngày'),
                        const SizedBox(height: 12),
                        _buildActivityChart(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('Loại học phần'),
                        const SizedBox(height: 12),
                        _buildDonutChart(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionLabel('Phân bổ giờ học trong ngày'),
              const SizedBox(height: 12),
              _buildHourChart(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _muted,
      letterSpacing: 0.4,
    ),
  );

  // ─── Metric row ────────────────────────────────────────────
  Widget _buildMetricRow() {
    final d = _data!;
    final items = [
      ('Tổng người dùng', '${d.totalUsers}', 'học viên'),
      ('Hoạt động hôm nay', '${d.activeToday}', 'người học'),
      ('Học phần', '${d.quizCount + d.fillCount}', 'bài tổng'),
      ('Streak TB', '${d.avgStreak}', 'ngày / người'),
    ];
    // Dùng 2 hàng x 2 cột thay vì GridView để kiểm soát chiều cao tốt hơn
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard(items[0].$1, items[0].$2, items[0].$3)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricCard(items[1].$1, items[1].$2, items[1].$3)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildMetricCard(items[2].$1, items[2].$2, items[2].$3)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricCard(items[3].$1, items[3].$2, items[3].$3)),
          ],
        ),
      ],
    );
  }

  // FIX: Dùng chiều cao cố định thay vì childAspectRatio để tránh overflow
  Widget _buildMetricCard(String label, String value, String sub) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // ✅ thêm dòng này
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: _muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          // ✅ bỏ SizedBox(height: 2) ở đây
          FittedBox( // ✅ FittedBox để số tự co lại nếu cần
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: _dark)),
          ),
          Text(sub,
              style: const TextStyle(fontSize: 10, color: _muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ─── Streak vertical bar chart — chỉ Top 5 + danh sách cuộn ───
  Widget _buildStreakChart() {
    final users = _data!.streakUsers;

    if (users.isEmpty) {
      return _buildCard(
        height: 80,
        child: const Center(
          child: Text('Chưa có dữ liệu streak',
              style: TextStyle(color: _muted, fontSize: 13)),
        ),
      );
    }

    // Sắp xếp cao → thấp
    final sorted = [...users]..sort((a, b) => b.streakCount.compareTo(a.streakCount));
    // Top 5 cho chart — từ thấp → cao (trái → phải trong bar chart)
    final top5 = sorted.take(5).toList().reversed.toList();
    final maxStreak = sorted.first.streakCount.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Phần 1: Bar chart Top 5 ──────────────────────────
        _buildCard(
          height: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Top 5',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _dark)),
                  const SizedBox(width: 6),
                  Text('streak cao nhất — chạm bar để xem chi tiết',
                      style: const TextStyle(fontSize: 10, color: _muted)),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxStreak * 1.3,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final user = top5[group.x.toInt()];
                          return BarTooltipItem(
                            '${user.displayName}\n🔥 ${rod.toY.toInt()} ngày',
                            const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (val, meta) {
                            final i = val.toInt();
                            if (i < 0 || i >= top5.length) return const SizedBox();
                            // Lấy tên cuối (họ tên Việt Nam — từ cuối là tên)
                            final parts = top5[i].displayName.trim().split(' ');
                            final shortName = parts.last;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(shortName,
                                  style: const TextStyle(
                                      fontSize: 10, color: _muted),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (val, meta) {
                            if (val == meta.max) return const SizedBox();
                            return Text('${val.toInt()}',
                                style: const TextStyle(
                                    fontSize: 9, color: _muted));
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: List.generate(top5.length, (i) {
                      // Top 5: index 0 = thấp nhất, index 4 = cao nhất → màu đậm dần
                      final colorIndex = (i * (_greenRamp.length - 1) ~/ (top5.length - 1))
                          .clamp(0, _greenRamp.length - 1);
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: top5[i].streakCount.toDouble(),
                            color: _greenRamp[colorIndex],
                            width: 36,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Phần 2: Danh sách đầy đủ tất cả user ───────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tất cả học viên',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _dark)),
                  Text('${sorted.length} người',
                      style: const TextStyle(fontSize: 11, color: _muted)),
                ],
              ),
              const SizedBox(height: 12),
              // Dùng ListView.builder để không bao giờ overflow dù 1000 user
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sorted.length,
                itemBuilder: (context, i) {
                  final user = sorted[i];
                  final progress = maxStreak > 0
                      ? user.streakCount / maxStreak
                      : 0.0;

                  final rankColor = i == 0
                      ? const Color(0xFFFFB800)
                      : i == 1
                      ? const Color(0xFF94A3B8)
                      : i == 2
                      ? const Color(0xFFCD7C2F)
                      : _muted;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Hạng
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: rankColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Tên + bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      user.displayName,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _dark),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '🔥 ${user.streakCount}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _dark),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    i < 3
                                        ? const Color(0xFF3B6D11)
                                        : const Color(0xFF97C459),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Daily activity line chart ─────────────────────────────
  Widget _buildActivityChart() {
    final labels = _data!.weekDayLabels;
    final counts = _data!.weekDayCounts;
    return _buildCard(
      height: 190,
      child: LineChart(LineChartData(
        gridData: FlGridData(
          getDrawingHorizontalLine: (_) =>
          const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
          const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (labels.length - 1).toDouble(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (val, _) {
                final i = val.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[i],
                      style: const TextStyle(fontSize: 9, color: _muted)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (val, _) => Text(
                '${val.toInt()}',
                style: const TextStyle(fontSize: 9, color: _muted),
              ),
            ),
          ),
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(counts.length,
                    (i) => FlSpot(i.toDouble(), counts[i].toDouble())),
            isCurved: true,
            color: const Color(0xFF5B8FF9),
            barWidth: 2.5,
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF5B8FF9).withOpacity(0.12),
            ),
            dotData: FlDotData(
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3,
                  color: const Color(0xFF5B8FF9),
                  strokeWidth: 0),
            ),
          ),
        ],
      )),
    );
  }

  // ─── Donut chart ───────────────────────────────────────────
  Widget _buildDonutChart() {
    final quiz = _data!.quizCount.toDouble();
    final fill = _data!.fillCount.toDouble();
    final total = quiz + fill;

    // FIX: Chiều cao cố định khớp với activity chart
    return Container(
      height: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Expanded(
            child: total == 0
                ? const Center(
                child: Text('Chưa có dữ liệu',
                    style: TextStyle(color: _muted, fontSize: 12)))
                : PieChart(PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30, // ✅ nhỏ lại để vừa card
              sections: [
                PieChartSectionData(
                  value: quiz,
                  color: const Color(0xFF5B8FF9),
                  title: '${(quiz / total * 100).round()}%',
                  titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  radius: 42,
                ),
                PieChartSectionData(
                  value: fill,
                  color: const Color(0xFF5AD8A6),
                  title: '${(fill / total * 100).round()}%',
                  titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  radius: 42,
                ),
              ],
            )),
          ),
          const SizedBox(height: 8),
          // FIX: Wrap legend để không bị tràn
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 4,
            children: [
              _legendDot(const Color(0xFF5B8FF9), 'Quiz'),
              _legendDot(const Color(0xFF5AD8A6), 'Điền từ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: _muted)),
    ],
  );

  // ─── Hour heatmap bar ─────────────────────────────────────
  Widget _buildHourChart() {
    final dist = _data!.hourDistribution;
    final maxVal =
    dist.values.isEmpty ? 1 : dist.values.reduce((a, b) => a > b ? a : b);
    final hours = List.generate(17, (i) => i + 6); // 6h–22h

    return _buildCard(
      height: 160,
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
              '${hours[g.x.toInt()]}h\n${rod.toY.toInt()} lượt',
              const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
        gridData: FlGridData(
          getDrawingHorizontalLine: (_) =>
          const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (val, _) {
                final h = hours[val.toInt().clamp(0, hours.length - 1)];
                if (h % 3 != 0) return const SizedBox();
                return Text('${h}h',
                    style: const TextStyle(fontSize: 9, color: _muted));
              },
            ),
          ),
          leftTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(hours.length, (i) {
          final h = hours[i];
          final count = dist[h] ?? 0;
          final intensity = maxVal > 0 ? count / maxVal : 0.0;
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              width: 12,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(3)),
              color: Color.lerp(
                const Color(0xFFD4C6F9),
                const Color(0xFF6B4FA0),
                intensity,
              ),
            ),
          ]);
        }),
      )),
    );
  }

  // ─── Shared card wrapper ───────────────────────────────────
  Widget _buildCard({required double height, required Widget child}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }
}