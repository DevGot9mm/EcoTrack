import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// One icon family, as in the prototype: a single outlined set, used at a
/// consistent 1.25em optical size with the surrounding text colour.
///
/// Keys match the icon names used by the prototype's domain data, so the data
/// tables below stay readable and portable.
const Map<String, IconData> kIcons = <String, IconData>{
  // ---- Navigation ---------------------------------------------------------
  'house': Icons.home_outlined,
  'clock': Icons.history,
  'chart': Icons.bar_chart,
  'flag': Icons.flag_outlined,
  'user': Icons.person_outline,

  // ---- Transport ----------------------------------------------------------
  'bus': Icons.directions_bus_outlined,
  'car': Icons.directions_car_outlined,
  'motorcycle': Icons.two_wheeler_outlined,
  'train': Icons.train_outlined,
  'bike': Icons.pedal_bike_outlined,
  'walk': Icons.directions_walk_outlined,

  // ---- Electricity --------------------------------------------------------
  'bolt': Icons.bolt_outlined,
  'snow': Icons.ac_unit_outlined,
  'plug': Icons.power_outlined,
  'air': Icons.air,
  'fan': Icons.toys_outlined,
  'laptop': Icons.laptop_mac_outlined,
  'desktop': Icons.desktop_windows_outlined,
  'television': Icons.tv_outlined,
  'refrigerator': Icons.kitchen_outlined,
  'washingMachine': Icons.local_laundry_service_outlined,

  // ---- Food ---------------------------------------------------------------
  'cow': Icons.pets_outlined,
  'chicken': Icons.dinner_dining_outlined,
  'pig': Icons.pets_outlined,
  'fish': Icons.set_meal_outlined,
  'egg': Icons.egg_alt_outlined,
  'grains': Icons.rice_bowl_outlined,
  'tofu': Icons.grain_outlined,
  'produce': Icons.eco_outlined,
  'food': Icons.restaurant_outlined,
  'leaf': Icons.eco_outlined,
  'sprout': Icons.spa_outlined,
  'grill': Icons.outdoor_grill_outlined,
  'fry': Icons.oil_barrel_outlined,
  'steam': Icons.soup_kitchen_outlined,
  'stirFry': Icons.ramen_dining,
  'sushi': Icons.restaurant_outlined,

  // ---- Interface ----------------------------------------------------------
  'bell': Icons.notifications_none,
  'sun': Icons.wb_sunny_outlined,
  'logout': Icons.logout_outlined,
  'plus': Icons.add,
  'minus': Icons.remove,
  'chevronR': Icons.chevron_right,
  'chevronL': Icons.chevron_left,
  'check': Icons.check,
  'close': Icons.close,
  'info': Icons.info_outline,
  'bookmark': Icons.bookmark_border,
  'bookmarkOn': Icons.bookmark,
  'tips': Icons.tips_and_updates_outlined,
  'sparkles': Icons.auto_awesome_outlined,
  'trophy': Icons.emoji_events_outlined,
  'lock': Icons.lock_outline,
  'target': Icons.gps_fixed,
  'trash': Icons.delete_outline,
  'arrowDown': Icons.arrow_downward,
  'arrowUp': Icons.arrow_upward,
  'arrowRight': Icons.arrow_forward,
  'share': Icons.ios_share_outlined,
  'mail': Icons.mail_outline,
  'shield': Icons.shield_outlined,
  'help': Icons.help_outline,
  'settings': Icons.settings_outlined,
  'flame': Icons.local_fire_department_outlined,
  'refresh': Icons.refresh,
  'book': Icons.menu_book_outlined,
};

/// Filled counterparts used only for the currently selected navigation tab.
/// The clock keeps its closest filled Material history glyph.
const Map<String, IconData> kSelectedIcons = <String, IconData>{
  'house': Icons.home,
  'clock': Icons.history_toggle_off,
  'chart': Icons.bar_chart,
  'flag': Icons.flag,
  'user': Icons.person,
};

const Map<String, FaIconData> kBrandIcons = <String, FaIconData>{
  'google': FontAwesomeIcons.google,
};

IconData ecoIcon(String name) => kIcons[name] ?? Icons.help_outline;

