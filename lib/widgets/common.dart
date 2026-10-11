import 'package:flutter/material.dart';

import '../icons.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';

/* ==========================================================================
   Primitives
   ========================================================================== */

/// Gives every tappable surface the prototype's subtle press transform
/// plus a smooth frosted-glass hover effect.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.975,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  bool _hovering = false;

  void _setDown(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  void _setHover(bool v) {
    if (_hovering != v) setState(() => _hovering = v);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: widget.onTap == null ? null : (_) => _setHover(true),
      onExit: widget.onTap == null ? null : (_) => _setHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: widget.onTap == null ? null : (_) => _setDown(true),
        onTapUp: widget.onTap == null ? null : (_) => _setDown(false),
        onTapCancel: widget.onTap == null ? null : () => _setDown(false),
        child: Stack(
          children: [
            AnimatedScale(
              scale: _down ? widget.scale : 1,
              duration: Eco.dur1,
              curve: Eco.easeOut,
              child: widget.child,
            ),
            if (_hovering && widget.onTap != null)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Eco.rCard),
                    border: Border.all(
                      color: cs.leaf.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SheetGrab extends StatelessWidget {
  const SheetGrab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 42,
      height: 5,
      decoration: BoxDecoration(
        color: cs.lineStrong,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 17,
      height: 17,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
        backgroundColor: Colors.white.withAlpha(115),
      ),
    );
  }
}

List<Widget> _gapped(List<Widget> items, double gap) {
  if (items.length < 2) return items;
  final List<Widget> out = <Widget>[];
  for (int i = 0; i < items.length; i++) {
    if (i > 0) out.add(SizedBox(width: gap));
    out.add(items[i]);
  }
  return out;
}

/// Horizontal padding used by every screen block.
class HPad extends StatelessWidget {
  const HPad({super.key, required this.child, this.value = 20});

  final Widget child;
  final double value;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: value), child: child);
}

/// Lays items out in fixed-column rows. Every card in a row is stretched to the
/// tallest, which is what the prototype's CSS grid does.
///
/// Cells are given explicit widths rather than `Expanded`, so the intrinsic
/// height pass stays cheap and well-defined. Nothing inside a cell may use a
/// `LayoutBuilder` (so no [EcoBar]) because intrinsic sizing cannot measure it.
class EcoGrid extends StatelessWidget {
  const EcoGrid({
    super.key,
    required this.items,
    this.columns = 2,
    this.gap = 12,
  });

  final List<Widget> items;
  final int columns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final int cols = columns < 1 ? 1 : columns;
        final double cellW =
            c.maxWidth.isFinite ? (c.maxWidth - gap * (cols - 1)) / cols : 0;

        final List<Widget> rows = <Widget>[];
        for (int i = 0; i < items.length; i += cols) {
          final List<Widget> row = <Widget>[];
          for (int k = 0; k < cols; k++) {
            final int idx = i + k;
            if (k > 0) row.add(SizedBox(width: gap));
            row.add(
              SizedBox(
                width: cellW,
                child:
                    idx < items.length ? items[idx] : const SizedBox.shrink(),
              ),
            );
          }
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: row,
              ),
            ),
          );
          if (i + cols < items.length) rows.add(SizedBox(height: gap));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

/* ==========================================================================
   Mascot art
   ========================================================================== */

const Map<String, String> _avatarAssetPaths = <String, String>{
  'image.png': 'image.png',
  'image-2.png': 'image-2.png',
  'image-5.png': 'image-5.png',
};

String mascotPath(String name) =>
    _avatarAssetPaths[name] ?? 'assets/mascot/$name.png';

