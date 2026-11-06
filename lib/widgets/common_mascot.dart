part of 'common.dart';

/* ==========================================================================
   Mascot art
   ========================================================================== */

const Map<String, String> _avatarAssetPaths = <String, String>{
  'image.png': 'assets/images/portraits/image.png',
  'image-2.png': 'assets/images/portraits/image-2.png',
  'image-5.png': 'assets/images/portraits/image-5.png',
  'level-1': 'assets/level-mascots/level-1.png',
  'level-2': 'assets/level-mascots/level-2.png',
  'level-3': 'assets/level-mascots/level-3.png',
  'level-4': 'assets/level-mascots/level-4.png',
  'level-5': 'assets/level-mascots/level-5.png',
};

const Set<String> _portraitAvatarNames = <String>{
  'image.png',
  'image-2.png',
  'image-5.png',
};

String mascotPath(String name) =>
    _avatarAssetPaths[name] ?? 'assets/mascot-clean/$name.png';

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
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          _mascotFallback(context),
    );
  }
}

Widget _mascotFallback(BuildContext context) => Center(
      child: Icon(
        Icons.eco_outlined,
        color: Theme.of(context).colorScheme.muted,
      ),
    );

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
    final int portraitCacheWidth =
        (size * photoScale * MediaQuery.devicePixelRatioOf(context))
            .round()
            .clamp(1, 256)
            .toInt();
    final Widget image = Container(
      width: size,
      height: size,
      color: bg,
      child: _avatarAssetPaths.containsKey(name)
          ? Image.asset(
              mascotPath(name),
              cacheWidth: _portraitAvatarNames.contains(name)
                  ? portraitCacheWidth
                  : null,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stack) =>
                      _mascotFallback(context),
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
                    errorBuilder: (BuildContext context, Object error,
                            StackTrace? stack) =>
                        _mascotFallback(context),
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

