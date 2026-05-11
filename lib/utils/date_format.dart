import 'package:intl/intl.dart';

/// Format tanggal Indonesia singkat: `21 Mei 2026`.
String formatTanggalIndo(DateTime d) =>
    DateFormat('dd MMM yyyy', 'id_ID').format(d);

/// Format tanggal Indonesia lengkap dengan nama hari: `Kamis, 21 Mei 2026`.
String formatTanggalLengkap(DateTime d) =>
    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);

/// Konversi [DateTime] ke ISO date string `YYYY-MM-DD` (tanpa jam).
/// Dipakai sebagai format kanonik kolom `due_date` di SQLite.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Parse ISO date string `YYYY-MM-DD` ke [DateTime] (jam 00:00 lokal).
/// Inverse dari [isoDate].
DateTime parseIsoDate(String iso) {
  final parts = iso.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

/// Senin (jam 00:00) dari minggu yang memuat [d].
/// `DateTime.monday == 1`, `DateTime.sunday == 7`.
DateTime startOfWeekMonday(DateTime d) {
  final daysFromMonday = d.weekday - DateTime.monday;
  final monday = DateTime(
    d.year,
    d.month,
    d.day,
  ).subtract(Duration(days: daysFromMonday));
  return monday;
}

/// Minggu (jam 23:59:59.999) dari minggu yang memuat [d].
/// Dipakai sebagai upper bound query mingguan agar inklusif sampai akhir hari.
DateTime endOfWeekSunday(DateTime d) {
  final monday = startOfWeekMonday(d);
  final sunday = monday.add(const Duration(days: 6));
  return DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999);
}
