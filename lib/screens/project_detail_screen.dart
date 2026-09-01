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
                    child: _BentoGallery(images: gallery, isMobile: isMobile),
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
  const _BentoGallery({required this.images, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final gap = isMobile ? 12.0 : 18.0;

    if (isMobile) {
      // One tall featured shot full-width, then two even 2-up rows —
      // still a mosaic, just single-column-friendly for narrow screens.
      return Column(
        children: [
          _GalleryTile(path: images[0], height: 260, index: 0),
          SizedBox(height: gap),
          Row(
            children: [
              Expanded(child: _GalleryTile(path: images[1], height: 170, index: 1)),
              SizedBox(width: gap),
              Expanded(child: _GalleryTile(path: images[2], height: 170, index: 2)),
            ],
          ),
          SizedBox(height: gap),
          Row(
            children: [
              Expanded(child: _GalleryTile(path: images[3], height: 170, index: 3)),
              SizedBox(width: gap),
              Expanded(child: _GalleryTile(path: images[4], height: 170, index: 4)),
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
              Expanded(flex: 3, child: _GalleryTile(path: images[0], height: 380, index: 0)),
              SizedBox(width: gap),
              Expanded(flex: 2, child: _GalleryTile(path: images[1], height: 380, index: 1)),
            ],
          ),
        ),
        SizedBox(height: gap),
        SizedBox(
          height: 230,
          child: Row(
            children: [
              Expanded(child: _GalleryTile(path: images[2], height: 230, index: 2)),
              SizedBox(width: gap),
              Expanded(child: _GalleryTile(path: images[3], height: 230, index: 3)),
              SizedBox(width: gap),
              Expanded(child: _GalleryTile(path: images[4], height: 230, index: 4)),
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
  const _GalleryTile({required this.path, required this.height, required this.index});

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
              ? Image.asset(
                  path,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      Container(decoration: BoxDecoration(gradient: context.colors.violetGradientWide)),
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
