import 'package:flutter_test/flutter_test.dart';

import 'package:ecotrack/models/models.dart';

void main() {
  group('format helpers', () {
    test('formats decimal and whole amounts consistently', () {
      expect(fmt1(2), '2.0');
      expect(fmt2(2.5), '2.50');
      expect(fmtAmount(4), '4');
      expect(fmtAmount(2.5), '2.5');
      expect(kgText(3.25), '3.3 kg');
    });

    test('clamps values to their inclusive bounds', () {
      expect(clampInt(0, 1, 5), 1);
      expect(clampInt(8, 1, 5), 5);
      expect(clampDouble(0.5, 1, 5), 1);
      expect(clampDouble(8, 1, 5), 5);
    });

    test('groups thousands and formats date/time values', () {
      expect(groupThousands(1234567), '1,234,567');
      expect(groupThousands(-1234), '-1,234');
      expect(longDate(DateTime(2026, 11, 6)), 'Friday 6 November');
      expect(weekdayShort(DateTime(2026, 11, 6)), 'Fri');
      expect(dayLabelShort(DateTime(2026, 11, 6)), 'Fri 6 Nov');
      expect(timeLabel(DateTime(2026, 11, 6, 9, 5)), '09:05');
    });
  });
}
