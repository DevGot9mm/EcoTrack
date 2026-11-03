import 'dart:math' as math;

import 'package:flutter/material.dart' hide Badge;

import 'theme.dart';

/* ==========================================================================
   Domain data — honest, plausible illustrative estimates.
   ========================================================================== */

/// Resolved category colors — tint and ink adapt to light/dark brightness.
class CatColors {
  const CatColors({required this.tint, required this.ink});
  final Color tint;
  final Color ink;
}

class Cat {
  const Cat({
    required this.id,
    required this.name,
    required this.blurb,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final String blurb;
  final Color color;
  final String icon;

  CatColors resolve(ColorScheme cs, {Color? color}) {
    if (color != null) {
      final Color tint = Color.alphaBlend(
        color.withValues(alpha: cs.brightness == Brightness.dark ? 0.24 : 0.12),
        cs.surface,
      );
      final Color ink = cs.brightness == Brightness.dark
          ? Color.lerp(color, Colors.white, 0.28)!
          : Color.lerp(color, Colors.black, 0.3)!;
      return CatColors(tint: tint, ink: ink);
    }

    final bool dark = cs.brightness == Brightness.dark;
    switch (id) {
      case 'transport':
        return CatColors(
          tint: dark ? cs.transportTint : const Color(0xFFE3F0F1),
          ink: dark ? cs.transportInk : const Color(0xFF2A5F68),
        );
      case 'electricity':
        return CatColors(
          tint: dark ? cs.electricityTint : const Color(0xFFFBF0DA),
          ink: dark ? cs.electricityInk : const Color(0xFF7F5606),
        );
      case 'food':
        return CatColors(
          tint: dark ? cs.foodTint : const Color(0xFFEDF4DE),
          ink: dark ? cs.foodInk : const Color(0xFF546D2C),
        );
    }
    return const CatColors(tint: Color(0xFFE3F0F1), ink: Color(0xFF2A5F68));
  }
}

const Map<String, Cat> kCats = <String, Cat>{
  'transport': Cat(
    id: 'transport',
    name: 'Transport',
    blurb: 'Getting around',
    color: Eco.transport,
    icon: 'bus',
  ),
  'electricity': Cat(
    id: 'electricity',
    name: 'Electricity',
    blurb: 'Power at home',
    color: Eco.electricity,
    icon: 'bolt',
  ),
  'food': Cat(
    id: 'food',
    name: 'Food',
    blurb: 'What you eat',
    color: Eco.food,
    icon: 'sprout',
  ),
};

const List<String> kCatOrder = <String>['transport', 'electricity', 'food'];

Cat catOf(String id) => kCats[id] ?? kCats['transport']!;

class ActivityDef {
  const ActivityDef({
    required this.key,
    required this.cat,
    required this.name,
    required this.unit,
    required this.factor,
    required this.step,
    required this.max,
    required this.chips,
    required this.icon,
    this.detail,
  });

  final String key;
  final String cat;
  final String name;
  final String unit;

  /// kg CO2e per unit.
  final double factor;
  final double step;
  final double max;
  final List<double> chips;
  final String icon;
  final String? detail;
}

class FoodPreparation {
  const FoodPreparation({
    required this.id,
    required this.name,
    required this.icon,
    required this.multiplier,
    required this.detail,
  });

  final String id;
  final String name;
  final String icon;
  final double multiplier;
  final String detail;
}

const List<FoodPreparation> kFoodPreparations = <FoodPreparation>[
  FoodPreparation(
    id: 'grilled',
    name: 'Grilled or roasted',
    icon: 'grill',
    multiplier: 1,
    detail: 'Dry-heat cooking; the ingredient remains the main source.',
  ),
  FoodPreparation(
    id: 'fried',
    name: 'Fried',
    icon: 'fry',
    multiplier: 1.08,
    detail: 'A small cooking estimate is added for oil and extra heat.',
  ),
  FoodPreparation(
    id: 'steamed',
    name: 'Boiled or steamed',
    icon: 'steam',
    multiplier: 0.96,
    detail: 'A lower-energy cooking estimate for a similar serving.',
  ),
  FoodPreparation(
    id: 'stir_fried',
    name: 'Stir-fried',
    icon: 'stirFry',
    multiplier: 1.04,
    detail: 'A small estimate is added for oil and cooking heat.',
  ),
  FoodPreparation(
    id: 'raw',
    name: 'Raw (sushi or sashimi)',
    icon: 'sushi',
    multiplier: 0.94,
    detail:
        'For raw fish dishes; fish sourcing and portion remain the main factors.',
  ),
];

List<FoodPreparation> foodPreparationOptions(String foodKey) =>
    <FoodPreparation>[
      ...kFoodPreparations.where(
        (FoodPreparation preparation) =>
            preparation.id != 'raw' || foodKey == 'fish',
      ),
    ];

const List<ActivityDef> kActivities = <ActivityDef>[
  ActivityDef(
      key: 'car',
      cat: 'transport',
      name: 'Car',
      unit: 'km',
      factor: 0.192,
      step: 5,
      max: 200,
      chips: <double>[5, 15, 40],
      icon: 'car'),
  ActivityDef(
      key: 'carpool',
      cat: 'transport',
      name: 'Shared car',
      unit: 'km',
      factor: 0.096,
      step: 5,
      max: 200,
      chips: <double>[5, 15, 40],
      icon: 'car',
      detail: 'Per passenger; assumes two people share a petrol car.'),
  ActivityDef(
      key: 'taxi',
      cat: 'transport',
      name: 'Taxi or rideshare',
      unit: 'km',
      factor: 0.192,
      step: 5,
      max: 200,
      chips: <double>[5, 15, 40],
      icon: 'car',
      detail: 'A typical occupied-car estimate per passenger kilometre.'),
  ActivityDef(
      key: 'electric_car',
      cat: 'transport',
      name: 'Electric car',
      unit: 'km',
      factor: 0.06,
      step: 5,
      max: 200,
      chips: <double>[5, 15, 40],
      icon: 'car',
      detail:
          'Use-phase estimate; actual emissions depend on your power grid.'),
  ActivityDef(
      key: 'motorcycle',
      cat: 'transport',
      name: 'Motorcycle',
      unit: 'km',
      factor: 0.103,
      step: 5,
      max: 200,
      chips: <double>[5, 15, 40],
      icon: 'motorcycle'),
  ActivityDef(
      key: 'bus',
      cat: 'transport',
      name: 'Bus',
      unit: 'km',
      factor: 0.082,
      step: 5,
      max: 200,
      chips: <double>[5, 15, 40],
      icon: 'bus'),
  ActivityDef(
      key: 'train',
      cat: 'transport',
      name: 'Train',
      unit: 'km',
      factor: 0.035,
      step: 5,
      max: 400,
      chips: <double>[5, 20, 60],
      icon: 'train',
      detail: 'A shared-rail estimate; route and occupancy can change it.'),
  ActivityDef(
      key: 'metro',
      cat: 'transport',
      name: 'Metro or subway',
      unit: 'km',
      factor: 0.035,
      step: 5,
      max: 200,
      chips: <double>[5, 15, 40],
      icon: 'train',
      detail: 'A typical shared-rail estimate per passenger kilometre.'),
  ActivityDef(
      key: 'bicycle',
      cat: 'transport',
      name: 'Bicycle',
      unit: 'km',
      factor: 0,
      step: 1,
      max: 60,
      chips: <double>[1, 5, 10],
      icon: 'bike',
      detail: 'Counts direct travel emissions, not equipment manufacturing.'),
  ActivityDef(
      key: 'walking',
      cat: 'transport',
      name: 'Walking',
      unit: 'km',
      factor: 0,
      step: 1,
      max: 30,
      chips: <double>[1, 3, 5],
      icon: 'walk',
      detail: 'No direct travel emissions.'),
  ActivityDef(
      key: 'home',
      cat: 'electricity',
      name: 'Electricity from bill',
      unit: 'kWh',
      factor: 0.72,
      step: 1,
      max: 40,
      chips: <double>[2, 5, 10],
      icon: 'bolt',
      detail: 'Enter kWh from your bill or meter; no conversion is needed.'),
  ActivityDef(
      key: 'ac',
      cat: 'electricity',
      name: 'Air conditioner (AC)',
      unit: 'hours',
      factor: 0.62,
      step: 1,
      max: 18,
      chips: <double>[1, 3, 8],
      icon: 'air',
      detail: 'Uses a typical 0.86 kW AC estimate; real units vary widely.'),
  ActivityDef(
      key: 'charging',
      cat: 'electricity',
      name: 'Phone or tablet charging',
      unit: 'hours',
      factor: 0.012,
      step: 1,
      max: 24,
      chips: <double>[1, 3, 6],
      icon: 'plug',
      detail: 'Typical 15 W charger estimate; actual devices vary.'),
  ActivityDef(
      key: 'fan',
      cat: 'electricity',
      name: 'Electric fan',
      unit: 'hours',
      factor: 0.036,
      step: 1,
      max: 24,
      chips: <double>[1, 4, 8],
      icon: 'plug',
      detail: 'Typical 50 W fan estimate, not a meter reading.'),
  ActivityDef(
      key: 'lighting',
      cat: 'electricity',
      name: 'LED light',
      unit: 'hours',
      factor: 0.007,
      step: 1,
      max: 24,
      chips: <double>[1, 4, 8],
      icon: 'sun',
      detail: 'Assumes one 10 W LED bulb.'),
  ActivityDef(
      key: 'laptop',
      cat: 'electricity',
      name: 'Laptop',
      unit: 'hours',
      factor: 0.04,
      step: 1,
      max: 24,
      chips: <double>[1, 4, 8],
      icon: 'laptop',
      detail: 'Typical 55 W laptop estimate while in use.'),
  ActivityDef(
      key: 'desktop',
      cat: 'electricity',
      name: 'Desktop computer',
      unit: 'hours',
      factor: 0.18,
      step: 1,
      max: 24,
      chips: <double>[1, 4, 8],
      icon: 'desktop',
      detail: 'Typical 250 W desktop estimate; gaming systems can use more.'),
  ActivityDef(
      key: 'television',
      cat: 'electricity',
      name: 'Television',
      unit: 'hours',
      factor: 0.07,
      step: 1,
      max: 24,
      chips: <double>[1, 3, 6],
      icon: 'television',
      detail: 'Typical 100 W television estimate.'),
  ActivityDef(
      key: 'laundry',
      cat: 'electricity',
      name: 'Washing machine',
      unit: 'loads',
      factor: 0.36,
      step: 1,
      max: 8,
      chips: <double>[1, 2, 4],
      icon: 'washingMachine',
      detail: 'Typical wash-cycle estimate; hot-water cycles use more.'),
  ActivityDef(
      key: 'refrigerator',
      cat: 'electricity',
      name: 'Refrigerator',
      unit: 'days',
      factor: 0.72,
      step: 1,
      max: 30,
      chips: <double>[1, 3, 7],
      icon: 'refrigerator',
      detail:
          'Typical daily estimate for an efficient fridge; older models vary.'),
  ActivityDef(
      key: 'beef',
      cat: 'food',
      name: 'Beef & steak',
      unit: 'servings',
      factor: 4.0,
      step: 1,
      max: 6,
      chips: <double>[1, 2, 3],
      icon: 'cow',
      detail: 'Estimate for a 150 g cooked serving; sides are not included.'),
  ActivityDef(
      key: 'chicken',
      cat: 'food',
      name: 'Chicken & poultry',
      unit: 'servings',
      factor: 1.6,
      step: 1,
      max: 6,
      chips: <double>[1, 2, 3],
      icon: 'chicken',
      detail:
          'Includes chicken or duck; estimate for one 150 g cooked serving.'),
  ActivityDef(
      key: 'pork_lamb',
      cat: 'food',
      name: 'Pork & lamb',
      unit: 'servings',
      factor: 2.8,
      step: 1,
      max: 6,
      chips: <double>[1, 2, 3],
      icon: 'pig',
      detail: 'Includes pork or lamb; estimate for one 150 g cooked serving.'),
  ActivityDef(
      key: 'fish',
      cat: 'food',
      name: 'Fish & seafood',
      unit: 'servings',
      factor: 1.1,
      step: 1,
      max: 6,
      chips: <double>[1, 2, 3],
      icon: 'fish',
      detail:
          'Estimate for a 150 g cooked serving; species can change the total.'),
  ActivityDef(
      key: 'dairy',
      cat: 'food',
      name: 'Dairy & eggs',
      unit: 'servings',
      factor: 1.0,
      step: 1,
      max: 6,
      chips: <double>[1, 2, 3],
      icon: 'egg',
      detail:
          'Includes milk, cheese or eggs; estimate for one typical serving.'),
  ActivityDef(
      key: 'rice_grains',
      cat: 'food',
      name: 'Rice & grains',
      unit: 'servings',
      factor: 0.8,
      step: 1,
      max: 6,
      chips: <double>[1, 2, 3],
      icon: 'grains',
      detail:
          'Includes rice, noodles or bread; estimate for one prepared serving.'),
  ActivityDef(
      key: 'plant_protein',
      cat: 'food',
      name: 'Plant-based protein',
      unit: 'servings',
      factor: 0.6,
      step: 1,
      max: 6,
      chips: <double>[1, 2, 3],
      icon: 'tofu',
      detail:
          'Includes tofu, tempeh or beans; estimate for one typical serving.'),
  ActivityDef(
      key: 'fruits_vegetables',
      cat: 'food',
      name: 'Fruits & vegetables',
      unit: 'servings',
      factor: 0.5,
      step: 1,
      max: 6,
      chips: <double>[1, 2, 3],
      icon: 'produce',
      detail:
          'A typical fresh-produce serving; growing methods and season vary.'),
  ActivityDef(
      key: 'vegetarian',
      cat: 'food',
      name: 'Vegetarian meal',
      unit: 'servings',
      factor: 0.7,
      step: 1,
      max: 6,
      chips: <double>[1, 2, 3],
      icon: 'leaf',
      detail:
          'A mixed vegetarian dish; ingredients and portion sizes can vary.'),
  ActivityDef(
      key: 'vegan',
      cat: 'food',
      name: 'Vegan meal',
      unit: 'servings',
      factor: 0.45,
      step: 1,
      max: 6,
      chips: <double>[1, 2, 3],
      icon: 'sprout',
      detail:
          'A fully plant-based meal; ingredients and portion sizes can vary.'),
];

final List<ActivityDef> kFoodVariants = List<ActivityDef>.unmodifiable(
  <ActivityDef>[
    for (final ActivityDef food in kActivities.where(
      (ActivityDef activity) => activity.cat == 'food',
    ))
      for (final FoodPreparation preparation
          in foodPreparationOptions(food.key))
        ActivityDef(
          key: '${food.key}_${preparation.id}',
          cat: 'food',
          name: '${food.name} · ${preparation.name.toLowerCase()}',
          unit: food.unit,
          factor: food.factor * preparation.multiplier,
          step: food.step,
          max: food.max,
          chips: food.chips,
          icon: preparation.icon,
          detail: preparation.detail,
        ),
  ],
);

ActivityDef? activityDef(String key) {
  for (final ActivityDef a in kActivities) {
    if (a.key == key) return a;
  }
  for (final ActivityDef a in kFoodVariants) {
    if (a.key == key) return a;
  }
  return null;
}

List<ActivityDef> actsOf(String cat) =>
    kActivities.where((ActivityDef a) => a.cat == cat).toList();

List<ActivityDef> foodPreparationsOf(String foodKey) => kFoodVariants
    .where((ActivityDef activity) => activity.key.startsWith('${foodKey}_'))
    .toList();

class Tip {
  const Tip({
    required this.id,
    required this.cat,
    required this.icon,
    required this.title,
    required this.action,
    required this.why,
    required this.ctaKey,
    required this.ctaAmount,
  });

  final String id;
  final String cat;
  final String icon;
  final String title;
  final String action;
  final String why;
  final String ctaKey;
  final double ctaAmount;
}

const List<Tip> kTips = <Tip>[
  Tip(
      id: 't1',
      cat: 'transport',
      icon: 'walk',
      title: 'Walk trips under 2 km',
      action: 'Leave the bike helmet at home for short errands.',
      why:
          'Trips under 2 km are the easiest to replace — and they are the ones where a cold engine burns the most fuel per kilometre.',
      ctaKey: 'walking',
      ctaAmount: 2),
  Tip(
      id: 't2',
      cat: 'electricity',
      icon: 'air',
      title: 'Set the AC to 25°C',
      action: 'Each degree warmer cuts roughly 6% of its power draw.',
      why:
          'Cooling is usually the single biggest load in a home. One degree is invisible to your comfort and visible on your footprint.',
      ctaKey: 'ac',
      ctaAmount: 3),
  Tip(
      id: 't3',
      cat: 'food',
      icon: 'leaf',
      title: 'Swap one beef meal a week',
      action: 'Try a vegetarian dish on the day you would have had beef.',
      why:
          'A beef dish carries roughly six times the emissions of a vegetarian one. One swap a week is a real dent.',
      ctaKey: 'vegetarian',
      ctaAmount: 1),
  Tip(
      id: 't4',
      cat: 'electricity',
      icon: 'plug',
      title: 'Unplug chargers when idle',
      action: 'Unplug your phone charger once the device is full.',
      why:
          'A charger draws little power, but unplugging it is a simple way to avoid unnecessary standby use.',
      ctaKey: 'charging',
      ctaAmount: 1),
  Tip(
      id: 't5',
      cat: 'transport',
      icon: 'bus',
      title: 'Take the bus once a week',
      action: 'Pick your longest regular drive and ride it instead.',
      why:
          'A bus spreads its emissions across everyone aboard, so your share of a full bus is a fraction of a solo car trip.',
      ctaKey: 'bus',
      ctaAmount: 15),
  Tip(
      id: 't6',
      cat: 'food',
      icon: 'sprout',
      title: 'Eat what you buy',
      action: 'Plan two meals around what is already in the fridge.',
      why:
          'Food that is grown, shipped and then thrown away carries all of its emissions and returns none of the nutrition.',
      ctaKey: 'vegan',
      ctaAmount: 1),
  Tip(
      id: 't7',
      cat: 'electricity',
      icon: 'refresh',
      title: 'Air-dry your laundry',
      action: 'Skip the dryer on the next sunny day.',
      why:
          'A tumble dryer is one of the hungriest appliances per cycle — a line costs nothing and produces nothing.',
      ctaKey: 'home',
      ctaAmount: 3),
  Tip(
      id: 't8',
      cat: 'transport',
      icon: 'bike',
      title: 'Cycle the short hop',
      action: 'Replace one short ride with pedal power.',
      why:
          'Cycling is genuinely zero-emission in use, and it replaces the trips where a car is least efficient.',
      ctaKey: 'bicycle',
      ctaAmount: 5),
  Tip(
      id: 't9',
      cat: 'food',
      icon: 'grains',
      title: 'Try rice or noodles as the main',
      action: 'Build one meal around grains with vegetables or beans.',
      why:
          'Grains are usually a lower-emission base than a large serving of beef, especially when paired with plant proteins.',
      ctaKey: 'rice_grains',
      ctaAmount: 1),
  Tip(
      id: 't10',
      cat: 'food',
      icon: 'tofu',
      title: 'Add beans or tofu',
      action: 'Replace one meat portion with beans, tofu or tempeh.',
      why:
          'Plant proteins provide satisfying alternatives with generally lower food-related emissions than meat.',
      ctaKey: 'plant_protein',
      ctaAmount: 1),
  Tip(
      id: 't11',
      cat: 'food',
      icon: 'produce',
      title: 'Choose seasonal produce',
      action: 'Add a serving of fresh fruit or vegetables to a meal.',
      why:
          'Seasonal produce can avoid some of the energy and transport associated with out-of-season options.',
      ctaKey: 'fruits_vegetables',
      ctaAmount: 1),
  Tip(
      id: 't12',
      cat: 'food',
      icon: 'produce',
      title: 'Choose a less-packaged snack',
      action: 'Try fruit, nuts or another minimally packaged option.',
      why:
          'Choosing less-packaged snacks can reduce packaging waste and make it easier to plan portions.',
      ctaKey: 'fruits_vegetables',
      ctaAmount: 1),
];

Tip? tipOf(String id) {
  for (final Tip t in kTips) {
    if (t.id == id) return t;
  }
  return null;
}

/// Challenge state machine: active → claimable → claimed.
enum ChallengeState { active, claimable, claimed }

class Challenge {
  Challenge({
    required this.id,
    required this.cat,
    required this.title,
    required this.why,
    required this.reward,
    required this.target,
    required this.progress,
    required this.state,
    this.featured = false,
    this.mascot = 'face-excited',
  });

  final String id;
  final String cat;
  final String title;
  final String why;
  final int reward;
  final double target;
  double progress;
  ChallengeState state;
  final bool featured;
  final String mascot;
}

String challengeWeekKey(DateTime date) {
  final DateTime monday =
      DateTime(date.year, date.month, date.day - date.weekday + 1);
  return '${monday.year}-${monday.month}-${monday.day}';
}

List<Challenge> seedChallenges({DateTime? now}) {
  final List<Challenge> pool = <Challenge>[
    Challenge(
      id: 'c1',
      cat: 'transport',
      title: 'Legs before engine',
      why: 'Choose walking or cycling for one short trip today.',
      reward: 30,
      target: 1,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-excited',
    ),
    Challenge(
      id: 'c2',
      cat: 'electricity',
      title: 'Lights off when you leave',
      why: 'Switch off unused lights once a day for three days in a row.',
      reward: 20,
      target: 3,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-annoyed',
    ),
    Challenge(
      id: 'c3',
      cat: 'food',
      title: 'Meat-free for a meal',
      why: 'Choose one plant-forward meal today.',
      reward: 25,
      target: 1,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-happy',
    ),
    Challenge(
      id: 'c4',
      cat: 'electricity',
      title: 'Unplug before bed',
      why: 'Switch off one idle device each night for three nights in a row.',
      reward: 20,
      target: 3,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-curious',
    ),
    Challenge(
      id: 'c5',
      cat: 'transport',
      title: 'Ride the bus once',
      why: 'Replace one car trip with public transport this week.',
      reward: 25,
      target: 1,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-excited',
    ),
    Challenge(
      id: 'c6',
      cat: 'electricity',
      title: 'Cooler by one degree',
      why: 'Set your AC a little warmer for three days in a row.',
      reward: 25,
      target: 3,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-happy',
    ),
    Challenge(
      id: 'c7',
      cat: 'food',
      title: 'Plan a leftovers meal',
      why: 'Use food you already have for one meal this week.',
      reward: 20,
      target: 1,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-curious',
    ),
    Challenge(
      id: 'c8',
      cat: 'transport',
      title: 'Cycle a short trip',
      why: 'Use a bicycle instead of a motor vehicle once this week.',
      reward: 25,
      target: 1,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-excited',
    ),
    Challenge(
      id: 'c9',
      cat: 'electricity',
      title: 'Air-dry a load',
      why: 'Skip the tumble dryer for one laundry load this week.',
      reward: 20,
      target: 1,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-calm',
    ),
    Challenge(
      id: 'c10',
      cat: 'food',
      title: 'Try a plant-based lunch',
      why: 'Choose a vegan lunch once this week.',
      reward: 25,
      target: 1,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-happy',
    ),
    Challenge(
      id: 'c11',
      cat: 'transport',
      title: 'Share the ride',
      why: 'Carpool or share a rideshare for one trip this week.',
      reward: 20,
      target: 1,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-curious',
    ),
    Challenge(
      id: 'c12',
      cat: 'electricity',
      title: 'Use daylight',
      why: 'Leave a light off while daylight is enough, three days in a row.',
      reward: 20,
      target: 3,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-happy',
    ),
    Challenge(
      id: 'c13',
      cat: 'food',
      title: 'Make two meat-free meals',
      why: 'Choose two plant-forward meals on separate days this week.',
      reward: 30,
      target: 2,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-annoyed',
    ),
    Challenge(
      id: 'c14',
      cat: 'transport',
      title: 'Choose the train',
      why: 'Take a train or metro for one journey this week.',
      reward: 25,
      target: 1,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-happy',
    ),
    Challenge(
      id: 'c15',
      cat: 'electricity',
      title: 'A lower-energy wash',
      why: 'Choose a cool wash cycle twice this week.',
      reward: 25,
      target: 2,
      progress: 0,
      state: ChallengeState.active,
      mascot: 'face-curious',
    ),
  ];
  final String key = challengeWeekKey(now ?? DateTime.now());
  final int seed = key.codeUnits.fold<int>(
    0,
    (int value, int unit) => value * 31 + unit,
  );
  pool.shuffle(math.Random(seed));
  final List<Challenge> selected = pool.take(5).toList();
  final int multiDayIndex = selected.indexWhere(
    (Challenge challenge) => challenge.target >= 3,
  );
  if (multiDayIndex < 0) {
    selected[4] =
        pool.skip(5).firstWhere((Challenge challenge) => challenge.target >= 3);
  } else if (multiDayIndex == 0) {
    final Challenge featured = selected[0];
    selected[0] = selected[4];
    selected[4] = featured;
  }
  return <Challenge>[
    for (int i = 0; i < selected.length; i++)
      Challenge(
        id: selected[i].id,
        cat: selected[i].cat,
        title: selected[i].title,
        why: selected[i].why,
        reward: selected[i].reward,
        target: selected[i].target,
        progress: 0,
        state: ChallengeState.active,
        featured: i == 0,
        mascot: selected[i].mascot,
      ),
  ];
}

class Badge {
  Badge({
    required this.id,
    required this.icon,
    required this.name,
    required this.desc,
    required this.unlocked,
    required this.progress,
    required this.target,
  });

  final String id;
  final String icon;
  final String name;
  final String desc;
  bool unlocked;
  double progress;
  final double target;
}

List<Badge> seedBadges() => <Badge>[
      Badge(
        id: 'b1',
        icon: 'sprout',
        name: 'First step',
        desc: 'Log your very first activity',
        unlocked: false,
        progress: 0,
        target: 1,
      ),
      Badge(
        id: 'b2',
        icon: 'flame',
        name: 'Week streak',
        desc: 'Open EcoTrack seven days in a row',
        unlocked: false,
        progress: 0,
        target: 7,
      ),
      Badge(
        id: 'b3',
        icon: 'leaf',
        name: 'Green chef',
        desc: 'Log five plant-based meals',
        unlocked: false,
        progress: 0,
        target: 5,
      ),
      Badge(
        id: 'b4',
        icon: 'bus',
        name: 'Transit regular',
        desc: 'Take the bus or train ten times',
        unlocked: false,
        progress: 0,
        target: 10,
      ),
      Badge(
        id: 'b5',
        icon: 'bike',
        name: 'Cyclist',
        desc: 'Cycle 25 km in total',
        unlocked: false,
        progress: 0,
        target: 25,
      ),
      Badge(
        id: 'b6',
        icon: 'bolt',
        name: 'Energy mindful',
        desc: 'Log ten electricity activities',
        unlocked: false,
        progress: 0,
        target: 10,
      ),
      Badge(
        id: 'b7',
        icon: 'flag',
        name: 'Challenger',
        desc: 'Complete five weekly challenges',
        unlocked: false,
        progress: 0,
        target: 5,
      ),
      Badge(
        id: 'b8',
        icon: 'trophy',
        name: 'Tree planter',
        desc: 'Reach 2,000 Eco Points',
        unlocked: false,
        progress: 0,
        target: 2000,
      ),
      Badge(
        id: 'b9',
        icon: 'walk',
        name: 'Low-carbon commute',
        desc: 'Log five walking or cycling trips',
        unlocked: false,
        progress: 0,
        target: 5,
      ),
      Badge(
        id: 'b10',
        icon: 'food',
        name: 'Mindful meals',
        desc: 'Log ten meals',
        unlocked: false,
        progress: 0,
        target: 10,
      ),
      Badge(
        id: 'b11',
        icon: 'plus',
        name: 'Your own footprint',
        desc: 'Log three custom activities',
        unlocked: false,
        progress: 0,
        target: 3,
      ),
      Badge(
        id: 'b12',
        icon: 'chart',
        name: 'Well-rounded',
        desc: 'Log an activity from every carbon category',
        unlocked: false,
        progress: 0,
        target: 3,
      ),
      Badge(
        id: 'b13',
        icon: 'bookmark',
        name: 'Tip collector',
        desc: 'Save five Eco Tips',
        unlocked: false,
        progress: 0,
        target: 5,
      ),
    ];

class Level {
  const Level(this.min, this.name);
  final int min;
  final String name;
}

const List<Level> kLevels = <Level>[
  Level(0, 'Seedling'),
  Level(300, 'Sprout'),
  Level(700, 'Sapling'),
  Level(1200, 'Green Guardian'),
  Level(1800, 'Canopy Keeper'),
];

class LevelInfo {
  const LevelInfo({
    required this.idx,
    required this.name,
    required this.pct,
    required this.toNext,
    required this.nextName,
  });

  final int idx;
  final String name;
  final int pct;
  final int toNext;
  final String? nextName;
}

LevelInfo levelOf(int points) {
  int idx = 0;
  for (int i = 0; i < kLevels.length; i++) {
    if (points >= kLevels[i].min) idx = i;
  }
  final Level? next = (idx + 1 < kLevels.length) ? kLevels[idx + 1] : null;
  final int from = kLevels[idx].min;
  final int to = next?.min ?? from + 600;
  final int pct = clampInt(
    (((points - from) / (to - from)) * 100).round(),
    0,
    100,
  );
  return LevelInfo(
    idx: idx,
    name: kLevels[idx].name,
    pct: pct,
    toNext: next != null ? to - points : 0,
    nextName: next?.name,
  );
}

/// A logged entry.
class Entry {
  const Entry({
    required this.id,
    required this.key,
    required this.cat,
    required this.amount,
    required this.co2,
    required this.at,
  });

  final String id;
  final String key;
  final String cat;
  final double amount;
  final double co2;
  final DateTime at;
}

/* ==========================================================================
   Formatting helpers — no third-party intl dependency.
   ========================================================================== */

const List<String> _weekdayLong = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _weekdayShort = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> _monthLong = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _monthShort = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

double round1(double n) => (n * 10).roundToDouble() / 10;

int clampInt(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);

double clampDouble(double v, double lo, double hi) =>
    v < lo ? lo : (v > hi ? hi : v);

String fmt1(double n) => n.toStringAsFixed(1);

String fmt2(double n) => n.toStringAsFixed(2);

/// Amounts read as `4` or `2.5`, never `4.0`.
String fmtAmount(double n) =>
    n == n.roundToDouble() ? n.toInt().toString() : n.toString();

String kgText(double n) => '${fmt1(n)} kg';

String amountLabel(ActivityDef a, double v) => '${fmtAmount(v)} ${a.unit}';

String groupThousands(int n) {
  final String s = n.abs().toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}$out';
}

String longDate(DateTime d) =>
    '${_weekdayLong[d.weekday - 1]} ${d.day} ${_monthLong[d.month - 1]}';

String weekdayShort(DateTime d) => _weekdayShort[d.weekday - 1];

String dayLabelShort(DateTime d) =>
    '${_weekdayShort[d.weekday - 1]} ${d.day} ${_monthShort[d.month - 1]}';

String timeLabel(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Whole days between two calendar dates, immune to DST shifts.
int _dayNumber(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

int daysAgo(DateTime ts) => _dayNumber(DateTime.now()) - _dayNumber(ts);

/// The calendar date `index` days before today. Day arithmetic (rather than
/// adding a Duration) keeps this correct across daylight-saving boundaries.
DateTime dayAgo(int index) {
  final DateTime n = DateTime.now();
  return DateTime(n.year, n.month, n.day - index);
}

/// Day bucket label used by History: Today / Yesterday / Tue 22 Sep.
String dayLabel(int index) {
  if (index == 0) return 'Today';
  if (index == 1) return 'Yesterday';
  return dayLabelShort(dayAgo(index));
}
