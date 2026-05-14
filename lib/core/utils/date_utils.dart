import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _timeFormat = DateFormat('hh:mm a');
  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _dayFormat = DateFormat('EEE, dd MMM');
  static final _shortDate = DateFormat('dd/MM/yyyy');
  static final _monthYear = DateFormat('MMMM yyyy');

  static String formatTime(DateTime dt) => _timeFormat.format(dt);
  static String formatDate(DateTime dt) => _dateFormat.format(dt);
  static String formatDay(DateTime dt) => _dayFormat.format(dt);
  static String formatShort(DateTime dt) => _shortDate.format(dt);
  static String formatMonthYear(DateTime dt) => _monthYear.format(dt);

  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dt);
  }
}
