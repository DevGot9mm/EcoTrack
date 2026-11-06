import 'package:flutter/material.dart';

import '../models/models.dart';
import '../core/responsive.dart';
import '../state/store.dart';
import '../core/theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  Widget _section({required Widget child}) =>
      Padding(padding: const EdgeInsets.only(top: 26), child: child);

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final int days = store.statsPeriod == 'week' ? 7 : 30;

    final List<double> series = <double>[];
    final List<Map<CarbonCategory, double>> categorySeries =
        <Map<CarbonCategory, double>>[];
    final List<String> chartLabels = <String>[];
    for (int d = days - 1; d >= 0; d--) {
      series.add(store.total(store.inRange(d, d)));
      categorySeries.add(store.catTotals(store.inRange(d, d)));
      chartLabels.add(dayLabel(d));
    }
    final double max = series.fold<double>(
      0,
      (double a, double b) => a > b ? a : b,
    );
    final double sum = series.fold<double>(
      0,
      (double a, double b) => a + b,
    );
    final double avg = sum / days;

    final Map<CarbonCategory, double> t =
        store.catTotals(store.inRange(0, days - 1));
    final double rawTot = kCatOrder.fold<double>(
      0,
      (double sum, CarbonCategory category) => sum + (t[category] ?? 0),
    );
    final double tot = rawTot > 0 ? rawTot : 1;

    final List<CarbonCategory> order = kCatOrder.toList()
      ..sort((CarbonCategory a, CarbonCategory b) =>
          (t[b] ?? 0).compareTo(t[a] ?? 0));
    final CarbonCategory biggest = order.first;

    final Map<String, double> byAct = <String, double>{};
    for (final Entry a in store.inRange(0, days - 1)) {
      byAct[a.key] = (byAct[a.key] ?? 0) + a.co2;
    }
    final List<MapEntry<String, double>> ranked = byAct.entries.toList()
      ..sort(
        (MapEntry<String, double> a, MapEntry<String, double> b) =>
            b.value.compareTo(a.value),
      );
    final List<MapEntry<String, double>> top = ranked.take(4).toList();
    final double rankMax = top.isNotEmpty ? top.first.value : 1;

    final double targetPerDay = store.weeklyTarget / 7;

    final bool twoCol = context.windowSize == WindowSize.expanded;
    const double twoColCardHeight = 320;

    final Widget trendLegend = Wrap(
      spacing: 14,
      runSpacing: 8,
      children: <Widget>[
        _legendItem(cs.leaf, 'Daily', '${fmt1(avg)} kg avg', cs),
        _legendItem(cs.muted, 'Goal', '${fmt1(targetPerDay)} kg/day', cs),
      ],
    );
    final Widget trendSection = _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SectionHead(title: 'Your trend'),
          SizedBox(
            height: twoCol ? twoColCardHeight : null,
            child: EcoCard(
              flat: true,
              padding: const EdgeInsets.fromLTRB(Eco.s16, 18, Eco.s16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: twoCol ? 240 : 220,
                    child: TrendChart(
                      series: series,
                      max: max,
                      targetPerDay: targetPerDay,
                      labels: chartLabels,
                      categorySeries: categorySeries,
                      categoryColors: <CarbonCategory, Color>{
                        for (final CarbonCategory id in kCatOrder)
                          id: store.categoryColor(id),
                      },
                    ),
                  ),
                  const SizedBox(height: Eco.s12),
                  trendLegend,
                ],
              ),
            ),
          ),
        ],
      ),
    );
    final Widget categorySection = _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SectionHead(title: 'By category'),
          SizedBox(
            height: twoCol ? twoColCardHeight : null,
            child: EcoCard(
              flat: true,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  final bool wide = context.windowSize != WindowSize.compact;
                  final double donutSize =
                      (c.maxWidth * (wide ? 0.4 : 0.32)).clamp(
                    100.0,
                    wide ? 190.0 : 160.0,
                  );
                  return Center(
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: donutSize,
                          height: donutSize,
                          child: Stack(
                            children: <Widget>[
                              DonutChart(
                                totals: t,
                                categoryColors: <CarbonCategory, Color>{
                                  for (final CarbonCategory id in kCatOrder)
                                    id: store.categoryColor(id),
                                },
                                size: donutSize,
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: _ImpactCenter(
                                    total: sum,
                                    average: avg,
                                    target: targetPerDay,
                                    size: donutSize * 0.76,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              for (int i = 0; i < kCatOrder.length; i++)
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: i == 0 ? 0 : Eco.s12),
                                  child: _catLegend(
                                    catOf(kCatOrder[i]),
                                    t[kCatOrder[i]] ?? 0,
                                    tot,
                                    cs,
                                    store,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
    final Widget trendAndCategory = context.windowSize == WindowSize.expanded
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: trendSection),
              const SizedBox(width: Eco.s16),
              Expanded(child: categorySection),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[trendSection, categorySection],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const EcoTopBar(title: 'Statistics'),
        HPad(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: EcoSegmented(
              items: const <String>['Last 7 days', 'Last 30 days'],
              index: days == 7 ? 0 : 1,
              onChanged: (int i) =>
                  store.setStatsPeriod(i == 0 ? 'week' : 'month'),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                EcoGrid(
                  columns: 3,
                  gap: 10,
                  items: <Widget>[
                    StatTile(value: fmt1(sum), caption: 'kg CO₂e total'),
                    StatTile(value: fmt1(avg), caption: 'kg per day'),
                    StatTile(
                      value: '${store.streak}',
                      caption: 'day streak',
                    ),
                  ],
                ),
                trendAndCategory,
                _section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SectionHead(title: 'Biggest sources'),
                      EcoCard(
                        flat: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            for (int i = 0; i < top.length; i++)
                              Padding(
                                padding:
                                    EdgeInsets.only(top: i == 0 ? 0 : Eco.s12),
                                child: _rankRow(top[i], rankMax, cs, store),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _section(
                  child: EcoCard(
                    tone: EcoCardTone.mint,
                    flat: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const MascotArt('face-curious', width: 62),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${catOf(biggest).name} leads your footprint',
                                style: F.role(context.type.titleMedium!,
                                    wght: 600, ls: -0.01, height: 1.25),
                              ),
                              const SizedBox(height: Eco.s4),
                              Text(
                                'It is ${((t[biggest] ?? 0) / tot * 100).round()}% of '
                                'the last $days days. Small changes here move '
                                'your number the most.',
                                style: F
                                    .role(context.type.labelLarge!)
                                    .copyWith(color: cs.ink2),
                              ),
                              const SizedBox(height: 10),
                              MiniBtn(
                                label:
                                    'See ${catOf(biggest).name.toLowerCase()} tips',
                                trailingIcon: 'arrowRight',
                                onTap: () {
                                  store.setTipFilter(
                                    TipFilterCategory.forCategory(biggest),
                                  );
                                  store.go(AppRoute.tips);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color dot, String label, String value, ColorScheme cs) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dot,
              borderRadius: BorderRadius.circular(Eco.rPill),
            ),
          ),
          const SizedBox(width: 7),
          Text(label, style: F.b(13, wght: 700, color: cs.ink2)),
          const SizedBox(width: Eco.s4),
          Text(value, style: F.b(13, wght: 700, color: cs.ink)),
        ],
      ),
    );
  }

  Widget _catLegend(
    Cat c,
    double value,
    double tot,
    ColorScheme cs,
    EcoStore store,
  ) {
    final int pc = ((value / tot) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: store.categoryColor(c.id),
                borderRadius: BorderRadius.circular(Eco.rPill),
              ),
            ),
            const SizedBox(width: Eco.s8),
            Expanded(
              child: Text(
                c.name,
                style: F.b(14, wght: 800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text('$pc% · ${kgText(value)}',
            style: F.b(13, height: 1.45, color: cs.muted)),
      ],
    );
  }

  Widget _rankRow(
    MapEntry<String, double> e,
    double rankMax,
    ColorScheme cs,
    EcoStore store,
  ) {
    final ActivityDef? def = store.activityOf(e.key);
    if (def == null) return const SizedBox.shrink();
    final Cat c = catOf(def.cat);
    final int pc = ((e.value / rankMax) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Expanded(child: Text(def.name, style: F.b(14.5, wght: 800))),
            Text(
              kgText(e.value),
              style: F.b(13, wght: 800, color: cs.muted),
            ),
          ],
        ),
        const SizedBox(height: 7),
        EcoBar(
          value: pc / 100,
          color: store.categoryColor(c.id),
          height: 6,
        ),
      ],
    );
  }
}

class _ImpactCenter extends StatefulWidget {
  const _ImpactCenter({
    required this.total,
    required this.average,
    required this.target,
    required this.size,
  });

  final double total;
  final double average;
  final double target;
  final double size;

  @override
  State<_ImpactCenter> createState() => _ImpactCenterState();
}

class _ImpactCenterState extends State<_ImpactCenter> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color statusColor;
    final String status;
    if (widget.average <= widget.target) {
      statusColor = cs.leaf;
      status = 'On track';
    } else if (widget.average <= widget.target * 1.25) {
      statusColor = cs.amber;
      status = 'Near goal';
    } else {
      statusColor = cs.danger;
      status = 'Above goal';
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _hovering = !_hovering),
        child: AnimatedScale(
          scale: _hovering ? 1.12 : 1,
          duration: const Duration(milliseconds: 600),
          curve: Eco.easeOut,
          child: Container(
            width: widget.size,
            height: widget.size,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surface,
              border: Border.all(color: statusColor, width: 1),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _hovering
                  ? Column(
                      key: const ValueKey<String>('period-status'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            status,
                            textAlign: TextAlign.center,
                            style: F.role(context.type.labelLarge!,
                                wght: 900, color: statusColor),
                          ),
                        ),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${fmt1(widget.average)} kg/day',
                            textAlign: TextAlign.center,
                            style: F.b(11.5, wght: 800, color: cs.ink),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Goal ${fmt1(widget.target)} kg/day',
                            textAlign: TextAlign.center,
                            style: F.b(10, wght: 700, color: cs.muted),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey<String>('period-total'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            fmt1(widget.total),
                            style: F.d(20, height: 1.05),
                          ),
                        ),
                        Text(
                          'kg total',
                          style: F.b(10, wght: 800, color: cs.muted),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
