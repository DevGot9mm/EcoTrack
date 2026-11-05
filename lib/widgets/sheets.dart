import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import 'charts.dart';
import 'common.dart';

/// Sheet chrome: grab handle, sheet radius, capped height, safe bottom inset.
Future<void> showEcoSheet(
  BuildContext context,
  Widget child, {
  double maxHeightFactor = 0.82,
  double maxWidth = double.infinity,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Eco.scrim,
    isScrollControlled: true,
    constraints: BoxConstraints(maxWidth: maxWidth),
    builder: (BuildContext ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SizedBox(
          width: double.infinity,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * maxHeightFactor,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Eco.rSheet),
              ),
              boxShadow: Eco.shadowSheet,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                Eco.s20,
                Eco.s12 - 2,
                Eco.s20,
                Eco.s20 + MediaQuery.of(ctx).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.lineStrong,
                        borderRadius: BorderRadius.circular(Eco.rPill),
                      ),
                    ),
                  ),
                  const SizedBox(height: Eco.s16),
                  child,
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showLevelInfoSheet(BuildContext context, EcoStore store) {
  final LevelInfo level = levelOf(store.points);
  return showEcoSheet(
    context,
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _sheetTitle('Eco Points & levels'),
        const SizedBox(height: 8),
        Text(
          'Levels are milestones that show your Eco Points progress. '
          'They are profile ranks and do not unlock app features.',
          style:
              F.b(13, height: 1.45, color: Theme.of(context).colorScheme.muted),
        ),
        const SizedBox(height: 16),
        EcoCard(
          flat: true,
          tone: EcoCardTone.mint,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              LevelRing(pct: level.pct, size: 64, thickness: 7),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Level ${level.idx + 1} · ${level.name}',
                      style: F.d(17),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${groupThousands(store.points)} Eco Points',
                      style: F.b(
                        13,
                        wght: 800,
                        color: Theme.of(context).colorScheme.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (level.nextName != null)
                      Text(
                        '${groupThousands(level.toNext)} points to '
                        'Level ${level.idx + 2} · ${level.nextName}',
                        style: F.b(
                          12,
                          wght: 700,
                          color: Theme.of(context).colorScheme.ink2,
                        ),
                      )
                    else
                      Text(
                        'Highest current level reached',
                        style: F.b(
                          12,
                          wght: 700,
                          color: Theme.of(context).colorScheme.ink2,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              MascotArt(
                'level-${level.idx + 1}',
                width: 82,
                height: 104,
                alignment: Alignment.bottomRight,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Earn points',
          style: F.d(16),
        ),
        const SizedBox(height: 5),
        Text(
          'Log an activity to earn 15 Eco Points. Complete and claim '
          'challenges to earn their displayed reward.',
          style:
              F.b(13, height: 1.45, color: Theme.of(context).colorScheme.muted),
        ),
        const SizedBox(height: 16),
        Text('Level milestones', style: F.d(16)),
        const SizedBox(height: 8),
        for (int i = 0; i < kLevels.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == level.idx
                        ? Theme.of(context).colorScheme.leaf
                        : Theme.of(context).colorScheme.surface2,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: F.b(
                      12,
                      wght: 900,
                      color: i == level.idx
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    kLevels[i].name,
                    style: F.b(13, wght: 800),
                  ),
                ),
                Text(
                  '${groupThousands(kLevels[i].min)} pts',
                  style: F.b(
                    12,
                    wght: 700,
                    color: Theme.of(context).colorScheme.muted,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

Widget _sheetTitle(String text) =>
    Text(text, style: F.d(20), maxLines: 1, overflow: TextOverflow.ellipsis);

class SheetTitle extends StatelessWidget {
  const SheetTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: F.d(20),
        textAlign: TextAlign.center,
      );
}

Widget _statCell(String value, String caption,
    {double size = 20, required ColorScheme cs}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        value,
        style: F.d(size),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 2),
      Text(caption, style: F.b(12.5, wght: 700, color: cs.muted)),
    ],
  );
}

Widget _twoCol(List<Widget> cells) {
  final List<Widget> rows = <Widget>[];
  for (int i = 0; i < cells.length; i += 2) {
    rows.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: cells[i]),
          const SizedBox(width: 14),
          Expanded(
            child:
                i + 1 < cells.length ? cells[i + 1] : const SizedBox.shrink(),
          ),
        ],
      ),
    );
    if (i + 2 < cells.length) rows.add(const SizedBox(height: 14));
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
}

/// Entry detail — what was logged, and a way to remove it.
Future<void> showActivitySheet(
  BuildContext context,
  EcoStore store,
  String id,
) {
  final cs = Theme.of(context).colorScheme;
  Entry? entry;
  for (final Entry x in store.activities) {
    if (x.id == id) entry = x;
  }
  if (entry == null) return Future<void>.value();
  final Entry a = entry;
  final ActivityDef? def = store.activityOf(a.key);
  if (def == null) return Future<void>.value();
  final Cat c = catOf(a.cat);

  return showEcoSheet(
    context,
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _sheetTitle(def.name),
        const SizedBox(height: 4),
        Text(
          '${dayLabel(daysAgo(a.at))} · ${timeLabel(a.at)}',
          style: F.b(13, height: 1.45, color: cs.muted),
        ),
        const SizedBox(height: 16),
        EcoCard(
          flat: true,
          child: _twoCol(<Widget>[
            _statCell(store.amountLabel(def, a.amount), 'Amount', cs: cs),
            _statCell('${fmt2(a.co2)} kg', 'CO₂e', cs: cs),
            _statCell(c.name, 'Category', size: 16, cs: cs),
            _statCell(
              def.factor == 0 ? '0' : fmt2(store.displayFactor(def)),
              'kg per ${store.unitFor(def)}',
              size: 16,
              cs: cs,
            ),
          ]),
        ),
        const SizedBox(height: 16),
        EcoButton(
          label: 'Delete this entry',
          leading: 'trash',
          tone: EcoButtonTone.ghost,
          block: true,
          onPressed: () {
            Navigator.of(context).pop();
            store.deleteActivity(a.id);
          },
        ),
      ],
    ),
  );
}
