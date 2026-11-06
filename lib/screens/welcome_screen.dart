import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../core/responsive.dart';
import '../state/store.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class _Slide {
  const _Slide(this.img, this.title, this.body);
  final String img;
  final String title;
  final String body;
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const List<_Slide> _slides = <_Slide>[
    _Slide(
      'body-front',
      'Meet Eco',
      'Your companion on the way to a lighter footprint. Small steps, every day.',
    ),
    _Slide(
      'body-jump-no-leaves',
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
    final int i = clampInt(store.onboardSlide, 0, _slides.length - 1);
    final _Slide s = _slides[i];
    final bool last = i == _slides.length - 1;
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: Eco.welcomeBg),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size screen = MediaQuery.sizeOf(context);
            final bool landscape = screen.width > screen.height;
            final bool tablet = context.windowSize != WindowSize.compact;
            if (landscape && context.windowSize != WindowSize.compact) {
              return _landscapeLayout(
                context,
                store,
                s,
                i,
                last,
                constraints,
                tablet,
              );
            }
            return _portraitLayout(
              context,
              store,
              s,
              i,
              last,
              constraints,
              tablet,
            );
          },
        ),
      ),
    );
  }

  Widget _landscapeLayout(
    BuildContext context,
    EcoStore store,
    _Slide slide,
    int index,
    bool last,
    BoxConstraints constraints,
    bool tablet,
  ) {
    final double mascotSize = math
        .min(constraints.maxHeight * 0.76, constraints.maxWidth * 0.36)
        .clamp(150.0, tablet ? 390.0 : 290.0);
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(Eco.s24, 36, Eco.s24, Eco.s12),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Center(child: _mascot(slide.img, mascotSize)),
              ),
              const SizedBox(width: Eco.s24),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: _welcomeContent(
                    context,
                    store,
                    slide,
                    index,
                    last,
                    tablet,
                    includeSkip: false,
                    compact: true,
                    alignCenter: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 2,
          right: 28,
          child: _skipButton(store, alignRight: true),
        ),
      ],
    );
  }

  Widget _portraitLayout(
    BuildContext context,
    EcoStore store,
    _Slide slide,
    int index,
    bool last,
    BoxConstraints constraints,
    bool tablet,
  ) {
    final double mascotSize = (constraints.maxWidth * (tablet ? 0.46 : 0.56))
        .clamp(190.0, tablet ? 380.0 : 300.0);
    final double heroHeight = (constraints.maxHeight * (tablet ? 0.38 : 0.32))
        .clamp(tablet ? 300.0 : 210.0, tablet ? 430.0 : 290.0);
    final Widget content = Padding(
      padding: const EdgeInsets.fromLTRB(Eco.s24, Eco.s4, Eco.s24, Eco.s20),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _skipButton(store, alignRight: true),
            SizedBox(
              height: heroHeight,
              child: Center(child: _mascot(slide.img, mascotSize)),
            ),
            _welcomeContent(
              context,
              store,
              slide,
              index,
              last,
              tablet,
              includeSkip: false,
              compact: constraints.maxHeight < 700,
            ),
          ],
        ),
      ),
    );

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: content,
    );
  }

  Widget _mascot(String image, double size) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: Eco.halo,
              ),
            ),
            MascotArt(image, width: size * 0.78),
          ],
        ),
      );

  Widget _skipButton(EcoStore store, {required bool alignRight}) => Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: store.finishOnboard,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Eco.s4, vertical: Eco.s8),
            child: Text(
              'Skip',
              style: F.b(14, wght: 700, color: Eco.onHeroMedium),
            ),
          ),
        ),
      );

  Widget _welcomeContent(
    BuildContext context,
    EcoStore store,
    _Slide slide,
    int index,
    bool last,
    bool tablet, {
    bool includeSkip = true,
    bool compact = false,
    bool alignCenter = true,
  }) {
    final TextAlign align = alignCenter ? TextAlign.center : TextAlign.left;
    final double scale = tablet ? 1.15 : 1;
    final CrossAxisAlignment crossAxisAlignment =
        alignCenter ? CrossAxisAlignment.stretch : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: <Widget>[
        if (includeSkip) _skipButton(store, alignRight: true),
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: 'Eco',
                style: F.d(38 * scale, color: Colors.white, ls: -0.02),
              ),
              TextSpan(
                text: 'Track',
                style: F.d(38 * scale, color: Eco.sage, ls: -0.02),
              ),
            ],
          ),
          textAlign: align,
        ),
        SizedBox(height: compact ? 3 : 8),
        Text(
          'Track your impact, change your future.',
          textAlign: align,
          style: F.b(16 * scale, color: Eco.onHeroHigh),
        ),
        Padding(
          padding: EdgeInsets.only(top: compact ? 8 : 18),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: <Widget>[
              Text(
                slide.title,
                textAlign: align,
                style: F.d(22 * scale, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                slide.body,
                textAlign: align,
                style: F.b(
                  15 * scale,
                  height: 1.4,
                  color: Eco.onHeroMedium,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: compact ? 8 : Eco.s16, bottom: Eco.s12),
          child: Row(
            mainAxisAlignment: alignCenter
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: <Widget>[
              for (int d = 0; d < _slides.length; d++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => store.setOnboardSlide(d),
                  child: AnimatedContainer(
                    duration: Eco.dur2,
                    curve: Eco.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    width: d == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: d == index ? Eco.sage : Eco.heroDot32,
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
          minHeight: compact ? 46 : 52,
          onPressed: last
              ? store.finishOnboard
              : () => store.setOnboardSlide(index + 1),
        ),
        const SizedBox(height: Eco.s8),
        EcoButton(
          label: 'I already have an account',
          tone: EcoButtonTone.onDark,
          block: true,
          minHeight: compact ? 46 : 52,
          onPressed: () => store.go(AppRoute.auth),
        ),
      ],
    );
  }
}
