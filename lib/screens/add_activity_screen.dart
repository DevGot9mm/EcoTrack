import 'package:flutter/material.dart';

import '../core/icons.dart';
import '../models/models.dart';
import '../core/responsive.dart';
import '../state/store.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';

class AddActivityScreen extends StatelessWidget {
  const AddActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final int step = store.addStep;

    final bool amountStep = step == store.amountStep;
    final String title = step == 0
        ? 'What did you do?'
        : step == 1
            ? store.isFoodFlow
                ? 'What was in the meal?'
                : 'Pick the activity'
            : amountStep
                ? 'How much?'
                : 'How was it cooked?';
    final String sub = step == 0
        ? 'Everything counts — pick the closest match.'
        : step == 1
            ? store.isFoodFlow
                ? 'Choose the main food. You can refine the preparation next.'
                : 'Pick what best matches. We show a simple estimate for each.'
            : amountStep
                ? 'Drag or use the buttons. You can fine-tune later.'
                : 'Cooking changes the estimate a little; ingredients matter more.';

    final bool canContinue = step == 0
        ? store.addCat != null
        : step == 1
            ? store.isFoodFlow
                ? store.addFoodType != null
                : store.addKey != null
            : store.isFoodFlow && !amountStep
                ? store.addKey != null
                : true;

