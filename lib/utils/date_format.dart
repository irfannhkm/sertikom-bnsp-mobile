import 'package:intl/intl.dart';

String formatTanggalIndo(DateTime d) =>
    DateFormat('dd MMM yyyy', 'id_ID').format(d);

String formatTanggalLengkap(DateTime d) =>
    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);

String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime parseIsoDate(String iso) {
  final parts = iso.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

DateTime startOfWeekMonday(DateTime d) {
  final daysFromMonday = d.weekday - DateTime.monday;
  final monday = DateTime(
    d.year,
    d.month,
    d.day,
  ).subtract(Duration(days: daysFromMonday));
  return monday;
}

DateTime endOfWeekSunday(DateTime d) {
  final monday = startOfWeekMonday(d);
  final sunday = monday.add(const Duration(days: 6));
  return DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999);
}
