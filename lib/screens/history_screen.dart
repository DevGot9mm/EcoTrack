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

    List<Entry> acts = store.sortedActivities;
    if (store.historyFilter != 'all') {
      acts = acts.where((Entry a) => a.cat == store.historyFilter).toList();
    }

    final Map<int, List<Entry>> groups = <int, List<Entry>>{};
    for (final Entry a in acts) {
      final int i = daysAgo(a.at);
      groups.putIfAbsent(i, () => <Entry>[]).add(a);
    }
    final List<int> keys = groups.keys.toList()..sort();

    final double weekTotal = store.total(store.inRange(0, 6));

    final Widget body = keys.isEmpty
        ? EcoEmptyState(
            mascot: 'face-sad',
            title: 'Nothing logged here yet',
            body:
                'Try another category, or add your first activity for this one.',
            action: EcoButton(
              label: 'Log an activity',
              leading: 'plus',
              onPressed: store.openAdd,
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final int k in keys) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Expanded(child: Text(dayLabel(k), style: F.d(16))),
                      Text(
                        '${kgText(store.total(groups[k]!))} CO₂e',
                        style: F.b(13, wght: 800, color: Eco.muted),
                      ),
                    ],
                  ),
                ),
                for (int i = 0; i < groups[k]!.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: 8),
                  _HistRow(entry: groups[k]![i], store: store),
                ],
              ],
            ],
          );

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
                        Text('logged in the last 7 days', style: F.statCap),
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
                active: store.historyFilter == 'all',
                onTap: () => store.setHistoryFilter('all'),
              ),
              for (final String id in kCatOrder)
                EcoChip(
                  label: catOf(id).name,
                  dotColor: catOf(id).color,
                  active: store.historyFilter == id,
                  onTap: () => store.setHistoryFilter(id),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: body,
          ),
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
    final ActivityDef? def = activityDef(entry.key);
    if (def == null) return const SizedBox.shrink();
    final Cat c = catOf(entry.cat);

    return Pressable(
      onTap: () => showActivitySheet(context, store, entry.id),
      scale: 0.99,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Eco.surface,
          border: Border.all(color: Eco.line),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: <Widget>[
            CatBadge(
              icon: def.icon,
              background: c.tint,
              foreground: c.ink,
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
                    style: F.b(12.5, wght: 600, color: Eco.muted),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: fmt2(entry.co2), style: F.d(16)),
                  TextSpan(
                    text: ' kg',
                    style: F.b(11, wght: 800, color: Eco.muted),
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
