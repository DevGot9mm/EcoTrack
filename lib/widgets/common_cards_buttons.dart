part of 'common.dart';

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
    this.padding = const EdgeInsets.all(Eco.s16 + 2),
    this.radius = Eco.rCard,
    this.onTap,
    this.gradient,
    this.background,
    this.highlighted = false,
    this.fillWidth = false,
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
  final bool fillWidth;

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
        grad = cs.heroCardGradient;
        border = Eco.heroBorder10;
        shadows = Eco.shadowDarkCard;
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

    final Widget box = SizedBox(
      width: fillWidth ? double.infinity : null,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: grad == null ? bg : null,
          gradient: grad,
          border: Border.all(color: border, width: borderWidth),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadows,
        ),
        child: child,
      ),
    );

    if (onTap == null) return box;
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      fillWidth: fillWidth,
      borderRadius: BorderRadius.circular(radius),
      child: box,
    );
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
        bg = cs.primary;
        fg = cs.onPrimary;
        border = null;
        shadows = Eco.shadowPrimaryBtn;
        break;
      case EcoButtonTone.amber:
        bg = cs.amber;
        fg = cs.onSecondary;
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
        bg = Eco.heroOverlay14;
        fg = Eco.heroInkSoft;
        border = Eco.heroBorder28;
        shadows = const <BoxShadow>[];
        break;
    }
    final TextStyle buttonStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  color: fg,
                ) ??
            F.role(context.type.bodyLarge!, wght: 800, color: fg);

    final bool enabled = onPressed != null && !loading;

    final List<Widget> content = <Widget>[
      if (loading)
        const _Spinner()
      else if (leading != null)
        EcoIcon(leading!, size: 19, color: fg),
      Flexible(
        child: Text(
          loading ? (loadingLabel ?? label) : label,
          style: buttonStyle,
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
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.symmetric(horizontal: Eco.s20),
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
      borderRadius: BorderRadius.circular(13),
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
        padding: const EdgeInsets.symmetric(vertical: Eco.s4),
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
    final Color fg = on ? cs.onPrimary : cs.ink2;
    final List<Widget> content = <Widget>[
      if (icon != null) EcoIcon(icon!, size: 16, color: fg),
      Flexible(
        child: Text(
          label,
          style: F.role(context.type.bodySmall!, wght: 800, color: fg),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (trailingIcon != null) EcoIcon(trailingIcon!, size: 16, color: fg),
    ];
    return Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Eco.rPill),
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

