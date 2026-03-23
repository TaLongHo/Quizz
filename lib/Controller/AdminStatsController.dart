import 'package:intl/intl.dart';
import 'package:quizz/Database/lesson_repo.dart';
import 'package:quizz/Database/study_log_repo.dart';
import 'package:quizz/Database/user_repo.dart';
import 'package:quizz/Models/User.dart';

class AdminStatsController {
  final UserRepo _userRepo = UserRepo();
  final LessonRepo _lessonRepo = LessonRepo();
  final StudyLogRepo _logRepo = StudyLogRepo();

  Future<AdminStatsData> loadAll() async {
    final users = await _userRepo.getLeaderboard(limit: 100);
    final lessonTypes = await _lessonRepo.getLessonTypeCount();
    final dailyActive = await _logRepo.getDailyActiveUsers();
    final hourDist = await _logRepo.getStudyHourDistribution();

    // Xây dựng 7 ngày gần nhất (fill 0 nếu không có data)
    const dayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final weekDays = <String>[];
    final weekCounts = <int>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final label = dayLabels[date.weekday % 7]; // weekday: 1=T2...7=CN, 0 không tồn tại
      weekDays.add(label);
      weekCounts.add(dailyActive[key] ?? 0);
    }

    // Streak sorted low to high (chỉ lấy tối đa 8 người)
    final sorted = [...users]
      ..sort((a, b) => a.streakCount.compareTo(b.streakCount));
    final topUsers = sorted.take(8).toList();

    return AdminStatsData(
      totalUsers: users.length,
      activeToday: dailyActive[DateFormat('yyyy-MM-dd').format(DateTime.now())] ?? 0,
      quizCount: lessonTypes['quiz'] ?? 0,
      fillCount: lessonTypes['fill'] ?? 0,
      avgStreak: users.isEmpty
          ? 0
          : (users.map((u) => u.streakCount).reduce((a, b) => a + b) / users.length).round(),
      streakUsers: topUsers,
      weekDayLabels: weekDays,
      weekDayCounts: weekCounts,
      hourDistribution: hourDist,
    );
  }
}

class AdminStatsData {
  final int totalUsers;
  final int activeToday;
  final int quizCount;
  final int fillCount;
  final int avgStreak;
  final List<User> streakUsers;
  final List<String> weekDayLabels;
  final List<int> weekDayCounts;
  final Map<int, int> hourDistribution;

  AdminStatsData({
    required this.totalUsers,
    required this.activeToday,
    required this.quizCount,
    required this.fillCount,
    required this.avgStreak,
    required this.streakUsers,
    required this.weekDayLabels,
    required this.weekDayCounts,
    required this.hourDistribution,
  });
}