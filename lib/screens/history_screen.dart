import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final cs = Theme.of(context).colorScheme;

    List<Entry> acts = store.sortedActivities;
    final CarbonCategory? filter = store.historyFilter;
    if (filter != null) {
      acts = acts.where((Entry a) => a.cat == filter).toList();
    }

    final Map<int, List<Entry>> groups = <int, List<Entry>>{};
    for (final Entry a in acts) {
      final int i = daysAgo(a.at);
      groups.putIfAbsent(i, () => <Entry>[]).add(a);
    }
    final List<int> keys = groups.keys.toList()..sort();
    final List<({int? day, Entry? entry})> historyItems =
        <({int? day, Entry? entry})>[];
    for (final int day in keys) {
      historyItems.add((day: day, entry: null));
      for (final Entry entry in groups[day]!) {
        historyItems.add((day: null, entry: entry));
      }
    }

    final double weekTotal = store.total(store.inRange(0, 6));

    final Widget body;
    if (keys.isEmpty) {
      body = EcoEmptyState(
        mascot: 'face-sad',
        title: 'Nothing logged here yet',
        body: 'Try another category, or add your first activity for this one.',
        action: EcoButton(
          label: 'Log an activity',
          leading: 'plus',
          onPressed: store.openAdd,
        ),
      );
    } else {
      body = ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        itemCount: historyItems.length,
        itemBuilder: (BuildContext context, int index) {
          final ({int? day, Entry? entry}) item = historyItems[index];
          if (item.entry == null) {
            final int day = item.day!;
            return Padding(
              padding: const EdgeInsets.only(top: 22, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Expanded(child: Text(dayLabel(day), style: F.d(16))),
                  Text(
                    '${kgText(store.total(groups[day]!))} CO₂e',
                    style: F.b(13, wght: 800, color: cs.muted),
                  ),
                ],
              ),
            );
          }
          final bool firstInDay = historyItems[index - 1].entry == null;
          return Padding(
            padding: EdgeInsets.only(top: firstInDay ? 0 : 8),
            child: _HistRow(entry: item.entry!, store: store),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EcoTopBar(
          title: 'History',
          right: EcoIconButton('plus', onPressed: store.openAdd),
        ),
        HPad(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: EcoCard(
              tone: EcoCardTone.mint,
              flat: true,
              padding: const EdgeInsets.all(15),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(kgText(weekTotal), style: F.statNum),
                        const SizedBox(height: 2),
                        Text('logged in the last 7 days',
                            style: F.b(12.5, wght: 700, color: cs.muted)),
                      ],
                    ),
                  ),
                  const MascotArt('face-calm', width: 54),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EcoRail(
            children: <Widget>[
              EcoChip(
                label: 'All',
                active: store.historyFilter == null,
                onTap: () => store.setHistoryFilter(null),
              ),
              for (final CarbonCategory id in kCatOrder)
                EcoChip(
                  label: catOf(id).name,
                  dotColor: store.categoryColor(id),
                  active: store.historyFilter == id,
                  onTap: () => store.setHistoryFilter(id),
                ),
            ],
          ),
        ),
        Expanded(
          child: keys.isEmpty
              ? SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  child: body,
                )
              : body,
        ),
      ],
    );
  }
}

class _HistRow extends StatelessWidget {
  const _HistRow({required this.entry, required this.store});

  final Entry entry;
  final EcoStore store;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ActivityDef? def = store.activityOf(entry.key);
    if (def == null) return const SizedBox.shrink();
    final Cat c = catOf(entry.cat);

    return Pressable(
      onTap: () => showActivitySheet(context, store, entry.id),
      scale: 0.99,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: <Widget>[
            CatBadge(
              icon: def.icon,
              background: c.resolve(cs, color: store.categoryColor(c.id)).tint,
              foreground: c.resolve(cs, color: store.categoryColor(c.id)).ink,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(def.name, style: F.b(15, wght: 800)),
                  const SizedBox(height: 1),
                  Text(
                    '${store.amountLabel(def, entry.amount)} · '
                    '${timeLabel(entry.at)}',
                    style: F.b(12.5, wght: 600, color: cs.muted),
                  ),
                ],
              ),
            ),
            RichText(
              textScaler: MediaQuery.textScalerOf(context),
              textAlign: TextAlign.end,
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: fmt2(entry.co2), style: F.d(16)),
                  TextSpan(
                    text: ' kg',
                    style: F.b(11, wght: 800, color: cs.muted),
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
