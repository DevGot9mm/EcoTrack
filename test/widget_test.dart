import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecotrack/main.dart';
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

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log activity').first);
    await tester.tap(find.text('Log activity').first);
    await tester.pumpAndSettle();
    expect(find.text('What did you do?'), findsOneWidget);

    await tester.tap(find.text('Transport'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Pick the activity'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('How much?'), findsOneWidget);
    expect(find.text('mi'), findsOneWidget);

    await tester.tap(find.text('Save activity'));
    await tester.pumpAndSettle();
    expect(find.text('Nice work'), findsOneWidget);

    await tester.tap(find.text('Back to home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log out'));
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();
    expect(find.text('Meet Sprout'), findsOneWidget);
  });
}
