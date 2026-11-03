import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecotrack/main.dart';
import 'package:ecotrack/models.dart';
import 'package:ecotrack/screens/add_activity_screen.dart';
import 'package:ecotrack/screens/challenges_screen.dart';
import 'package:ecotrack/screens/home_screen.dart';
import 'package:ecotrack/screens/profile_screen.dart';
import 'package:ecotrack/store.dart';
import 'package:ecotrack/theme.dart';
import 'package:ecotrack/widgets/tab_bar.dart';
import 'package:ecotrack/widgets/celebrations.dart';
import 'package:ecotrack/widgets/common.dart';
import 'package:ecotrack/widgets/sheets.dart';

void main() {
  test('activity options include clear electricity and food variants', () {
    expect(activityDef('home')?.name, 'Electricity from bill');
    expect(
        actsOf('electricity').map((ActivityDef activity) => activity.key),
        containsAll(
            <String>['fan', 'lighting', 'laptop', 'laundry', 'charging']));
    expect(activityDef('appliance'), isNull);
    expect(
      actsOf('food').map((ActivityDef activity) => activity.key),
      containsAll(<String>[
        'beef',
        'chicken',
        'pork_lamb',
        'fish',
        'dairy',
        'rice_grains',
        'plant_protein',
        'fruits_vegetables',
        'vegetarian',
        'vegan',
      ]),
    );
    expect(activityDef('snacks_processed'), isNull);
    expect(activityDef('beef')?.icon, 'cow');
    expect(activityDef('chicken')?.icon, 'chicken');
    expect(activityDef('pork_lamb')?.icon, 'pig');
    expect(kTips, hasLength(12));
    expect(kTips.every((Tip tip) => activityDef(tip.ctaKey) != null), isTrue);
    expect(activityDef('chicken'), isNotNull);
    expect(activityDef('chicken_grilled')?.factor, 1.6);
    expect(
      activityDef('chicken_fried')!.factor,
      greaterThan(activityDef('chicken_grilled')!.factor),
    );
    expect(foodPreparationsOf('chicken'), hasLength(4));
  });

  test('food logging has a distinct preparation step', () {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);

    store.openAdd();
    store.pickCat('food');
    store.addNext();
    expect(store.addStep, 1);
    expect(store.stepCount, 4);
    expect(store.amountStep, 3);

    store.pickFoodType('chicken');
    store.addNext();
    expect(store.addStep, 2);
    store.pickAct('chicken_fried');
    store.addNext();
    expect(store.addStep, 3);

    store.saveActivity();
    expect(store.lastActivity?.key, 'chicken_fried');
    expect(store.lastActivity?.co2, 1.7);

    store.openAdd();
    store.pickCat('electricity');
    store.addNext();
    store.pickAct('fan');
    store.addNext();
    expect(store.addStep, 2);
    expect(store.stepCount, 3);
    expect(store.amountStep, 2);
  });

  test('custom activities keep the manually entered total', () {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);

    store.openAdd();
    store.pickCat('food');
    store.pickCustomActivity('Homemade stew', 2.37);

    expect(store.addStep, store.amountStep);
    expect(store.addKey, startsWith('custom_'));
    expect(store.activityOf(store.addKey!)?.factor, 2.37);

    store.saveActivity();
    expect(store.lastActivity?.key, store.addKey);
    expect(store.lastActivity?.co2, 2.37);
    expect(store.activityOf(store.lastActivity!.key)?.name, 'Homemade stew');
  });

  test('trying a tip opens amount entry and backs out to tips', () {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);

    store.go('tips');
    store.tryTip('t2');
    expect(store.route, 'add');
    expect(store.addStep, store.amountStep);

    store.addBack();
    expect(store.route, 'tips');
  });

  test('food tips select a preparation before opening amount entry', () {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);

    store.go('tips');
    store.tryTip('t3');
    expect(store.addKey, 'vegetarian_grilled');
    expect(store.addFoodType, 'vegetarian');
    expect(store.addStep, store.amountStep);
  });

  test('weekly challenges are five stable choices with daily check-ins', () {
    final DateTime monday = DateTime(2026, 1, 5);
    final List<Challenge> firstWeek = seedChallenges(now: monday);
    final List<Challenge> sameWeek = seedChallenges(
      now: monday.add(const Duration(days: 3)),
    );
    expect(firstWeek, hasLength(5));
    expect(firstWeek.map((Challenge challenge) => challenge.id).toSet(),
        hasLength(5));
    expect(firstWeek.map((Challenge challenge) => challenge.id),
        sameWeek.map((Challenge challenge) => challenge.id));
    expect(firstWeek.every((Challenge challenge) => challenge.progress == 0),
        isTrue);
    expect(
      firstWeek.any((Challenge challenge) => challenge.target >= 3),
      isTrue,
    );

    final EcoStore store = EcoStore();
    addTearDown(store.dispose);
    final Challenge multiDay = store.challenges.firstWhere(
      (Challenge challenge) => challenge.target >= 3,
    );
    final DateTime today = DateTime.now();
    final DateTime day = DateTime(today.year, today.month, today.day);

    store.challengeDone(multiDay.id, now: day);
    expect(multiDay.progress, 1);
    expect(store.challengeCheckedInToday(multiDay.id, now: day), isTrue);

    store.challengeDone(multiDay.id, now: day);
    expect(multiDay.progress, 1);

    store.challengeDone(multiDay.id, now: day.add(const Duration(days: 1)));
    expect(multiDay.progress, 2);
    store.challengeDone(multiDay.id, now: day.add(const Duration(days: 3)));
    expect(multiDay.progress, 1);
  });

  testWidgets('challenge cards reflect daily check-in state',
      (WidgetTester tester) async {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);
    final Challenge multiDay = store.challenges.firstWhere(
      (Challenge challenge) => challenge.target >= 3 && !challenge.featured,
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ecoTheme(),
        home: EcoScope(
          notifier: store,
          child: const ChallengesScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text(multiDay.title),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(multiDay.title), findsOneWidget);
    expect(find.text('0 / ${multiDay.target.round()}'), findsOneWidget);

    final Finder card = find
        .ancestor(
          of: find.text(multiDay.title),
          matching: find.byType(Pressable),
        )
        .first;
    final Finder checkIn = find.descendant(
      of: card,
      matching: find.widgetWithText(EcoButton, 'Check in today'),
    );
    await tester.scrollUntilVisible(
      checkIn,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(checkIn);
    await tester.pump();
    expect(
        find.descendant(
          of: card,
          matching: find.widgetWithText(EcoButton, 'Checked in today'),
        ),
        findsOneWidget);
    expect(multiDay.progress, 1);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('home carousel actions work with drag and wheel scrolling',
      (WidgetTester tester) async {
    final EcoStore store = EcoStore()..playerAvatar = 'face-happy';
    addTearDown(store.dispose);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ecoTheme(),
        home: EcoScope(
          notifier: store,
          child: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('TODAY SO FAR'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
    expect(tester.getSize(find.byType(PageView)).height, 246);
    final Finder logButton =
        find.byKey(const ValueKey<String>('home-banner-log-button'));
    final double actionBottom = tester.getBottomLeft(logButton).dy;
    expect(tester.getSize(logButton).height, lessThanOrEqualTo(48));
    final Finder todayCard =
        find.byKey(const ValueKey<String>('home-banner-today-card'));
    final Finder todayProgress =
        find.descendant(of: todayCard, matching: find.byType(EcoBar));
    expect(
      tester.getTopLeft(logButton).dy - tester.getBottomLeft(todayProgress).dy,
      closeTo(13, 1),
    );

    final Offset bannerCenter = tester.getCenter(find.text('TODAY SO FAR'));
    await tester.dragFrom(
      bannerCenter,
      const Offset(-300, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(find.text('A QUICK WIN'), findsOneWidget);
    final Finder tipsButton =
        find.byKey(const ValueKey<String>('home-banner-tips-button'));
    expect(tester.getBottomLeft(tipsButton).dy, closeTo(actionBottom, 1));
    await tester.tap(find.text('Explore Eco Tips'));
    await tester.pumpAndSettle();
    expect(store.route, 'tips');

    final Offset carouselCenter = tester.getCenter(find.byType(PageView));
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: carouselCenter,
        scrollDelta: const Offset(0, 80),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('KEEP YOUR MOMENTUM'), findsOneWidget);
    final Finder challengeButton =
        find.byKey(const ValueKey<String>('home-banner-challenges-button'));
    expect(tester.getBottomLeft(challengeButton).dy, closeTo(actionBottom, 1));
    expect(tester.getSize(challengeButton).height, lessThanOrEqualTo(48));
    await tester.tap(find.text('View challenges'));
    await tester.pumpAndSettle();
    expect(store.route, 'challenges');
  });

  testWidgets('app shell uses Scaffold, ListView, and landscape navigation',
      (WidgetTester tester) async {
    debugDisableCelebrationAnimations = true;
    addTearDown(() => debugDisableCelebrationAnimations = false);
    final EcoStore store = EcoStore()..go('challenges');
    addTearDown(store.dispose);
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ecoTheme(),
        home: EcoScope(notifier: store, child: const AppGate()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is EcoTabBar && widget.vertical,
      ),
      findsOneWidget,
    );

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is EcoTabBar && widget.vertical,
      ),
      findsNothing,
    );
    expect(find.byType(EcoTabBar), findsOneWidget);
  });

  testWidgets('profile help shares issue reports and explains the project',
      (WidgetTester tester) async {
    final EcoStore store = EcoStore()..playerAvatar = 'face-happy';
    addTearDown(store.dispose);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ecoTheme(),
        home: EcoScope(
          notifier: store,
          child: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Help & support'));
    await tester.tap(find.text('Help & support'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Report an issue'));
    await tester.tap(find.text('Report an issue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Button is stuck');
    await tester.enterText(
      find.byType(TextField).at(1),
      'The continue button does not advance the activity form.',
    );
    expect(find.text('Share report'), findsOneWidget);
    expect(find.textContaining('share sheet'), findsOneWidget);
    Navigator.of(tester.element(find.text('Report an issue'))).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('About EcoTrack'));
    await tester.tap(find.text('About EcoTrack'));
    await tester.pumpAndSettle();
    expect(find.text('SDG 13 · Climate Action'), findsOneWidget);
    expect(find.text('Devin Owen Sanusi'), findsOneWidget);
    expect(find.text('Anggara Adelee'), findsOneWidget);
    expect(find.text('Kelvin Kurniawan'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('profile sorts locked badges first and unlocked badges last',
      (WidgetTester tester) async {
    final EcoStore store = EcoStore()..playerAvatar = 'face-happy';
    addTearDown(store.dispose);
    for (final Badge badge in store.badges) {
      badge.unlocked = false;
    }
    store.badges.last.unlocked = true;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ecoTheme(),
        home: EcoScope(
          notifier: store,
          child: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('badges'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('First step'));
    await tester.ensureVisible(find.text('Tip collector'));

    expect(
      tester.getTopLeft(find.text('First step')).dy,
      lessThan(tester.getTopLeft(find.text('Tip collector')).dy),
    );
    final ColorScheme colors = Theme.of(
      tester.element(find.text('First step')),
    ).colorScheme;
    final Finder lockedCard = find
        .ancestor(
          of: find.text('First step'),
          matching: find.byType(Container),
        )
        .first;
    final Finder unlockedCard = find
        .ancestor(
          of: find.text('Tip collector'),
          matching: find.byType(Container),
        )
        .first;
    expect(
      (tester.widget<Container>(lockedCard).decoration as BoxDecoration).color,
      colors.surface,
    );
    expect(
      (tester.widget<Container>(unlockedCard).decoration as BoxDecoration)
          .color,
      colors.mint,
    );
  });

  testWidgets('level sheet uses a distinct current-level mascot on the right',
      (WidgetTester tester) async {
    final EcoStore store = EcoStore()..points = 0;
    addTearDown(store.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ecoTheme(),
        home: EcoScope(
          notifier: store,
          child: const Scaffold(body: Text('Level test')),
        ),
      ),
    );
    showLevelInfoSheet(tester.element(find.text('Level test')), store);
    await tester.pumpAndSettle();

    final MascotArt mascot = tester.widget<MascotArt>(find.byType(MascotArt));
    expect(mascot.name, 'level-1');
    expect(mascot.width, 82);
  });

  testWidgets('food logger lets people choose a cooking method',
      (WidgetTester tester) async {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);
    store.openAdd();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ecoTheme(),
        home: EcoScope(
          notifier: store,
          child: const AddActivityScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 4'), findsOneWidget);

    await tester.tap(find.text('Chicken & poultry'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Step 3 of 4'), findsOneWidget);
    expect(find.text('How was it cooked?'), findsOneWidget);

    final Finder fried = find.text('Chicken & poultry · fried');
    await tester.ensureVisible(fried);
    await tester.tap(fried);
    await tester.pumpAndSettle();
    expect(store.addKey, 'chicken_fried');
  });

  testWidgets('custom activity can be added from the final food choice',
      (WidgetTester tester) async {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);
    store.openAdd();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ecoTheme(),
        home: EcoScope(
          notifier: store,
          child: const AddActivityScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Other meal or food'));
    await tester.tap(find.text('Other meal or food'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
    await tester.enterText(find.byType(TextField).at(0), 'Homemade curry');
    await tester.enterText(find.byType(TextField).at(1), '2.37');
    await tester.tap(find.text('Use this estimate'));
    await tester.pumpAndSettle();

    expect(store.activityOf(store.addKey!)?.name, 'Homemade curry');
    expect(store.activityOf(store.addKey!)?.factor, 2.37);
    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();
    expect(store.lastActivity?.co2, 2.37);
  });

  testWidgets('shows the EcoTrack onboarding screen',
      (WidgetTester tester) async {
    // Disable infinite animations for testing
    debugDisableCelebrationAnimations = true;
    addTearDown(() => debugDisableCelebrationAnimations = false);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EcoTrackApp());
    await tester.pumpAndSettle();

    expect(find.text('Meet Eco'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.ensureVisible(find.text('Continue as guest'));
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    expect(find.textContaining(', Guest'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tips_and_updates_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Eco Tips'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    final List<Finder> profileStatTiles = <Finder>[
      find.byType(StatTile).at(0),
      find.byType(StatTile).at(1),
      find.byType(StatTile).at(2),
    ];
    final double totalCardWidth = tester.getSize(profileStatTiles[0]).width;
    expect(tester.getSize(profileStatTiles[1]).width, totalCardWidth);
    expect(tester.getSize(profileStatTiles[2]).width, totalCardWidth);
    await tester.tap(find.text('badges'));
    await tester.pumpAndSettle();
    expect(find.text('Log your very first activity'), findsNothing);
    final Offset badgeCenter = tester.getCenter(find.text('First step'));
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: badgeCenter);
    await mouse.moveTo(badgeCenter);
    await tester.pumpAndSettle();
    expect(find.text('Log your very first activity'), findsOneWidget);
    final List<Transform> badgeTransforms = tester
        .widgetList<Transform>(
          find.ancestor(
            of: find.text('Log your very first activity'),
            matching: find.byType(Transform),
          ),
        )
        .toList();
    expect(
      badgeTransforms.where(
          (Transform transform) => transform.transform.entry(0, 0) < -0.99),
      hasLength(2),
    );
    await mouse.removePointer();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester
        .tap(find.byTooltip('Profile picture: Portrait 1. Tap to change.'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a profile picture'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byTooltip('Profile picture: Portrait 1. Tap to change.'),
        matching: find.byType(ClipOval),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byTooltip('Profile picture: Portrait 1. Tap to change.'),
        matching: find.byType(CircleAvatar),
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('Use Eco profile picture'), findsNothing);
    expect(find.byTooltip('Use Portrait 1 profile picture'), findsOneWidget);
    expect(find.byTooltip('Use Portrait 2 profile picture'), findsOneWidget);
    expect(find.byTooltip('Use Portrait 3 profile picture'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byTooltip('Profile picture: Portrait 1. Tap to change.'),
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/images/portraits/image.png',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Use Portrait 2 profile picture'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Profile picture: Portrait 2. Tap to change.'),
        findsOneWidget);

    await tester.ensureVisible(find.text('Units & colors'));
    await tester.tap(find.text('Units & colors'));
    await tester.pumpAndSettle();
    expect(find.text('Carbon source colors'), findsOneWidget);
    await tester.tap(find.text('Miles'));
    await tester.pumpAndSettle();
    expect(find.text('mi'), findsOneWidget);
    await tester.tap(find.text('Units & colors'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('#8E44AD').first);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label == 'Transport color #8E44AD' &&
            widget.properties.selected == true,
      ),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Tips').last);
    await tester.tap(find.text('Tips').last);
    await tester.pumpAndSettle();
    expect(find.text('Eco Tips'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Account & security'));
    await tester.tap(find.text('Account & security'));
    await tester.pumpAndSettle();
    expect(find.text('Account & security'), findsWidgets);
    expect(find.text('Save name'), findsOneWidget);
    await tester.tap(find.text('Save name'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Help & support'));
    await tester.tap(find.text('Help & support'));
    await tester.pumpAndSettle();
    expect(find.text('Where is my data stored?'), findsOneWidget);
    await tester.ensureVisible(find.text('Browse Eco Tips'));
    await tester.tap(find.text('Browse Eco Tips'));
    await tester.pumpAndSettle();
    expect(find.text('Eco Tips'), findsOneWidget);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    expect(find.text('History'), findsWidgets);

    await tester.tap(find.text('Stats').last);
    await tester.pumpAndSettle();
    expect(find.text('Statistics'), findsOneWidget);

    await tester.tap(find.text('Challenges').last);
    await tester.pumpAndSettle();
    expect(find.text('Challenges'), findsWidgets);
    await tester.tap(find.widgetWithText(EcoButton, 'Check in today').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('daily check-ins'), findsOneWidget);
    expect(
      find.text('Checked in today').evaluate().isNotEmpty ||
          find.textContaining('Claim ').evaluate().isNotEmpty,
      isTrue,
    );

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log activity').first);
    await tester.tap(find.text('Log activity').first);
    await tester.pumpAndSettle();
    expect(find.text('What did you do?'), findsOneWidget);

    await tester.tap(find.text('Transport'));
    await tester.pumpAndSettle();
    final Finder transportCard = find
        .ancestor(
          of: find.text('Transport').first,
          matching: find.byType(EcoCard),
        )
        .first;
    expect(tester.widget<EcoCard>(transportCard).highlighted, isTrue);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Pick the activity'), findsOneWidget);
    final Finder carCard = find
        .ancestor(
          of: find.text('Car'),
          matching: find.byType(EcoCard),
        )
        .first;
    final Finder motorcycleCard = find
        .ancestor(
          of: find.text('Motorcycle'),
          matching: find.byType(EcoCard),
        )
        .first;
    expect(tester.getSize(carCard).width, greaterThan(150));
    expect(
      tester.getSize(motorcycleCard).width,
      tester.getSize(carCard).width,
    );
    final Finder busCard = find
        .ancestor(
          of: find.text('Bus'),
          matching: find.byType(EcoCard),
        )
        .first;
    expect(tester.widget<EcoCard>(busCard).onTap, isNotNull);
    expect(
      find.descendant(of: busCard, matching: find.byType(Pressable)),
      findsOneWidget,
    );
    await tester.ensureVisible(busCard);
    await tester.tap(busCard);
    await tester.pumpAndSettle();
    expect(tester.widget<EcoCard>(busCard).highlighted, isTrue);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('How much?'), findsOneWidget);
    expect(find.text('Bus'), findsOneWidget);
    expect(find.text('mi'), findsOneWidget);

    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();
    expect(find.text('Nice work'), findsOneWidget);

    await tester.tap(find.text('Back to home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Instagram'));
    expect(find.text('Follow EcoTrack'), findsOneWidget);
    expect(find.text('TikTok'), findsOneWidget);
    expect(find.text('X'), findsOneWidget);
    expect(find.text('YouTube'), findsNothing);
    await tester.ensureVisible(find.text('Log out'));
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();
    expect(find.text('Meet Eco'), findsOneWidget);
  });

  testWidgets('dark mode switches app surfaces and keeps readable text',
      (WidgetTester tester) async {
    debugDisableCelebrationAnimations = true;
    addTearDown(() => debugDisableCelebrationAnimations = false);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EcoTrackApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue as guest'));
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Switch to dark appearance'));
    await tester.pumpAndSettle();

    final ThemeData darkTheme =
        tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
    expect(darkTheme.brightness, Brightness.dark);
    expect(darkTheme.colorScheme.surface, EcoDark.surface);
    expect(darkTheme.colorScheme.onSurface, EcoDark.ink);
    expect(darkTheme.scaffoldBackgroundColor, EcoDark.ground);
    final DefaultTextStyle profileHeadingStyle =
        tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text("This week's goal"),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(profileHeadingStyle.style.color, EcoDark.ink);

    await tester.tap(find.byTooltip('Switch to light appearance'));
    await tester.pumpAndSettle();

    final ThemeData lightTheme =
        tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
    expect(lightTheme.brightness, Brightness.light);
  });

  testWidgets('home challenge changes to claim and completed states',
      (WidgetTester tester) async {
    debugDisableCelebrationAnimations = true;
    addTearDown(() => debugDisableCelebrationAnimations = false);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EcoTrackApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue as guest'));
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('I did this today'));
    await tester.tap(find.text('I did this today'));
    await tester.pump(const Duration(seconds: 3));
    expect(
      find.text('Checked in today').evaluate().isNotEmpty ||
          find.textContaining('Claim ').evaluate().isNotEmpty,
      isTrue,
    );
  });

  testWidgets('saved tips filter shows bookmarked tips only',
      (WidgetTester tester) async {
    debugDisableCelebrationAnimations = true;
    addTearDown(() => debugDisableCelebrationAnimations = false);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EcoTrackApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue as guest'));
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tips_and_updates_outlined));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Saved'));
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('No saved tips yet'), findsOneWidget);

    await tester.ensureVisible(find.text('All'));
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    final Finder bookmarkButtons = find.byWidgetPredicate(
      (Widget widget) => widget is EcoIconButton && widget.icon == 'bookmark',
    );
    await tester.ensureVisible(bookmarkButtons.first);
    await tester.tap(bookmarkButtons.first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.ensureVisible(find.text('Saved'));
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.text('No saved tips yet'), findsNothing);
    expect(bookmarkButtons, findsOneWidget);
  });

  testWidgets('home small-win cards all match walk and AC card size',
      (WidgetTester tester) async {
    debugDisableCelebrationAnimations = true;
    addTearDown(() => debugDisableCelebrationAnimations = false);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EcoTrackApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue as guest'));
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Small wins for today'));

    const List<String> tipTitles = <String>[
      'Walk trips under 2 km',
      'Set the AC to 25°C',
      'Swap one beef meal a week',
      'Unplug chargers when idle',
    ];
    final List<Size> cardSizes = tipTitles.map((String title) {
      final Finder card = find.ancestor(
        of: find.text(title),
        matching: find.byType(EcoCard),
      );
      return tester.getSize(card);
    }).toList();

    expect(cardSizes, hasLength(4));
    expect(cardSizes, everyElement(const Size(214, 142)));
  });
}
