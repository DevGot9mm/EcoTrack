import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class _Slide {
  const _Slide(this.img, this.title, this.body);
  final String img;
  final String title;
  final String body;
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const List<_Slide> slides = <_Slide>[
    _Slide(
      'body-front',
      'Meet Sprout',
      'Your companion on the way to a lighter footprint. Small steps, every day.',
    ),
    _Slide(
      'body-jump',
      'See your impact',
      'Log a trip, a meal or an hour of power — EcoTrack turns it into a number you can actually act on.',
    ),
    _Slide(
      'body-bag',
      'Build the habit',
      'Challenges, streaks and Eco Points keep the small choices coming. Ready to start?',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final int i = clampInt(store.onboardSlide, 0, slides.length - 1);
    final _Slide s = slides[i];
    final bool last = i == slides.length - 1;

    return Container(
      decoration: const BoxDecoration(gradient: Eco.welcomeBg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: store.finishOnboard,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Text(
                    'Skip',
                    style: F.b(14, wght: 700, color: const Color(0xC7FFFFFF)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: 224,
                          height: 224,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: Eco.halo,
                          ),
                        ),
                        MascotArt(s.img, width: 168),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Eco',
                    style: F.d(38, color: Colors.white, ls: -0.02),
                  ),
                  TextSpan(
                    text: 'Track',
                    style: F.d(38, color: Eco.sage, ls: -0.02),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your impact, change your future.',
              textAlign: TextAlign.center,
              style: F.b(16, color: const Color(0xCCFFFFFF)),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 96),
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Column(
                  children: <Widget>[
                    Text(
                      s.title,
                      textAlign: TextAlign.center,
                      style: F.d(22, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.body,
                      textAlign: TextAlign.center,
                      style: F.b(
                        15,
                        height: 1.5,
                        color: const Color(0xC2FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int d = 0; d < slides.length; d++)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => store.setOnboardSlide(d),
                      child: AnimatedContainer(
                        duration: Eco.dur2,
                        curve: Eco.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        width: d == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: d == i
                              ? Eco.sage
                              : const Color(0x52FFFFFF),
                          borderRadius: BorderRadius.circular(Eco.rPill),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            EcoButton(
              label: last ? 'Get started' : 'Next',
              trailing: 'arrowRight',
              tone: EcoButtonTone.amber,
              block: true,
              onPressed: last
                  ? store.finishOnboard
                  : () => store.setOnboardSlide(i + 1),
            ),
            const SizedBox(height: 10),
            EcoButton(
              label: 'I already have an account',
              tone: EcoButtonTone.onDark,
              block: true,
              onPressed: () => store.go('auth'),
            ),
          ],
        ),
      ),
    );
  }
}
