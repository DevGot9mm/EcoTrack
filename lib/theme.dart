import 'package:flutter/material.dart';

/// EcoTrack design tokens.
///
/// These are a direct port of the prototype's `:root` block, so every colour,
/// radius, shadow and duration in [Eco] can be traced back to one place.
class Eco {
  Eco._();

  // ---- Surfaces -----------------------------------------------------------
  static const Color ground = Color(0xFFF7F8F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF1F5EA);
  static const Color ink = Color(0xFF14231A);
  static const Color ink2 = Color(0xFF3C4F42);
  static const Color muted = Color(0xFF5F6F63);
  static const Color line = Color(0xFFE5EADE);
  static const Color lineStrong = Color(0xFFD3DCC9);
  static const Color lineMint = Color(0xFFD3E6C5);
  static const Color lineAmber = Color(0xFFF0DFB9);

  // ---- Greens -------------------------------------------------------------
  static const Color forest = Color(0xFF1F5C34);
  static const Color forestHover = Color(0xFF256B3D);
  static const Color forestDeep = Color(0xFF143F24);
  static const Color forestInk = Color(0xFF0F3320);
  static const Color leaf = Color(0xFF4E9A51);
  static const Color sage = Color(0xFFA9C79A);
  static const Color mint = Color(0xFFE4F1DC);
  static const Color cream = Color(0xFFFBF9F0);

  // ---- Amber --------------------------------------------------------------
  static const Color amber = Color(0xFFE8A33D);
  static const Color amberHover = Color(0xFFF0AF4D);
  static const Color amberTint = Color(0xFFFBF0DA);
  static const Color amberInk = Color(0xFF7F5606);

  // ---- Categories ---------------------------------------------------------
  static const Color transport = Color(0xFF3C7C86);
  static const Color transportTint = Color(0xFFE3F0F1);
  static const Color transportInk = Color(0xFF2A5F68);

  static const Color electricity = Color(0xFFE2A63C);
  static const Color electricityTint = Color(0xFFFBF0DA);
  static const Color electricityInk = Color(0xFF7F5606);

  static const Color food = Color(0xFF8FAE5A);
  static const Color foodTint = Color(0xFFEDF4DE);
  static const Color foodInk = Color(0xFF546D2C);

  // ---- Danger -------------------------------------------------------------
  static const Color danger = Color(0xFFB8452F);
  static const Color dangerTint = Color(0xFFFBEAE5);

  // ---- Radii --------------------------------------------------------------
  static const double rCard = 22;
  static const double rBtn = 16;
  static const double rSheet = 28;
  static const double rSm = 12;
  static const double rPill = 999;

  // ---- Elevation ----------------------------------------------------------
  static const List<BoxShadow> shadow1 = <BoxShadow>[
    BoxShadow(color: Color(0x0D14311D), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x4714311D),
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -14,
    ),
  ];

  static const List<BoxShadow> shadow2 = <BoxShadow>[
    BoxShadow(color: Color(0x0F14311D), offset: Offset(0, 2), blurRadius: 6),
    BoxShadow(
      color: Color(0x6614311D),
      offset: Offset(0, 20),
      blurRadius: 40,
      spreadRadius: -22,
    ),
  ];

  static const List<BoxShadow> shadowDarkCard = <BoxShadow>[
    BoxShadow(color: Color(0x290F3320), offset: Offset(0, 3), blurRadius: 8),
    BoxShadow(
      color: Color(0x9E0F3320),
      offset: Offset(0, 24),
      blurRadius: 44,
      spreadRadius: -24,
    ),
  ];

  static const List<BoxShadow> shadowPrimaryBtn = <BoxShadow>[
    BoxShadow(color: Color(0x290F3320), offset: Offset(0, 2), blurRadius: 4),
    BoxShadow(
      color: Color(0xB30F3320),
      offset: Offset(0, 14),
      blurRadius: 26,
      spreadRadius: -16,
    ),
  ];

  static const List<BoxShadow> shadowAmberBtn = <BoxShadow>[
    BoxShadow(color: Color(0x2E7A5406), offset: Offset(0, 2), blurRadius: 4),
    BoxShadow(
      color: Color(0x997A5406),
      offset: Offset(0, 14),
      blurRadius: 26,
      spreadRadius: -16,
    ),
  ];

  static const List<BoxShadow> shadowFab = <BoxShadow>[
    BoxShadow(color: Color(0x387A5406), offset: Offset(0, 3), blurRadius: 8),
    BoxShadow(
      color: Color(0x997A5406),
      offset: Offset(0, 18),
      blurRadius: 30,
      spreadRadius: -14,
    ),
  ];

  static const List<BoxShadow> shadowTabBar = <BoxShadow>[
    BoxShadow(
      color: Color(0x8014311D),
      offset: Offset(0, -8),
      blurRadius: 24,
      spreadRadius: -18,
    ),
  ];

  static const List<BoxShadow> shadowSheet = <BoxShadow>[
    BoxShadow(
      color: Color(0x99102818),
      offset: Offset(0, -10),
      blurRadius: 40,
      spreadRadius: -18,
    ),
  ];

  static const List<BoxShadow> shadowToast = <BoxShadow>[
    BoxShadow(
      color: Color(0xB3102818),
      offset: Offset(0, 14),
      blurRadius: 30,
      spreadRadius: -14,
    ),
  ];

  // ---- Motion -------------------------------------------------------------
  static const Duration dur1 = Duration(milliseconds: 180);
  static const Duration dur2 = Duration(milliseconds: 240);
  static const Duration dur3 = Duration(milliseconds: 380);
  static const Curve easeOut = Cubic(0.22, 1, 0.36, 1);
  static const Curve easeIn = Cubic(0.4, 0, 1, 1);

  static const double tabbarH = 62;

  // ---- Gradients ----------------------------------------------------------
  static const LinearGradient cardDark = LinearGradient(
    begin: Alignment(-0.38, -0.93),
    end: Alignment(0.38, 0.93),
    colors: <Color>[Color(0xFF24683A), Color(0xFF17482A), Color(0xFF113A22)],
    stops: <double>[0, 0.58, 1],
  );

  static const RadialGradient welcomeBg = RadialGradient(
    center: Alignment(0, -1),
    radius: 1.2,
    colors: <Color>[Color(0xFF2A7245), Color(0xFF17492B), Color(0xFF0F3320)],
    stops: <double>[0, 0.52, 1],
  );

  static const RadialGradient halo = RadialGradient(
    colors: <Color>[Color(0x57A9C79A), Color(0x1AA9C79A), Color(0x00A9C79A)],
    stops: <double>[0, 0.58, 0.72],
  );

  static const RadialGradient resultHalo = RadialGradient(
    colors: <Color>[Color(0x6BA9C79A), Color(0x00A9C79A)],
    stops: <double>[0, 0.68],
  );

  static const LinearGradient chartArea = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0x424E9A51), Color(0x00000000)],
  );

  static const LinearGradient footerFade = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: <Color>[ground, Color(0x00F7F8F3)],
    stops: <double>[0, 0.62],
  );
}

