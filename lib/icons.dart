import 'package:flutter/material.dart';

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

  // ---- Food ---------------------------------------------------------------
  'steak': Icons.outdoor_grill_outlined,
  'chicken': Icons.restaurant_outlined,
  'fish': Icons.set_meal_outlined,
  'egg': Icons.egg_alt_outlined,
  'leaf': Icons.eco_outlined,
  'sprout': Icons.spa_outlined,

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
  'mail': Icons.mail_outline,
  'shield': Icons.shield_outlined,
  'help': Icons.help_outline,
  'settings': Icons.settings_outlined,
  'flame': Icons.local_fire_department_outlined,
  'refresh': Icons.refresh,
  'book': Icons.menu_book_outlined,
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
    return Icon(ecoIcon(name), size: size, color: color);
  }
}
