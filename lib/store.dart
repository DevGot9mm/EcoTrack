import 'dart:async';

import 'package:flutter/material.dart' hide Badge;

import 'icons.dart';
import 'models.dart';
import 'widgets/celebrations.dart';

/* ==========================================================================
   Routes
   ========================================================================== */

const List<String> kTabRoutes = <String>[
  'home',
  'history',
  'stats',
  'challenges',
  'profile',
];

const List<String> kHideTabBar = <String>['welcome', 'auth', 'add', 'result'];

const Map<String, String> kTabActiveFor = <String, String>{
  'tips': 'home',
  'points': 'profile',
  'result': 'home',
};

class TabSpec {
  const TabSpec(this.id, this.label, this.icon);
  final String id;
  final String label;
  final String icon;
}

const List<TabSpec> kTabs = <TabSpec>[
  TabSpec('home', 'Home', 'house'),
  TabSpec('history', 'History', 'clock'),
  TabSpec('stats', 'Stats', 'chart'),
  TabSpec('challenges', 'Challenges', 'flag'),
  TabSpec('profile', 'Profile', 'user'),
];

/* ==========================================================================
   Store
   ========================================================================== */

/// Single source of truth for both the domain data and the transient UI state,
/// mirroring the prototype's `store` + `ui` objects.
class EcoStore extends ChangeNotifier {
  static const double _kmPerMile = 1.609344;

  EcoStore() {
    activities.addAll(_seedActivities());
    checkBadges(award: false);
  }

  // ---- Domain ------------------------------------------------------------
  bool onboarded = false;
  String playerName = 'Aya';
  String playerAvatar = 'image.png';
  final String joined = 'September 2026';
  int points = 1520;
  int streak = 7;
  double dailyTarget = 6;
  double weeklyTarget = 42;
  String distanceUnit = 'km';
  bool notifyOn = true;
  final Map<String, bool> savedTips = <String, bool>{};
  final Map<String, Color> categoryColors = <String, Color>{};
  final Map<String, ActivityDef> customActivityDefs = <String, ActivityDef>{};
  final List<Entry> activities = <Entry>[];
  final List<Challenge> _challenges = seedChallenges();
  String _challengeWeek = challengeWeekKey(DateTime.now());
  final Map<String, DateTime> _challengeCheckins = <String, DateTime>{};
  final List<Badge> badges = seedBadges();

  // ---- UI state ----------------------------------------------------------
  String route = 'welcome';
  final List<String> _stack = <String>[];
  int onboardSlide = 0;
  String authMode = 'login';
  int addStep = 0;
  String? addCat;
  String? addKey;
  String? addFoodType;
  double addAmount = 4;
  String historyFilter = 'all';
  String statsPeriod = 'week';
  String tipFilter = 'all';
  final Map<String, bool> openTips = <String, bool>{};
  Entry? lastActivity;
  bool isDark = false;

  String toastText = '';
  IconData toastIcon = Icons.check;
  bool toastVisible = false;
  bool profileFocusSocial = false;
  bool _returnToTipsOnAddBack = false;
  Timer? _toastTimer;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _toastTimer?.cancel();
    super.dispose();
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  /* ---- Derived --------------------------------------------------------- */

  List<Entry> get sortedActivities =>
      activities.toList()..sort((Entry a, Entry b) => b.at.compareTo(a.at));

  List<Entry> inRange(int fromAgo, int toAgoInclusive) =>
      activities.where((Entry a) {
        final int i = daysAgo(a.at);
        return i >= fromAgo && i <= toAgoInclusive;
      }).toList();

  double total(List<Entry> acts) =>
      acts.fold<double>(0, (double s, Entry a) => s + a.co2);

  Map<String, double> catTotals(List<Entry> acts) {
    final Map<String, double> t = <String, double>{
      'transport': 0,
      'electricity': 0,
      'food': 0,
    };
    for (final Entry a in acts) {
      t[a.cat] = (t[a.cat] ?? 0) + a.co2;
    }
    return t;
  }

  int get unlockedBadgeCount => badges.where((Badge b) => b.unlocked).length;

  List<Challenge> get challenges {
    refreshChallengeWeek();
    return _challenges;
  }

