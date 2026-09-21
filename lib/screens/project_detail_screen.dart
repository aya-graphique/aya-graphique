import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_project.dart';
import '../providers/language_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/social_links_footer.dart';
import '../widgets/tilt_3d_card.dart';

/// A single project's full case-study page, opened by tapping its tile
/// in the "Who am I" Projects grid (see _ProjectCard in
/// who_am_i_screen.dart). The write-up (category, title, description,
/// Behance link) leads at the very top — above every photo, not just
/// above a lone cover shot — then the project's 5 photos follow in a
/// distinctive "bento" gallery: one featured shot plus 4 supporting
/// ones, each tilting toward the pointer on hover (see [Tilt3DCard]) —
/// or fewer tiles, re-laid-out to fit, when a project has fewer than 5
/// photos (no empty placeholder slots).
/// Projects with more than 5 photos keep going below the bento in an
/// even grid of full-ratio tiles (see [_PortraitGrid]) — nothing past
/// the 5th photo is dropped. A project can also opt out of the bento
/// entirely ([ProjectGalleryLayout.grid]) so every photo — e.g. a set of
/// ad designs — shows whole, uncropped.
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
  // ([images] here is always the project's full, actual photo list — the
  // tapped tile's index maps straight onto it).
  //
  // This is a real go_router route (not a bare Navigator.push overlay
  // like a dialog) specifically so it gets its own browser/back-button
  // history entry — otherwise, on mobile, the phone's back button (which
  // acts on browser history, not Flutter's widget-level Navigator) has
  // nothing of this screen to step back through and skips straight past
  // it to wherever the last *tracked* location was.
  //
  // The project id + tapped index are both encoded straight into the
  // URL (instead of passed via `extra`) so this route can rebuild
  // itself — and the two routes underneath it in the stack — purely
  // from the URL. That's what makes the phone's *physical* back button
  // step back one screen at a time (lightbox -> project -> category ->
  // my-works) instead of bouncing all the way to my-works: a real
  // hardware/browser back press re-parses each URL from scratch with no
  // `extra` available, and this project's routes used to treat that as
  // "nothing to show" and redirect straight to '/my-works'.
  void _openLightbox(BuildContext context, List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    context.push('/my-works/project/${project.id}/lightbox/$initialIndex');
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
    // The bento shows the project's first 5 real photos — no empty
    // placeholder slots: with 3 photos it lays out 3 tiles, with 2 it
    // lays out 2, and so on. Any photos beyond the 5th don't fit the
    // bento, so they go into [extraImages] and render in the grid that
    // follows it.
    final gallery = project.images.take(5).toList();
    final extraImages =
        project.images.length > 5 ? project.images.sublist(5) : const <String>[];
    // Grid projects skip the bento altogether and show every photo whole.
    final useGrid =
        project.galleryLayout == ProjectGalleryLayout.grid && project.images.isNotEmpty;

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
                          onTap: () => context.pop(),
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
                    child: useGrid
                        ? _PortraitGrid(
                            images: project.images,
                            startIndex: 0,
                            isMobile: isMobile,
                            onTapImage: (i) => _openLightbox(context, project.images, i),
                          )
                        : Column(
                            children: [
                              _BentoGallery(
                                images: gallery,
                                isMobile: isMobile,
                                onTapImage: (i) => _openLightbox(context, project.images, i),
                              ),
                              if (extraImages.isNotEmpty) ...[
                                SizedBox(height: isMobile ? 12 : 18),
                                _PortraitGrid(
                                  images: extraImages,
                                  // Extras continue the project's photo
                                  // list right after the bento's 5, so
                                  // the lightbox index is offset by 5.
                                  startIndex: 5,
                                  isMobile: isMobile,
                                  onTapImage: (i) => _openLightbox(context, project.images, i),
                                ),
                              ],
                            ],
                          ),
                  ),
                  const SizedBox(height: 44),
                  Center(child: SocialLinksFooter(isMobile: isMobile)),
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

/// The project's photos laid out as an asymmetric "bento" mosaic instead
/// of a plain stack. It adapts to however many real photos there are
/// (1 to 5) — it never pads with empty placeholder plates:
///   * 5 — wide featured + tall side shot, then three even shots
///   * 4 — two staggered rows (wide+tall, then tall+wide)
///   * 3 — one row: wide | tall | wide
///   * 2 — wide featured + tall side shot
///   * 1 — a single large shot
/// On mobile: one featured shot full-width, then the rest in 2-up rows
/// (a last odd photo takes the full row). Each tile tilts toward the
/// pointer on hover (desktop) and eases into view as it scrolls onscreen.
class _BentoGallery extends StatelessWidget {
  final List<String> images; // only the project's real photos: 1–5 of them
  final bool isMobile;
  final ValueChanged<int> onTapImage;
  const _BentoGallery({required this.images, required this.isMobile, required this.onTapImage});