    return EcoScreen(
      header: _StepHeader(
        step: step,
        stepCount: store.stepCount,
        onBack: store.addBack,
      ),
      padding: const EdgeInsets.fromLTRB(Eco.s20, 0, Eco.s20, 28),
      footer: FlowFooter(
        children: <Widget>[
          if (amountStep)
            EcoButton(
              label: 'Save activity',
              leading: 'check',
              block: true,
              onPressed: store.saveActivity,
            )
          else
            EcoButton(
              label: 'Continue',
              trailing: 'arrowRight',
              block: true,
              onPressed: canContinue ? store.addNext : null,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title,
              style: F.role(context.type.titleLarge!,
                  wght: 600, ls: -0.01, height: 1.2)),
          const SizedBox(height: Eco.s4),
          Text(sub,
              style: F.role(context.type.bodySmall!,
                  color: cs.muted, height: 1.45)),
          const SizedBox(height: 18),
          if (step == 0)
            _catStep(context, store)
          else if (step == 1)
            _actStep(context, store)
          else if (store.isFoodFlow && !amountStep)
            _foodPreparationStep(context, store)
          else
            _amountStep(store, cs),
        ],
      ),
    );
  }

  Widget _catStep(BuildContext context, EcoStore store) {
    final cs = Theme.of(context).colorScheme;
    final List<Widget> tiles = <Widget>[];
    for (final CarbonCategory id in kCatOrder) {
      final Cat c = catOf(id);
      final bool on = store.addCat == id;
      final int choiceCount = actsOf(id).length;
      tiles.add(
        EcoCard(
          flat: true,
          highlighted: on,
          padding: const EdgeInsets.all(17),
          onTap: () => store.pickCat(id),
          child: Row(
            children: <Widget>[
              CatBadge(
                icon: c.icon,
                background: c.resolve(cs, color: store.categoryColor(id)).tint,
                foreground: c.resolve(cs, color: store.categoryColor(id)).ink,
                size: 48,
                iconSize: 24,
                radius: 16,
              ),
              const SizedBox(width: Eco.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.name, style: F.d(18)),
                    const SizedBox(height: 2),
                    Text(
                      '${c.blurb} · '
                      '$choiceCount '
                      '${id == CarbonCategory.food ? 'meal types' : 'activities'}',
                      style: F.role(context.type.bodySmall!,
                          wght: 600, color: cs.muted),
                    ),
                  ],
                ),
              ),
              EcoIcon('chevronR', size: 20, color: cs.muted),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _stacked(tiles, 12),
    );
  }

  Widget _actStep(BuildContext context, EcoStore store) {
    final cs = Theme.of(context).colorScheme;
    final Cat c = catOf(store.addCat ?? kCatOrder.first);
    final List<Widget> tiles = <Widget>[];
    for (final ActivityDef a in actsOf(store.addCat ?? kCatOrder.first)) {
      final bool food = store.isFoodFlow;
      final bool on = food ? store.addFoodType == a.key : store.addKey == a.key;
      tiles.add(
        EcoCard(
          flat: true,
          highlighted: on,
          fillWidth: true,
          padding: const EdgeInsets.all(15),
          onTap: () => food ? store.pickFoodType(a.key) : store.pickAct(a.key),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CatBadge(
                icon: a.icon,
                background:
                    c.resolve(cs, color: store.categoryColor(c.id)).tint,
                foreground: c.resolve(cs, color: store.categoryColor(c.id)).ink,
                size: 44,
                iconSize: 22,
                radius: 15,
              ),
              const SizedBox(height: Eco.s8),
              Text(
                a.name,
                style:
                    F.role(context.type.bodyMedium!, wght: 800, height: 1.25),
              ),
              const SizedBox(height: Eco.s8),
              Text(
                a.factor == 0
                    ? 'Zero emission'
                    : food
                        ? 'From ${fmt2(a.factor)} kg CO₂e per serving'
                        : '${fmt2(store.displayFactor(a))} kg / ${store.unitFor(a)}',
                style: F.role(context.type.labelSmall!,
                    wght: 700, color: cs.muted),
              ),
              if (a.detail != null) ...<Widget>[
                const SizedBox(height: 5),
                Text(
                  a.detail!,
                  style: F.b(11.5, height: 1.35, color: cs.muted),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EcoGrid(
          items: tiles,
          columns: switch (context.windowSize) {
            WindowSize.compact => 2,
            WindowSize.medium => 3,
            WindowSize.expanded => 4,
          },
          gap: 12,
        ),
        const SizedBox(height: Eco.s12),
        _customActivityOption(
          context,
          store,
          title: store.isFoodFlow ? 'Other meal or food' : 'Other activity',
        ),
      ],
    );
  }

  Widget _foodPreparationStep(BuildContext context, EcoStore store) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String foodKey = store.addFoodType!;
    final ActivityDef food = store.activityOf(foodKey)!;
    final Cat category = catOf(CarbonCategory.food);
    final List<Widget> tiles = <Widget>[];
    for (final ActivityDef preparation in foodPreparationsOf(foodKey)) {
      final bool on = store.addKey == preparation.key;
      tiles.add(
        EcoCard(
          flat: true,
          highlighted: on,
          fillWidth: true,
          padding: const EdgeInsets.all(15),
          onTap: () => store.pickAct(preparation.key),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CatBadge(
                icon: preparation.icon,
                background: category
                    .resolve(cs, color: store.categoryColor(category.id))
                    .tint,
                foreground: category
                    .resolve(cs, color: store.categoryColor(category.id))
                    .ink,
                size: 44,
                iconSize: 22,
                radius: 15,
              ),
              const SizedBox(height: Eco.s8),
              Text(
                preparation.name,
                style:
                    F.role(context.type.bodyMedium!, wght: 800, height: 1.25),
              ),
              const SizedBox(height: 5),
              Text(
                '${fmt2(preparation.factor)} kg CO₂e per serving',
                style: F.role(context.type.labelSmall!,
                    wght: 700, color: cs.muted),
              ),
              const SizedBox(height: 5),
              Text(
                preparation.detail ?? '',
                style: F.b(11.5, height: 1.35, color: cs.muted),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EcoCard(
          tone: EcoCardTone.mint,
          flat: true,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: Eco.s12),
          child: Row(
            children: <Widget>[
              CatBadge(
                icon: food.icon,
                background: category
                    .resolve(cs, color: store.categoryColor(category.id))
                    .tint,
                foreground: category
                    .resolve(cs, color: store.categoryColor(category.id))
                    .ink,
                size: 38,
                iconSize: 19,
                radius: 13,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  '${food.name}: cooking method adjusts the estimate modestly.',
                  style: F.role(context.type.labelMedium!,
                      color: cs.ink2, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Eco.s12),
        EcoGrid(
          items: tiles,
          columns: switch (context.windowSize) {
            WindowSize.compact => 2,
            WindowSize.medium => 3,
            WindowSize.expanded => 4,
          },
          gap: 12,
        ),
        const SizedBox(height: Eco.s12),
        _customActivityOption(
          context,
          store,
          title: 'Other preparation',
          suggestedName: '${food.name} — other preparation',
        ),
      ],
    );
  }

  Widget _customActivityOption(
    BuildContext context,
    EcoStore store, {
    required String title,
    String? suggestedName,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Cat category = catOf(store.addCat!);
    return EcoCard(
      flat: true,
      radius: Eco.rCard,
      padding: const EdgeInsets.all(14),
      onTap: () => showEcoSheet(
        context,
        _CustomActivityForm(
          store: store,
          suggestedName: suggestedName,
        ),
      ),
      child: Row(
        children: <Widget>[
          CatBadge(
            icon: 'plus',
            background: category
                .resolve(cs, color: store.categoryColor(category.id))
                .tint,
            foreground: category
                .resolve(cs, color: store.categoryColor(category.id))
                .ink,
            size: 40,
            iconSize: 20,
            radius: 14,
          ),
          const SizedBox(width: Eco.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: F.role(context.type.labelLarge!, wght: 800)),
                const SizedBox(height: 2),
                Text(
                  'Enter the activity and its total CO₂e estimate',
                  style: F.role(context.type.labelSmall!,
                      color: cs.muted, height: 1.35),
                ),
              ],
            ),
          ),
          EcoIcon('chevronR', size: 20, color: cs.muted),
        ],
      ),
    );
  }

  Widget _amountStep(EcoStore store, ColorScheme cs) {
    final ActivityDef a = store.activityOf(store.addKey!)!;
    final bool custom = store.isCustomActivity(a.key);
    final Cat c = catOf(a.cat);
    final double co2 = custom ? a.factor : round1(a.factor * store.addAmount);
    final double displayFactor = store.displayFactor(a);
    final String displayUnit = store.unitFor(a);
    final double displayAmount = store.displayAmount(a, store.addAmount);
    // The canonical minimum is 1 (serving / km). Convert it to the display
    // unit so the slider bounds stay valid when the user picks miles.
    final bool hasUnitMinimum =
        a.unit == 'servings' || (a.unit == 'km' && a.factor == 0);
    final double minAmount = hasUnitMinimum ? store.displayAmount(a, 1) : 0;
    final double maxAmount = store.displayMax(a);
    final double amountStep = store.displayStep(a);
    final bool zeroEmission = a.key == 'walking' || a.key == 'bicycle';

    final String mascot = co2 <= 0.5
        ? 'face-happy'
        : co2 <= 2
            ? 'face-curious'
            : 'face-surprised';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EcoCard(
          flat: true,
          child: Row(
            children: <Widget>[
              CatBadge(
                icon: a.icon,
                background:
                    c.resolve(cs, color: store.categoryColor(c.id)).tint,
                foreground: c.resolve(cs, color: store.categoryColor(c.id)).ink,
                size: 44,
                iconSize: 22,
                radius: 15,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(a.name, style: F.b(15, wght: 800)),
                    const SizedBox(height: 1),
                    Text(
                      custom
                          ? '${c.name} · manual total estimate'
                          : a.factor == 0
                              ? '${c.name} · zero emission'
                              : '${c.name} · ${fmt2(displayFactor)} kg CO₂e per $displayUnit',
                      style: F.b(13, height: 1.45, color: cs.muted),
                    ),
                    if (a.detail != null) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        a.detail!,
                        style: F.b(11.5, height: 1.35, color: cs.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    fmtAmount(displayAmount),
                    style: F.d(54, height: 1, ls: -0.03),
                  ),
                  const SizedBox(width: Eco.s8),
                  Text(
                    displayUnit,
                    style: F.b(16, wght: 800, color: cs.muted),
                  ),
                ],
              ),
              const SizedBox(height: Eco.s8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  zeroEmission
                      ? 'No emissions on the way — this one is pure bonus.'
                      : 'About ${fmt2(displayFactor)} kg CO₂e for every $displayUnit.',
                  textAlign: TextAlign.center,
                  style: F.b(13.5, wght: 600, color: cs.muted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (custom)
          EcoCard(
            flat: true,
            background: cs.surface2,
            child: Text(
              'Your estimate is for one logged activity. EcoTrack will use '
              'the total you entered without applying a preset factor.',
              style: F.b(13, height: 1.45, color: cs.muted),
            ),
          )
        else ...<Widget>[
          Row(
            children: <Widget>[
              _StepperBtn(icon: 'minus', onTap: () => store.amtStep(-1)),
              const SizedBox(width: 14),
              Expanded(
                child: Slider(
                  value: displayAmount.clamp(minAmount, maxAmount).toDouble(),
                  min: minAmount,
                  max: maxAmount,
                  divisions: ((maxAmount - minAmount) / amountStep)
                      .round()
                      .clamp(1, 1000)
                      .toInt(),
                  onChanged: store.amtSet,
                ),
              ),
              const SizedBox(width: 14),
              _StepperBtn(icon: 'plus', onTap: () => store.amtStep(1)),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final double v in store.displayChips(a))
                EcoChip(
                  label: '${fmtAmount(v)} $displayUnit',
                  active: v == displayAmount,
                  onTap: () => store.amtSet(v),
                ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        EcoCard(
          tone: EcoCardTone.mint,
          flat: true,
          padding:
              const EdgeInsets.symmetric(horizontal: Eco.s16, vertical: 15),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Estimated impact',
                        style: F.b(12.5, wght: 700, color: cs.muted)),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: fmt2(co2),
                            style: F.d(26, height: 1),
                          ),
                          TextSpan(
                            text: ' kg CO₂e',
                            style: F.b(12.5, wght: 800, color: cs.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              MascotArt(mascot, width: 52),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          custom
              ? 'You entered this total directly; EcoTrack applies no factor or quantity adjustment.'
              : 'This is a guide, not a meter reading. Actual impact varies with portion size, device efficiency, and your local electricity mix.',
          style: F.b(13, height: 1.45, color: cs.muted),
        ),
      ],
    );
  }
}

class _CustomActivityForm extends StatefulWidget {
  const _CustomActivityForm({
    required this.store,
    this.suggestedName,
  });

  final EcoStore store;
  final String? suggestedName;

  @override
  State<_CustomActivityForm> createState() => _CustomActivityFormState();
}

class _CustomActivityFormState extends State<_CustomActivityForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.suggestedName ?? '');
  final TextEditingController _co2e = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _co2e.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final double? total =
        double.tryParse(_co2e.text.trim().replaceAll(',', '.'));
    if (_name.text.trim().length < 2) {
      setState(() => _error = 'Enter a name with at least two characters.');
      return;
    }
    if (total == null || !total.isFinite || total < 0) {
      setState(() => _error = 'Enter a valid total of 0 or more kg CO₂e.');
      return;
    }
    widget.store.pickCustomActivity(_name.text, total);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Cat category = catOf(widget.store.addCat!);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SheetTitle(title: 'Add a custom activity'),
        const SizedBox(height: 6),
        Text(
          'We will not guess an emission factor. Enter the total CO₂e '
          'estimate for one occurrence.',
          style: F.role(context.type.bodySmall!, color: cs.muted, height: 1.45),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Activity name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _co2e,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Total emissions',
            suffixText: 'kg CO₂e',
          ),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: Eco.s8),
          Text(_error!,
              style: F.role(context.type.labelMedium!, color: cs.danger)),
        ],
        const SizedBox(height: 14),
        EcoCard(
          flat: true,
          tone: EcoCardTone.mint,
          padding: const EdgeInsets.all(Eco.s12),
          child: Row(
            children: <Widget>[
              CatBadge(
                icon: category.icon,
                background: category
                    .resolve(cs, color: widget.store.categoryColor(category.id))
                    .tint,
                foreground: category
                    .resolve(cs, color: widget.store.categoryColor(category.id))
                    .ink,
                size: 36,
                iconSize: 18,
                radius: 12,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Category: ${category.name} · one activity',
                  style: F.role(context.type.labelMedium!,
                      wght: 700, color: cs.ink2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        EcoButton(
          label: 'Use this estimate',
          leading: 'check',
          block: true,
          onPressed: () => _save(context),
        ),
      ],
    );
  }
}

List<Widget> _stacked(List<Widget> items, double gap) {
  final List<Widget> out = <Widget>[];
  for (int i = 0; i < items.length; i++) {
    if (i > 0) out.add(SizedBox(height: gap));
    out.add(items[i]);
  }
  return out;
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.stepCount,
    required this.onBack,
  });

  final int step;
  final int stepCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Eco.s20, 6, Eco.s20, Eco.s12),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              EcoIconButton(
                step == 0 ? 'close' : 'chevronL',
                onPressed: onBack,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Step ${step + 1} of $stepCount',
                    style: F.role(context.type.bodySmall!,
                        wght: 800, color: cs.muted),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: Eco.s12),
          Row(
            children: <Widget>[
              for (int i = 0; i < stepCount; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: AnimatedContainer(
                    duration: Eco.dur2,
                    curve: Eco.easeOut,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step ? cs.leaf : cs.lineStrong,
                      borderRadius: BorderRadius.circular(Eco.rPill),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      scale: 0.93,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.surface,
          shape: BoxShape.circle,
          border: Border.all(color: cs.lineStrong, width: 1.5),
        ),
        child: EcoIcon(icon, size: 22, color: cs.leaf),
      ),
    );
  }
}
