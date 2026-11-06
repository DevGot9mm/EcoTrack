part of 'common.dart';

/* ==========================================================================
   Structure
   ========================================================================== */

/// Title bar with screen titles aligned to the content gutter.
class EcoTopBar extends StatelessWidget {
  const EcoTopBar({
    super.key,
    required this.title,
    this.noBack = true,
    this.onBack,
    this.right,
    this.centerTitle = false,
  });

  final String title;
  final bool noBack;
  final VoidCallback? onBack;
  final Widget? right;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Widget left = noBack
        ? const SizedBox.shrink()
        : EcoIconButton('chevronL', onPressed: onBack ?? store.back);

    final Widget titleWidget = Text(
      title,
      style: textTheme.titleLarge,
      textAlign: centerTitle ? TextAlign.center : TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(Eco.s20, 6, Eco.s20, 14),
      child: Row(
        children: <Widget>[
          if (!noBack) ...<Widget>[left, const SizedBox(width: 10)],
          Expanded(child: titleWidget),
          const SizedBox(width: 10),
          right ?? const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class SectionHead extends StatelessWidget {
  const SectionHead({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Eco.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Both sides are flexible so a long action wraps instead of
          // overflowing at large text scales.
          Flexible(child: Text(title, style: textTheme.titleLarge)),
          if (action != null) ...<Widget>[
            const SizedBox(width: Eco.s12),
            Flexible(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: action!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Standard screen body: optional bar, a scrolling middle, optional footer.
class EcoScreen extends StatelessWidget {
  const EcoScreen({
    super.key,
    this.header,
    this.child,
    this.children,
    this.footer,
    this.padding = const EdgeInsets.fromLTRB(Eco.s20, 0, Eco.s20, 28),
    this.scrollController,
  }) : assert(child != null || children != null);

  final Widget? header;
  final Widget? child;
  final List<Widget>? children;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final Widget scrollable = children == null
        ? SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            padding: padding,
            child: child,
          )
        : ListView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            padding: padding,
            children: children!,
          );
    return Column(
      children: <Widget>[
        if (header != null) header!,
        Expanded(child: scrollable),
        if (footer != null) footer!,
      ],
    );
  }
}

/// The soft gradient strip that sits above the fold on the add/result flows.
class FlowFooter extends StatelessWidget {
  const FlowFooter({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(Eco.s20, Eco.s12, Eco.s20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            Theme.of(context).colorScheme.ground,
            Theme.of(context).colorScheme.ground.withValues(alpha: 0),
          ],
          stops: const <double>[0, 0.62],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _gappedVertical(children, 10),
      ),
    );
  }
}

List<Widget> _gappedVertical(List<Widget> items, double gap) {
  if (items.length < 2) return items;
  final List<Widget> out = <Widget>[];
  for (int i = 0; i < items.length; i++) {
    if (i > 0) out.add(SizedBox(height: gap));
    out.add(items[i]);
  }
  return out;
}

/// A horizontal rail: the next card peeks past the edge, and the trailing pad
/// survives the overflow.
class EcoRail extends StatelessWidget {
  const EcoRail({
    super.key,
    required this.children,
    this.pad = 20,
    this.gap = 8,
  });

  final List<Widget> children;
  final double pad;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Row(children: _gapped(children, gap)),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.caption,
    this.valueSize = 20,
  });

  final String value;
  final String caption;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return EcoCard(
      flat: true,
      padding: const EdgeInsets.symmetric(horizontal: Eco.s12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(fontSize: valueSize),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 12.5,
              letterSpacing: 0,
              color: cs.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable list row with optional leading and trailing details.
class EcoListRow extends StatelessWidget {
  const EcoListRow({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingText,
    this.valueText,
    this.onTap,
    this.danger = false,
    this.showChevron = true,
  });

  final String label;
  final String? leadingIcon;
  final String? trailingText;
  final String? valueText;
  final VoidCallback? onTap;
  final bool danger;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding:
            const EdgeInsets.symmetric(horizontal: Eco.s16, vertical: Eco.s12),
        color: cs.surface,
        child: Row(
          children: <Widget>[
            if (leadingIcon != null) ...<Widget>[
              EcoIcon(
                leadingIcon!,
                size: 19,
                color: danger ? cs.danger : cs.leaf,
              ),
              const SizedBox(width: Eco.s12),
            ],
            Expanded(
              child: Text(
                label,
                style: F.b(15, wght: 700, color: danger ? cs.danger : cs.ink),
              ),
            ),
            if (valueText != null)
              Text(valueText!,
                  style: F.role(context.type.bodySmall!,
                      color: cs.muted, height: 1.45))
            else if (trailingText != null)
              Text(trailingText!,
                  style: F.role(context.type.bodySmall!,
                      color: cs.muted, height: 1.45)),
            if (showChevron) ...<Widget>[
              const SizedBox(width: Eco.s8),
              Icon(
                Icons.chevron_right,
                size: 17,
                color: cs.muted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EcoList extends StatelessWidget {
  const EcoList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) rows.add(Container(height: 1, color: cs.outline));
      rows.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(Eco.rCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }
}

class EcoEmptyState extends StatelessWidget {
  const EcoEmptyState({
    super.key,
    required this.title,
    required this.body,
    required this.mascot,
    this.action,
  });

  final String title;
  final String body;
  final String mascot;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Eco.s20, vertical: 30),
      child: Column(
        children: <Widget>[
          MascotArt(mascot, width: 118),
          const SizedBox(height: 10),
          Text(title,
              style: F.role(context.type.titleMedium!,
                  wght: 600, ls: -0.01, height: 1.25),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Text(body,
                style:
                    F.role(context.type.labelLarge!).copyWith(color: cs.muted),
                textAlign: TextAlign.center),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(height: 10),
            action!,
          ],
        ],
      ),
    );
  }
}

/// The floating amber action button.
class EcoFab extends StatelessWidget {
  const EcoFab(
      {super.key,
      required this.label,
      required this.onTap,
      this.icon = 'plus',
      this.tablet = false});

  final String label;
  final VoidCallback onTap;
  final String icon;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      borderRadius: BorderRadius.circular(Eco.rPill),
      child: Container(
        constraints: BoxConstraints(minHeight: tablet ? 58 : 54),
        padding: EdgeInsets.only(
            left: tablet ? 20 : 17, right: tablet ? 23 : Eco.s20),
        decoration: BoxDecoration(
          color: cs.amber,
          borderRadius: BorderRadius.circular(Eco.rPill),
          boxShadow: Eco.shadowFab,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            EcoIcon(icon, size: tablet ? 21 : 20, color: cs.onSecondary),
            const SizedBox(width: 9),
            Text(
              label,
              style: F.b(tablet ? 16 : 15, wght: 800, color: cs.onSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin uppercase label used above numbers.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      text.toUpperCase(),
      style: textTheme.labelSmall?.copyWith(color: color ?? cs.muted),
    );
  }
}