  Widget _tile(int i, double height) =>
      _GalleryTile(path: images[i], height: height, index: i, onTap: () => onTapImage(i));

  // One row of tiles: [indices] sized by matching [flex] weights.
  Widget _row(List<int> indices, List<int> flex, double height, double gap) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (var k = 0; k < indices.length; k++) ...[
            if (k > 0) SizedBox(width: gap),
            Expanded(flex: flex[k], child: _tile(indices[k], height)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = images.length;
    if (n == 0) return const SizedBox.shrink();
    final gap = isMobile ? 12.0 : 18.0;

    if (isMobile) {
      // One featured shot full-width, then 2-up rows; if the count of
      // remaining photos is odd, the last one gets a full-width row.
      return Column(
        children: [
          SizedBox(width: double.infinity, child: _tile(0, n == 1 ? 300 : 260)),
          for (var i = 1; i < n; i += 2) ...[
            SizedBox(height: gap),
            Row(
              children: [
                Expanded(child: _tile(i, 170)),
                if (i + 1 < n) ...[
                  SizedBox(width: gap),
                  Expanded(child: _tile(i + 1, 170)),
                ],
              ],
            ),
          ],
        ],
      );
    }

    // Desktop.
    if (n == 1) {
      return SizedBox(width: double.infinity, child: _tile(0, 460));
    }
    if (n == 2) {
      return _row([0, 1], [3, 2], 380, gap);
    }
    if (n == 3) {
      return _row([0, 1, 2], [3, 2, 3], 380, gap);
    }
    if (n == 4) {
      return Column(
        children: [
          _row([0, 1], [3, 2], 340, gap),
          SizedBox(height: gap),
          _row([2, 3], [2, 3], 340, gap),
        ],
      );
    }
    // 5 photos: a wide featured shot + a tall side shot sharing the top
    // row, then three even shots underneath.
    return Column(
      children: [
        _row([0, 1], [3, 2], 380, gap),
        SizedBox(height: gap),
        _row([2, 3, 4], [1, 1, 1], 230, gap),
      ],
    );
  }
}

/// A project's photos as an even grid of uncropped tiles. Used both for
/// photos 6+ of a bento project (the ones that don't fit its 5 slots)
/// and, for [ProjectGalleryLayout.grid] projects, for every photo.
/// An even grid (2 across on mobile, 3–4 on desktop) whose tiles keep the
/// 4:5 portrait ratio the ad designs are made in, so each design shows
/// whole instead of being center-cropped like in the bento. A short last
/// row is centered rather than left-hanging. Tapping a tile opens the
/// same lightbox as the bento does, at this photo's place in the full
/// list ([startIndex] + its position here).
class _PortraitGrid extends StatelessWidget {
  final List<String> images; // real photos only, no '' placeholders
  final int startIndex;
  final bool isMobile;
  final ValueChanged<int> onTapImage;
  const _PortraitGrid({
    required this.images,
    required this.startIndex,
    required this.isMobile,
    required this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    final gap = isMobile ? 12.0 : 18.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 2 across on mobile, 4 on a wide desktop, 3 on narrower ones.
        final columns = isMobile ? 2 : (constraints.maxWidth >= 1000 ? 4 : 3);
        final tileWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < images.length; i++)
              SizedBox(
                width: tileWidth,
                child: _GalleryTile(
                  path: images[i],
                  height: tileWidth * 1.25, // 4:5 portrait
                  // Stagger the reveal within a row, not across the
                  // whole list, so tiles further down don't wait ages.
                  index: i % columns,
                  onTap: () => onTapImage(startIndex + i),
                ),
              ),
          ],
        );
      },
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
class ProjectImageLightbox extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const ProjectImageLightbox({super.key, required this.images, required this.initialIndex});

  @override
  State<ProjectImageLightbox> createState() => _ProjectImageLightboxState();
}

class _ProjectImageLightboxState extends State<ProjectImageLightbox> {
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
                onTap: () => context.pop(),
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
