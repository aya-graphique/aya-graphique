import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/shimmer_text.dart';
import 'main_shell.dart';

/// The very first thing a visitor sees. Flutter's engine boots and this
/// widget is on screen immediately — nothing here blocks the app from
/// opening fast. Meanwhile [SupabaseService.init] (the one genuinely slow
/// step) runs in the background, and this screen simply holds for a fixed
/// 5 seconds of brand moment before handing off to [MainShell]. If, on a
/// very slow connection, init happens to take longer than 5 seconds, this
/// waits the little bit extra rather than dropping the visitor into a
/// half-ready app — but on any normal connection the two finish together
/// and the handoff feels instant.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minDisplay = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final stopwatch = Stopwatch()..start();
    await SupabaseService.init();
    final elapsed = stopwatch.elapsed;
    final remaining = _minDisplay - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    // A bit bigger than before on both breakpoints, and noticeably larger
    // again on desktop/wide screens where there's room to let it breathe.
    final badgeSize = isMobile ? 148.0 : 190.0;

    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      body: AnimatedBackdrop(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PortraitBadge(size: badgeSize)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 30),
              ShimmerHeadline(
                text: "Aya's Graphique",
                style: AppFonts.display(color: context.colors.cream, size: 26),
              ).animate().fadeIn(duration: 600.ms, delay: 150.ms),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'NOTEBOOKS · CALENDARS · VISUAL DESIGN · ARTS · ADVERTISING',
                  textAlign: TextAlign.center,
                  style: AppFonts.label(color: context.colors.orchid, size: 13, letterSpacing: 2.2),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 250.ms),
              const SizedBox(height: 46),
              const _LoadingBar(duration: _minDisplay)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 350.ms),
            ],
          ),
        ),
      ),
    );
  }
}

/// The brand photo, ringed in a slowly rotating gradient halo — reads as
/// intentional and premium rather than a plain avatar in a box, and gives
/// the splash a bit of motion even before anything else has loaded.
class _PortraitBadge extends StatefulWidget {
  final double size;
  const _PortraitBadge({required this.size});

  @override
  State<_PortraitBadge> createState() => _PortraitBadgeState();
}

class _PortraitBadgeState extends State<_PortraitBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
    final outer = widget.size;
    final gap = outer * 0.915; // ring thickness stays a consistent ~4-5%
    final photo = outer * 0.845;
    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft ambient glow behind everything.
          Container(
            width: outer,
            height: outer,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.violetPop.withOpacity(0.4),
                  blurRadius: outer * 0.38,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Slowly rotating gradient ring.
          RotationTransition(
            turns: _controller,
            child: Container(
              width: outer,
              height: outer,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    colors.orchid,
                    colors.violetPop,
                    colors.violetDeep,
                    colors.orchid,
                  ],
                ),
              ),
            ),
          ),
          // Background-colored gap between the ring and the photo, so the
          // ring reads as a thin outline rather than a filled disc.
          Container(
            width: gap,
            height: gap,
            decoration: BoxDecoration(shape: BoxShape.circle, color: colors.bgDeep),
          ),
          ClipOval(
            child: Image.asset(
              'assets/images/aya_portrait.png',
              width: photo,
              height: photo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: photo,
                height: photo,
                decoration: BoxDecoration(gradient: colors.violetGradient, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  'AG',
                  style: AppFonts.display(color: Colors.white, size: outer * 0.26, weight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A slim progress track whose fill actually tracks the splash's real
/// 5-second hold — quieter and more purposeful than a spinner, since it
/// gives the visitor an honest sense of "almost there" rather than an
/// indefinite loop.
class _LoadingBar extends StatefulWidget {
  final Duration duration;
  const _LoadingBar({required this.duration});

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 140,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          color: Colors.white.withOpacity(0.08),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _controller.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [colors.violetPop, colors.orchid]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
