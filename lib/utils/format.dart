/// Pure formatting and date helpers shared by EcoTrack models and screens.
///
/// Kept separate from domain models so formatting rules can be maintained and
/// tested without mixing them with seed data and model declarations.

library;

const List<String> _weekdayLong = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _weekdayShort = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> _monthLong = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _monthShort = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

double round1(double n) => (n * 10).roundToDouble() / 10;

int clampInt(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);

double clampDouble(double v, double lo, double hi) =>
    v < lo ? lo : (v > hi ? hi : v);

String fmt1(double n) => n.toStringAsFixed(1);

String fmt2(double n) => n.toStringAsFixed(2);

/// Amounts read as `4` or `2.5`, never `4.0`.
String fmtAmount(double n) =>
    n == n.roundToDouble() ? n.toInt().toString() : n.toString();

String kgText(double n) => '${fmt1(n)} kg';

String groupThousands(int n) {
  final String s = n.abs().toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}$out';
}

String longDate(DateTime d) =>
    '${_weekdayLong[d.weekday - 1]} ${d.day} ${_monthLong[d.month - 1]}';

String weekdayShort(DateTime d) => _weekdayShort[d.weekday - 1];

String dayLabelShort(DateTime d) =>
    '${_weekdayShort[d.weekday - 1]} ${d.day} ${_monthShort[d.month - 1]}';

String timeLabel(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Whole days between two calendar dates, immune to DST shifts.
int _dayNumber(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

int daysAgo(DateTime ts) => _dayNumber(DateTime.now()) - _dayNumber(ts);

/// The calendar date `index` days before today. Day arithmetic (rather than
/// adding a Duration) keeps this correct across daylight-saving boundaries.
DateTime dayAgo(int index) {
  final DateTime n = DateTime.now();
  return DateTime(n.year, n.month, n.day - index);
}

/// Day bucket label used by History: Today / Yesterday / Tue 22 Sep.
String dayLabel(int index) {
  if (index == 0) return 'Today';
  if (index == 1) return 'Yesterday';
  return dayLabelShort(dayAgo(index));
}
