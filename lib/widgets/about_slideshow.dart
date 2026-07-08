import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/about_me.dart';
import '../theme/app_theme.dart';

/// Flutter's default web scroll behaviour only lets touch/stylus pointers
/// drag a scrollable — a mouse click-and-drag is ignored, which is why the
/// slideshow used to only respond to the tiny arrow buttons on desktop
/// browsers. This allows touch, mouse, trackpad, and stylus to all drag it,
/// so swiping works the same way everywhere: phone, trackpad, or mouse.
class _DraggableScrollBehavior extends MaterialScrollBehavior {
  const _DraggableScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// The photo slideshow at the top of the "Who am I" page. Fully manual —
/// no autoplay — so the visitor is always the one in control: swipe, tap a
/// dot, or use the arrow buttons.
///
/// The frame itself is a single fixed size (set by [height], scaled for
/// mobile/desktop by the caller) so every photo — portrait, landscape,
/// square, panoramic — sits inside the exact same box. Each photo is drawn
/// twice: a soft, blurred, cropped copy fills the whole frame edge-to-edge
/// as a backdrop, and the full, uncropped photo sits centered on top at
/// its real proportions. That combination means no photo is ever cropped
/// or squeezed to fit, and no photo (portrait or panoramic) leaves an
/// awkward patch of empty background — the frame looks intentional for
/// every picture, and never jumps size while swiping between them.
class AboutSlideshow extends StatefulWidget {
  final List<AboutSlide> slides;

  /// Fixed frame height for this breakpoint (e.g. 240 on mobile, 480 on
  /// desktop). Every slide renders inside a box exactly this tall.
  final double height;

  const AboutSlideshow({super.key, required this.slides, this.height = 380});

  @override
  State<AboutSlideshow> createState() => _AboutSlideshowState();
}

class _AboutSlideshowState extends State<AboutSlideshow> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void didUpdateWidget(covariant AboutSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) {
      _page = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (!_controller.hasClients) return;
    _controller.animateToPage(
      index.clamp(0, widget.slides.length - 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return _EmptySlide(height: widget.height);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: [
            ScrollConfiguration(
              behavior: const _DraggableScrollBehavior(),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final slide = widget.slides[i];
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double page = i.toDouble();
                      if (_controller.hasClients && _controller.position.haveDimensions) {
                        page = _controller.page ?? _page.toDouble();
                      } else {
                        page = _page.toDouble();
                      }
                      final delta = (page - i).abs().clamp(0.0, 1.0);
                      final scale = 1 - (delta * 0.12);
                      final opacity = 1 - (delta * 0.4);
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(opacity: opacity, child: child),
                      );
                    },
                    child: _FramedPhoto(
                      imageUrl: slide.imageUrl,
                      errorFallback: _EmptySlide(height: widget.height),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.slides.length > 1) ...[
              Positioned(
                left: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _ArrowButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _page > 0 ? () => _goTo(_page - 1) : null,
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _ArrowButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _page < widget.slides.length - 1 ? () => _goTo(_page + 1) : null,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.slides.length, (i) {
                    final active = i == _page;
                    return GestureDetector(
                      onTap: () => _goTo(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: active ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One slide: a blurred, edge-to-edge cropped copy of the photo fills the
/// frame as a backdrop, and the same photo — uncropped, at its real aspect
/// ratio — sits centered on top. Works identically well whether the source
/// photo is a tall portrait, a wide landscape, a square, or a panorama.
class _FramedPhoto extends StatelessWidget {
  final String imageUrl;
  final Widget errorFallback;

  const _FramedPhoto({required this.imageUrl, required this.errorFallback});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Dimmed, cropped copy fills the frame as a backdrop — no blur
        // filter (ImageFiltered/backdrop blur is unreliable on Flutter Web
        // and was the likely reason the whole slide could render blank).
        // A plain darkened cover-fit copy gives the same "no dead space"
        // effect at far lower risk.
        Opacity(
          opacity: 0.4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.18))),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => errorFallback,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 0.9 : 0.25,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _EmptySlide extends StatelessWidget {
  final double height;
  const _EmptySlide({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: context.colors.violetGradientWide,
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 44,
        color: Colors.white.withOpacity(0.6),
      ),
    );
  }
}