  void refreshChallengeWeek({DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    final String key = challengeWeekKey(current);
    if (key == _challengeWeek) return;
    _challenges
      ..clear()
      ..addAll(seedChallenges(now: current));
    _challengeCheckins.clear();
    _challengeWeek = key;
  }

  void openSocialProfile() {
    profileFocusSocial = true;
    go('profile');
  }

  void clearSocialProfileFocus() {
    profileFocusSocial = false;
  }

  double get allTimeTotal => total(activities);

  String get greeting {
    final int h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  bool get showTabBar => !kHideTabBar.contains(route);

  String get activeTab => kTabActiveFor[route] ?? route;

  /* ---- UI state ---------------------------------------------------------- */

  void toggleTheme() {
    isDark = !isDark;
    _emit();
  }

  Color categoryColor(String id) => categoryColors[id] ?? catOf(id).color;

  ActivityDef? activityOf(String key) =>
      customActivityDefs[key] ?? activityDef(key);

  void setCategoryColor(String id, Color color) {
    if (!kCats.containsKey(id)) {
      throw ArgumentError.value(id, 'id', 'Unknown carbon category');
    }
    categoryColors[id] = color;
    _emit();
  }

  /* ---- Celebrations ---------------------------------------------------- */

  CelebrationKind? celebrationKind;
  Map<String, dynamic> celebrationData = <String, dynamic>{};

  void showPoints(int amount, String reason) {
    celebrationKind = CelebrationKind.points;
    celebrationData = <String, dynamic>{'amount': amount, 'reason': reason};
    _emit();
  }

  void showBadgeUnlock(Badge badge) {
    celebrationKind = CelebrationKind.badge;
    celebrationData = <String, dynamic>{'badge': badge};
    _emit();
  }

  void showLevelUp(String name, int idx) {
    celebrationKind = CelebrationKind.levelUp;
    celebrationData = <String, dynamic>{'name': name, 'idx': idx};
    _emit();
  }

  void showChallengeComplete(String title, int points) {
    celebrationKind = CelebrationKind.challengeComplete;
    celebrationData = <String, dynamic>{'title': title, 'points': points};
    _emit();
  }

  void clearCelebration() {
    celebrationKind = null;
    celebrationData = <String, dynamic>{};
    _emit();
  }

  /* ---- Routing ---------------------------------------------------------- */

  void go(String r) {
    if (r == route) {
      _emit();
      return;
    }
    if (_stack.isEmpty || _stack.last != route) {
      _stack.add(route);
      if (_stack.length > 12) _stack.removeAt(0);
    }
    route = r;
    _emit();
  }

  void back() {
    if (route == 'add' && addStep > 0) {
      addBack();
      return;
    }
    route = _stack.isNotEmpty ? _stack.removeLast() : 'home';
    _emit();
  }

  /* ---- Feedback --------------------------------------------------------- */

  void toast(String msg, [IconData? icon]) {
    toastText = msg;
    toastIcon = icon ?? Icons.check;
    toastVisible = true;
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2400), () {
      toastVisible = false;
      _emit();
    });
    _emit();
  }

  void award(int n, String reason) {
    final int oldLevel = levelOf(points).idx;
    points += n;
    final int newLevel = levelOf(points).idx;
    if (newLevel > oldLevel) {
      showLevelUp(kLevels[newLevel].name, newLevel);
    } else {
      showPoints(n, reason);
    }
  }

  List<Badge> checkBadges({bool award = true}) {
    final List<Entry> plants = activities
        .where(
            (Entry entry) => entry.key == 'vegan' || entry.key == 'vegetarian')
        .toList();
    final List<Entry> transit = activities
        .where((Entry entry) => entry.key == 'bus' || entry.key == 'train')
        .toList();
    final double bikeDistance = total(
      activities.where((Entry entry) => entry.key == 'bicycle').toList(),
    );
    final double lowCarbonTrips = activities
        .where(
            (Entry entry) => entry.key == 'bicycle' || entry.key == 'walking')
        .length
        .toDouble();
    final double electricityCount = activities
        .where((Entry entry) => entry.cat == 'electricity')
        .length
        .toDouble();
    final double foodCount = activities
        .where((Entry entry) => entry.cat == 'food')
        .length
        .toDouble();
    final double categoryCount =
        activities.map((Entry entry) => entry.cat).toSet().length.toDouble();
    final double customCount = activities
        .where((Entry entry) => entry.key.startsWith('custom_'))
        .length
        .toDouble();
    final double claimedChallenges = challenges
        .where(
            (Challenge challenge) => challenge.state == ChallengeState.claimed)
        .length
        .toDouble();
    final List<Badge> newly = <Badge>[];
    for (final Badge b in badges) {
      final double progress = switch (b.id) {
        'b1' => activities.isEmpty ? 0 : 1,
        'b2' => streak.toDouble(),
        'b3' => plants.length.toDouble(),
        'b4' => transit.length.toDouble(),
        'b5' => bikeDistance,
        'b6' => electricityCount,
        'b7' => claimedChallenges,
        'b8' => points.toDouble(),
        'b9' => lowCarbonTrips,
        'b10' => foodCount,
        'b11' => customCount,
        'b12' => categoryCount,
        'b13' => savedTips.length.toDouble(),
        _ => b.progress,
      };
      b.progress = progress.clamp(0, b.target).toDouble();
      if (progress >= b.target && !b.unlocked) {
        b.unlocked = true;
        if (award) newly.add(b);
      }
    }
    if (award && newly.isNotEmpty) {
      points += 50 * newly.length;
      showBadgeUnlock(newly.first);
    }
    return newly;
  }