/// Font families. Both are bundled locally as OFL variable fonts.
class EcoFont {
  EcoFont._();
  static const String display = 'Fredoka';
  static const String body = 'NunitoSans';
}

FontWeight _weight(double w) {
  if (w <= 300) return FontWeight.w300;
  if (w <= 400) return FontWeight.w400;
  if (w <= 500) return FontWeight.w500;
  if (w <= 600) return FontWeight.w600;
  if (w <= 700) return FontWeight.w700;
  if (w <= 800) return FontWeight.w800;
  return FontWeight.w900;
}

/// The type scale.
///
/// Every style pins both `fontWeight` and an explicit `wght` variation, so the
/// bundled variable fonts render at the intended weight on every platform.
class F {
  F._();

  static TextStyle d(
    double size, {
    double wght = 600,
    Color color = Eco.ink,
    double? height,
    double? ls,
  }) {
    return TextStyle(
      fontFamily: EcoFont.display,
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: ls ?? -0.01,
      fontWeight: _weight(wght),
      fontVariations: <FontVariation>[FontVariation('wght', wght)],
    );
  }

  static TextStyle b(
    double size, {
    double wght = 400,
    Color color = Eco.ink,
    double? height,
    double ls = 0,
  }) {
    return TextStyle(
      fontFamily: EcoFont.body,
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: ls,
      fontWeight: _weight(wght),
      fontVariations: <FontVariation>[FontVariation('wght', wght)],
    );
  }

  static TextStyle get h1 => d(27, height: 1.16);
  static TextStyle get h2 => d(21, height: 1.2);
  static TextStyle get h3 => d(17, height: 1.25);
  static TextStyle get display20 => d(20);
  static TextStyle get eyebrow => b(12, wght: 800, ls: 1.2, color: Eco.muted);
  static TextStyle get small => b(14);
  static TextStyle get caption => b(13, height: 1.45, color: Eco.muted);
  static TextStyle get body2 => b(14.5, height: 1.5, color: Eco.ink2);
  static TextStyle get statNum => d(20);
  static TextStyle get statCap => b(12.5, wght: 700, color: Eco.muted);
}

ThemeData ecoTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: Eco.forest,
  ).copyWith(
    primary: Eco.forest,
    onPrimary: const Color(0xFFF4FAF0),
    secondary: Eco.amber,
    onSecondary: const Color(0xFF3A2703),
    error: Eco.danger,
    onError: Colors.white,
    surface: Eco.surface,
    onSurface: Eco.ink,
  );

  final TextTheme text = const TextTheme().apply(
    fontFamily: EcoFont.body,
    bodyColor: Eco.ink,
    displayColor: Eco.ink,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: Eco.ground,
    canvasColor: Eco.ground,
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    dividerColor: Eco.line,
    fontFamily: EcoFont.body,
    textTheme: text,
    hintColor: Eco.muted,
  );
}
