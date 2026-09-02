import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../models/portfolio_project.dart';
import '../providers/language_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_heading.dart';
import '../widgets/tilt_3d_card.dart';
import 'project_detail_screen.dart';

/// A representative glyph per project category, used only to give an
/// empty (no-image-yet) project cover something more designed than a
/// flat gradient — a large, faint watermark hinting at the kind of work
/// it is, rather than a blank plate.
IconData _iconForCategory(ProjectCategory category) {
  switch (category) {
    case ProjectCategory.logoIdentity:
      return Icons.auto_awesome_outlined;
    case ProjectCategory.packaging:
      return Icons.inventory_2_outlined;
    case ProjectCategory.advertising:
      return Icons.campaign_outlined;
    case ProjectCategory.artwork:
      return Icons.brush_outlined;
  }
}

// ---------------------------------------------------------------------
// ✏️ عدّلي هنا يدويًا: كل مشروع جديد ضيفيه كـ PortfolioProject في
// الليستة دي (النوع نفسه معرّف في lib/models/portfolio_project.dart).
// - title / description / fullDescription: بالعربي والانجليزي حسب
//   isArabic زي باقي الصفحة. description قصير (مش بيظهر في الجريد حاليًا
//   بس متاح لأي استخدام تاني)، fullDescription هو النص اللي بيظهر في
//   صفحة تفاصيل المشروع (زي وصف المشروع في بيهانس).
// - category: واحدة من 4 أنواع بس (ProjectCategory.logoIdentity /
//   .packaging / .advertising / .artwork) — بتظهر كـ تاج صغير فوق
//   الصورة وفي أعلى صفحة التفاصيل.
// - images: لستة بـ 5 صور بالظبط لكل مشروع، مسارها تحت assets/images/
//   (المجلد كله مسجّل في pubspec.yaml أصلاً، مفيش داعي تضيفي حاجة —
//   كفاية تحطي الملفات في المسارات دي). أول صورة هي غلاف الكارت في
//   الجريد، والـ5 صور بيظهروا في صفحة التفاصيل في جاليري "بينتو"
//   مميز (صورة كبيرة رئيسية + 4 صور جنبها) بدل ما يتعرضوا تحت بعض
//   عادي. سيبي أي مسار زي ما هو من غير ما تحطي صورة عشان تظهر بلاطة
//   بنفسجية بدالها لحد ما تجهزي الصور.
// - url: رابط بيهانس الحقيقي للمشروع (اختياري) — بيظهر كزرار "View on
//   Behance" في صفحة التفاصيل، أو سيبيه فاضي عشان الزرار ميظهرش.
// ---------------------------------------------------------------------
List<PortfolioProject> kProjects(bool isArabic) => [
      PortfolioProject(
        title: isArabic ? 'اسم المشروع الأول' : 'First Project Name',
        category: ProjectCategory.logoIdentity,
        description: isArabic
            ? 'وصف مختصر للمشروع: إيه اللي اتعمل فيه وليه.'
            : 'A short description of the project: what it is and why.',
        images: const [
          'assets/images/projects/project_1/1.jpg',
          'assets/images/projects/project_1/2.jpg',
          'assets/images/projects/project_1/3.jpg',
          'assets/images/projects/project_1/4.jpg',
          'assets/images/projects/project_1/5.jpg',
        ],
        url: '',
      ),
      PortfolioProject(
        title: isArabic ? 'بيتزا بالكسور' : 'Pizza Fractions',
        category: ProjectCategory.packaging,
        description: isArabic
            ? 'أشهى طريقة لتعلم الكسور'
            : 'The tastiest way to learn fractions.',
        // Standalone box packshot as the grid cover — kept out of the
        // 5-photo gallery below.
        coverOverride: 'assets/images/projects/project_2/cover.jpg',
        images: const [
          'assets/images/projects/project_2/1.jpg',
          'assets/images/projects/project_2/2.jpg',
          'assets/images/projects/project_2/3.jpg',
          'assets/images/projects/project_2/4.jpg',
          'assets/images/projects/project_2/5.jpg',
        ],
        url: '',
      ),
      PortfolioProject(
        title: isArabic ? 'اسم المشروع الثالث' : 'Third Project Name',
        category: ProjectCategory.advertising,
        description: isArabic
            ? 'وصف مختصر للمشروع التالت.'
            : 'A short description of the third project.',
        images: const [
          'assets/images/projects/project_3/1.jpg',
          'assets/images/projects/project_3/2.jpg',
          'assets/images/projects/project_3/3.jpg',
          'assets/images/projects/project_3/4.jpg',
          'assets/images/projects/project_3/5.jpg',
        ],
        url: '',
      ),
      PortfolioProject(
        title: isArabic ? 'اسم المشروع الرابع' : 'Fourth Project Name',
        category: ProjectCategory.artwork,
        description: isArabic
            ? 'وصف مختصر للمشروع الرابع.'
            : 'A short description of the fourth project.',
        images: const [
          'assets/images/projects/project_4/1.jpg',
          'assets/images/projects/project_4/2.jpg',
          'assets/images/projects/project_4/3.jpg',
          'assets/images/projects/project_4/4.jpg',
          'assets/images/projects/project_4/5.jpg',
        ],
        url: '',
      ),
    ];

