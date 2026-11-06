import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecotrack/models/models.dart';
import 'package:ecotrack/screens/profile_screen.dart';
import 'package:ecotrack/state/store.dart';
import 'package:ecotrack/core/theme.dart';
import 'package:ecotrack/widgets/common.dart';
import 'package:ecotrack/widgets/sheets.dart';

void main() {
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
    for (final Achievement badge in store.badges) {
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
}
