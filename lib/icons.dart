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
  'steak': Icons.lunch_dining_outlined,
  'chicken': Icons.dinner_dining_outlined,
  'fish': Icons.set_meal_outlined,
  'egg': Icons.egg_alt_outlined,
  'grains': Icons.rice_bowl_outlined,
  'tofu': Icons.grain_outlined,
  'produce': Icons.local_grocery_store_outlined,
  'bacon': Icons.fastfood_outlined,
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
  'google': Icons.g_mobiledata,
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

const Map<String, FaIconData> _specialIcons = <String, FaIconData>{
  'snack': FontAwesomeIcons.cookieBite,
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
    if (name == 'steak' || name == 'chicken') {
      return CustomPaint(
        size: Size.square(size),
        painter: _FoodIconPainter(
          name: name,
          color: color ?? IconTheme.of(context).color ?? Colors.black,
        ),
      );
    }
    final FaIconData? special = _specialIcons[name];
    if (special != null) {
      return FaIcon(special, size: size, color: color);
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

    if (name == 'steak') {
      final Path cut = Path()
        ..moveTo(0.16, 0.36)
        ..cubicTo(0.24, 0.17, 0.48, 0.14, 0.63, 0.24)
        ..cubicTo(0.72, 0.30, 0.73, 0.37, 0.76, 0.42)
        ..cubicTo(0.88, 0.35, 0.94, 0.48, 0.85, 0.56)
        ..cubicTo(0.90, 0.73, 0.68, 0.88, 0.47, 0.83)
        ..cubicTo(0.25, 0.81, 0.10, 0.62, 0.16, 0.36)
        ..close();
      canvas.drawPath(cut, outline);
      canvas.drawLine(
        const Offset(0.72, 0.38),
        const Offset(0.87, 0.23),
        outline,
      );
      canvas.drawCircle(const Offset(0.89, 0.20), 0.065, outline);
      final Path marbling = Path()
        ..moveTo(0.30, 0.40)
        ..cubicTo(0.36, 0.34, 0.42, 0.35, 0.47, 0.40)
        ..moveTo(0.31, 0.57)
        ..cubicTo(0.38, 0.51, 0.44, 0.52, 0.49, 0.56);
      canvas.drawPath(marbling, outline);
    } else {
      final Path bird = Path()
        ..moveTo(0.19, 0.48)
        ..cubicTo(0.19, 0.27, 0.36, 0.17, 0.56, 0.20)
        ..cubicTo(0.79, 0.22, 0.86, 0.43, 0.77, 0.60)
        ..cubicTo(0.68, 0.78, 0.42, 0.83, 0.25, 0.68)
        ..cubicTo(0.20, 0.63, 0.18, 0.56, 0.19, 0.48)
        ..close();
      final Path wing = Path()
        ..moveTo(0.29, 0.45)
        ..cubicTo(0.40, 0.33, 0.58, 0.35, 0.68, 0.46)
        ..cubicTo(0.59, 0.54, 0.43, 0.59, 0.30, 0.55);
      final Path legs = Path()
        ..moveTo(0.34, 0.72)
        ..lineTo(0.23, 0.82)
        ..moveTo(0.63, 0.72)
        ..lineTo(0.76, 0.82);
      canvas
        ..drawPath(bird, outline)
        ..drawPath(wing, outline)
        ..drawPath(legs, outline)
        ..drawCircle(const Offset(0.19, 0.85), 0.055, outline)
        ..drawCircle(const Offset(0.80, 0.85), 0.055, outline);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FoodIconPainter oldDelegate) =>
      oldDelegate.name != name || oldDelegate.color != color;
}
