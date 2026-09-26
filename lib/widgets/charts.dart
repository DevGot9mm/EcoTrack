import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

/* ==========================================================================
   Week bars (Home)
   ========================================================================== */

class DayBar {
  const DayBar(
      {required this.total, required this.isToday, required this.label});

  final double total;
  final bool isToday;
  final String label;
}

class WeekBars extends StatelessWidget {
  const WeekBars({super.key, required this.days, required this.maxDay});

  final List<DayBar> days;
  final double maxDay;

  @override
  Widget build(BuildContext context) {
    final List<Widget> cols = <Widget>[];
    for (int i = 0; i < days.length; i++) {
      final DayBar d = days[i];
      final double ratio = maxDay <= 0 ? 0 : d.total / maxDay;
      final double h = math.max(5, (ratio * 62).roundToDouble());
      cols.add(
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AnimatedContainer(
                duration: Eco.dur3,
                curve: Eco.easeOut,
                height: h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: d.isToday ? Eco.leaf : Eco.mint,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                d.label,
                style: F.b(
                  11,
                  wght: 800,
                  color: d.isToday ? Eco.forest : Eco.muted,
                ),
              ),
            ],
          ),
        ),
      );
      if (i < days.length - 1) cols.add(const SizedBox(width: 6));
    }

    return SizedBox(height: 88, child: Row(children: cols));
  }
}

/* ==========================================================================
   Trend chart (Statistics)
   ========================================================================== */

class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.series,
    required this.max,
    required this.targetPerDay,
    required this.days,
  });

  final List<double> series;
  final double max;
  final double targetPerDay;
  final int days;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 320 / 132,
      child: CustomPaint(
        size: Size.infinite,
        painter: _TrendPainter(
          series: series,
          max: max <= 0 ? 1 : max,
          target: targetPerDay,
          label: days > 7 ? '30 days ago' : '7 days ago',
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.series,
    required this.max,
    required this.target,
    required this.label,
  });

  final List<double> series;
  final double max;
  final double target;
  final String label;

  static const double w = 320;
  static const double h = 128;
  static const double padT = 12;
  static const double padB = 18;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    canvas.save();
    canvas.scale(size.width / w, size.height / (h + 4));

    final double usable = h - padT - padB;
    double y(double v) => padT + usable - (v / max) * usable;

    final int n = series.length;
    final double stepX = n > 1 ? w / (n - 1) : w;
    final List<Offset> pts = <Offset>[
      for (int i = 0; i < n; i++) Offset(i * stepX, y(series[i])),
    ];

    final Path line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final double cx = (pts[i].dx + pts[i + 1].dx) / 2;
      line.cubicTo(
        cx,
        pts[i].dy,
        cx,
        pts[i + 1].dy,
        pts[i + 1].dx,
        pts[i + 1].dy,
      );
    }

    final Path area = Path.from(line)
      ..lineTo(pts.last.dx, h - padB)
      ..lineTo(pts.first.dx, h - padB)
      ..close();

    // Area fill — the gradient is mapped to the path's own bounding box, just
    // like the prototype's objectBoundingBox gradient.
    final Rect bounds = area.getBounds();
    if (bounds.height > 0.5) {
      canvas.drawPath(
        area,
        Paint()..shader = Eco.chartArea.createShader(bounds),
      );
    }

    // Daily goal guideline.
    final double ty = y(target);
    if (ty >= padT && ty <= h - padB) {
      _dashedLine(
        canvas,
        Offset(0, ty),
        Offset(w, ty),
        const Color(0xFFA9C79A),
        1.4,
        4,
        5,
      );
    }

    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Eco.leaf,
    );

    // Data points, thinned on the 30-day range.
    final Paint dotFill = Paint()..color = Colors.white;
    final Paint dotStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Eco.leaf;
    for (int i = 0; i < n; i++) {
      if (n > 10 && i % 3 != 0 && i != n - 1) continue;
      canvas.drawCircle(pts[i], 2.6, dotFill);
      canvas.drawCircle(pts[i], 2.6, dotStroke);
    }

    final double labelY = h - padB + 4;
    _text(canvas, label, Offset(0, labelY), TextAlign.left);
    _text(canvas, 'today', Offset(w, labelY), TextAlign.right);

    canvas.restore();
  }

  void _text(Canvas canvas, String s, Offset at, TextAlign align) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: s,
        style: F.b(10, color: Eco.muted),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    tp.layout();
    final double dx = align == TextAlign.right ? at.dx - tp.width : at.dx;
    tp.paint(canvas, Offset(dx, at.dy));
  }

  void _dashedLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Color color,
    double width,
    double dash,
    double gap,
  ) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.butt;
    final double total = (b - a).distance;
    final Offset dir = (b - a) / total;
    double t = 0;
    while (t < total) {
      final double end = math.min(t + dash, total);
      canvas.drawLine(a + dir * t, a + dir * end, p);
      t = end + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.series != series || old.max != max || old.target != target;
}

/* ==========================================================================
   Category donut (Statistics)
   ========================================================================== */

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.totals,
    this.size = 132,
    this.thickness = 16,
  });

  final Map<String, double> totals;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _DonutPainter(totals, thickness),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.totals, this.thickness);

  final Map<String, double> totals;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final double sum =
        totals.values.fold<double>(0, (double a, double b) => a + b);
    final double denom = sum <= 0 ? 1 : sum;

    final double r = (size.width - thickness) / 2;
    final double c = 2 * math.pi * r;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: r,
    );

    double off = 0;
    for (final String id in kCatOrder) {
      final double len = ((totals[id] ?? 0) / denom) * c;
      final double arc = math.max(0, len - 3);
      if (arc > 0) {
        final double start = -math.pi / 2 + (off / c) * 2 * math.pi;
        canvas.drawArc(
          rect,
          start,
          (arc / c) * 2 * math.pi,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = thickness
            ..color = catOf(id).color,
        );
      }
      off += len;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.totals != totals;
}

/* ==========================================================================
   Level ring (Rewards)
   ========================================================================== */

class LevelRing extends StatelessWidget {
  const LevelRing({
    super.key,
    required this.pct,
    this.size = 168,
    this.thickness = 14,
  });

  final int pct;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _RingPainter(pct, thickness),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.pct, this.thickness);

  final int pct;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final double r = (size.width - thickness) / 2;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: r,
    );

    canvas.drawCircle(
      rect.center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = Eco.mint,
    );

    final double frac = clampInt(pct, 0, 100) / 100;
    if (frac > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        frac * 2 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round
          ..color = Eco.forest,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.pct != pct;
}
