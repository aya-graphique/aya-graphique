import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A small, on-brand floating confirmation — used anywhere a tap needs a
/// quick "yes, that worked" moment (saving/removing a favorite, copying a
/// link, etc.) without reaching for the default Material [SnackBar], whose
/// plain white/dark bar reads flat against this app's glassy violet
/// surfaces and is easy to miss.
///
/// Rendered through the nearest [Overlay] (not ScaffoldMessenger), so it
/// floats centered near the top of the screen — clear of the bottom nav on
/// mobile and of any Scaffold nesting quirks — and always uses the same
/// pop-in/settle/fade timeline regardless of which screen triggered it.
void showAppToast(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_rounded,
  Color? accentColor,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final colors = context.colors;
  final accent = accentColor ?? colors.orchid;
  final entry = OverlayEntry(
    builder: (context) => _AppToast(
      message: message,
      icon: icon,
      accent: accent,
      colors: colors,
    ),
  );

  overlay.insert(entry);
  Timer(const Duration(milliseconds: 2000), () {
    entry.remove();
  });
}

class _AppToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color accent;
  final AppColors colors;

  const _AppToast({
    required this.message,
    required this.icon,
    required this.accent,
    required this.colors,
  });

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _iconPop;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _slide = Tween<double>(begin: -24, end: 0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _iconPop = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.15, 1, curve: Curves.elasticOut)),
    );
    _controller.forward();
    // Start the exit fade shortly before the overlay entry is actually
    // removed, so the toast never just pops off screen.
    Future.delayed(const Duration(milliseconds: 1550), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Positioned(
      top: media.padding.top + 18,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fade.value,
                child: Transform.translate(
                  offset: Offset(0, _slide.value),
                  child: child,
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
                decoration: BoxDecoration(
                  color: widget.colors.isDark
                      ? widget.colors.surfaceRaised.withOpacity(0.92)
                      : widget.colors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: widget.accent.withOpacity(0.45), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.28),
                      blurRadius: 22,
                      spreadRadius: -2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _iconPop,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [widget.accent, widget.accent.withOpacity(0.6)],
                          ),
                        ),
                        child: Icon(widget.icon, size: 15, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          text: widget.message,
                          size: 13.5,
                          weight: FontWeight.w600,
                          color: widget.colors.cream,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