class MascotArt extends StatelessWidget {
  const MascotArt(
    this.name, {
    super.key,
    required this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  final String name;
  final double width;
  final double? height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      mascotPath(name),
      width: width,
      height: height,
      fit: BoxFit.contain,
      alignment: alignment,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// The cropped mascot used inside avatars and chips — the art is scaled past the
/// rounded frame and clipped, exactly as the prototype does.
class MascotCrop extends StatelessWidget {
  const MascotCrop(
    this.name, {
    super.key,
    required this.size,
    required this.radius,
    this.scale = 1.28,
    this.dx = -0.14,
    this.dy = 0.04,
    this.background,
    this.circular = false,
    this.photoScale = 1,
  });

  final String name;
  final double size;
  final double radius;
  final double scale;
  final double dx;
  final double dy;
  final Color? background;
  final bool circular;
  final double photoScale;

  @override
  Widget build(BuildContext context) {
    final Color bg = background ?? Theme.of(context).colorScheme.mint;
    final Widget image = Container(
      width: size,
      height: size,
      color: bg,
      child: _avatarAssetPaths.containsKey(name)
          ? Image.asset(
              mascotPath(name),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            )
          : Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                Positioned(
                  left: size * dx,
                  top: size * dy,
                  width: size * scale,
                  child: Image.asset(
                    mascotPath(name),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ],
            ),
    );

    if (circular) {
      return ClipOval(
        child: Transform.scale(scale: photoScale, child: image),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: image,
    );
  }
}

/* ==========================================================================
   Card
   ========================================================================== */

enum EcoCardTone { plain, mint, amber, dark }

class EcoCard extends StatelessWidget {
  const EcoCard({
    super.key,
    required this.child,
    this.tone = EcoCardTone.plain,
    this.flat = false,
    this.padding = const EdgeInsets.all(18),
    this.radius = Eco.rCard,
    this.onTap,
    this.gradient,
    this.background,
    this.highlighted = false,
  });

  final Widget child;
  final EcoCardTone tone;
  final bool flat;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? background;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg = cs.surface;
    Color border = cs.outline;
    List<BoxShadow> shadows = flat ? const <BoxShadow>[] : Eco.shadow1;
    Gradient? grad = gradient;

    switch (tone) {
      case EcoCardTone.plain:
        break;
      case EcoCardTone.mint:
        bg = cs.mint;
        border = cs.lineMint;
        break;
      case EcoCardTone.amber:
        bg = cs.amberTint;
        border = cs.lineAmber;
        break;
      case EcoCardTone.dark:
        grad = cs.brightness == Brightness.dark ? null : Eco.cardDark;
        border = const Color(0x1AFFFFFF);
        shadows = cs.brightness == Brightness.dark ? const <BoxShadow>[] : Eco.shadowDarkCard;
        break;
    }

    if (background != null) bg = background!;

    double borderWidth = 1;
    if (highlighted) {
      border = cs.leaf;
      borderWidth = 1.5;
      shadows = <BoxShadow>[
        BoxShadow(color: cs.leaf.withValues(alpha: 0.14), spreadRadius: 3),
      ];
    }

    final Widget box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: grad == null ? bg : null,
        gradient: grad,
        border: Border.all(color: border, width: borderWidth),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap == null) return box;
    return Pressable(onTap: onTap, scale: 0.99, child: box);
  }
}

/* ==========================================================================
   Buttons
   ========================================================================== */

enum EcoButtonTone { primary, amber, ghost, onDark }

class EcoButton extends StatelessWidget {
  const EcoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.tone = EcoButtonTone.primary,
    this.block = false,
    this.loading = false,
    this.loadingLabel,
    this.minHeight = 52,
    this.radius = Eco.rBtn,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? leading;
  final String? trailing;
  final EcoButtonTone tone;
  final bool block;
  final bool loading;
  final String? loadingLabel;
  final double minHeight;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    Color? border;
    List<BoxShadow> shadows;

    switch (tone) {
      case EcoButtonTone.primary:
        bg = cs.leaf;
        fg = const Color(0xFFF4FAF0);
        border = null;
        shadows = Eco.shadowPrimaryBtn;
        break;
      case EcoButtonTone.amber:
        bg = cs.amber;
        fg = const Color(0xFF3A2703);
        border = null;
        shadows = Eco.shadowAmberBtn;
        break;
      case EcoButtonTone.ghost:
        bg = cs.surface;
        fg = cs.ink;
        border = cs.lineStrong;
        shadows = const <BoxShadow>[];
        break;
      case EcoButtonTone.onDark:
        bg = const Color(0x24FFFFFF);
        fg = const Color(0xFFF2F9EC);
        border = const Color(0x47FFFFFF);
        shadows = const <BoxShadow>[];
        break;
    }

    final bool enabled = onPressed != null && !loading;

    final List<Widget> content = <Widget>[
      if (loading)
        const _Spinner()
      else if (leading != null)
        EcoIcon(leading!, size: 19, color: fg),
      Flexible(
        child: Text(
          loading ? (loadingLabel ?? label) : label,
          style: F.b(16, wght: 800, color: fg),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (!loading && trailing != null) EcoIcon(trailing!, size: 19, color: fg),
    ];

    // The prototype dims a disabled control with `opacity: .55`; keeping the
    // whole control translucent matches that better than tinting the fill.
    final Widget button = Pressable(
      onTap: enabled ? onPressed : null,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: border == null ? null : Border.all(color: border),
          boxShadow: enabled ? shadows : const <BoxShadow>[],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _gapped(content, 8),
        ),
      ),
    );

    final Widget result =
        enabled ? button : Opacity(opacity: 0.55, child: button);

    return SizedBox(width: block ? double.infinity : null, child: result);
  }
}

class EcoIconButton extends StatelessWidget {
  const EcoIconButton(
    this.icon, {
    super.key,
    this.onPressed,
    this.plain = false,
    this.size = 40,
    this.iconSize = 19,
    this.iconColor,
  });

