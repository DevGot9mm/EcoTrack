import 'package:flutter/material.dart';

import '../icons.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final List<Tip> filtered = store.tipFilter == 'all'
        ? kTips
        : kTips.where((Tip t) => t.cat == store.tipFilter).toList();

    return EcoScreen(
      header: const EcoTopBar(title: 'Eco Tips'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 16),
          _FilterBar(store: store),
          const SizedBox(height: 22),
          ...filtered.map((Tip tip) => _TipCard(tip: tip, store: store)),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          _filterChip('All', 'all', store),
          const SizedBox(width: 8),
          ...kCatOrder.map((String cat) {
            final c = catOf(cat);
            return _filterChip(c.name, cat, store);
          }),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String cat, EcoStore store) {
    final bool active = store.tipFilter == cat;
    return Pressable(
      onTap: () => store.setTipFilter(cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Eco.forest : Eco.surface,
          border: Border.all(
            color: active ? Eco.forest : Eco.lineStrong,
          ),
          borderRadius: BorderRadius.circular(Eco.rPill),
        ),
        child: Text(
          label,
          style: F.b(13, wght: 700, color: active ? Colors.white : Eco.ink2),
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
                      color: c.tint,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: EcoIcon(tip.icon, size: 22, color: c.ink),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(tip.title, style: F.d(16.5)),
                        const SizedBox(height: 4),
                        Text(tip.action, style: F.body2),
                      ],
                    ),
                  ),
                  if (store.savedTips[tip.id] ?? false)
                    const EcoIcon('bookmark', size: 20, color: Eco.amber),
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
                    style: F.b(13, wght: 800, color: Eco.forest),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tip.why,
                    style: F.small.copyWith(color: Eco.ink2),
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
            crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: Eco.dur2,
          ),
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              EcoIconButton(
                store.savedTips[tip.id] ?? false ? 'bookmark' : 'bookmark',
                plain: true,
                iconSize: 18,
                iconColor: (store.savedTips[tip.id] ?? false) ? Eco.amber : Eco.ink2,
                onPressed: () => store.toggleTipSave(tip.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
