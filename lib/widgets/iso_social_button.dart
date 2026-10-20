import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IsoSocialButton extends StatefulWidget {
  const IsoSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.hoverFace,
    required this.hoverLeft,
    required this.hoverBottom,
    this.idleFace = const Color(0xFFFFFFFF),
    this.idleSide = const Color(0xFFB1B1B1),
    this.idleContent = const Color(0xFF262626),
    this.hoverContent = const Color(0xFFFFFFFF),
    this.width = 230,
    this.height = 80,
    this.depth = 20,
    this.rotationDeg = -30,
    this.skewDeg = 25,
    this.hoverLift = const Offset(20, -15),
    this.duration = const Duration(milliseconds: 500),
    this.onTap,
  });

  final FaIconData icon;
  final String label;
  final Color hoverFace;
  final Color hoverLeft;
  final Color hoverBottom;
  final Color idleFace;
  final Color idleSide;
  final Color idleContent;
  final Color hoverContent;
  final double width;
  final double height;
  final double depth;
  final double rotationDeg;
  final double skewDeg;
  final Offset hoverLift;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  State<IsoSocialButton> createState() => _IsoSocialButtonState();
}

class _IsoSocialButtonState extends State<IsoSocialButton> {
  bool _hovered = false;

  Matrix4 get _isoMatrix {
    final Matrix4 skew = Matrix4.identity()
      ..setEntry(0, 1, math.tan(widget.skewDeg * math.pi / 180));
    return Matrix4.identity()
      ..rotateZ(widget.rotationDeg * math.pi / 180)
      ..multiply(skew);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Transform(
        alignment: Alignment.center,
        transform: _isoMatrix,
        child: MouseRegion(
          cursor: widget.onTap == null
              ? MouseCursor.defer
              : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: _hovered ? 1 : 0),
              duration: widget.duration,
              curve: Curves.ease,
              builder: (BuildContext context, double t, Widget? child) {
                final Color face =
                    Color.lerp(widget.idleFace, widget.hoverFace, t)!;
                final Color left =
                    Color.lerp(widget.idleSide, widget.hoverLeft, t)!;
                final Color bottom =
                    Color.lerp(widget.idleSide, widget.hoverBottom, t)!;
                final Color content =
                    Color.lerp(widget.idleContent, widget.hoverContent, t)!;
                return Transform.scale(
                  scale: 1 + 0.05 * t,
                  child: Transform.translate(
                    offset: widget.hoverLift * t,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _IsoPainter(
                              face: face,
                              left: left,
                              bottom: bottom,
                              depth: widget.depth,
                              shadowOffset: Offset.lerp(
                                const Offset(-20, 20),
                                const Offset(-50, 50),
                                t,
                              )!,
                              shadowBlur: 10 + 40 * t,
                            ),
                          ),
                        ),
                        if (t > 0)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _IsoHolographicPainter(
                                  progress: t,
                                  sweepColor: const Color(0xFF7BC96F),
                                ),
                              ),
                            ),
                          ),
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  FaIcon(widget.icon, size: 24, color: content),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      widget.label,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        letterSpacing: 1,
                                        color: content,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _IsoHolographicPainter extends CustomPainter {
  const _IsoHolographicPainter({
    required this.progress,
    required this.sweepColor,
  });

  final double progress;
  final Color sweepColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final Rect sweepRect = Rect.fromCenter(
      center: Offset(0, size.height * 2 * (progress - 0.5)),
      width: size.longestSide * 4,
      height: size.longestSide * 2,
    );
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: <Color>[
          Colors.transparent,
          Colors.transparent,
          sweepColor.withValues(alpha: 0.3 * progress),
        ],
        stops: const <double>[0, 0.3, 1],
      ).createShader(sweepRect);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 4);
    canvas.drawRect(sweepRect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IsoHolographicPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.sweepColor != sweepColor;
}

class _IsoPainter extends CustomPainter {
  const _IsoPainter({
    required this.face,
    required this.left,
    required this.bottom,
    required this.depth,
    required this.shadowOffset,
    required this.shadowBlur,
  });

  final Color face;
  final Color left;
  final Color bottom;
  final double depth;
  final Offset shadowOffset;
  final double shadowBlur;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double d = depth;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height).shift(shadowOffset),
      Paint()
        ..color = const Color(0x80000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur / 2),
    );

    final Path leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, height)
      ..lineTo(-d, height + d)
      ..lineTo(-d, d)
      ..close();
    canvas.drawPath(leftPath, Paint()..color = left);

    final Path bottomPath = Path()
      ..moveTo(0, height)
      ..lineTo(width, height)
      ..lineTo(width - d, height + d)
      ..lineTo(-d, height + d)
      ..close();
    canvas.drawPath(bottomPath, Paint()..color = bottom);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), Paint()..color = face);
  }

  @override
  bool shouldRepaint(covariant _IsoPainter oldDelegate) =>
      oldDelegate.face != face ||
      oldDelegate.left != left ||
      oldDelegate.bottom != bottom ||
      oldDelegate.depth != depth ||
      oldDelegate.shadowOffset != shadowOffset ||
      oldDelegate.shadowBlur != shadowBlur;
}
