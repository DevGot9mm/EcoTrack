part of '../profile_screen.dart';

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.store});
  final EcoStore store;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool wide = context.windowSize != WindowSize.compact;
    final Map<String, int> originalOrder = <String, int>{
      for (int i = 0; i < store.badges.length; i++) store.badges[i].id: i,
    };
    final List<Achievement> orderedBadges = List<Achievement>.of(store.badges)
      ..sort((Achievement a, Achievement b) {
        if (a.unlocked != b.unlocked) return a.unlocked ? 1 : -1;
        return originalOrder[a.id]!.compareTo(originalOrder[b.id]!);
      });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionHead(title: 'Badges'),
        const SizedBox(height: Eco.s12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 5 : 3,
            crossAxisSpacing: wide ? 12 : 10,
            mainAxisSpacing: wide ? 12 : 10,
            childAspectRatio: wide ? 1.1 : 0.82,
          ),
          itemCount: orderedBadges.length,
          itemBuilder: (BuildContext context, int i) {
            final Achievement b = orderedBadges[i];
            return _BadgeItem(
              b: b,
              cs: cs,
              onTap: () => _showBadgeDetail(context, b),
            );
          },
        ),
      ],
    );
  }

  void _showBadgeDetail(BuildContext context, Achievement b) {
    final cs = Theme.of(context).colorScheme;
      showEcoSheet(
        context,
        maxWidth: 920,
        Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: b.unlocked ? cs.mint : cs.surface2,
                shape: BoxShape.circle,
              ),
              child: EcoIcon(b.icon,
                  size: 26, color: b.unlocked ? cs.leaf : cs.muted),
            ),
          ),
          const SizedBox(height: Eco.s12),
          Text(
            b.name,
            style: F.d(18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Eco.s4),
          Text(
            b.desc,
            style:
                F.role(context.type.bodySmall!, color: cs.muted, height: 1.45),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Eco.s12),
          Text(
            b.unlocked ? 'Unlocked' : 'Locked',
            style: F.role(context.type.bodySmall!,
                wght: 800, color: b.unlocked ? cs.leaf : cs.muted),
          ),
          const SizedBox(height: Eco.s12),
          EcoBar(
            value: b.progress / b.target,
            color: b.unlocked ? cs.leaf : cs.muted,
            height: 8,
          ),
          const SizedBox(height: 6),
          Text(
            '${b.progress.round()} of ${b.target.round()} complete',
            style:
                F.role(context.type.bodySmall!, color: cs.muted, height: 1.45),
          ),
          const SizedBox(height: 14),
          EcoButton(
            label: 'Close',
            block: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      maxHeightFactor: 0.72,
    );
  }
}

class _BadgeItem extends StatefulWidget {
  const _BadgeItem({required this.b, required this.cs, required this.onTap});

  final Achievement b;
  final ColorScheme cs;
  final VoidCallback onTap;

  @override
  State<_BadgeItem> createState() => _BadgeItemState();
}

class _BadgeItemState extends State<_BadgeItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final double angle = _hovering ? math.pi : 0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: angle),
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeInOutCubic,
          builder: (BuildContext context, double value, Widget? child) {
            final bool showingBack = value > math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateY(value),
              child: HolographicCard(
                borderRadius: Eco.rCard,
                backgroundColor: Colors.transparent,
                hoverScale: 1.01,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        widget.b.unlocked ? widget.cs.mint : widget.cs.surface,
                    border: Border.all(
                      color: widget.b.unlocked
                          ? widget.cs.outline
                          : widget.cs.lineStrong,
                    ),
                    borderRadius: BorderRadius.circular(Eco.rCard),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: showingBack
                      ? _backFace(widget.cs)
                      : _frontFace(widget.cs),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _frontFace(ColorScheme cs) {
    final Achievement b = widget.b;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: b.unlocked ? cs.mint : cs.surface3,
            shape: BoxShape.circle,
          ),
          child: EcoIcon(
            b.icon,
            size: 24,
            color: b.unlocked ? cs.leaf : cs.muted,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          b.name,
          style: F.b(11.5, wght: 800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          '${b.progress.round()}/${b.target.round()}',
          style: F.b(12, height: 1.3, color: cs.muted),
        ),
        const SizedBox(height: Eco.s4),
        SizedBox(
          height: 5,
          child: b.unlocked
              ? Center(child: EcoIcon('check', size: 14, color: cs.leaf))
              : EcoBar(value: b.progress / b.target, color: cs.leaf, height: 5),
        ),
      ],
    );
  }

  Widget _backFace(ColorScheme cs) {
    final Achievement b = widget.b;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(math.pi),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            b.name,
            style: F.b(12, wght: 800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: Text(
                b.desc,
                style: F.b(11, height: 1.3, color: cs.ink2),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Text(
            b.unlocked ? 'Achieved' : 'In progress',
            style: F.b(11, wght: 800, color: b.unlocked ? cs.leaf : cs.muted),
          ),
          const SizedBox(height: 3),
          Text(
            '${b.progress.round()} of ${b.target.round()}',
            style: F.b(11, color: cs.muted),
          ),
        ],
      ),
    );
  }
}

