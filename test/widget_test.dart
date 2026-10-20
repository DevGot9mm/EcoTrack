import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecotrack/main.dart';
import 'package:ecotrack/theme.dart';
import 'package:ecotrack/widgets/celebrations.dart';
import 'package:ecotrack/widgets/common.dart';

void main() {
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

    expect(find.text('Meet Sprout'), findsOneWidget);
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
              (widget.image as AssetImage).assetName == 'image.png',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Use Portrait 2 profile picture'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Profile picture: Portrait 2. Tap to change.'),
        findsOneWidget);

    await tester.ensureVisible(find.text('Units'));
    await tester.tap(find.text('Units'));
    await tester.pumpAndSettle();
    expect(find.text('Distance units'), findsOneWidget);
    await tester.tap(find.text('Miles'));
    await tester.pumpAndSettle();
    expect(find.text('mi'), findsOneWidget);

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
    // Tap the featured challenge's "Mark as done" button
    await tester.tap(find.widgetWithText(EcoButton, 'Mark as done').first);
    await tester.pumpAndSettle();
    expect(find.text('Claim 30 pts'), findsOneWidget);
    await tester.tap(find.text('Claim 30 pts'));
    // Pump to trigger post-frame callback for celebration
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Challenge complete'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

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
    expect(find.text('Meet Sprout'), findsOneWidget);
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
    expect(find.text('Claim 30 pts'), findsOneWidget);

    await tester.tap(find.text('Claim 30 pts'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Challenge complete'), findsOneWidget);
    expect(find.text('Claim 30 pts'), findsNothing);
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
    await tester.ensureVisible(find.byType(EcoIconButton).first);
    await tester.tap(find.byType(EcoIconButton).first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.ensureVisible(find.text('Saved'));
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.text('No saved tips yet'), findsNothing);
    expect(find.byType(EcoIconButton), findsOneWidget);
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
