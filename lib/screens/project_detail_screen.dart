import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_project.dart';
import '../providers/language_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/tilt_3d_card.dart';

/// A single project's full case-study page, opened by tapping its tile
/// in the "Who am I" Projects grid (see _ProjectCard in
/// who_am_i_screen.dart). The write-up (category, title, description,
/// Behance link) leads at the very top — above every photo, not just
/// above a lone cover shot — then the project's 5 photos follow in a
/// distinctive "bento" gallery: one featured shot plus 4 supporting
/// ones, each tilting toward the pointer on hover (see [Tilt3DCard]).
class ProjectDetailScreen extends StatelessWidget {
  final PortfolioProject project;
  const ProjectDetailScreen({super.key, required this.project});

  Future<void> _openBehanceUrl(String raw) async {
    final url = raw.trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // Opens the tapped photo full-screen, pinch/scroll-zoomable, and lets
  // the user swipe between the rest of this project's real photos
  // (the padded placeholder slots in the bento grid are never tappable,
  // so [images] here is always the project's actual, un-padded list).
  void _openLightbox(BuildContext context, List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.95),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, __) => FadeTransition(
          opacity: animation,
          child: _ImageLightbox(images: images, initialIndex: initialIndex),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);
    final isArabic = context.isArabicLanguage;
    AppFonts.forceArabic = context.isArabicFontMode;

    final categoryLabel = project.category.labelFor(isArabic);
    final description = project.descriptionFor();
    final hasUrl = project.url.trim().isNotEmpty;
    // Exactly 5 slots for the bento gallery below — padded with empty
    // strings (rendered as violet placeholder plates) if fewer than 5
    // images were supplied, and capped at 5 if more were.
    final gallery = List<String>.generate(
      5,
      (i) => i < project.images.length ? project.images[i] : '',
    );

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.colors.bgDeep,
        body: AnimatedBackdrop(
          intensity: 0.5,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: 20),
                    child: Row(
                      children: [
                        _RoundIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Write-up block — category, title, description, link —
                  // sits above the entire gallery now, so the story is
                  // read first and the photos illustrate it underneath,
                  // rather than a single hero image fronting the text.
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.colors.orchid.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: context.colors.orchid.withOpacity(0.4)),
                          ),
                          child: Text(categoryLabel,
                            style: AppFonts.label(
                              text: categoryLabel,
                              size: 12.5,
                              weight: FontWeight.w700,
                              color: context.colors.orchid,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(project.title,
                          style: AppFonts.display(
                            text: project.title,
                            size: isMobile ? 28 : 38,
                            weight: FontWeight.w800,
                            color: context.colors.cream,
                            height: 1.15,
                          ),
                        ),
                        if (description.trim().isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(description,
                            style: AppFonts.body(
                              text: description,
                              size: isMobile ? 16 : 17.5,
                              weight: FontWeight.w500,
                              height: 1.6,
                              color: context.colors.creamDim,
                            ),
                          ),
                        ],
                        if (hasUrl) ...[
                          const SizedBox(height: 22),
                          _BehanceButton(onTap: () => _openBehanceUrl(project.url), isArabic: isArabic),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
                    child: _BentoGallery(
                      images: gallery,
                      isMobile: isMobile,
                      onTapImage: (i) => _openLightbox(context, project.images, i),
                    ),
                  ),
                  const SizedBox(height: 44),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The project's 5 photos laid out as an asymmetric "bento" mosaic
/// instead of a plain stack — one larger featured shot up top, then 4
/// supporting shots below it. Each tile tilts toward the pointer on
/// hover (desktop) and eases into view as it scrolls onscreen, so the
/// gallery reads as a deliberate showcase rather than a photo dump.
class _BentoGallery extends StatelessWidget {
  final List<String> images; // always length 5 (some may be '')
  final bool isMobile;
  final ValueChanged<int> onTapImage;
  const _BentoGallery({required this.images, required this.isMobile, required this.onTapImage});

  @override
  Widget build(BuildContext context) {
    final gap = isMobile ? 12.0 : 18.0;

    if (isMobile) {
      // One tall featured shot full-width, then two even 2-up rows —
      // still a mosaic, just single-column-friendly for narrow screens.
      return Column(
        children: [
          _GalleryTile(path: images[0], height: 260, index: 0, onTap: () => onTapImage(0)),
          SizedBox(height: gap),
          Row(
            children: [
              Expanded(child: _GalleryTile(path: images[1], height: 170, index: 1, onTap: () => onTapImage(1))),
              SizedBox(width: gap),
              Expanded(child: _GalleryTile(path: images[2], height: 170, index: 2, onTap: () => onTapImage(2))),
            ],
          ),
          SizedBox(height: gap),
          Row(
            children: [
              Expanded(child: _GalleryTile(path: images[3], height: 170, index: 3, onTap: () => onTapImage(3))),
              SizedBox(width: gap),
              Expanded(child: _GalleryTile(path: images[4], height: 170, index: 4, onTap: () => onTapImage(4))),
            ],
          ),
        ],
      );
    }

    // Desktop bento: a wide featured shot + a tall side shot sharing the
    // top row, then three even shots underneath — five photos, five
    // distinct proportions, nothing repeating the plain "stack" reading.
    return Column(
      children: [
        SizedBox(
          height: 380,
          child: Row(
            children: [
              Expanded(flex: 3, child: _GalleryTile(path: images[0], height: 380, index: 0, onTap: () => onTapImage(0))),
              SizedBox(width: gap),
              Expanded(flex: 2, child: _GalleryTile(path: images[1], height: 380, index: 1, onTap: () => onTapImage(1))),
            ],
          ),
        ),
        SizedBox(height: gap),
        SizedBox(
          height: 230,
          child: Row(
            children: [
              Expanded(child: _GalleryTile(path: images[2], height: 230, index: 2, onTap: () => onTapImage(2))),
              SizedBox(width: gap),
              Expanded(child: _GalleryTile(path: images[3], height: 230, index: 3, onTap: () => onTapImage(3))),
              SizedBox(width: gap),
              Expanded(child: _GalleryTile(path: images[4], height: 230, index: 4, onTap: () => onTapImage(4))),
            ],
          ),
        ),
      ],
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final String path;
  final double height;
  final int index;
  final VoidCallback onTap;
  const _GalleryTile({required this.path, required this.height, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = path.trim().isNotEmpty;
    return RevealOnScroll(
      delay: Duration(milliseconds: 70 * index),
      offsetY: 28,
      child: SizedBox(
        height: height,
        child: Tilt3DCard(
          maxTiltDegrees: 6,
          liftOnHover: 6,
          borderRadius: BorderRadius.circular(18),
          child: hasImage
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Image.asset(
                      path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          Container(decoration: BoxDecoration(gradient: context.colors.violetGradientWide)),
                    ),
                  ),
                )
              : Container(decoration: BoxDecoration(gradient: context.colors.violetGradientWide)),
        ),
      ),
    );
  }
}

class _BehanceButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isArabic;
  const _BehanceButton({required this.onTap, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final label = isArabic ? 'عرض على بيهانس' : 'View on Behance';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            gradient: context.colors.violetGradient,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppFonts.label(text: label, size: 14, weight: FontWeight.w700, color: Colors.white)),
              const SizedBox(width: 8),
              const Icon(Icons.north_east_rounded, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface.withOpacity(0.7),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: context.colors.cream),
        ),
      ),
    );
  }
}