  /* ---- Onboarding / auth ------------------------------------------------ */

  void setOnboardSlide(int i) {
    onboardSlide = i;
    _emit();
  }

  void setAuthMode(String mode) {
    authMode = mode;
    _emit();
  }

  void finishOnboard() {
    onboarded = true;
    go('auth');
  }

  void setPlayerName(String n) {
    final String trimmed = n.trim();
    if (trimmed.isNotEmpty) playerName = trimmed.split(' ').first;
    _emit();
  }

  void setPlayerAvatar(String avatar) {
    playerAvatar = avatar;
    _emit();
  }

  /* ---- Add-activity flow ------------------------------------------------ */

  void openAdd() {
    _returnToTipsOnAddBack = false;
    addStep = 0;
    addCat = null;
    addKey = null;
    addFoodType = null;
    _emit();
    go('add');
  }

  void pickCat(String cat) {
    addCat = cat;
    addKey = null;
    addFoodType = null;
    _emit();
  }

  void pickAct(String key) {
    addKey = key;
    final ActivityDef? d = activityOf(key);
    if (d != null) addAmount = defaultAmount(d);
    _emit();
  }

  void pickFoodType(String key) {
    addFoodType = key;
    addKey = null;
    _emit();
  }

  void pickCustomActivity(String name, double totalCo2e) {
    final String trimmedName = name.trim();
    if (addCat == null ||
        trimmedName.length < 2 ||
        !totalCo2e.isFinite ||
        totalCo2e < 0) {
      throw ArgumentError('Custom activity needs a name, category, and total.');
    }
    final String key = 'custom_${DateTime.now().microsecondsSinceEpoch}';
    final Cat category = catOf(addCat!);
    customActivityDefs[key] = ActivityDef(
      key: key,
      cat: category.id,
      name: trimmedName,
      unit: 'activity',
      factor: totalCo2e,
      step: 1,
      max: 1,
      chips: const <double>[1],
      icon: category.icon,
      detail: 'User-entered total CO₂e; no catalog factor was assumed.',
    );
    addKey = key;
    addAmount = 1;
    addStep = amountStep;
    _emit();
  }

  bool isCustomActivity(String? key) =>
      key != null && customActivityDefs.containsKey(key);

  bool get isFoodFlow => addCat == 'food';
  int get amountStep => isFoodFlow ? 3 : 2;
  int get stepCount => isFoodFlow ? 4 : 3;

  void addNext() {
    if (addStep == 0) {
      if (addCat == null) return;
      addStep = 1;
      if (isFoodFlow) {
        addFoodType = null;
        addKey = null;
      } else if (addKey == null) {
        final List<ActivityDef> list = actsOf(addCat!);
        if (list.isNotEmpty) {
          addKey = list.first.key;
          addAmount = defaultAmount(list.first);
        }
      }
    } else if (addStep == 1) {
      if (isFoodFlow) {
        if (addFoodType == null) return;
        addStep = 2;
      } else {
        if (addKey == null) return;
        addStep = 2;
        final ActivityDef? d = activityOf(addKey!);
        if (d != null) addAmount = defaultAmount(d);
      }
    } else if (addStep == 2 && isFoodFlow) {
      if (addKey == null) return;
      addStep = 3;
      final ActivityDef? d = activityOf(addKey!);
      if (d != null) addAmount = defaultAmount(d);
    }
    _emit();
  }

