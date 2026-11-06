import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecotrack/main.dart';
import 'package:ecotrack/models/models.dart';
import 'package:ecotrack/screens/challenges_screen.dart';
import 'package:ecotrack/screens/home_screen.dart';
import 'package:ecotrack/state/store.dart';
import 'package:ecotrack/core/theme.dart';
import 'package:ecotrack/widgets/celebrations.dart';
import 'package:ecotrack/widgets/common.dart';

void main() {
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
    expect(store.route, AppRoute.tips);

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
    expect(store.route, AppRoute.challenges);
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
