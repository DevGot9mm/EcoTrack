import 'dart:math' as math;
import 'package:flutter/material.dart' hide Badge;

import '../icons.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';

/* ==========================================================================
   Celebration types
   ========================================================================== */

/// Set to true in tests to disable infinite animations (StreakPulse, etc.)
bool debugDisableCelebrationAnimations = false;

enum CelebrationKind {
  badge,
  levelUp,
  challengeComplete,
  points,
}

/* ==========================================================================
   The overlay entry — managed by AppGate via store state
   ========================================================================== */

/// Drives the overlay entry from the store's current celebration state.
/// Inserted into the overlay by [AppGate]; this widget does not render
/// anything visible itself — it reads the store's active celebration and
/// shows the appropriate animated overlay.
class CelebrationHost extends StatefulWidget {
  const CelebrationHost({super.key});

  @override
  State<CelebrationHost> createState() => _CelebrationHostState();
}

class _CelebrationHostState extends State<CelebrationHost>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _slide;
  CelebrationKind? _active;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _slide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _show(CelebrationKind kind, Map<String, dynamic> data) {
    _active = kind;
    _data = data;
    _ctrl.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      _ctrl.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _active = null;
          _data = null;
        });
        final EcoStore store = EcoScope.of(context);
        store.clearCelebration();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EcoScope.of(context),
      builder: (BuildContext context, Widget? child) {
        final EcoStore store = EcoScope.of(context);
        final kind = store.celebrationKind;
        final data = store.celebrationData;

        Widget? overlay;
        if (kind != null && kind != _active) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _show(kind, data));
        }

        if (_active == null) return const SizedBox.shrink();

        overlay = _buildOverlay(_active!, _data ?? {});

        return AnimatedBuilder(
          animation: _ctrl,
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: _SlideIn(
                  progress: _slide.value,
                  child: overlay!,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverlay(CelebrationKind kind, Map<String, dynamic> data) {
    switch (kind) {
      case CelebrationKind.badge:
        return _BadgeCelebration(badge: data['badge'] as Badge);
      case CelebrationKind.levelUp:
        return _LevelUpCelebration(
          name: data['name'] as String,
          idx: data['idx'] as int,
        );
      case CelebrationKind.challengeComplete:
        return _ChallengeCelebration(
          title: data['title'] as String,
          points: data['points'] as int,
        );
      case CelebrationKind.points:
        return _PointsPopup(
          amount: data['amount'] as int,
          reason: data['reason'] as String,
        );
    }
  }
}

/// Wraps the card in a bottom-to-top slide-in.
class _SlideIn extends StatelessWidget {
  const _SlideIn({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.25 * (1 - progress),
        ),
        child: child,
      ),
    );
  }
}

/* ==========================================================================
   Badge unlock celebration
   ========================================================================== */

class _BadgeCelebration extends StatelessWidget {
  const _BadgeCelebration({required this.badge});