  void addBack() {
    if (_returnToTipsOnAddBack) {
      _returnToTipsOnAddBack = false;
      route = _stack.isNotEmpty ? _stack.removeLast() : 'tips';
      _emit();
      return;
    }
    if (addStep == 0) {
      go('home');
      return;
    }
    addStep -= 1;
    _emit();
  }

  void amtStep(double delta) {
    final ActivityDef? a = addKey == null ? null : activityOf(addKey!);
    if (a == null) return;
    addAmount = clampAmount(a, addAmount + delta * a.step);
    _emit();
  }

  void amtSet(double v) {
    final ActivityDef? a = addKey == null ? null : activityOf(addKey!);
    if (a == null) return;
    final double canonicalAmount =
        a.unit == 'km' && distanceUnit == 'mi' ? v * _kmPerMile : v;
    addAmount = clampAmount(a, canonicalAmount);
    _emit();
  }

  void saveActivity() {
    if (addKey == null) return;
    final ActivityDef a = activityOf(addKey!)!;
    final Entry entry = Entry(
      id: 'a${DateTime.now().microsecondsSinceEpoch}',
      key: a.key,
      cat: a.cat,
      amount: addAmount,
      co2: isCustomActivity(a.key) ? a.factor : round1(a.factor * addAmount),
      at: DateTime.now(),
    );
    activities.add(entry);
    lastActivity = entry;
    _returnToTipsOnAddBack = false;
    final int oldLevel = levelOf(points).idx;
    points += 15;
    final int newLevel = levelOf(points).idx;
    if (newLevel > oldLevel) {
      showLevelUp(kLevels[newLevel].name, newLevel);
    } else {
      showPoints(15, 'Activity logged');
    }
    checkBadges();
    onboarded = true;
    go('result');
  }

  void logAnother() {
    addStep = 0;
    addCat = null;
    addKey = null;
    addFoodType = null;
    go('add');
  }

  /* ---- History ---------------------------------------------------------- */

  void setHistoryFilter(String cat) {
    historyFilter = cat;
    _emit();
  }

  void deleteActivity(String id) {
    activities.removeWhere((Entry x) => x.id == id);
    toast('Entry deleted', kIcons['trash']);
  }

  /* ---- Statistics ------------------------------------------------------- */

  void setStatsPeriod(String p) {
    statsPeriod = p;
    _emit();
  }

  /* ---- Tips ------------------------------------------------------------- */

  void setTipFilter(String cat) {
    tipFilter = cat;
    _emit();
  }

  void toggleTipWhy(String id) {
    openTips[id] = !(openTips[id] ?? false);
    _emit();
  }

  void toggleTipSave(String id) {
    if (savedTips[id] ?? false) {
      savedTips.remove(id);
      toast('Removed from saved tips', kIcons['bookmark']);
    } else {
      savedTips[id] = true;
      toast('Tip saved', kIcons['bookmark']);
    }
    checkBadges();
  }

  void openTipFromRail(String id) {
    tipFilter = 'all';
    openTips[id] = true;
    go('tips');
  }

  void tryTip(String id) {
    final Tip? t = tipOf(id);
    if (t == null) return;
    final ActivityDef? a = activityOf(t.ctaKey);
    if (a == null) return;
    addCat = a.cat;
    addKey = a.cat == 'food' ? foodPreparationsOf(a.key).first.key : a.key;
    addFoodType = a.cat == 'food' ? a.key : null;
    addAmount = t.ctaAmount;
    addStep = amountStep;
    _returnToTipsOnAddBack = true;
    go('add');
  }

  /// Used by the Home breakdown and the Stats insight to jump to History.
  void browseCategory(String cat) {
    historyFilter = cat;
    go('history');
  }

  /* ---- Challenges ------------------------------------------------------- */

  Challenge? challengeOf(String id) {
    for (final Challenge c in challenges) {
      if (c.id == id) return c;
    }
    return null;
  }

