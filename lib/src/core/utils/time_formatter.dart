import 'package:intl/intl.dart';

class TimeFormatter {
  static String format(DateTime dt) => DateFormat('hh:mm').format(dt);

  static String formatDay(DateTime dt) => DateFormat('EEEE, MMM d').format(dt);
}