/// Lets a mouse/trackpad drag the lightbox's PageView on desktop web —
/// by default Flutter only treats touch/stylus drags as page-swipe
/// gestures, which is why dragging with a mouse did nothing.
class _LightboxDragScrollBehavior extends MaterialScrollBehavior {
  const _LightboxDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// Full-screen photo viewer opened by tapping any gallery image. Each
/// photo is pinch/scroll-zoomable and pannable (see [InteractiveViewer]),
/// and swiping left/right moves between the rest of the project's real
/// photos without leaving this view. A tap outside the zoomed image, the
/// close button, or the back gesture all dismiss it.
class _ImageLightbox extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _ImageLightbox({required this.images, required this.initialIndex});

  @override
  State<_ImageLightbox> createState() => _ImageLightboxState();
}

class _ImageLightboxState extends State<_ImageLightbox> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            ScrollConfiguration(
              behavior: const _LightboxDragScrollBehavior(),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  return _ZoomableImage(path: widget.images[i]);
                },
              ),
            ),
            Positioned(
              top: 12,
              right: 16,
              child: _RoundIconButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            // Left/right arrow buttons — mainly for desktop web, where
            // there's no obvious touch-swipe affordance. Hidden at the
            // first/last image instead of disabled, so it's clear when
            // there's nowhere further to go. Wrapping to previous/next
            // uses direct page numbers rather than +1/-1 so RTL page
            // order doesn't flip the intended direction.
            if (widget.images.length > 1) ...[
              if (_index > 0)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 12,
                  child: Center(
                    child: _RoundIconButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => _controller.animateToPage(
                        _index - 1,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                ),
              if (_index < widget.images.length - 1)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 12,
                  child: Center(
                    child: _RoundIconButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: () => _controller.animateToPage(
                        _index + 1,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                ),
            ],
            if (widget.images.length > 1)
              Positioned(
                bottom: 22,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single lightbox photo: pinch-to-zoom and pannable via
/// [InteractiveViewer], but crucially panning stays OFF while the image
/// is at its normal, un-zoomed scale. InteractiveViewer otherwise
/// swallows every horizontal drag for its own panning before the
/// [PageView] above it ever sees it, which is exactly why swiping
/// between photos previously did nothing. Panning turns back on only
/// once the user has actually pinched (or double-tapped) to zoom in, at
/// which point dragging pans the zoomed image instead of changing pages
/// — the same trade-off most photo viewers make.
class _ZoomableImage extends StatefulWidget {
  final String path;
  const _ZoomableImage({required this.path});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _transformController = TransformationController();
  bool _zoomed = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    final scale = _transformController.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.01;
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  void _onDoubleTap() {
    if (_zoomed) {
      _transformController.value = Matrix4.identity();
      setState(() => _zoomed = false);
    } else {
      _transformController.value = Matrix4.identity()..scale(2.5);
      setState(() => _zoomed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 1,
        maxScale: 4,
        panEnabled: _zoomed,
        onInteractionEnd: _onInteractionEnd,
        child: Center(
          child: Image.asset(
            widget.path,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
