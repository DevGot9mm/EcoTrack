import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecotrack/celebration_data.dart';
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
  test('streak uses consecutive days with activity', () {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    Entry entryAt(String id, DateTime at) => Entry(
          id: id,
          key: 'walking',
          cat: CarbonCategory.transport,
          amount: 1,
          co2: 0,
          at: at,
        );

    store.activities
      ..clear()
      ..add(entryAt('yesterday', today.subtract(const Duration(days: 1))));
    expect(store.streak, 1);

    store.activities
      ..add(entryAt('today', today.add(const Duration(hours: 12))))
      ..add(entryAt('older', today.subtract(const Duration(days: 3))));
    expect(store.streak, 2);
  });

  test('display name is retained while greeting uses its first word', () {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);

    store.setPlayerName('  Kelvin Kurniawan  ');

    expect(store.playerName, 'Kelvin Kurniawan');
    expect(store.greetingName, 'Kelvin');
  });

  test('celebration state uses typed payloads', () {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);

    store.showPoints(12, 'Activity logged');
    expect(store.celebrationData, isA<PointsCelebration>());
    expect((store.celebrationData! as PointsCelebration).amount, 12);

    final Achievement badge = store.badges.first;
    store.showBadgeUnlock(badge);
    expect(store.celebrationData, isA<BadgeUnlockCelebration>());
    expect((store.celebrationData! as BadgeUnlockCelebration).badge, badge);

    store.showLevelUp('Seedling', 1);
    expect(store.celebrationData, isA<LevelUpCelebration>());
    expect((store.celebrationData! as LevelUpCelebration).idx, 1);

    store.showChallengeComplete('Walk more', 20);
    expect(store.celebrationData, isA<ChallengeCompleteCelebration>());
    expect(
      (store.celebrationData! as ChallengeCompleteCelebration).points,
      20,
    );
  });

  test('activity options include clear electricity and food variants', () {
    expect(activityDef('home')?.name, 'Electricity from bill');
    expect(
        actsOf(CarbonCategory.electricity)
            .map((ActivityDef activity) => activity.key),
        containsAll(
            <String>['fan', 'lighting', 'laptop', 'laundry', 'charging']));
    expect(activityDef('appliance'), isNull);
    expect(
      actsOf(CarbonCategory.food).map((ActivityDef activity) => activity.key),
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
    store.pickCat(CarbonCategory.food);
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
    store.pickCat(CarbonCategory.electricity);
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
    store.pickCat(CarbonCategory.food);
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

    store.go(AppRoute.tips);
    store.tryTip('t2');
    expect(store.route, AppRoute.add);
    expect(store.addStep, store.amountStep);

    store.addBack();
    expect(store.route, AppRoute.tips);
  });

  test('food tips select a preparation before opening amount entry', () {
    final EcoStore store = EcoStore();
    addTearDown(store.dispose);

    store.go(AppRoute.tips);
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
}
