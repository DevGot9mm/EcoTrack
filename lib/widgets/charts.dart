import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';
import '../responsive.dart';
import '../theme.dart';

/* ==========================================================================
   Week bars (Home)
   ========================================================================== */

class DayBar {
  const DayBar({
    required this.total,
    required this.isToday,
    required this.label,
    this.categories = const <CarbonCategory, double>{},
  });

  final double total;
  final bool isToday;
  final String label;
  final Map<CarbonCategory, double> categories;
}

class WeekBars extends StatelessWidget {
  const WeekBars({
    super.key,
    required this.days,
    required this.maxDay,
    required this.categoryColors,
  });

  final List<DayBar> days;
  final double maxDay;
  final Map<CarbonCategory, Color> categoryColors;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool tablet = context.windowSize != WindowSize.compact;
    final double barMaxHeight = tablet ? 82 : 62;
    final double chartHeight = tablet ? 110 : 88;
    final List<Widget> cols = <Widget>[];
    for (int i = 0; i < days.length; i++) {
      final DayBar d = days[i];
      final double ratio = maxDay <= 0 ? 0 : d.total / maxDay;
      final double h = math.max(5, (ratio * barMaxHeight).roundToDouble());
      final List<CarbonCategory> categories = kCatOrder
          .where((CarbonCategory id) => (d.categories[id] ?? 0) > 0)
          .toList();
      cols.add(
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: h,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: categories.isEmpty
                      ? ColoredBox(color: d.isToday ? cs.leaf : cs.mint)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            for (final CarbonCategory id in categories)
                              Container(
                                height: h *
                                    (d.categories[id] ?? 0) /
                                    (d.total > 0 ? d.total : 1),
                                color: categoryColors[id] ?? cs.leaf,
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                d.label,
                style: F.b(
                  11,
                  wght: 800,
                  color: d.isToday ? cs.leaf : cs.muted,
                ),
              ),
            ],
          ),
        ),
      );
      if (i < days.length - 1) cols.add(const SizedBox(width: 6));
    }

    return SizedBox(height: chartHeight, child: Row(children: cols));
  }
}

/* ==========================================================================
   Trend chart (Statistics)
   ========================================================================== */

class TrendChart extends StatefulWidget {
  const TrendChart({
    super.key,
    required this.series,
    required this.max,
    required this.targetPerDay,
    required this.labels,
    required this.categorySeries,
    required this.categoryColors,
  });