  final Badge badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: cs.mint,
          borderRadius: BorderRadius.circular(Eco.rSheet),
          boxShadow: Eco.shadowToast,
          border: Border.all(color: cs.lineMint, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _GlowRing(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.mint,
                  shape: BoxShape.circle,
                ),
                child: EcoIcon(badge.icon, size: 40, color: cs.leaf),
              ),
            ),
            const SizedBox(height: 16),
            Text('Badge Unlocked!',
                style: F.eyebrow(context).copyWith(color: cs.leaf)),
            const SizedBox(height: 6),
            Text(
              badge.name,
              style: F.d(22, color: cs.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              badge.desc,
              style: F.caption(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                EcoIcon('sparkles', size: 16, color: cs.amber),
                const SizedBox(width: 6),
                Text(
                  '+50 Eco Points',
                  style: F.b(14, wght: 800, color: cs.amberInk),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ==========================================================================
   Level up celebration
   ========================================================================== */

class _LevelUpCelebration extends StatelessWidget {
  const _LevelUpCelebration({required this.name, required this.idx});

  final String name;
  final int idx;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: cs.heroCardGradient,
          borderRadius: BorderRadius.circular(Eco.rSheet),
          boxShadow: Eco.shadowToast,
          border: Border.all(color: const Color(0x47FFFFFF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'LEVEL UP',
              style: F.eyebrow(context).copyWith(
                    color: const Color(0xB3FFFFFF),
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Level ${idx + 1}',
              style: F.d(32, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: F.d(22, color: cs.sage),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                EcoIcon('sparkles', size: 16, color: cs.amber),
                const SizedBox(width: 6),
                Text(
                  'New title unlocked!',
                  style: F.b(14, wght: 700, color: const Color(0xD9FFFFFF)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ==========================================================================
   Challenge complete celebration
   ========================================================================== */

class _ChallengeCelebration extends StatelessWidget {
  const _ChallengeCelebration({required this.title, required this.points});

  final String title;
  final int points;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: cs.amberTint,
          borderRadius: BorderRadius.circular(Eco.rSheet),
          boxShadow: Eco.shadowToast,
          border: Border.all(color: cs.lineAmber, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                EcoIcon('check-circle', size: 24, color: cs.leaf),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Challenge complete!',
                    style: F.d(18, color: cs.ink),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: F.b(14, color: cs.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                EcoIcon('sparkles', size: 18, color: cs.amber),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '+$points Eco Points',
                    style: F.b(18, wght: 800, color: cs.amberInk),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ==========================================================================
   Floating points popup
   ========================================================================== */

class _PointsPopup extends StatelessWidget {
  const _PointsPopup({required this.amount, required this.reason});

  final int amount;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: cs.forest,
          borderRadius: BorderRadius.circular(Eco.rPill),
          boxShadow: Eco.shadowToast,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            EcoIcon('sparkles', size: 18, color: cs.sage),
            const SizedBox(width: 10),
            Text(
              '+$amount pts',
              style: F.b(17, wght: 800, color: Colors.white),
            ),
            if (reason.isNotEmpty) ...<Widget>[
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 16,
                color: const Color(0x4DFFFFFF),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  reason,
                  style: F.b(13, color: cs.sage),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/* ==========================================================================
   Ambient glow ring used on badge reveal
   ========================================================================== */

class _GlowRing extends StatefulWidget {
  const _GlowRing({required this.child});

  final Widget child;

  @override
  State<_GlowRing> createState() => _GlowRingState();
}

class _GlowRingState extends State<_GlowRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: cs.sage.withValues(alpha: 0.3 + 0.3 * _ctrl.value),
                blurRadius: 12 + 8 * _ctrl.value,
                spreadRadius: 2 + 4 * _ctrl.value,
              ),
            ],
          ),
          child: Center(child: widget.child),
        );
      },
    );
  }
}

/* ==========================================================================
   Sparkle confetti particles — ambient background on celebrations
   ========================================================================== */

class SparkleField extends StatefulWidget {
  const SparkleField({super.key, this.count = 20});

  final int count;

  @override
  State<SparkleField> createState() => _SparkleFieldState();
}

class _SparkleFieldState extends State<SparkleField>
    with TickerProviderStateMixin {
  late List<_Particle> _particles;
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    final cs = Theme.of(context).colorScheme;
    _particles = List<_Particle>.generate(
      widget.count,
      (_) => _Particle(
        c0: cs.sage,
        c1: cs.amber,
        c2: cs.forest,
      ),
    );
    if (!debugDisableCelebrationAnimations) {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
    } else {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      );
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (debugDisableCelebrationAnimations) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: _SparklePainter(
            particles: _particles,
            t: _ctrl.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  _Particle({
    required Color c0,
    required Color c1,
    required Color c2,
  }) : color = [c0, c1, c2, c0][math.Random().nextInt(4)];

  final double x = math.Random().nextDouble();
  final double y = math.Random().nextDouble();
  final double size = 2 + math.Random().nextDouble() * 4;
  final double speed = 0.3 + math.Random().nextDouble() * 0.7;
  final double phase = math.Random().nextDouble() * math.pi * 2;
  final Color color;
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.particles, required this.t});

  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final double y = ((p.y - t * p.speed) % 1.0) * size.height;
      final double alpha =
          (math.sin(t * math.pi * 2 + p.phase) * 0.5 + 0.5) * 0.7;
      final Paint paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.x * size.width, y),
        p.size * (0.8 + 0.4 * math.sin(t * math.pi * 2 + p.phase)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => t != old.t;
}

/* ==========================================================================
   Streak flame pulse — used on the challenges screen streak pill
   ========================================================================== */

class StreakPulse extends StatefulWidget {
  const StreakPulse({super.key, required this.days, required this.child});

  final int days;
  final Widget child;

  @override
  State<StreakPulse> createState() => _StreakPulseState();
}

class _StreakPulseState extends State<StreakPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    if (!debugDisableCelebrationAnimations) {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
    } else {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (debugDisableCelebrationAnimations) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: 1.0 + 0.08 * _ctrl.value,
          child: Opacity(
            opacity: 0.85 + 0.15 * _ctrl.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
