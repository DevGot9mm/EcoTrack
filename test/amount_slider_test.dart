import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecotrack/core/theme.dart';
import 'package:ecotrack/main.dart';
import 'package:ecotrack/models/models.dart';
import 'package:ecotrack/state/store.dart';

void main() {
  for (final String key in <String>['walking', 'bicycle']) {
    testWidgets('$key slider stays in range when the unit is miles',
        (WidgetTester tester) async {
      final EcoStore store = EcoStore()
        ..distanceUnit = 'mi'
        ..addCat = CarbonCategory.transport
        ..pickAct(key);
      store
        ..addStep = store.amountStep
        ..go(AppRoute.add);
      addTearDown(store.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ecoTheme(),
          home: EcoScope(notifier: store, child: const AppGate()),
        ),
      );
      await tester.pumpAndSettle();

      // Drive the amount to both canonical limits (1 km and the maximum).
      store.amtSet(0.1);
      await tester.pumpAndSettle();
      Slider slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, greaterThanOrEqualTo(slider.min));
      expect(slider.value, lessThanOrEqualTo(slider.max));

      store.amtSet(10000);
      await tester.pumpAndSettle();
      slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, greaterThanOrEqualTo(slider.min));
      expect(slider.value, lessThanOrEqualTo(slider.max));
      expect(tester.takeException(), isNull);
    });
  }
}
