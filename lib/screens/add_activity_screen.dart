import 'package:flutter/material.dart';

import '../icons.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AddActivityScreen extends StatelessWidget {
  const AddActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final int step = store.addStep;

    final String title = step == 0
        ? 'What did you do?'
        : step == 1
            ? 'Pick the activity'
            : 'How much?';
    final String sub = step == 0
        ? 'Everything counts — pick the closest match.'
        : step == 1
            ? 'Tap the activity that fits best.'
            : 'Drag or use the buttons. You can fine-tune later.';

    final bool canContinue = step == 0
        ? store.addCat != null
        : step == 1
            ? store.addKey != null
            : true;

    return EcoScreen(
      header: _StepHeader(step: step, onBack: store.addBack),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: F.h2),
          const SizedBox(height: 4),
          Text(sub, style: F.b(13, height: 1.45, color: cs.muted)),
          const SizedBox(height: 18),
          if (step == 0)
            _catStep(context, store)
          else if (step == 1)
            _actStep(context, store)
          else
            _amountStep(store, cs),
        ],
      ),
      footer: FlowFooter(
        children: <Widget>[
          if (step == 2)
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
    );
  }

  Widget _catStep(BuildContext context, EcoStore store) {
    final cs = Theme.of(context).colorScheme;
    final List<Widget> tiles = <Widget>[];
    for (final String id in kCatOrder) {
      final Cat c = catOf(id);
      final bool on = store.addCat == id;
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
                background: c.resolve(cs).tint,
                foreground: c.resolve(cs).ink,
                size: 48,
                iconSize: 24,
                radius: 16,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.name, style: F.d(18)),
                    const SizedBox(height: 2),
                    Text(
                      '${c.blurb} · ${actsOf(id).length} activities',
                      style: F.b(13, wght: 600, color: cs.muted),
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
      final bool on = store.addKey == a.key;
      tiles.add(
        EcoCard(
          flat: true,
          highlighted: on,
          fillWidth: true,
          padding: const EdgeInsets.all(15),
          onTap: () => store.pickAct(a.key),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CatBadge(
                icon: a.icon,
                background: c.resolve(cs).tint,
                foreground: c.resolve(cs).ink,
                size: 44,
                iconSize: 22,
                radius: 15,
              ),
              const SizedBox(height: 8),
              Text(
                a.name,
                style: F.b(14.5, wght: 800, height: 1.25),
              ),
              const SizedBox(height: 8),
              Text(
                a.factor == 0
                    ? 'Zero emission'
                    : '${fmt2(store.displayFactor(a))} kg / ${store.unitFor(a)}',
                style: F.b(12, wght: 700, color: cs.muted),
              ),
            ],
          ),
        ),
      );
    }
    return EcoGrid(items: tiles, columns: 2, gap: 12);
  }

  Widget _amountStep(EcoStore store, ColorScheme cs) {
    final ActivityDef a = activityDef(store.addKey!)!;
    final Cat c = catOf(a.cat);
    final double co2 = round1(a.factor * store.addAmount);
    final double displayFactor = store.displayFactor(a);
    final String displayUnit = store.unitFor(a);
    final double displayAmount = store.displayAmount(a, store.addAmount);
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
                background: c.resolve(cs).tint,
                foreground: c.resolve(cs).ink,
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
                      a.factor == 0
                          ? '${c.name} · zero emission'
                          : '${c.name} · ${fmt2(displayFactor)} kg CO₂e per $displayUnit',
                      style: F.b(13, height: 1.45, color: cs.muted),
                    ),
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
                  const SizedBox(width: 8),
                  Text(
                    displayUnit,
                    style: F.b(16, wght: 800, color: cs.muted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
        Row(
          children: <Widget>[
            _StepperBtn(icon: 'minus', onTap: () => store.amtStep(-1)),
            const SizedBox(width: 14),
            Expanded(
              child: _AmountSlider(
                value: displayAmount,
                min: (a.unit == 'servings' || (a.unit == 'km' && a.factor == 0))
                    ? 1.0
                    : 0.0,
                max: store.displayMax(a),
                step: store.displayStep(a),
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
        const SizedBox(height: 18),
        EcoCard(
          tone: EcoCardTone.mint,
          flat: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
          'Estimate uses average emission factors — treat it as a good-enough guide, not a lab measurement.',
          style: F.b(13, height: 1.45, color: cs.muted),
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
  const _StepHeader({required this.step, required this.onBack});

  final int step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
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
                    'Step ${step + 1} of 3',
                    style: F.b(13, wght: 800, color: cs.muted),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              for (int i = 0; i < 3; i++) ...<Widget>[
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

/// Range control built to the prototype's slider spec: a bordered track with a
/// forest thumb ringed in white.
class _AmountSlider extends StatelessWidget {
  const _AmountSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;

  static const double _thumb = 28;

  void _handle(double dx, double trackWidth) {
    final double usable = trackWidth - _thumb;
    if (usable <= 0) return;
    final double frac = clampDouble((dx - _thumb / 2) / usable, 0, 1);
    final double raw = min + frac * (max - min);
    final double snapped = (raw / step).round() * step;
    onChanged(clampDouble(snapped, min, max));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double trackW = c.maxWidth;
        final double usable = trackW - _thumb;
        final double frac =
            max <= min ? 0 : clampDouble((value - min) / (max - min), 0, 1);
        final double left = usable * frac;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails d) => _handle(d.localPosition.dx, trackW),
          onHorizontalDragStart: (DragStartDetails d) =>
              _handle(d.localPosition.dx, trackW),
          onHorizontalDragUpdate: (DragUpdateDetails d) =>
              _handle(d.localPosition.dx, trackW),
          child: SizedBox(
            height: 34,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: cs.surface2,
                      borderRadius: BorderRadius.circular(Eco.rPill),
                      border: Border.all(color: cs.outline),
                    ),
                  ),
                ),
                Positioned(
                  top: 3,
                  left: left,
                  child: Container(
                    width: _thumb,
                    height: _thumb,
                    decoration: BoxDecoration(
                      color: cs.leaf,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 4),
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x590F3320),
                          offset: Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
