import 'package:intl/intl.dart';

class TimeFormatter {
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm').format(date);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
