part of 'common.dart';

/* ==========================================================================
   Chips / segmented
   ========================================================================== */

class EcoChip extends StatelessWidget {
  const EcoChip({
    super.key,
    required this.label,
    this.active = false,
    this.dotColor,
    this.onTap,
  });

  final String label;
  final bool active;
  final Color? dotColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color fg = active ? cs.onPrimary : cs.ink2;
    return Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Eco.rPill),
      child: Container(
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? cs.leaf : cs.surface,
          border: Border.all(color: active ? cs.leaf : cs.lineStrong),
          borderRadius: BorderRadius.circular(Eco.rPill),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (dotColor != null) ...<Widget>[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(Eco.rPill),
                ),
              ),
              const SizedBox(width: 7),
            ],
            Text(label, style: F.b(13.5, wght: 700, color: fg)),
          ],
        ),
      ),
    );
  }
}

class EcoSegmented extends StatelessWidget {
  const EcoSegmented({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: <ButtonSegment<int>>[
        for (int i = 0; i < items.length; i++)
          ButtonSegment<int>(value: i, label: Text(items[i])),
      ],
      selected: <int>{index},
      showSelectedIcon: false,
      onSelectionChanged: (Set<int> selection) {
        if (selection.isNotEmpty) onChanged(selection.first);
      },
    );
  }
}

/* ==========================================================================
   Bars, badges, pills
   ========================================================================== */

class EcoBar extends StatelessWidget {
  const EcoBar({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
    this.track,
  });

  /// 0..1
  final double value;
  final Color? color;
  final double height;
  final Color? track;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double v = value.isNaN ? 0 : clampDouble(value, 0, 1);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double w = c.maxWidth.isFinite ? c.maxWidth : 0;
        return Stack(
          children: <Widget>[
            Container(
              height: height,
              decoration: BoxDecoration(
                color: track ?? cs.surface2,
                borderRadius: BorderRadius.circular(Eco.rPill),
              ),
            ),
            AnimatedContainer(
              duration: Eco.dur3,
              curve: Eco.easeOut,
              height: height,
              width: w * v,
              decoration: BoxDecoration(
                color: color ?? cs.leaf,
                borderRadius: BorderRadius.circular(Eco.rPill),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CatBadge extends StatelessWidget {
  const CatBadge({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 42,
    this.iconSize = 21,
    this.radius = 14,
  });

  final String icon;
  final Color background;
  final Color foreground;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: EcoIcon(icon, size: iconSize, color: foreground),
    );
  }
}

class StatePill extends StatelessWidget {
  const StatePill({
    super.key,
    required this.label,
    this.background,
    this.foreground,
    this.icon,
  });

  final String label;
  final Color? background;
  final Color? foreground;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color bg = background ?? cs.surface2;
    final Color fg = foreground ?? cs.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Eco.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            EcoIcon(icon!, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: F.role(context.type.labelMedium!, wght: 800, color: fg)),
        ],
      ),
    );
  }
}

