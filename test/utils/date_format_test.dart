import 'package:agenda_nusantara/utils/date_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('formatTanggalIndo', () {
    test('formats DateTime to "DD MMM YYYY" Indonesian', () {
      final d = DateTime(2026, 5, 8);
      expect(formatTanggalIndo(d), '08 Mei 2026');
    });

    test('handles single-digit day with leading zero', () {
      expect(formatTanggalIndo(DateTime(2026, 1, 3)), '03 Jan 2026');
    });
  });

  group('formatTanggalLengkap', () {
    test('formats with weekday', () {
      final d = DateTime(2026, 5, 4);
      expect(formatTanggalLengkap(d), 'Senin, 4 Mei 2026');
    });
  });

  group('isoDate', () {
    test('returns YYYY-MM-DD', () {
      expect(isoDate(DateTime(2026, 5, 8)), '2026-05-08');
    });
  });

  group('parseIsoDate', () {
    test('round trip with isoDate', () {
      final d = DateTime(2026, 5, 8);
      expect(parseIsoDate(isoDate(d)), d);
    });
  });

  group('startOfWeekMonday / endOfWeekSunday', () {
    test('Monday of week containing 2026-05-08 (Friday) is 2026-05-04', () {
      final fri = DateTime(2026, 5, 8);
      expect(startOfWeekMonday(fri), DateTime(2026, 5, 4));
    });

    test('Sunday end is 23:59:59 of that day', () {
      final fri = DateTime(2026, 5, 8);
      final end = endOfWeekSunday(fri);
      expect(end.year, 2026);
      expect(end.month, 5);
      expect(end.day, 10);
      expect(end.hour, 23);
      expect(end.minute, 59);
    });

    test('when given Monday itself, start equals same day', () {
      final mon = DateTime(2026, 5, 4);
      expect(startOfWeekMonday(mon), mon);
    });

    test('when given Sunday, start is previous Monday', () {
      final sun = DateTime(2026, 5, 10);
      expect(startOfWeekMonday(sun), DateTime(2026, 5, 4));
    });
  });
}