/// Convenience wrapper that keeps icon sizing in `em`, like the prototype's
/// `.ic { width: 1.25em; height: 1.25em }` rule.
class EcoIcon extends StatelessWidget {
  const EcoIcon(this.name, {super.key, this.size = 20, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final FaIconData? brandIcon = kBrandIcons[name];
    if (brandIcon != null) {
      return FaIcon(brandIcon, size: size, color: color);
    }
    if (name == 'cow' ||
        name == 'chicken' ||
        name == 'pig' ||
        name == 'produce') {
      return CustomPaint(
        size: Size.square(size),
        painter: _FoodIconPainter(
          name: name,
          color: color ?? IconTheme.of(context).color ?? Colors.black,
        ),
      );
    }
    return Icon(ecoIcon(name), size: size, color: color);
  }
}

class _FoodIconPainter extends CustomPainter {
  const _FoodIconPainter({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width, size.height);
    final Paint outline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (name == 'cow') {
      final Path ears = Path()
        ..moveTo(0.30, 0.36)
        ..cubicTo(0.18, 0.23, 0.09, 0.25, 0.12, 0.39)
        ..lineTo(0.29, 0.47)
        ..moveTo(0.70, 0.36)
        ..cubicTo(0.82, 0.23, 0.91, 0.25, 0.88, 0.39)
        ..lineTo(0.71, 0.47);
      final Path horns = Path()
        ..moveTo(0.36, 0.32)
        ..cubicTo(0.31, 0.20, 0.37, 0.12, 0.44, 0.23)
        ..moveTo(0.64, 0.32)
        ..cubicTo(0.69, 0.20, 0.63, 0.12, 0.56, 0.23);
      final Path head = Path()
        ..moveTo(0.28, 0.37)
        ..cubicTo(0.33, 0.27, 0.67, 0.27, 0.72, 0.37)
        ..cubicTo(0.82, 0.52, 0.75, 0.77, 0.62, 0.82)
        ..cubicTo(0.55, 0.86, 0.45, 0.86, 0.38, 0.82)
        ..cubicTo(0.25, 0.77, 0.18, 0.52, 0.28, 0.37)
        ..close();
      canvas
        ..drawPath(ears, outline)
        ..drawPath(horns, outline)
        ..drawPath(head, outline)
        ..drawOval(const Rect.fromLTRB(0.33, 0.57, 0.67, 0.76), outline)
        ..drawCircle(const Offset(0.39, 0.48), 0.025, outline)
        ..drawCircle(const Offset(0.61, 0.48), 0.025, outline)
        ..drawCircle(const Offset(0.43, 0.66), 0.025, outline)
        ..drawCircle(const Offset(0.57, 0.66), 0.025, outline);
    } else if (name == 'chicken') {
      final Path bird = Path()
        ..moveTo(0.20, 0.54)
        ..cubicTo(0.18, 0.39, 0.31, 0.29, 0.47, 0.34)
        ..cubicTo(0.59, 0.25, 0.76, 0.31, 0.77, 0.45)
        ..lineTo(0.91, 0.49)
        ..lineTo(0.78, 0.57)
        ..cubicTo(0.76, 0.73, 0.58, 0.79, 0.42, 0.70)
        ..cubicTo(0.29, 0.71, 0.20, 0.65, 0.20, 0.54)
        ..close();
      final Path comb = Path()
        ..moveTo(0.43, 0.34)
        ..cubicTo(0.39, 0.24, 0.47, 0.20, 0.51, 0.30)
        ..cubicTo(0.55, 0.19, 0.64, 0.23, 0.60, 0.33);
      final Path wing = Path()
        ..moveTo(0.34, 0.48)
        ..cubicTo(0.42, 0.40, 0.58, 0.42, 0.66, 0.52)
        ..cubicTo(0.59, 0.62, 0.44, 0.63, 0.34, 0.57);
      final Path legs = Path()
        ..moveTo(0.44, 0.72)
        ..lineTo(0.42, 0.84)
        ..moveTo(0.61, 0.72)
        ..lineTo(0.63, 0.84)
        ..moveTo(0.38, 0.84)
        ..lineTo(0.46, 0.84)
        ..moveTo(0.59, 0.84)
        ..lineTo(0.67, 0.84);
      canvas
        ..drawPath(bird, outline)
        ..drawPath(comb, outline)
        ..drawPath(wing, outline)
        ..drawPath(legs, outline)
        ..drawCircle(const Offset(0.73, 0.39), 0.018, outline);
    } else if (name == 'pig') {
      final Path ears = Path()
        ..moveTo(0.29, 0.39)
        ..lineTo(0.21, 0.17)
        ..cubicTo(0.36, 0.20, 0.43, 0.27, 0.44, 0.34)
        ..moveTo(0.71, 0.39)
        ..lineTo(0.79, 0.17)
        ..cubicTo(0.64, 0.20, 0.57, 0.27, 0.56, 0.34);
      final Path head = Path()
        ..moveTo(0.22, 0.44)
        ..cubicTo(0.22, 0.28, 0.36, 0.27, 0.50, 0.31)
        ..cubicTo(0.64, 0.27, 0.78, 0.28, 0.78, 0.44)
        ..cubicTo(0.88, 0.61, 0.73, 0.81, 0.50, 0.81)
        ..cubicTo(0.27, 0.81, 0.12, 0.61, 0.22, 0.44)
        ..close();
      canvas
        ..drawPath(ears, outline)
        ..drawPath(head, outline)
        ..drawOval(const Rect.fromLTRB(0.33, 0.49, 0.67, 0.68), outline)
        ..drawCircle(const Offset(0.43, 0.58), 0.025, outline)
        ..drawCircle(const Offset(0.57, 0.58), 0.025, outline)
        ..drawCircle(const Offset(0.37, 0.44), 0.025, outline)
        ..drawCircle(const Offset(0.63, 0.44), 0.025, outline);
    } else {
      final Path apple = Path()
        ..moveTo(0.48, 0.34)
        ..cubicTo(0.36, 0.24, 0.17, 0.34, 0.18, 0.53)
        ..cubicTo(0.19, 0.73, 0.35, 0.86, 0.49, 0.78)
        ..cubicTo(0.65, 0.86, 0.82, 0.72, 0.82, 0.52)
        ..cubicTo(0.82, 0.34, 0.64, 0.25, 0.52, 0.34)
        ..moveTo(0.50, 0.34)
        ..lineTo(0.50, 0.20)
        ..moveTo(0.51, 0.26)
        ..cubicTo(0.58, 0.16, 0.70, 0.17, 0.74, 0.22);
      final Path carrot = Path()
        ..moveTo(0.69, 0.48)
        ..lineTo(0.88, 0.44)
        ..lineTo(0.74, 0.82)
        ..close()
        ..moveTo(0.71, 0.43)
        ..lineTo(0.66, 0.31)
        ..moveTo(0.73, 0.43)
        ..lineTo(0.80, 0.30);
      canvas
        ..drawPath(apple, outline)
        ..drawPath(carrot, outline);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FoodIconPainter oldDelegate) =>
      oldDelegate.name != name || oldDelegate.color != color;
}
