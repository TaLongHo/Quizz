import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../Service/ThemeService.dart';

class StreakCalendarModal extends StatelessWidget {
  final List<String> studyDates;
  final int streakCount;

  const StreakCalendarModal({super.key, required this.studyDates, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        // SỬA: Dùng cardColor để tự đổi màu theo Theme
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh gạch ngang nhỏ trên đầu modal
          Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)
              )
          ),
          const SizedBox(height: 25),

          const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 50),
          Text(
              "$streakCount Ngày liên tiếp",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.blue[300] : Colors.blue[900] // Đổi màu tiêu đề theo mode
              )
          ),
          Text(
              "Duy trì việc học mỗi ngày nhé!",
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey)
          ),
          const SizedBox(height: 15),

          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: isDark ? Colors.white70 : Colors.black54),
              rightChevronIcon: Icon(Icons.chevron_right, color: isDark ? Colors.white70 : Colors.black54),
            ),
            // SỬA: Thêm style cho các ngày trong tuần và ngày bình thường
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              weekendStyle: const TextStyle(color: Colors.redAccent),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
              outsideDaysVisible: false,
            ),
            calendarBuilders: CalendarBuilders(
              // Custom hiển thị cho từng ngày
              defaultBuilder: (context, day, focusedDay) {
                String formatted = DateFormat('yyyy-MM-dd').format(day);
                // Nếu là ngày có streak (đã học)
                if (studyDates.contains(formatted)) {
                  return _buildCalendarDay(day.day, Colors.orange.withOpacity(0.2), Colors.orange[900]!, true, isDark);
                }
                // Ngày bình thường không học (SỬA để hiện rõ chữ)
                return Center(
                  child: Text(
                    "${day.day}",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  ),
                );
              },
              // Ngày hiện tại
              todayBuilder: (context, day, focusedDay) {
                String formatted = DateFormat('yyyy-MM-dd').format(day);
                bool hasStudied = studyDates.contains(formatted);
                return _buildCalendarDay(
                    day.day,
                    isDark ? Colors.blue[900]!.withOpacity(0.5) : Colors.blue[50]!,
                    isDark ? Colors.blue[200]! : Colors.blue[900]!,
                    hasStudied,
                    isDark,
                    isToday: true
                );
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Widget dùng chung để vẽ ô ngày chuyên nghiệp
  Widget _buildCalendarDay(int dayNum, Color bgColor, Color textColor, bool showFire, bool isDark, {bool isToday = false}) {
    // Nếu ở Dark Mode, màu text của ngày có streak nên sáng hơn để dễ đọc
    Color finalTextColor = isDark ? Colors.orange[200]! : textColor;
    if(isToday && !isDark) finalTextColor = Colors.blue[900]!;
    if(isToday && isDark) finalTextColor = Colors.blue[100]!;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: isDark ? Colors.blue[400]! : Colors.blue[800]!, width: 2)
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text("$dayNum", style: TextStyle(fontWeight: FontWeight.bold, color: finalTextColor)),
          if (showFire)
            const Positioned(
              bottom: 4,
              child: Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 10),
            ),
        ],
      ),
    );
  }
}