  final String icon;
  final VoidCallback? onPressed;
  final bool plain;
  final double size;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onPressed,
      scale: 0.94,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: plain ? Colors.transparent : cs.surface,
          border: Border.all(
            color: plain ? Colors.transparent : cs.outline,
          ),
          borderRadius: BorderRadius.circular(13),
        ),
        child: EcoIcon(icon, size: iconSize, color: iconColor ?? cs.ink2),
      ),
    );
  }
}

class SectionLink extends StatelessWidget {
  const SectionLink({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(label, style: F.b(13.5, wght: 800, color: cs.leaf)),
      ),
    );
  }
}

class MiniBtn extends StatelessWidget {
  const MiniBtn({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.on = false,
    this.onTap,
  });

  final String label;
  final String? icon;
  final String? trailingIcon;
  final bool on;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color fg = on ? const Color(0xFFF4FAF0) : cs.ink2;
    final List<Widget> content = <Widget>[
      if (icon != null) EcoIcon(icon!, size: 16, color: fg),
      Flexible(
        child: Text(
          label,
          style: F.b(13, wght: 800, color: fg),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (trailingIcon != null) EcoIcon(trailingIcon!, size: 16, color: fg),
    ];
    return Pressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: on ? cs.leaf : cs.surface,
          border: Border.all(color: on ? cs.leaf : cs.lineStrong),
          borderRadius: BorderRadius.circular(Eco.rPill),
        ),
        alignment: Alignment.center,
        child:
            Row(mainAxisSize: MainAxisSize.min, children: _gapped(content, 6)),
      ),
    );
  }
}

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
    final Color fg = active ? const Color(0xFFF4FAF0) : cs.ink2;
    return Pressable(
      onTap: onTap,
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
    final cs = Theme.of(context).colorScheme;
    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final bool on = i == index;
      cells.add(
        Expanded(
          child: Pressable(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: Eco.dur1,
              curve: Eco.easeOut,
              constraints: const BoxConstraints(minHeight: 40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? cs.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(Eco.rPill),
                boxShadow: on ? Eco.shadow1 : const <BoxShadow>[],
              ),
              child: Text(
                items[i],
                style: F.b(
                  14,
                  wght: 800,
                  color: on ? cs.leaf : cs.muted,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surface2,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(Eco.rPill),
      ),
      child: Row(children: _gapped(cells, 4)),
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
          Text(label, style: F.b(12.5, wght: 800, color: fg)),
        ],
      ),
    );
  }
}

/* ==========================================================================
   Structure
   ========================================================================== */

/// Title bar. `noBack` reserves the trailing space so the title stays centred
/// on the same axis as screens that do show a back control.
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
    final Widget left = noBack
        ? const SizedBox(width: 40)
        : EcoIconButton(
            'chevronL',
            onPressed: onBack ?? store.back,
          );

    final Widget titleWidget = Text(
      title,
      style: F.d(21),
      textAlign: centerTitle ? TextAlign.center : TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Row(
        children: <Widget>[
          left,
          const SizedBox(width: 10),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Expanded(child: Text(title, style: F.h2)),
          if (action != null) action!,
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
    required this.child,
    this.footer,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 28),
  });

  final Widget? header;
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (header != null) header!,
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: padding,
            child: child,
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(gradient: Eco.footerFade),
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
    return EcoCard(
      flat: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: F.d(valueSize),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(caption, style: F.b(12.5, wght: 700, color: cs.muted)),
        ],
      ),
    );
  }
}

/// A card that behaves like a data cell: big number on top, caption underneath.
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: cs.surface,
        child: Row(
          children: <Widget>[
            if (leadingIcon != null) ...<Widget>[
              EcoIcon(
                leadingIcon!,
                size: 19,
                color: danger ? cs.danger : cs.leaf,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: F.b(15, wght: 700, color: danger ? cs.danger : cs.ink),
              ),
            ),
            if (valueText != null)
              Text(valueText!, style: F.b(13, height: 1.45, color: cs.muted))
            else if (trailingText != null)
              Text(trailingText!, style: F.b(13, height: 1.45, color: cs.muted)),
            if (showChevron) ...<Widget>[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 17,
                color: Color(0xFFA8B3A9),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: <Widget>[
          MascotArt(mascot, width: 118),
          const SizedBox(height: 10),
          Text(title, style: F.h3, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Text(body,
                style: F.small.copyWith(color: cs.muted),
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
      this.icon = 'plus'});

  final String label;
  final VoidCallback onTap;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.only(left: 17, right: 20),
        decoration: BoxDecoration(
          color: cs.amber,
          borderRadius: BorderRadius.circular(Eco.rPill),
          boxShadow: Eco.shadowFab,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            EcoIcon(icon, size: 20, color: const Color(0xFF3A2703)),
            const SizedBox(width: 9),
            Text(
              label,
              style: F.b(15, wght: 800, color: const Color(0xFF3A2703)),
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
    return Text(
      text.toUpperCase(),
      style: F.eyebrow(context).copyWith(color: color ?? cs.muted),
    );
  }
}
