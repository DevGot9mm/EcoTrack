import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecotrack/main.dart';
import 'package:ecotrack/screens/add_activity_screen.dart';
import 'package:ecotrack/store.dart';
import 'package:ecotrack/theme.dart';
import 'package:ecotrack/widgets/celebrations.dart';
import 'package:ecotrack/widgets/common.dart';

void main() {
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
          (Widget widget) {
            if (widget is! Image || widget.image is! ResizeImage) return false;
            final ResizeImage image = widget.image as ResizeImage;
            return image.imageProvider is AssetImage &&
                (image.imageProvider as AssetImage).assetName ==
                    'assets/images/portraits/image.png' &&
                image.width! <= 256;
          },
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
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is EcoIconButton && widget.icon == 'bookmarkOn',
      ),
      findsOneWidget,
    );
  });
}