  final List<double> series;
  final double max;
  final double targetPerDay;
  final List<String> labels;
  final List<Map<CarbonCategory, double>> categorySeries;
  final Map<CarbonCategory, Color> categoryColors;

  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final bool tablet = context.windowSize != WindowSize.compact;
        final double height = (c.maxWidth * 0.38).clamp(
          190.0,
          tablet ? 310.0 : 250.0,
        );
        return MouseRegion(
          onHover: (event) {
            final int count = widget.series.length;
            if (count < 2) return;
            final double chartWidth = c.maxWidth - 54;
            final double localX = event.localPosition.dx - 46;
            final int index =
                (localX / chartWidth * (count - 1)).round().clamp(0, count - 1);
            if (_hoveredIndex != index) setState(() => _hoveredIndex = index);
          },
          onExit: (_) => setState(() => _hoveredIndex = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails details) {
              final int count = widget.series.length;
              if (count < 2) return;
              final double chartWidth = c.maxWidth - 54;
              final double localX = details.localPosition.dx - 46;
              final int index = (localX / chartWidth * (count - 1))
                  .round()
                  .clamp(0, count - 1);
              setState(() => _hoveredIndex = index);
            },
            child: SizedBox(
              width: c.maxWidth,
              height: height,
              child: CustomPaint(
                painter: _TrendPainter(
                  series: widget.series,
                  max: math.max(
                    1.0,
                    math.max(widget.max, widget.targetPerDay) * 1.15,
                  ),
                  labels: widget.labels,
                  categorySeries: widget.categorySeries,
                  categoryColors: widget.categoryColors,
                  hoveredIndex: _hoveredIndex,
                  axisColor: cs.forest,
                  mutedColor: cs.muted,
                  gridColor: cs.lineStrong,
                  dotFillColor: cs.surface,
                  tooltipBackground: cs.surface,
                  tooltipTextColor: cs.ink,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.series,
    required this.max,
    required this.labels,
    required this.categorySeries,
    required this.categoryColors,
    required this.hoveredIndex,
    required this.axisColor,
    required this.mutedColor,
    required this.gridColor,
    required this.dotFillColor,
    required this.tooltipBackground,
    required this.tooltipTextColor,
  });

  final List<double> series;
  final double max;
  final List<String> labels;
  final List<Map<CarbonCategory, double>> categorySeries;
  final Map<CarbonCategory, Color> categoryColors;
  final int? hoveredIndex;
  final Color axisColor;
  final Color mutedColor;
  final Color gridColor;
  final Color dotFillColor;
  final Color tooltipBackground;
  final Color tooltipTextColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    const double left = 46;
    const double right = 10;
    const double top = 14;
    const double bottom = 30;
    final double plotWidth = math.max(1, size.width - left - right);
    final double plotHeight = math.max(1, size.height - top - bottom);
    final double baseline = top + plotHeight;
    double y(double value) => baseline - (value / max) * plotHeight;
    final int n = series.length;
    final double stepX = n > 1 ? plotWidth / (n - 1) : plotWidth;
    final List<Offset> pts = <Offset>[
      for (int i = 0; i < n; i++) Offset(left + i * stepX, y(series[i])),
    ];

    for (int tick = 0; tick <= 4; tick++) {
      final double value = max * tick / 4;
      final double tickY = y(value);
      canvas.drawLine(
        Offset(left, tickY),
        Offset(size.width - right, tickY),
        Paint()
          ..color = gridColor
          ..strokeWidth = 0.8,
      );
      _text(
        canvas,
        fmt1(value),
        0,
        tickY - 6,
        TextAlign.left,
        color: axisColor,
        weight: 900,
      );
    }
    for (int i = 0; i < pts.length - 1; i++) {
      final Offset first = pts[i];
      final Offset second = pts[i + 1];
      final double centerX = (first.dx + second.dx) / 2;
      final Color color = _mixColors(_pointColor(i), _pointColor(i + 1));
      final Path area = Path()
        ..moveTo(first.dx, baseline)
        ..lineTo(first.dx, first.dy)
        ..cubicTo(centerX, first.dy, centerX, second.dy, second.dx, second.dy)
        ..lineTo(second.dx, baseline)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              color.withValues(alpha: 0.42),
              color.withValues(alpha: 0.03),
            ],
          ).createShader(Rect.fromLTRB(first.dx, top, second.dx, baseline)),
      );
      final Path segment = Path()
        ..moveTo(first.dx, first.dy)
        ..cubicTo(centerX, first.dy, centerX, second.dy, second.dx, second.dy);
      canvas.drawPath(
        segment,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }
    final Paint dotFill = Paint()..color = dotFillColor;
    for (int i = 0; i < n; i++) {
      if (n > 10 && i % 3 != 0 && i != n - 1) continue;
      canvas.drawCircle(pts[i], 3.2, dotFill);
      canvas.drawCircle(
        pts[i],
        3.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = _pointColor(i),
      );
    }
    _text(
      canvas,
      labels.isNotEmpty ? labels.first : 'start',
      left,
      baseline + 8,
      TextAlign.left,
    );
    _text(
      canvas,
      labels.length > 1 ? labels.last : 'today',
      size.width - right,
      baseline + 8,
      TextAlign.right,
    );
    if (hoveredIndex case final int index when index >= 0 && index < n) {
      _drawHover(canvas, size, pts[index], index);
    }
  }

  Color _pointColor(int index) {
    if (index >= categorySeries.length) return Eco.leaf;
    final Map<CarbonCategory, double> values = categorySeries[index];
    final double total = values.values
        .fold<double>(0, (double sum, double value) => sum + value);
    if (total <= 0) return Eco.leaf;
    int r = 0;
    int g = 0;
    int b = 0;
    for (final CarbonCategory id in kCatOrder) {
      final double weight = (values[id] ?? 0) / total;
      final Color color = categoryColors[id] ?? catOf(id).color;
      r += (color.r * 255 * weight).round();
      g += (color.g * 255 * weight).round();
      b += (color.b * 255 * weight).round();
    }
    return Color.fromARGB(
        255, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
  }

  Color _mixColors(Color first, Color second) => Color.fromARGB(
        255,
        ((first.r + second.r) * 127.5).round(),
        ((first.g + second.g) * 127.5).round(),
        ((first.b + second.b) * 127.5).round(),
      );

  void _drawHover(Canvas canvas, Size size, Offset point, int index) {
    const double width = 168;
    const double height = 88;
    final double left =
        (point.dx + 10).clamp(4.0, math.max(4.0, size.width - width - 4));
    final double top = (point.dy - height - 8).clamp(4.0, size.height - height);
    final Rect rect = Rect.fromLTWH(left, top, width, height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = tooltipBackground,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = gridColor,
    );
    final String label =
        index < labels.length ? labels[index] : 'Day ${index + 1}';
    _text(
      canvas,
      '$label · ${fmt1(series[index])} kg',
      left + 8,
      top + 8,
      TextAlign.left,
      color: tooltipTextColor,
      weight: 900,
    );
    final double delta = index == 0 ? 0 : series[index] - series[index - 1];
    final String change = index == 0
        ? 'First day'
        : '${delta > 0 ? '+' : ''}${fmt1(delta)} kg vs prior day';
    _text(
      canvas,
      change,
      left + 8,
      top + 27,
      TextAlign.left,
      weight: 800,
    );
    final Map<CarbonCategory, double> values = index < categorySeries.length
        ? categorySeries[index]
        : const <CarbonCategory, double>{};
    for (int row = 0; row < kCatOrder.length; row++) {
      final CarbonCategory id = kCatOrder[row];
      final double value = values[id] ?? 0;
      final double yPos = top + 46 + row * 12;
      canvas.drawCircle(
        Offset(left + 12, yPos + 4),
        3,
        Paint()..color = categoryColors[id] ?? catOf(id).color,
      );
      _text(
        canvas,
        '${_categoryLabel(id)} ${fmt1(value)}',
        left + 20,
        yPos,
        TextAlign.left,
        weight: 700,
      );
    }
  }

  void _text(
    Canvas canvas,
    String s,
    double dx,
    double labelY,
    TextAlign align, {
    Color? color,
    double weight = 700,
  }) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: s,
        style: F.b(10, wght: weight, color: color ?? mutedColor),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    tp.layout();
    final double adjustedDx = align == TextAlign.right ? dx - tp.width : dx;
    tp.paint(canvas, Offset(adjustedDx, labelY));
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.series != series ||
      old.max != max ||
      old.labels != labels ||
      old.categorySeries != categorySeries ||
      old.categoryColors != categoryColors ||
      old.hoveredIndex != hoveredIndex ||
      old.axisColor != axisColor ||
      old.mutedColor != mutedColor ||
      old.gridColor != gridColor ||
      old.dotFillColor != dotFillColor ||
      old.tooltipBackground != tooltipBackground ||
      old.tooltipTextColor != tooltipTextColor;
}

