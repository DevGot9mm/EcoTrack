part of 'common.dart';

/* ==========================================================================
   Primitives
   ========================================================================== */

/// Applies a press response and the shared holographic hover effect.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.975,
    this.fillWidth = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(Eco.rCard)),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool fillWidth;
  final BorderRadius borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _setDown(bool v) => setState(() => _down = v);

  @override
  Widget build(BuildContext context) {
    Widget child = widget.fillWidth
        ? SizedBox(width: double.infinity, child: widget.child)
        : widget.child;
    if (RendererBinding.instance.mouseTracker.mouseIsConnected) {
      child = HolographicCard(
        borderRadius: widget.borderRadius.topLeft.x,
        backgroundColor: Colors.transparent,
        sweepColor: Eco.holoSweep,
        glowColor: Eco.holoGlow,
        hoverScale: 1.01,
        width: widget.fillWidth ? double.infinity : null,
        height: null,
        child: child,
      );
    }
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      child: widget.onTap == null
          ? child
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              onTapDown: (_) => _setDown(true),
              onTapUp: (_) => _setDown(false),
              onTapCancel: () => _setDown(false),
              child: AnimatedScale(
                scale: _down ? widget.scale : 1,
                duration: Eco.dur1,
                curve: Eco.easeOut,
                child: child,
              ),
            ),
    );
  }
}

class HolographicCard extends StatefulWidget {
  const HolographicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 15,
    this.backgroundColor = Eco.holoBase,
    this.sweepColor = Eco.holoSweep,
    this.glowColor = Eco.holoGlow,
    this.hoverScale = 1.015,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color backgroundColor;
  final Color sweepColor;
  final Color glowColor;
  final double hoverScale;
  final Duration duration;

  @override
  State<HolographicCard> createState() => _HolographicCardState();
}

class _HolographicCardState extends State<HolographicCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(parent: _controller, curve: Curves.ease);
  }

  @override
  void didUpdateWidget(covariant HolographicCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(widget.borderRadius);
    return MouseRegion(
      cursor: MouseCursor.defer,
      onEnter: (_) => _setActive(true),
      onExit: (_) => _setActive(false),
      child: AnimatedBuilder(
        animation: _progress,
        builder: (BuildContext context, Widget? child) {
          final double t = _progress.value;
          return Transform.scale(
            scale: 1 + (widget.hoverScale - 1) * t,
            child: Container(
              width: widget.width?.isFinite == true ? widget.width : null,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: radius,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: widget.glowColor.withValues(alpha: 0.5 * t),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _HolographicSweepPainter(
                            progress: t,
                            sweepColor: widget.sweepColor,
                          ),
                        ),
                      ),
                    ),
                    child!,
                  ],
                ),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }

  void _setActive(bool active) {
    active ? _controller.forward() : _controller.reverse();
  }
}

class _HolographicSweepPainter extends CustomPainter {
  const _HolographicSweepPainter({
    required this.progress,
    required this.sweepColor,
  });

  final double progress;
  final Color sweepColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || size.isEmpty) return;
    final double extent = size.longestSide * 2;
    final Rect sweepRect = Rect.fromCenter(
      center: Offset(0, extent * (progress - 0.5)),
      width: extent * 2,
      height: extent,
    );
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: <Color>[
          Colors.transparent,
          Colors.transparent,
          sweepColor.withValues(alpha: 0.3),
        ],
        stops: const <double>[0, 0.3, 1],
      ).createShader(sweepRect);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 4);
    canvas.drawRect(sweepRect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HolographicSweepPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.sweepColor != sweepColor;
}

class FlipIconButton extends StatefulWidget {
  const FlipIconButton({
    super.key,
    required this.frontIcon,
    required this.backIcon,
    required this.onPressed,
    required this.background,
    required this.foreground,
    required this.backBackground,
    required this.backForeground,
    required this.border,
    this.size = 36,
    this.borderRadius = 12,
    this.duration = const Duration(milliseconds: 500),
    this.tooltip,
  });

  final IconData frontIcon;
  final IconData backIcon;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;
  final Color backBackground;
  final Color backForeground;
  final Color border;
  final double size;
  final double borderRadius;
  final Duration duration;
  final String? tooltip;

  @override
  State<FlipIconButton> createState() => _FlipIconButtonState();
}

class _FlipIconButtonState extends State<FlipIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(parent: _controller, curve: Curves.ease);
  }

  @override
  void didUpdateWidget(covariant FlipIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _face(IconData icon, Color background, Color foreground) => Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: widget.border),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Icon(icon, size: 18, color: foreground),
      );

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? '',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _controller.forward(),
        onExit: (_) => _controller.reverse(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
            animation: _progress,
            builder: (BuildContext context, Widget? child) {
              final double t = _progress.value;
              final Matrix4 frontMatrix = Matrix4.identity()
                ..setEntry(1, 3, widget.size * 0.5 * t)
                ..rotateX(math.pi / 2 * t);
              final Matrix4 backMatrix = Matrix4.identity()
                ..setEntry(1, 3, -widget.size * 0.5 * (1 - t))
                ..rotateX(math.pi / 2 * (1 - t));
              return Stack(
                children: <Widget>[
                  Opacity(
                    opacity: 1 - t,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: frontMatrix,
                      child: _face(
                        widget.frontIcon,
                        widget.background,
                        widget.foreground,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: t,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: backMatrix,
                        child: _face(
                          widget.backIcon,
                          widget.backBackground,
                          widget.backForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 17,
      height: 17,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: cs.onPrimary,
        backgroundColor: cs.onPrimary.withAlpha(115),
      ),
    );
  }
}

