import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../icons.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _white66 = Color(0xA8FFFFFF);
  static const Color _white72 = Color(0xB8FFFFFF);

  Widget _section({required Widget child}) =>
      Padding(padding: const EdgeInsets.only(top: 26), child: child);

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final double screenW = MediaQuery.of(context).size.width;

    final double todayTotal = store.total(store.inRange(0, 0));
    final double tw = store.total(store.inRange(0, 6));
    final double lw = store.total(store.inRange(7, 13));
    final int delta = lw > 0 ? (((tw - lw) / lw) * 100).round() : 0;
    final bool improved = delta <= 0;
    final Map<String, double> t = store.catTotals(store.inRange(0, 6));
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

    final double heroNumSize = (screenW * 0.135).clamp(44.0, 56.0);

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
                      MascotCrop(store.playerAvatar, size: 46, radius: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${store.greeting}, ${store.playerName}',
                              style: F.d(20, height: 1.15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              longDate(DateTime.now()),
                              style: F.b(13, wght: 600, color: Eco.muted),
                            ),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: 'Eco tips',
                        child: EcoIconButton(
                          'tips',
                          onPressed: () => store.go('tips'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Hero -----------------------------------------------------
              HPad(
                child: EcoCard(
                  tone: EcoCardTone.dark,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Eyebrow(
                                  'Today so far',
                                  color: _white66,
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: <Widget>[
                                      Text(
                                        fmt1(todayTotal),
                                        style: F.d(
                                          heroNumSize,
                                          color: Colors.white,
                                          height: 0.96,
                                          ls: -0.03,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        'kg CO₂e',
                                        style: F.b(
                                          15,
                                          wght: 800,
                                          color: _white72,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x38A9C79A),
                                        borderRadius: BorderRadius.circular(
                                          Eco.rPill,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          EcoIcon(
                                            improved ? 'arrowDown' : 'arrowUp',
                                            size: 15,
                                            color: const Color(0xFFDFF0D3),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${improved ? 'Down ' : 'Up '}'
                                            '${delta.abs()}% vs last week',
                                            style: F.b(
                                              13,
                                              wght: 800,
                                              color: const Color(0xFFDFF0D3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const MascotArt('face-curious', width: 96),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Daily goal ${fmt1(store.dailyTarget)} kg',
                              style: F.b(12.5, wght: 700, color: _white72),
                            ),
                          ),
                          Text(
                            '$targetPct%',
                            style: F.d(15, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      EcoBar(
                        value: targetPct / 100,
                        color: Eco.sage,
                        track: const Color(0x2EFFFFFF),
                      ),
                      const SizedBox(height: 16),
                      EcoButton(
                        label: 'Log activity',
                        leading: 'plus',
                        tone: EcoButtonTone.onDark,
                        block: true,
                        onPressed: store.openAdd,
                      ),
                    ],
                  ),
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
                          style: F.b(13, wght: 800, color: Eco.ink2),
                        ),
                      ),
                      EcoCard(
                        flat: true,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            WeekBars(days: days, maxDay: maxDay),
                            const SizedBox(height: 12),
                            Text(
                              improved
                                  ? 'You are ${delta.abs()}% below last week — about '
                                      '${fmt1((lw - tw).abs())} kg kept out of the air.'
                                  : 'You are $delta% above last week. One swapped trip usually closes the gap.',
                              style: F.caption,
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
                          for (final String id in kCatOrder)
                            _BreakdownRow(
                              cat: catOf(id),
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
                          onTap: () => store.go('challenges'),
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
                                      color: Eco.amberTint,
                                      borderRadius: BorderRadius.circular(
                                        Eco.rPill,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const EcoIcon(
                                          'sparkles',
                                          size: 14,
                                          color: Eco.amberInk,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '+${featured.reward} pts',
                                          style: F.b(
                                            12.5,
                                            wght: 800,
                                            color: Eco.amberInk,
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
                                  Text(featured.why, style: F.caption),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      EcoButton(
                        label: 'I did this today',
                        leading: 'check',
                        block: true,
                        onPressed: () => store.challengeDone(featured.id),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: EcoCard(
                              flat: true,
                              padding: const EdgeInsets.all(14),
                              onTap: () => store.go('points'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      const EcoIcon(
                                        'trophy',
                                        size: 17,
                                        color: Eco.amber,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Eco Points',
                                          style: F.statCap,
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
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      'Level ${lvl.idx + 1} · ${lvl.name}',
                                      style: F.caption,
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
                              onTap: () => store.go('challenges'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      const EcoIcon(
                                        'flame',
                                        size: 17,
                                        color: Eco.forest,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Streak', style: F.statCap),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${store.streak} days',
                                    style: F.d(25),
                                    maxLines: 1,
                                  ),
                                  Text(
                                    'Best run: 12 days',
                                    style: F.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                      onTap: () => store.go('tips'),
                    ),
                  ),
                ),
              ),
              EcoRail(
                gap: 12,
                children: <Widget>[
                  for (final Tip tp in kTips.take(4))
                    SizedBox(
                      width: 214,
                      child: EcoCard(
                        flat: true,
                        padding: const EdgeInsets.all(15),
                        onTap: () => store.openTipFromRail(tp.id),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CatBadge(
                              icon: tp.icon,
                              background: catOf(tp.cat).tint,
                              foreground: catOf(tp.cat).ink,
                              size: 38,
                              iconSize: 19,
                              radius: 12,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tp.title,
                              style: F.d(15.5, height: 1.25),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tp.action,
                              style: F.caption,
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
          child: EcoFab(label: 'Log activity', onTap: store.openAdd),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.cat,
    required this.value,
    required this.pct,
    required this.onTap,
  });

  final Cat cat;
  final double value;
  final int pct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
        child: Row(
          children: <Widget>[
            CatBadge(
              icon: cat.icon,
              background: cat.tint,
              foreground: cat.ink,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(cat.name, style: F.b(15, wght: 800)),
                  const SizedBox(height: 5),
                  EcoBar(value: pct / 100, color: cat.color, height: 6),
                  const SizedBox(height: 5),
                  Text(
                    '$pct% of your week',
                    style: F.b(12.5, wght: 600, color: Eco.muted),
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
                    style: F.b(11.5, wght: 800, color: Eco.muted),
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
