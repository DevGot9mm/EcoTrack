import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecotrack/main.dart';
import 'package:ecotrack/store.dart';
import 'package:ecotrack/theme.dart';
import 'package:ecotrack/widgets/common.dart';
import 'package:ecotrack/widgets/tab_bar.dart';
import 'package:ecotrack/widgets/celebrations.dart';
import 'package:ecotrack/widgets/sheets.dart';

void main() {
  testWidgets('tablet-sized app lays out onboarding and tips without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
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

    expect(find.text('Eco Tips'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large system text scale is capped at 1.3',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          textScaler: TextScaler.linear(2),
        ),
        child: const EcoTrackApp(),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.text('Skip'));
    expect(MediaQuery.textScalerOf(context).scale(10), 13);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom sheet input remains above the keyboard inset',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Center(
              child: ElevatedButton(
                onPressed: () => showEcoSheet(
                  context,
                  const TextField(
                    decoration: InputDecoration(labelText: 'Input'),
                  ),
                ),
                child: const Text('Open sheet'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(
        tester.getRect(find.byType(TextField)).bottom, lessThanOrEqualTo(544));
    expect(tester.takeException(), isNull);
  });

  testWidgets('app shell uses Scaffold, ListView, and landscape navigation',
      (WidgetTester tester) async {
    debugDisableCelebrationAnimations = true;
    addTearDown(() => debugDisableCelebrationAnimations = false);
    final EcoStore store = EcoStore()..go(AppRoute.challenges);
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

  testWidgets('home uses Scaffold bottomNavigationBar and the Log activity button',
      (WidgetTester tester) async {
    debugDisableCelebrationAnimations = true;
    addTearDown(() => debugDisableCelebrationAnimations = false);
    final EcoStore store = EcoStore()..go(AppRoute.home);
    addTearDown(store.dispose);
    tester.view.physicalSize = const Size(390, 844);
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

    final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.bottomNavigationBar, isA<EcoTabBar>());
    expect(find.byType(EcoFab), findsOneWidget);

    await tester.tap(find.byType(EcoFab));
    await tester.pumpAndSettle();
    expect(store.route, AppRoute.add);
    expect(find.byType(EcoFab), findsNothing);
  });
}
