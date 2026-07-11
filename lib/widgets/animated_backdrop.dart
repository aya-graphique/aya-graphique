import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A slow, ambient, looping background: soft blurred color orbs drifting
/// on independent sine paths, plus a thin scatter of drifting particles.
/// Pure CustomPainter + one AnimationController — cheap enough to run
/// behind the whole page on web.
class AnimatedBackdrop extends StatefulWidget {
  final Widget? child;
  final double intensity;

  const AnimatedBackdrop({super.key, this.child, this.intensity = 1.0});

  @override
  State<AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = List.generate(
    26,
    (i) => _Particle.random(i),
  );

  Offset? _pointer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Light mode: plain, static background — no drifting orbs, no
    // particles, no cursor glow. Dark mode keeps the full ambient scene.
    if (!colors.isDark) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: colors.bgDeep),
          if (widget.child != null) widget.child!,
        ],
      );
    }

    return MouseRegion(
      onHover: (e) => setState(() => _pointer = e.position),
      onExit: (_) => setState(() => _pointer = null),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: colors.bgDeep),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _BackdropPainter(
                  t: _controller.value,
                  particles: _particles,
                  intensity: widget.intensity,
                  colors: colors,
                ),
              );
            },
          ),
          // A soft violet glow that drifts toward the cursor — a subtle,
          // continuously-animated layer so the page always feels alive.
          // AnimatedPositioned must sit directly inside the Stack for its
          // Positioned parent data to apply; IgnorePointer goes *inside* it.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            left: (_pointer?.dx ?? -400) - 260,
            top: (_pointer?.dy ?? -400) - 260,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _pointer != null ? 1 : 0,
                child: Container(
                  width: 520,
                  height: 520,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.violetPop.withOpacity(0.16),
                        colors.violetPop.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _Particle {
  final double seed;
  final double radius;
  final double speed;
  final double xBase;
  final double yBase;
  final bool bright;

  _Particle({
    required this.seed,
    required this.radius,
    required this.speed,
    required this.xBase,
    required this.yBase,
    required this.bright,
  });

  factory _Particle.random(int i) {
    final rnd = math.Random(i * 977);
    return _Particle(
      seed: rnd.nextDouble() * math.pi * 2,
      radius: 1.0 + rnd.nextDouble() * 2.2,
      speed: 0.4 + rnd.nextDouble() * 0.8,
      xBase: rnd.nextDouble(),
      yBase: rnd.nextDouble(),
      bright: rnd.nextBool(),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  final double t; // 0..1 looping
  final List<_Particle> particles;
  final double intensity;
  final AppColors colors;

  _BackdropPainter({
    required this.t,
    required this.particles,
    required this.intensity,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t * 2 * math.pi;

    void orb(Offset center, double radius, Color color, double opacity) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withOpacity(opacity * intensity),
            color.withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      canvas.drawCircle(center, radius, paint);
    }

    // Three large drifting orbs on independent elliptical paths. The top
    // two used to run brighter (0.30 / 0.28) — strong enough that any
    // transparent section which happened to scroll into their fixed
    // screen-space position (the backdrop doesn't move with scroll) read
    // as an odd, mismatched light patch instead of blending in. Dialed
    // down so the ambient glow stays subtle everywhere it's exposed.
    orb(
      Offset(
        size.width * 0.18 + math.sin(angle) * size.width * 0.08,
        size.height * 0.22 + math.cos(angle * 0.8) * size.height * 0.06,
      ),
      size.shortestSide * 0.42,
      colors.violetPop,
      0.16,
    );

    orb(
      Offset(
        size.width * 0.82 + math.cos(angle * 0.6) * size.width * 0.07,
        size.height * 0.30 + math.sin(angle * 0.9) * size.height * 0.07,
      ),
      size.shortestSide * 0.36,
      colors.violetLight,
      0.15,
    );

    orb(
      Offset(
        size.width * 0.55 + math.sin(angle * 0.5 + 2) * size.width * 0.10,
        size.height * 0.85 + math.cos(angle * 0.7) * size.height * 0.05,
      ),
      size.shortestSide * 0.40,
      colors.orchid,
      0.16,
    );

    // Fourth orb — deep ink-purple, slow pulse, adds more dark-purple wash.
    final pulse = 0.85 + math.sin(angle * 1.6) * 0.15;
    orb(
      Offset(
        size.width * 0.30 + math.cos(angle * 0.4 + 1.3) * size.width * 0.12,
        size.height * 0.62 + math.sin(angle * 0.55 + 0.7) * size.height * 0.08,
      ),
      size.shortestSide * 0.46 * pulse,
      colors.violetDeep,
      0.34,
    );

    // Drifting + twinkling particles.
    for (final p in particles) {
      final dx = (p.xBase + math.sin(angle * p.speed + p.seed) * 0.04) %
          1.0 *
          size.width;
      final dy =
          ((p.yBase - t * p.speed * 0.15 + p.seed) % 1.0) * size.height;
      final twinkle = 0.5 + 0.5 * math.sin(angle * (1.5 + p.speed) + p.seed * 3);
      final paint = Paint()
        ..color = (p.bright ? colors.orchid : colors.cream)
            .withOpacity((0.18 + 0.3 * twinkle) * intensity);
      canvas.drawCircle(Offset(dx, dy), p.radius * (0.8 + 0.4 * twinkle), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) => true;
}
