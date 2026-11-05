import 'package:flutter/material.dart';

import '../icons.dart';
import '../models.dart';
import '../responsive.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final List<Tip> filtered = switch (store.tipFilter) {
      TipFilter.all => kTips,
      TipFilter.saved =>
        kTips.where((Tip tip) => store.savedTips[tip.id] ?? false).toList(),
      final TipFilter filter =>
        kTips.where((Tip tip) => tip.cat == filter.category).toList(),
    };

    return EcoScreen(
      header: EcoTopBar(title: 'Eco Tips', noBack: false, onBack: store.back),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 16),
          _FilterBar(store: store),
          const SizedBox(height: 22),
          if (filtered.isEmpty)
            const EcoEmptyState(
              mascot: 'face-curious',
              title: 'No saved tips yet',
              body: 'Bookmark a tip and it will appear here for later.',
            )
          else
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int columns = switch (context.windowSize) {
                  WindowSize.compact => 1,
                  WindowSize.medium => 2,
                  WindowSize.expanded => 3,
                };
                final double width =
                    (constraints.maxWidth - 12 * (columns - 1)) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    for (final Tip tip in filtered)
                      SizedBox(
                        width: width,
                        child: _TipCard(tip: tip, store: store),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.store});
  final EcoStore store;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          _filterChip('All', TipFilter.all, store, cs),
          const SizedBox(width: 8),
          ...kCatOrder.map((CarbonCategory category) {
            final c = catOf(category);
            return _filterChip(
              c.name,
              TipFilterCategory.forCategory(category),
              store,
              cs,
            );
          }),
          const SizedBox(width: 8),
          _filterChip(
            'Saved',
            TipFilter.saved,
            store,
            cs,
            icon: 'bookmark',
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String label,
    TipFilter filter,
    EcoStore store,
    ColorScheme cs, {
    String? icon,
  }) {
    final bool active = store.tipFilter == filter;
    return Pressable(
      onTap: () => store.setTipFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? cs.leaf : cs.surface,
          border: Border.all(
            color: active ? cs.leaf : cs.lineStrong,
          ),
          borderRadius: BorderRadius.circular(Eco.rPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              EcoIcon(
                icon,
                size: 14,
                color: active ? cs.onPrimary : cs.ink2,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: F.b(13, wght: 700, color: active ? cs.onPrimary : cs.ink2),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip, required this.store});

  final Tip tip;
  final EcoStore store;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = catOf(tip.cat);
    final bool open = store.openTips[tip.id] ?? false;

    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => store.toggleTipWhy(tip.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          c.resolve(cs, color: store.categoryColor(c.id)).tint,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: EcoIcon(
                      tip.icon,
                      size: 22,
                      color:
                          c.resolve(cs, color: store.categoryColor(c.id)).ink,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(tip.title, style: F.d(16.5)),
                        const SizedBox(height: 4),
                        Text(tip.action,
                            style: F.b(14.5, height: 1.5, color: cs.ink2)),
                      ],
                    ),
                  ),
                  if (store.savedTips[tip.id] ?? false)
                    EcoIcon('bookmark', size: 20, color: cs.amber),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Why it matters',
                    style: F.b(13, wght: 800, color: cs.leaf),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tip.why,
                    style: F.small.copyWith(color: cs.ink2),
                  ),
                  const SizedBox(height: 12),
                  EcoButton(
                    label: 'Try this',
                    leading: 'arrowRight',
                    tone: EcoButtonTone.primary,
                    radius: Eco.rPill,
                    minHeight: 38,
                    block: true,
                    onPressed: () => store.tryTip(tip.id),
                  ),
                ],
              ),
            ),
            crossFadeState:
                open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: Eco.dur2,
          ),
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              EcoIconButton(
                store.savedTips[tip.id] ?? false ? 'bookmarkOn' : 'bookmark',
                plain: true,
                iconSize: 18,
                iconColor:
                    (store.savedTips[tip.id] ?? false) ? cs.amber : cs.ink2,
                onPressed: () => store.toggleTipSave(tip.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
