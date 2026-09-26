import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  Widget _section({required Widget child}) =>
      Padding(padding: const EdgeInsets.only(top: 26), child: child);

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final int days = store.statsPeriod == 'week' ? 7 : 30;

    final List<double> series = <double>[];
    for (int d = days - 1; d >= 0; d--) {
      series.add(store.total(store.inRange(d, d)));
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

    final Map<String, double> t = store.catTotals(store.inRange(0, days - 1));
    final double rawTot =
        (t['transport'] ?? 0) + (t['electricity'] ?? 0) + (t['food'] ?? 0);
    final double tot = rawTot > 0 ? rawTot : 1;

    final List<String> order = kCatOrder.toList()
      ..sort((String a, String b) => (t[b] ?? 0).compareTo(t[a] ?? 0));
    final String biggest = order.first;

    final Map<String, double> byAct = <String, double>{};
    for (final Entry a in store.inRange(0, days - 1)) {
      byAct[a.key] = (byAct[a.key] ?? 0) + a.co2;
    }
    final List<MapEntry<String, double>> ranked =
        byAct.entries.toList()
          ..sort(
            (MapEntry<String, double> a, MapEntry<String, double> b) =>
                b.value.compareTo(a.value),
          );
    final List<MapEntry<String, double>> top = ranked.take(4).toList();
    final double rankMax = top.isNotEmpty ? top.first.value : 1;

    final double targetPerDay = store.weeklyTarget / 7;

    final Widget trendLegend = Wrap(
      spacing: 14,
      runSpacing: 8,
      children: <Widget>[
        _legendItem(Eco.leaf, 'Daily', '${fmt1(avg)} kg avg'),
        _legendItem(Eco.sage, 'Goal', '${fmt1(targetPerDay)} kg/day'),
      ],
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
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

                _section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SectionHead(title: 'Your trend'),
                      EcoCard(
                        flat: true,
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TrendChart(
                              series: series,
                              max: max,
                              targetPerDay: targetPerDay,
                              days: days,
                            ),
                            const SizedBox(height: 12),
                            trendLegend,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _section(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SectionHead(title: 'By category'),
                      EcoCard(
                        flat: true,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 132,
                              height: 132,
                              child: Stack(
                                children: <Widget>[
                                  DonutChart(totals: t, size: 132),
                                  Positioned.fill(
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            fmt1(sum),
                                            style: F.d(22, height: 1.05),
                                          ),
                                          Text(
                                            'kg total',
                                            style: F.b(
                                              11,
                                              wght: 800,
                                              color: Eco.muted,
                                            ),
                                          ),
                                        ],
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
                                children: <Widget>[
                                  for (int i = 0; i < kCatOrder.length; i++)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: i == 0 ? 0 : 12,
                                      ),
                                      child: _catLegend(
                                        catOf(kCatOrder[i]),
                                        t[kCatOrder[i]] ?? 0,
                                        tot,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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
                                padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                                child: _rankRow(top[i], rankMax),
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
                                style: F.h3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'It is ${((t[biggest] ?? 0) / tot * 100).round()}% of '
                                'the last $days days. Small changes here move '
                                'your number the most.',
                                style: F.small.copyWith(color: Eco.ink2),
                              ),
                              const SizedBox(height: 10),
                              MiniBtn(
                                label:
                                    'See ${catOf(biggest).name.toLowerCase()} tips',
                                trailingIcon: 'arrowRight',
                                onTap: () => store.browseCategory(biggest),
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

  Widget _legendItem(Color dot, String label, String value) {
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
          Text(label, style: F.b(13, wght: 700, color: Eco.ink2)),
          const SizedBox(width: 4),
          Text(value, style: F.b(13, wght: 700, color: Eco.ink)),
        ],
      ),
    );
  }

  Widget _catLegend(Cat c, double value, double tot) {
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
                color: c.color,
                borderRadius: BorderRadius.circular(Eco.rPill),
              ),
            ),
            const SizedBox(width: 8),
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
        Text('$pc% · ${kgText(value)}', style: F.caption),
      ],
    );
  }

  Widget _rankRow(MapEntry<String, double> e, double rankMax) {
    final ActivityDef? def = activityDef(e.key);
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
              style: F.b(13, wght: 800, color: Eco.muted),
            ),
          ],
        ),
        const SizedBox(height: 7),
        EcoBar(value: pc / 100, color: c.color, height: 6),
      ],
    );
  }
}
