import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../icons.dart';
import '../models.dart';
import '../responsive.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _section({required Widget child}) =>
      Padding(padding: const EdgeInsets.only(top: 26), child: child);

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final bool tablet = context.windowSize != WindowSize.compact;

    final double todayTotal = store.total(store.inRange(0, 0));
    final double tw = store.total(store.inRange(0, 6));
    final double lw = store.total(store.inRange(7, 13));
    final int delta = lw > 0 ? (((tw - lw) / lw) * 100).round() : 0;
    final bool improved = delta <= 0;
    final Map<CarbonCategory, double> t = store.catTotals(store.inRange(0, 6));
    final double weekTotal = tw > 0 ? tw : 1;
    final int targetPct = clampInt(
      ((todayTotal / store.dailyTarget) * 100).round(),
      0,
      100,
    );

    final List<DayBar> days = <DayBar>[];
    for (int d = 6; d >= 0; d--) {
      days.add(
        DayBar(
          total: store.total(store.inRange(d, d)),
          isToday: d == 0,
          label: weekdayShort(dayAgo(d)).substring(0, 1),
          categories: store.catTotals(store.inRange(d, d)),
        ),
      );
    }
    final double maxDay = days
        .map((DayBar x) => x.total)
        .fold<double>(0, (double a, double b) => math.max(a, b));

    final Challenge featured = store.challenges.firstWhere(
      (Challenge c) => c.featured,
      orElse: () => store.challenges.first,
    );
    final LevelInfo lvl = levelOf(store.points);

    return Stack(
      children: <Widget>[
        EcoScreen(
          padding: const EdgeInsets.only(bottom: 104),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ---- Greeting -------------------------------------------------
              HPad(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 18),
                  child: Row(
                    children: <Widget>[
                      Semantics(
                        button: true,
                        label: 'Open profile',
                        child: Tooltip(
                          message: 'Profile',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => store.go(AppRoute.profile),
                            child: MascotCrop(
                              store.playerAvatar,
                              size: 46,
                              radius: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${store.greeting}, ${store.greetingName}',
                              style: F.d(20, height: 1.15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              longDate(DateTime.now()),
                              style: F.b(13, wght: 600, color: cs.muted),
                            ),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: 'Eco tips',
                        child: EcoIconButton(
                          'tips',
                          onPressed: () => store.go(AppRoute.tips),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Hero -----------------------------------------------------
              HPad(
                child: _HomeBannerCarousel(
                  height: 268,
                  cards: <Widget>[
                    _HomeBannerCard(
                      key: const ValueKey<String>('home-banner-today-card'),
                      mascot: 'face-curious',
                      eyebrow: 'TODAY SO FAR',
                      title: '${fmt1(todayTotal)} kg CO₂e',
                      subtitle:
                          '${improved ? 'Down' : 'Up'} ${delta.abs()}% vs last '
                          'week. Small steps still add up.',
                      detail: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Daily goal ${fmt1(store.dailyTarget)} kg',
                                  style:
                                      F.b(12, wght: 700, color: Eco.onHero72),
                                ),
                              ),
                              Text(
                                '$targetPct%',
                                style: F.b(12, wght: 800, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          EcoBar(
                            value: targetPct / 100,
                            color: cs.leaf,
                            track: Eco.heroOverlay18,
                          ),
                        ],
                      ),
                      buttonLabel: 'Log activity',
                      buttonIcon: 'plus',
                      buttonKey: const ValueKey<String>(
                        'home-banner-log-button',
                      ),
                      onPressed: store.openAdd,
                    ),
                    _HomeBannerCard(
                      mascot: 'face-excited',
                      eyebrow: 'A QUICK WIN',
                      title: 'Make your next choice count',
                      subtitle: 'Find easy ideas for lighter trips, meals, and '
                          'home energy.',
                      detail: _BannerNote(
                        icon: 'tips',
                        text: 'One practical idea at a time',
                      ),
                      buttonLabel: 'Explore Eco Tips',
                      buttonIcon: 'arrowRight',
                      buttonKey: const ValueKey<String>(
                        'home-banner-tips-button',
                      ),
                      onPressed: () => store.openTipFromRail('t1'),
                    ),
                    _HomeBannerCard(
                      mascot: 'face-happy',
                      eyebrow: 'KEEP YOUR MOMENTUM',
                      title: '${store.streak}-day streak',
                      subtitle:
                          'Your small daily actions are building a greener '
                          'routine.',
                      detail: _BannerNote(
                        icon: 'trophy',
                        text: 'Check in on this week’s challenges',
                      ),
                      buttonLabel: 'View challenges',
                      buttonIcon: 'flag',
                      buttonKey: const ValueKey<String>(
                        'home-banner-challenges-button',
                      ),
                      onPressed: () => store.go(AppRoute.challenges),
                    ),
                  ],
                ),
              ),

              // ---- This week ------------------------------------------------
              _section(
                child: HPad(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SectionHead(
                        title: 'This week',
                        action: Text(
                          '${fmt1(tw)} kg of ${fmt1(store.weeklyTarget)} kg goal',
                          style: F.b(13, wght: 800, color: cs.ink2),
                        ),
                      ),
                      EcoCard(
                        flat: true,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            WeekBars(
                              days: days,
                              maxDay: maxDay,
                              categoryColors: <CarbonCategory, Color>{
                                for (final CarbonCategory id in kCatOrder)
                                  id: store.categoryColor(id),
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              improved
                                  ? 'You are ${delta.abs()}% below last week — about '
                                      '${fmt1((lw - tw).abs())} kg kept out of the air.'
                                  : 'You are $delta% above last week. One swapped trip usually closes the gap.',
                              style: F.b(13, height: 1.45, color: cs.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Breakdown ------------------------------------------------
              _section(
                child: HPad(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SectionHead(title: 'Where it comes from'),
                      Column(
                        children: <Widget>[
                          for (final CarbonCategory id in kCatOrder)
                            _BreakdownRow(
                              cat: catOf(id),
                              categoryColor: store.categoryColor(id),
                              value: t[id] ?? 0,
                              pct: ((t[id] ?? 0) / weekTotal * 100).round(),
                              onTap: () => store.browseCategory(id),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Today's challenge ----------------------------------------
              _section(
                child: HPad(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SectionHead(
                        title: 'Today’s challenge',
                        action: SectionLink(
                          label: 'All',
                          onTap: () => store.go(AppRoute.challenges),
                        ),
                      ),
                      EcoCard(
                        tone: EcoCardTone.amber,
                        child: Row(
                          children: <Widget>[
                            MascotArt(featured.mascot, width: 78),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.amberTint,
                                      borderRadius: BorderRadius.circular(
                                        Eco.rPill,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        EcoIcon(
                                          'sparkles',
                                          size: 14,
                                          color: cs.amberInk,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '+${featured.reward} pts',
                                          style: F.b(
                                            12.5,
                                            wght: 800,
                                            color: cs.amberInk,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    featured.title,
                                    style: F.d(16.5),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(featured.why,
                                      style: F.b(13,
                                          height: 1.45, color: cs.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListenableBuilder(
                        listenable: store,
                        builder: (BuildContext context, Widget? child) {
                          final bool claimable =
                              featured.state == ChallengeState.claimable;
                          final bool completed =
                              featured.state == ChallengeState.claimed;
                          final bool checkedInToday =
                              store.challengeCheckedInToday(featured.id);
                          return EcoButton(
                            label: completed
                                ? 'Challenge complete'
                                : claimable
                                    ? 'Claim ${featured.reward} pts'
                                    : checkedInToday
                                        ? 'Checked in today'
                                        : 'I did this today',
                            leading: completed
                                ? 'check'
                                : claimable
                                    ? 'sparkles'
                                    : 'check',
                            tone: completed
                                ? EcoButtonTone.ghost
                                : checkedInToday
                                    ? EcoButtonTone.ghost
                                    : EcoButtonTone.primary,
                            block: true,
                            onPressed: completed || checkedInToday
                                ? null
                                : () {
                                    if (claimable) {
                                      store.claim(featured.id);
                                    } else {
                                      store.challengeDone(featured.id);
                                    }
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Momentum -------------------------------------------------
              _section(
                child: HPad(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SectionHead(title: 'Your momentum'),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              child: EcoCard(
                                flat: true,
                                padding: const EdgeInsets.all(14),
                                onTap: () => showLevelInfoSheet(context, store),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        EcoIcon(
                                          'trophy',
                                          size: 17,
                                          color: cs.amber,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Eco Points',
                                            style: F.b(12.5, wght: 700, color: cs.muted),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      groupThousands(store.points),
                                      style: F.d(25),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        'Level ${lvl.idx + 1} · ${lvl.name}',
                                        style: F.b(13, height: 1.45, color: cs.muted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: EcoCard(
                                flat: true,
                                padding: const EdgeInsets.all(14),
                                onTap: () => store.go(AppRoute.challenges),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        EcoIcon(
                                          'flame',
                                          size: 17,
                                          color: cs.forest,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Streak',
                                            style: F.b(12.5, wght: 700, color: cs.muted),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${store.streak} days',
                                      style: F.d(25),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    const SizedBox(height: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Tips rail ------------------------------------------------
              _section(
                child: HPad(
                  child: SectionHead(
                    title: 'Small wins for today',
                    action: SectionLink(
                      label: 'All tips',
                      onTap: () => store.go(AppRoute.tips),
                    ),
                  ),
                ),
              ),
              EcoRail(
                gap: 12,
                children: <Widget>[
                  for (final Tip tp in kTips.take(4))
                    SizedBox(
                      width: tablet ? 246 : 214,
                      height: tablet ? 166 : 142,
                      child: EcoCard(
                        flat: true,
                        padding: const EdgeInsets.all(12),
                        onTap: () => store.openTipFromRail(tp.id),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CatBadge(
                              icon: tp.icon,
                              background: catOf(tp.cat)
                                  .resolve(
                                    cs,
                                    color: store.categoryColor(tp.cat),
                                  )
                                  .tint,
                              foreground: catOf(tp.cat)
                                  .resolve(
                                    cs,
                                    color: store.categoryColor(tp.cat),
                                  )
                                  .ink,
                              size: tablet ? 36 : 32,
                              iconSize: tablet ? 19 : 17,
                              radius: 11,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tp.title,
                              style: F.d(tablet ? 16 : 14.5, height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tp.action,
                              style: F.b(
                                tablet ? 13 : 12,
                                height: 1.35,
                                color: cs.muted,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: EcoFab(
            label: 'Log activity',
            onTap: store.openAdd,
            tablet: tablet,
          ),
        ),
      ],
    );
  }
}

class _HomeBannerCarousel extends StatefulWidget {
  const _HomeBannerCarousel({
    required this.height,
    required this.cards,
  });

  final double height;
  final List<Widget> cards;

  @override
  State<_HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<_HomeBannerCarousel> {
  late final PageController _controller = PageController();
  int _index = 0;
  double _wheelDelta = 0;
  bool _wheelAnimating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        !_controller.hasClients ||
        _wheelAnimating) {
      return;
    }

    final double delta = event.scrollDelta.dy;
    if (delta == 0) return;

    final int nextIndex =
        (_index + (delta > 0 ? 1 : -1)).clamp(0, widget.cards.length - 1);
    if (nextIndex == _index) {
      _wheelDelta = 0;
      return;
    }

    GestureBinding.instance.pointerSignalResolver.register(
      event,
      (PointerSignalEvent _) {
        _wheelDelta += delta;
        if (_wheelDelta.abs() < 36) return;

        final int targetIndex = (_index + (_wheelDelta > 0 ? 1 : -1))
            .clamp(0, widget.cards.length - 1);
        _wheelDelta = 0;
        if (targetIndex == _index) return;

        _wheelAnimating = true;
        _controller
            .animateToPage(
              targetIndex,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
            )
            .whenComplete(() => _wheelAnimating = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.textScalerOf(context).scale(widget.height) - 22,
          child: Listener(
            onPointerSignal: _handlePointerSignal,
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                dragDevices: <PointerDeviceKind>{
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
              ),
              child: PageView(
                controller: _controller,
                physics: const PageScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                onPageChanged: (int value) => setState(() => _index = value),
                children: <Widget>[
                  for (final Widget card in widget.cards)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: card,
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 22,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < widget.cards.length; i++)
                Semantics(
                  button: true,
                  label: 'Show banner ${i + 1} of ${widget.cards.length}',
                  selected: i == _index,
                  child: GestureDetector(
                    onTap: () => _controller.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _index ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _index ? cs.leaf : cs.lineStrong,
                        borderRadius: BorderRadius.circular(Eco.rPill),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeBannerCard extends StatelessWidget {
  const _HomeBannerCard({
    super.key,
    required this.mascot,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.buttonKey,
    required this.onPressed,
  });

  final String mascot;
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget detail;
  final String buttonLabel;
  final String buttonIcon;
  final Key buttonKey;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return EcoCard(
      tone: EcoCardTone.dark,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 98),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 78,
                  height: 82,
                  child: MascotArt(mascot, width: 78, height: 82),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        eyebrow.toUpperCase(),
                        style: F.eyebrow(context).copyWith(color: Eco.onHero66),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        style: F.d(19, height: 1.08, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: F.b(
                          11.5,
                          height: 1.3,
                          color: Eco.onHero72,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Align(
              alignment: Alignment.topLeft,
              child: detail,
            ),
          ),
          const SizedBox(height: 8),
          EcoButton(
            key: buttonKey,
            label: buttonLabel,
            leading: buttonIcon,
            tone: EcoButtonTone.onDark,
            block: true,
            minHeight: 44,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _BannerNote extends StatelessWidget {
  const _BannerNote({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Eco.heroOverlay14,
        borderRadius: BorderRadius.circular(Eco.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          EcoIcon(icon, size: 15, color: Eco.heroMint),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              style: F.b(11.5, wght: 700, color: Eco.heroMint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.cat,
    required this.categoryColor,
    required this.value,
    required this.pct,
    required this.onTap,
  });

  final Cat cat;
  final Color categoryColor;
  final double value;
  final int pct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
        child: Row(
          children: <Widget>[
            CatBadge(
              icon: cat.icon,
              background: cat.resolve(cs, color: categoryColor).tint,
              foreground: cat.resolve(cs, color: categoryColor).ink,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(cat.name, style: F.b(15, wght: 800)),
                  const SizedBox(height: 5),
                  EcoBar(value: pct / 100, color: categoryColor, height: 6),
                  const SizedBox(height: 5),
                  Text(
                    '$pct% of your week',
                    style: F.b(12.5, wght: 600, color: cs.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: fmt1(value), style: F.d(16)),
                  TextSpan(
                    text: ' kg',
                    style: F.b(11.5, wght: 800, color: cs.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