  bool challengeCheckedInToday(String id, {DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    final DateTime day = DateTime(current.year, current.month, current.day);
    return _challengeCheckins[id] == day;
  }

  void challengeDone(String id, {DateTime? now}) {
    final Challenge? c = challengeOf(id);
    if (c == null || c.state != ChallengeState.active) return;
    final DateTime today = now ?? DateTime.now();
    final DateTime day = DateTime(today.year, today.month, today.day);
    final DateTime? lastCheckin = _challengeCheckins[id];
    if (challengeCheckedInToday(id, now: today)) {
      toast('You already checked in for this challenge today', kIcons['info']);
      return;
    }
    if (c.target > 1) {
      final bool continuesStreak =
          lastCheckin != null && day.difference(lastCheckin).inDays == 1;
      c.progress = continuesStreak ? c.progress + 1 : 1;
    } else {
      c.progress = 1;
    }
    _challengeCheckins[id] = day;
    if (c.progress >= c.target) c.state = ChallengeState.claimable;
    _emit();
    toast(
      c.state == ChallengeState.claimable
          ? 'Nice — claim your reward'
          : 'Daily check-in saved',
      kIcons['check'],
    );
  }

  void claim(String id) {
    final Challenge? c = challengeOf(id);
    if (c == null || c.state != ChallengeState.claimable) return;
    c.state = ChallengeState.claimed;
    points += c.reward;
    checkBadges();
    showChallengeComplete(c.title, c.reward);
    _emit();
  }

  /* ---- Settings --------------------------------------------------------- */

  void setDailyTarget(double v) {
    dailyTarget = v;
    weeklyTarget = v * 7;
    _emit();
    toast('Daily goal set to ${fmt1(dailyTarget)} kg', kIcons['target']);
  }

  void setDistanceUnit(String unit) {
    if (unit != 'km' && unit != 'mi') return;
    if (distanceUnit == unit) return;
    distanceUnit = unit;
    _emit();
    toast('Distance unit set to $unit');
  }

  void signOut() {
    _toastTimer?.cancel();
    onboarded = false;
    playerName = 'Aya';
    playerAvatar = 'image.png';
    points = 1520;
    streak = 7;
    dailyTarget = 6;
    weeklyTarget = 42;
    distanceUnit = 'km';
    notifyOn = true;
    savedTips.clear();
    _returnToTipsOnAddBack = false;
    profileFocusSocial = false;
    openTips.clear();
    customActivityDefs.clear();
    activities
      ..clear()
      ..addAll(_seedActivities());
    _challenges
      ..clear()
      ..addAll(seedChallenges());
    _challengeWeek = challengeWeekKey(DateTime.now());
    _challengeCheckins.clear();
    badges
      ..clear()
      ..addAll(seedBadges());
    checkBadges(award: false);
    route = 'welcome';
    _stack.clear();
    onboardSlide = 0;
    authMode = 'login';
    addStep = 0;
    addCat = null;
    addKey = null;
    addFoodType = null;
    addAmount = 4;
    historyFilter = 'all';
    statsPeriod = 'week';
    tipFilter = 'all';
    lastActivity = null;
    toastVisible = false;
    isDark = false;
    celebrationKind = null;
    celebrationData = <String, dynamic>{};
    _emit();
  }

  String unitFor(ActivityDef activity) =>
      activity.unit == 'km' ? distanceUnit : activity.unit;

  double displayAmount(ActivityDef activity, double amount) {
    if (activity.unit == 'km' && distanceUnit == 'mi') {
      return round1(amount / _kmPerMile);
    }
    return amount;
  }

  double displayFactor(ActivityDef activity) =>
      activity.unit == 'km' && distanceUnit == 'mi'
          ? activity.factor * _kmPerMile
          : activity.factor;

  double displayStep(ActivityDef activity) =>
      activity.unit == 'km' && distanceUnit == 'mi'
          ? activity.step / _kmPerMile
          : activity.step;

  double displayMax(ActivityDef activity) =>
      activity.unit == 'km' && distanceUnit == 'mi'
          ? activity.max / _kmPerMile
          : activity.max;

  List<double> displayChips(ActivityDef activity) => activity.chips
      .map((double value) => displayAmount(activity, value))
      .toList();

  String amountLabel(ActivityDef activity, double amount) =>
      '${fmtAmount(displayAmount(activity, amount))} ${unitFor(activity)}';

  /* ---- Amount helpers --------------------------------------------------- */

  static double defaultAmount(ActivityDef a) {
    if (a.unit == 'km') return a.chips.length > 1 ? a.chips[1] : a.chips[0];
    if (a.unit == 'kWh') return a.chips[0];
    if (a.unit == 'hours') return a.chips[0];
    return 1;
  }

  static double clampAmount(ActivityDef a, double v) {
    final double min =
        (a.unit == 'servings' || (a.unit == 'km' && a.factor == 0)) ? 1.0 : 0.0;
    double out = v;
    if (out < min) out = min;
    if (out > a.max) out = a.max;
    return round1(out);
  }

  /* ---- Seed ------------------------------------------------------------- */

  static List<Entry> _seedActivities() {
    // [daysAgo, hour, minute, activity key, amount]
    const List<List<Object>> seed = <List<Object>>[
      <Object>[0, 7, 40, 'motorcycle', 6],
      <Object>[0, 12, 15, 'vegetarian', 1],
      <Object>[0, 19, 5, 'home', 2],
      <Object>[1, 8, 0, 'car', 22],
      <Object>[1, 12, 30, 'chicken', 1],
      <Object>[1, 21, 0, 'ac', 3],
      <Object>[2, 7, 20, 'bus', 15],
      <Object>[2, 13, 0, 'vegan', 2],
      <Object>[2, 20, 10, 'home', 3],
      <Object>[3, 8, 10, 'motorcycle', 8],
      <Object>[3, 12, 45, 'fish', 1],
      <Object>[3, 18, 30, 'ac', 2],
      <Object>[3, 22, 0, 'charging', 3],
      <Object>[4, 9, 0, 'walking', 3],
      <Object>[4, 12, 20, 'vegetarian', 2],
      <Object>[4, 19, 40, 'home', 5],
      <Object>[5, 6, 50, 'train', 40],
      <Object>[5, 12, 10, 'chicken', 1],
      <Object>[5, 21, 30, 'ac', 4],
      <Object>[6, 10, 0, 'bicycle', 6],
      <Object>[6, 12, 40, 'vegan', 1],
      <Object>[6, 19, 0, 'home', 2.5],
      <Object>[6, 20, 30, 'beef', 1],
      <Object>[8, 7, 30, 'car', 26],
      <Object>[8, 12, 0, 'beef', 1],
      <Object>[8, 19, 0, 'home', 4],
      <Object>[8, 21, 0, 'ac', 3],
      <Object>[9, 8, 0, 'motorcycle', 14],
      <Object>[9, 12, 30, 'chicken', 1],
      <Object>[9, 18, 0, 'charging', 4],
      <Object>[10, 7, 50, 'car', 30],
      <Object>[10, 13, 0, 'fish', 2],
      <Object>[10, 20, 0, 'home', 5],
      <Object>[11, 9, 10, 'bus', 18],
      <Object>[11, 12, 15, 'beef', 1],
      <Object>[11, 21, 0, 'ac', 5],
      <Object>[12, 8, 40, 'car', 24],
      <Object>[12, 12, 0, 'dairy', 2],
      <Object>[12, 19, 30, 'home', 4],
      <Object>[12, 22, 0, 'charging', 2],
      <Object>[13, 10, 20, 'train', 22],
      <Object>[13, 13, 0, 'chicken', 2],
      <Object>[13, 18, 30, 'ac', 4],
    ];

    final DateTime n = DateTime.now();
    final List<Entry> out = <Entry>[];
    for (int i = 0; i < seed.length; i++) {
      final List<Object> s = seed[i];
      final ActivityDef? a = activityDef(s[3] as String);
      if (a == null) continue;
      final double amount = (s[4] as num).toDouble();
      out.add(
        Entry(
          id: 'seed$i',
          key: a.key,
          cat: a.cat,
          amount: amount,
          co2: round1(a.factor * amount),
          at: DateTime(
            n.year,
            n.month,
            n.day - (s[0] as int),
            s[1] as int,
            s[2] as int,
          ),
        ),
      );
    }
    return out;
  }
}

/// Makes the store available to the whole tree and rebuilds dependents whenever
/// the store notifies — the Flutter equivalent of the prototype's `render()`.
class EcoScope extends InheritedNotifier<EcoStore> {
  const EcoScope({super.key, super.notifier, required super.child});

  static EcoStore of(BuildContext context) {
    final EcoScope? scope =
        context.dependOnInheritedWidgetOfExactType<EcoScope>();
    if (scope == null) {
      throw FlutterError(
        'No EcoScope found above this widget. '
        'Ensure EcoScope is an ancestor of this context.',
      );
    }
    return scope.notifier!;
  }
}