String _categoryLabel(CarbonCategory category) => switch (category) {
      CarbonCategory.transport => 'Transport',
      CarbonCategory.electricity => 'Energy',
      CarbonCategory.food => 'Food',
    };

/* ==========================================================================
   Category donut (Statistics)
   ========================================================================== */

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.totals,
    required this.categoryColors,
    this.size = 132,
    this.thickness = 16,
  });

  final Map<CarbonCategory, double> totals;
  final Map<CarbonCategory, Color> categoryColors;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _DonutPainter(totals, categoryColors, thickness),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.totals, this.categoryColors, this.thickness);

  final Map<CarbonCategory, double> totals;
  final Map<CarbonCategory, Color> categoryColors;
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
    for (final CarbonCategory id in kCatOrder) {
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
            ..color = categoryColors[id] ?? catOf(id).color,
        );
      }
      off += len;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.totals != totals || old.categoryColors != categoryColors;
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
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _RingPainter(pct, thickness, cs.mint, cs.leaf),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.pct, this.thickness, this.trackColor, this.arcColor);

  final int pct;
  final double thickness;
  final Color trackColor;
  final Color arcColor;

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
        ..color = trackColor,
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
          ..color = arcColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.pct != pct ||
      old.trackColor != trackColor ||
      old.arcColor != arcColor;
}
