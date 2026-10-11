import 'package:flutter/material.dart' hide Badge;

import 'theme.dart';

/* ==========================================================================
   Domain data — honest, plausible illustrative estimates.
   ========================================================================== */

/// Resolved category colors — tint and ink adapt to light/dark brightness.
class CatColors {
  const CatColors({required this.tint, required this.ink});
  final Color tint;
  final Color ink;
}

class Cat {
  const Cat({
    required this.id,
    required this.name,
    required this.blurb,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final String blurb;
  final Color color;
  final String icon;

  CatColors resolve(ColorScheme cs) {
    final bool dark = cs.brightness == Brightness.dark;
    switch (id) {
      case 'transport':
        return CatColors(
          tint: dark ? cs.transportTint : const Color(0xFFE3F0F1),
          ink: dark ? cs.transportInk : const Color(0xFF2A5F68),
        );
      case 'electricity':
        return CatColors(
          tint: dark ? cs.electricityTint : const Color(0xFFFBF0DA),
          ink: dark ? cs.electricityInk : const Color(0xFF7F5606),
        );
      case 'food':
        return CatColors(
          tint: dark ? cs.foodTint : const Color(0xFFEDF4DE),
          ink: dark ? cs.foodInk : const Color(0xFF546D2C),
        );
    }
    return const CatColors(tint: Color(0xFFE3F0F1), ink: Color(0xFF2A5F68));
  }
}

const Map<String, Cat> kCats = <String, Cat>{
  'transport': Cat(
    id: 'transport',
    name: 'Transport',
    blurb: 'Getting around',
    color: Eco.transport,
    icon: 'bus',
  ),
  'electricity': Cat(
    id: 'electricity',
    name: 'Electricity',
    blurb: 'Power at home',
    color: Eco.electricity,
    icon: 'bolt',
  ),
  'food': Cat(
    id: 'food',
    name: 'Food',
    blurb: 'What you eat',
    color: Eco.food,
    icon: 'sprout',
  ),
};

const List<String> kCatOrder = <String>['transport', 'electricity', 'food'];

Cat catOf(String id) => kCats[id] ?? kCats['transport']!;

class ActivityDef {
  const ActivityDef({
    required this.key,
    required this.cat,
    required this.name,
    required this.unit,
    required this.factor,
    required this.step,
    required this.max,
    required this.chips,
    required this.icon,
  });

  final String key;
  final String cat;
  final String name;
  final String unit;

  /// kg CO2e per unit.
  final double factor;
  final double step;
  final double max;
  final List<double> chips;
  final String icon;
}

const List<ActivityDef> kActivities = <ActivityDef>[
  ActivityDef(key: 'car', cat: 'transport', name: 'Car', unit: 'km', factor: 0.192, step: 5, max: 200, chips: <double>[5, 15, 40], icon: 'car'),
  ActivityDef(key: 'motorcycle', cat: 'transport', name: 'Motorcycle', unit: 'km', factor: 0.103, step: 5, max: 200, chips: <double>[5, 15, 40], icon: 'motorcycle'),
  ActivityDef(key: 'bus', cat: 'transport', name: 'Bus', unit: 'km', factor: 0.082, step: 5, max: 200, chips: <double>[5, 15, 40], icon: 'bus'),
  ActivityDef(key: 'train', cat: 'transport', name: 'Train', unit: 'km', factor: 0.035, step: 5, max: 400, chips: <double>[5, 20, 60], icon: 'train'),
  ActivityDef(key: 'bicycle', cat: 'transport', name: 'Bicycle', unit: 'km', factor: 0, step: 1, max: 60, chips: <double>[1, 5, 10], icon: 'bike'),
  ActivityDef(key: 'walking', cat: 'transport', name: 'Walking', unit: 'km', factor: 0, step: 1, max: 30, chips: <double>[1, 3, 5], icon: 'walk'),

  ActivityDef(key: 'home', cat: 'electricity', name: 'Home electricity', unit: 'kWh', factor: 0.72, step: 1, max: 40, chips: <double>[2, 5, 10], icon: 'bolt'),
  ActivityDef(key: 'ac', cat: 'electricity', name: 'Air conditioner', unit: 'hours', factor: 0.62, step: 1, max: 18, chips: <double>[1, 3, 8], icon: 'snow'),
  ActivityDef(key: 'appliance', cat: 'electricity', name: 'Other appliances', unit: 'hours', factor: 0.45, step: 1, max: 18, chips: <double>[1, 4, 8], icon: 'plug'),

  ActivityDef(key: 'beef', cat: 'food', name: 'Beef dish', unit: 'servings', factor: 4.0, step: 1, max: 6, chips: <double>[1, 2, 3], icon: 'steak'),
  ActivityDef(key: 'chicken', cat: 'food', name: 'Chicken dish', unit: 'servings', factor: 1.6, step: 1, max: 6, chips: <double>[1, 2, 3], icon: 'chicken'),
  ActivityDef(key: 'fish', cat: 'food', name: 'Fish dish', unit: 'servings', factor: 1.1, step: 1, max: 6, chips: <double>[1, 2, 3], icon: 'fish'),
  ActivityDef(key: 'dairy', cat: 'food', name: 'Dairy & eggs', unit: 'servings', factor: 1.0, step: 1, max: 6, chips: <double>[1, 2, 3], icon: 'egg'),
  ActivityDef(key: 'vegetarian', cat: 'food', name: 'Vegetarian meal', unit: 'servings', factor: 0.7, step: 1, max: 6, chips: <double>[1, 2, 3], icon: 'leaf'),
  ActivityDef(key: 'vegan', cat: 'food', name: 'Vegan meal', unit: 'servings', factor: 0.45, step: 1, max: 6, chips: <double>[1, 2, 3], icon: 'sprout'),
];

ActivityDef? activityDef(String key) {
  for (final ActivityDef a in kActivities) {
    if (a.key == key) return a;
  }
  return null;
}

List<ActivityDef> actsOf(String cat) =>
    kActivities.where((ActivityDef a) => a.cat == cat).toList();

class Tip {
  const Tip({
    required this.id,
    required this.cat,
    required this.icon,
    required this.title,
    required this.action,
    required this.why,
    required this.ctaKey,
    required this.ctaAmount,
  });

  final String id;
  final String cat;
  final String icon;
  final String title;
  final String action;
  final String why;
  final String ctaKey;
  final double ctaAmount;
}

const List<Tip> kTips = <Tip>[
  Tip(id: 't1', cat: 'transport', icon: 'walk', title: 'Walk trips under 2 km', action: 'Leave the bike helmet at home for short errands.', why: 'Trips under 2 km are the easiest to replace — and they are the ones where a cold engine burns the most fuel per kilometre.', ctaKey: 'walking', ctaAmount: 2),
  Tip(id: 't2', cat: 'electricity', icon: 'snow', title: 'Set the AC to 25°C', action: 'Each degree warmer cuts roughly 6% of its power draw.', why: 'Cooling is usually the single biggest load in a home. One degree is invisible to your comfort and visible on your footprint.', ctaKey: 'ac', ctaAmount: 3),
  Tip(id: 't3', cat: 'food', icon: 'leaf', title: 'Swap one beef meal a week', action: 'Try a vegetarian dish on the day you would have had beef.', why: 'A beef dish carries roughly six times the emissions of a vegetarian one. One swap a week is a real dent.', ctaKey: 'vegetarian', ctaAmount: 1),
  Tip(id: 't4', cat: 'electricity', icon: 'plug', title: 'Unplug chargers when idle', action: 'Switch off the strip before you leave the room.', why: 'Standby load is small per device, but it runs every hour you are asleep or away — and it adds up across a house.', ctaKey: 'appliance', ctaAmount: 1),
  Tip(id: 't5', cat: 'transport', icon: 'bus', title: 'Take the bus once a week', action: 'Pick your longest regular drive and ride it instead.', why: 'A bus spreads its emissions across everyone aboard, so your share of a full bus is a fraction of a solo car trip.', ctaKey: 'bus', ctaAmount: 15),
  Tip(id: 't6', cat: 'food', icon: 'sprout', title: 'Eat what you buy', action: 'Plan two meals around what is already in the fridge.', why: 'Food that is grown, shipped and then thrown away carries all of its emissions and returns none of the nutrition.', ctaKey: 'vegan', ctaAmount: 1),
  Tip(id: 't7', cat: 'electricity', icon: 'refresh', title: 'Air-dry your laundry', action: 'Skip the dryer on the next sunny day.', why: 'A tumble dryer is one of the hungriest appliances per cycle — a line costs nothing and produces nothing.', ctaKey: 'home', ctaAmount: 3),
  Tip(id: 't8', cat: 'transport', icon: 'bike', title: 'Cycle the short hop', action: 'Replace one short ride with pedal power.', why: 'Cycling is genuinely zero-emission in use, and it replaces the trips where a car is least efficient.', ctaKey: 'bicycle', ctaAmount: 5),
];

Tip? tipOf(String id) {
  for (final Tip t in kTips) {
    if (t.id == id) return t;
  }
  return null;
}

/// Challenge state machine: active → claimable → claimed.
enum ChallengeState { active, claimable, claimed }

class Challenge {
  Challenge({
    required this.id,
    required this.cat,
    required this.title,
    required this.why,
    required this.reward,
    required this.target,
    required this.progress,
    required this.state,
    this.featured = false,
    this.mascot = 'face-excited',
  });

  final String id;
  final String cat;
  final String title;
  final String why;
  final int reward;
  final double target;
  double progress;
  ChallengeState state;
  final bool featured;
  final String mascot;
}

List<Challenge> seedChallenges() => <Challenge>[
  Challenge(id: 'c1', cat: 'transport', title: 'Legs before engine', why: 'Choose walking or cycling for one short trip today.', reward: 30, target: 1, progress: 0, state: ChallengeState.active, featured: true, mascot: 'face-excited'),
  Challenge(id: 'c2', cat: 'electricity', title: 'Lights off when you leave', why: 'Turn off unused lights for three days running.', reward: 20, target: 3, progress: 2, state: ChallengeState.active),
  Challenge(id: 'c3', cat: 'food', title: 'Meat-free for a meal', why: 'Pick one plant-forward meal today.', reward: 25, target: 1, progress: 1, state: ChallengeState.claimable),
  Challenge(id: 'c4', cat: 'electricity', title: 'Unplug overnight', why: 'Kill the standby load before bed.', reward: 20, target: 1, progress: 1, state: ChallengeState.claimed),
  Challenge(id: 'c5', cat: 'transport', title: 'Ride the bus once', why: 'Swap one regular drive for the bus this week.', reward: 25, target: 1, progress: 0, state: ChallengeState.active),
];

class Badge {
  Badge({
    required this.id,
    required this.icon,
    required this.name,
    required this.desc,
    required this.unlocked,
    required this.progress,
    required this.target,
  });

  final String id;
  final String icon;
  final String name;
  final String desc;
  bool unlocked;
  double progress;
  final double target;
}

List<Badge> seedBadges() => <Badge>[
  Badge(id: 'b1', icon: 'sprout', name: 'First step', desc: 'Log your very first activity', unlocked: true, progress: 1, target: 1),
  Badge(id: 'b2', icon: 'flame', name: 'Week streak', desc: 'Open EcoTrack seven days in a row', unlocked: true, progress: 7, target: 7),
  Badge(id: 'b3', icon: 'leaf', name: 'Green chef', desc: 'Log five plant-based meals', unlocked: true, progress: 5, target: 5),
  Badge(id: 'b4', icon: 'bus', name: 'Transit regular', desc: 'Take the bus or train ten times', unlocked: true, progress: 10, target: 10),
  Badge(id: 'b5', icon: 'bike', name: 'Cyclist', desc: 'Cycle 25 km in total', unlocked: false, progress: 14, target: 25),
  Badge(id: 'b6', icon: 'bolt', name: 'Power saver', desc: 'Save 20 kWh against your baseline', unlocked: false, progress: 12, target: 20),
  Badge(id: 'b7', icon: 'flag', name: 'Challenger', desc: 'Complete five daily challenges', unlocked: false, progress: 3, target: 5),
  Badge(id: 'b8', icon: 'trophy', name: 'Tree planter', desc: 'Reach 2 000 Eco Points', unlocked: false, progress: 1520, target: 2000),
];

class Level {
  const Level(this.min, this.name);
  final int min;
  final String name;
}

const List<Level> kLevels = <Level>[
  Level(0, 'Seedling'),
  Level(300, 'Sprout'),
  Level(700, 'Sapling'),
  Level(1200, 'Green Guardian'),
  Level(1800, 'Canopy Keeper'),
];

class LevelInfo {
  const LevelInfo({
    required this.idx,
    required this.name,
    required this.pct,
    required this.toNext,
    required this.nextName,
  });

  final int idx;
  final String name;
  final int pct;
  final int toNext;
  final String? nextName;
}

LevelInfo levelOf(int points) {
  int idx = 0;
  for (int i = 0; i < kLevels.length; i++) {
    if (points >= kLevels[i].min) idx = i;
  }
  final Level? next = (idx + 1 < kLevels.length) ? kLevels[idx + 1] : null;
  final int from = kLevels[idx].min;
  final int to = next?.min ?? from + 600;
  final int pct = clampInt(
    (((points - from) / (to - from)) * 100).round(),
    0,
    100,
  );
  return LevelInfo(
    idx: idx,
    name: kLevels[idx].name,
    pct: pct,
    toNext: next != null ? to - points : 0,
    nextName: next?.name,
  );
}

/// A logged entry.
class Entry {
  const Entry({
    required this.id,
    required this.key,
    required this.cat,
    required this.amount,
    required this.co2,
    required this.at,
  });

  final String id;
  final String key;
  final String cat;
  final double amount;
  final double co2;
  final DateTime at;
}

/* ==========================================================================
   Formatting helpers — no third-party intl dependency.
   ========================================================================== */

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
String fmtAmount(double n) => n == n.roundToDouble() ? n.toInt().toString() : n.toString();

String kgText(double n) => '${fmt1(n)} kg';

String amountLabel(ActivityDef a, double v) => '${fmtAmount(v)} ${a.unit}';

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
