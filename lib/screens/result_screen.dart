import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../icons.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final Entry? entry = store.lastActivity;
    if (entry == null) return const HomeScreen();

    final Entry a = entry;
    final ActivityDef? def = activityDef(a.key);
    if (def == null) return const HomeScreen();
    final Cat c = catOf(a.cat);

    final bool zero = a.co2 == 0;
    final double equiv = def.factor > 0 ? a.co2 / 0.192 : 0;
    final double artH = zero ? 229 : 184;

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: 168,
                      height: artH,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Positioned(
                            left: -6,
                            right: -6,
                            top: -14,
                            bottom: -4,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: Eco.resultHalo,
                              ),
                            ),
                          ),
                          MascotArt(
                            zero ? 'body-jump' : 'face-excited',
                            width: 168,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Eyebrow('Activity saved'),
                    const SizedBox(height: 8),
                    Text(
                      zero ? 'Beautifully clean' : 'Nice work',
                      style: F.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        '${def.name} · ${store.amountLabel(def, a.amount)}',
                        style: F.b(14.5, height: 1.5, color: cs.ink2),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Eyebrow('Estimated impact'),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: fmt2(a.co2),
                            style: F.d(48, height: 1, ls: -0.03),
                          ),
                          TextSpan(
                            text: ' kg CO₂e',
                            style: F.b(15, wght: 800, color: cs.muted),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        border: Border.all(color: cs.outline),
                        borderRadius: BorderRadius.circular(Eco.rBtn),
                      ),
                      child: Text(
                        zero
                            ? 'That is a journey with no emissions at all — the best kind of number.'
                            : 'About the same as driving ${equiv.round()} km in a petrol car.',
                        textAlign: TextAlign.center,
                        style: F.b(14, wght: 700, color: cs.ink2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _pill(
                          background: cs.surface,
                          border: cs.lineStrong,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: c.color,
                                  borderRadius:
                                      BorderRadius.circular(Eco.rPill),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                c.name,
                                style: F.b(13.5, wght: 700, color: cs.ink2),
                              ),
                            ],
                          ),
                        ),
                        _pill(
                          background: cs.amberTint,
                          border: cs.lineAmber,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              EcoIcon(
                                'sparkles',
                                size: 16,
                                color: cs.amberInk,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                '+15 Eco Points',
                                style:
                                    F.b(13.5, wght: 700, color: cs.amberInk),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            FlowFooter(
              children: <Widget>[
                EcoButton(
                  label: 'Back to home',
                  block: true,
                  onPressed: () => store.go('home'),
                ),
                EcoButton(
                  label: 'Log another activity',
                  tone: EcoButtonTone.ghost,
                  block: true,
                  onPressed: store.logAnother,
                ),
              ],
            ),
          ],
        ),
        const Positioned.fill(
          child: IgnorePointer(child: ConfettiOverlay()),
        ),
      ],
    );
  }

  Widget _pill({
    required Color background,
    required Color border,
    required Widget child,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(Eco.rPill),
      ),
      child: child,
    );
  }
}

class _Piece {
  const _Piece(this.left, this.color, this.delayMs, this.spin);

  final double left;
  final Color color;
  final double delayMs;
  final double spin;
}

/// The prototype's celebration confetti: sixteen petals falling and turning.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  static const List<Color> _colors = <Color>[
    Color(0xFF4E9A51),
    Color(0xFFA9C79A),
    Color(0xFFE8A33D),
    Color(0xFFE4F1DC),
  ];

  late final AnimationController _c;
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final math.Random rnd = math.Random(1337);
    _pieces = List<_Piece>.generate(16, (int i) {
      return _Piece(
        0.04 + rnd.nextDouble() * 0.92,
        _colors[i % _colors.length],
        rnd.nextDouble() * 420,
        rnd.nextDouble() * 180,
      );
    });
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _opacityFor(double t) {
    if (t <= 0 || t >= 1) return 0;
    if (t < 0.12) return (t / 0.12) * 0.95;
    return 0.95 * (1 - (t - 0.12) / 0.88);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        return AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? child) {
            final double elapsed = _c.value * 2100;
            final List<Widget> children = <Widget>[];
            for (final _Piece p in _pieces) {
              final double t = clampDouble(
                (elapsed - p.delayMs) / 2100,
                0,
                1,
              );
              final double e = Curves.easeIn.transform(t);
              children.add(
                Positioned(
                  left: p.left * c.maxWidth,
                  top: -18,
                  child: Opacity(
                    opacity: _opacityFor(t),
                    child: Transform.translate(
                      offset: Offset(0, 560 * e),
                      child: Transform.rotate(
                        angle: (p.spin + 320 * e) * math.pi / 180,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: p.color,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(7.2),
                              bottomRight: Radius.circular(7.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return Stack(clipBehavior: Clip.hardEdge, children: children);
          },
        );
      },
    );
  }
}