/// Standalone "My Works" tab — previously the Projects section embedded
/// inside the "Who am I" screen, now its own top-level page reached from
/// the nav bar. Shows the same Behance-style masonry grid of
/// [PortfolioProject]s (see [kProjects] above to add/edit projects);
/// tapping any cover opens [ProjectDetailScreen] for the full case study.
class MyWorksScreen extends StatelessWidget {
  final bool isMobile;
  const MyWorksScreen({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageController>().isArabic;
    final projects = kProjects(isArabic);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 60, isMobile ? 90 : 110, isMobile ? 20 : 60, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            eyebrow: context.strings.myWorksEyebrow,
            title: context.strings.myWorksTitle,
            subtitle: context.strings.myWorksSubtitle,
            boostArabicSize: false,
          ),
          const SizedBox(height: 44),
          if (projects.isNotEmpty)
            _ProjectsMasonryGrid(projects: projects, isMobile: isMobile)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

/// One project tile in the manual Projects grid — image on top (or a
/// placeholder icon if [PortfolioProject.coverImage] is empty), title,
/// and category, tapping through to [ProjectDetailScreen] for the full
/// Behance-style case study.
/// Lays [projects] out the way a Behance profile's "Projects" tab does:
/// fixed columns (2 on mobile, more as the screen widens), each project a
/// cover image of its own height with the title/category printed as plain
/// text underneath — rather than one uniform row of poster cards with the
/// caption overlaid on the artwork.
///
/// There's no masonry-grid package in this project, so the staggering is
/// done by hand: items are dealt round-robin into N side-by-side Columns,
/// and each cover's aspect ratio is picked deterministically from its
/// index so the columns naturally drift out of sync with each other —
/// exactly the uneven-height look a real masonry layout would produce,
/// without pulling in a new dependency.
class _ProjectsMasonryGrid extends StatelessWidget {
  final List<PortfolioProject> projects;
  final bool isMobile;

  const _ProjectsMasonryGrid({
    required this.projects,
    required this.isMobile,
  });

  // A small repeating cycle of aspect ratios (width / height) so covers
  // read as photographed/designed pieces of varying shape — tall poster,
  // square, and wide landscape — the same mix you'd see scrolling a real
  // Behance grid, instead of every tile being identically cropped.
  static const List<double> _aspectCycle = [0.78, 1.0, 0.62, 0.9];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = isMobile
        ? 2
        : AppBreakpoints.isTablet(width)
            ? 3
            : 4;

    final columnItems = List.generate(columns, (_) => <int>[]);
    for (var i = 0; i < projects.length; i++) {
      columnItems[i % columns].add(i);
    }

    const gap = 16.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < columns; c++) ...[
          if (c != 0) const SizedBox(width: gap),
          Expanded(
            child: Column(
              children: [
                for (final i in columnItems[c]) ...[
                  if (i >= columns) const SizedBox(height: gap),
                  _ProjectCard(
                    project: projects[i],
                    aspectRatio: _aspectCycle[i % _aspectCycle.length],
                    index: i,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One project cover, Behance-card style: the artwork fills a fixed-ratio
/// frame with a category tag pinned over it top-start, and — like hovering
/// a Behance cover before it takes you to the case study — a soft dark
/// veil plus a centered "view" glyph fades in only on hover/press. The
/// title and category live as plain text *underneath* the frame, the way
/// a Behance grid item's title sits below its cover rather than stamped
/// across it. Tapping anywhere on the tile opens [ProjectDetailScreen]
/// with this project's full gallery and write-up.
class _ProjectCard extends StatefulWidget {
  final PortfolioProject project;
  final double aspectRatio;
  // Position in the grid — drives the placeholder's "01" index badge and
  // a small stagger on the entrance animation, so the whole grid doesn't
  // pop in as one flat block.
  final int index;
  const _ProjectCard({
    required this.project,
    required this.aspectRatio,
    required this.index,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isArabic = context.isArabicLanguage;
    final project = widget.project;
    final categoryLabel = project.category.labelFor(isArabic);
    final hasImage = project.coverImage.trim().isNotEmpty;
    final indexLabel = (widget.index + 1).toString().padLeft(2, '0');

    return RevealOnScroll(
      delay: Duration(milliseconds: 60 * (widget.index % 6)),
      offsetY: 26,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: project)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: widget.aspectRatio,
                // Tilts gently toward the pointer and lifts with a violet
                // glow on hover — the same premium, "designed" hover
                // language as the project detail gallery, so the grid and
                // the case-study page read as one consistent product.
                child: Tilt3DCard(
                  maxTiltDegrees: 5,
                  liftOnHover: 5,
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base layer: the artwork itself, or a deliberately
                      // designed violet placeholder plate — a soft light
                      // sweep plus a large faint category glyph — never a
                      // flat, empty-looking rectangle, so the section
                      // reads as finished even before real photos land.
                      if (hasImage)
                        AnimatedScale(
                          scale: _hovering ? 1.06 : 1.0,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          child: Image.asset(
                            project.coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _ProjectPlaceholderArt(
                              category: project.category,
                              hovering: _hovering,
                              colors: colors,
                            ),
                          ),
                        )
                      else
                        _ProjectPlaceholderArt(
                          category: project.category,
                          hovering: _hovering,
                          colors: colors,
                        ),

                      // Category tag, top-start — real content (what kind
                      // of work this is), not decoration.
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.32),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.white.withOpacity(0.18)),
                          ),
                          child: Text(categoryLabel,
                            style: AppFonts.label(text: categoryLabel, size: 11, weight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3),
                          ),
                        ),
                      ),

                      // "01" index badge, top-end — a small catalogue-style
                      // touch that makes the grid read as a numbered
                      // portfolio rather than a loose set of tiles.
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.32),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.white.withOpacity(0.18)),
                          ),
                          child: Text(indexLabel,
                            style: AppFonts.label(text: indexLabel, size: 11, weight: FontWeight.w700, color: Colors.white.withOpacity(0.85), letterSpacing: 0.5),
                          ),
                        ),
                      ),

                      // Hover veil + "view" glyph — mirrors the darken +
                      // centered eye/arrow treatment a Behance cover shows
                      // on hover, right before it opens the project's case
                      // study page.
                      AnimatedOpacity(
                        opacity: _hovering ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.38)),
                          child: const Center(
                            child: Icon(Icons.north_east_rounded, size: 26, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Small accent dash above the title — the same eyebrow
              // language used at the top of the page — so the caption
              // reads as a deliberate label, not just leftover text.
              Container(width: 18, height: 2, color: _hovering ? colors.orchid : colors.orchid.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text(project.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(size: 15.5, weight: FontWeight.w700, color: colors.cream, text: project.title),
              ),
              const SizedBox(height: 2),
              Text(categoryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(size: 13, weight: FontWeight.w500, color: colors.creamDim, text: categoryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "no photo yet" cover: a violet gradient plate with a soft light
/// sweep in one corner and a large, faint glyph for the project's
/// category — designed to look intentional rather than empty, and to
/// brighten slightly on hover along with the rest of the tile.
class _ProjectPlaceholderArt extends StatelessWidget {
  final ProjectCategory category;
  final bool hovering;
  final AppColors colors;
  const _ProjectPlaceholderArt({required this.category, required this.hovering, required this.colors});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final glyphSize = constraints.maxWidth * 0.56;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          decoration: BoxDecoration(gradient: colors.violetGradientWide),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Soft light sweep, top-start — adds depth so the plate
              // doesn't read as one flat color.
              Positioned(
                top: -constraints.maxWidth * 0.35,
                left: -constraints.maxWidth * 0.25,
                child: Container(
                  width: constraints.maxWidth * 0.9,
                  height: constraints.maxWidth * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white.withOpacity(hovering ? 0.16 : 0.10), Colors.transparent],
                    ),
                  ),
                ),
              ),
              // Large faint category glyph, bottom-end — hints at what
              // kind of work this is even with no photo in place yet.
              Positioned(
                right: -glyphSize * 0.16,
                bottom: -glyphSize * 0.16,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    _iconForCategory(category),
                    size: glyphSize,
                    color: Colors.white.withOpacity(hovering ? 0.18 : 0.13),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
