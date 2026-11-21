import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat number = NumberFormat.decimalPattern('ar');
  static String steps(int value) => number.format(value);
  static String km(double value) => value.toStringAsFixed(2);
  static String calories(double value) => value.toStringAsFixed(0);
  static String date(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('EEEE، d MMMM', 'ar').format(parsed);
  }
}
