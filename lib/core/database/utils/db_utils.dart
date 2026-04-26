class DbUtils {
  static int dayKeyFromDate(DateTime date) {
    return (date.year * 10000) + (date.month * 100) + date.day;
  }

  static DateTime dateFromDayKey(int dayKey) {
    final year = dayKey ~/ 10000;
    final month = (dayKey % 10000) ~/ 100;
    final day = dayKey % 100;
    return DateTime(year, month, day);
  }
}
