import 'package:intl/intl.dart';

// ✅ Dynamically generates the last 7 days including today
List<Map<String, String>> getDays() {
  DateTime now = DateTime.now();
  List<Map<String, String>> days = [];

  for (int i = 6; i >= 0; i--) {
    DateTime date = now.subtract(Duration(days: i));
    days.add({
      "label": DateFormat('E').format(date), // ✅ "Mon", "Tue", etc.
      "day": DateFormat('d').format(date), // ✅ "23", "24", etc.
    });
  }
  return days;
}

// ✅ Generate the days dynamically
List<Map<String, String>> days = getDays();

// ✅ Generates months dynamically for the current year
List<Map<String, String>> getMonths() {
  List<Map<String, String>> months = [];
  DateTime now = DateTime.now();

  for (int i = 0; i < 12; i++) {
    DateTime date = DateTime(now.year, i + 1, 1);
    months.add({
      "label": DateFormat('yyyy').format(date), // ✅ Year (e.g., "2025")
      "day": DateFormat('MMM').format(date), // ✅ Short Month Name (e.g., "Jan")
    });
  }
  return months;
}

// ✅ Use this in `stats_page.dart`
List<Map<String, String>> months = getMonths();
