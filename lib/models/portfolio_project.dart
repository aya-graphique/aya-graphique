/// The four kinds of work shown on the "Who am I" Projects grid. Kept as
/// a closed set (instead of free-text per project) so every project's
/// category tag is phrased consistently in both languages — see
/// [ProjectCategoryLabel.labelFor].
enum ProjectCategory { logoIdentity, packaging, advertising, artwork }

extension ProjectCategoryLabel on ProjectCategory {
  String labelFor(bool isArabic) {
    switch (this) {
      case ProjectCategory.logoIdentity:
        return isArabic ? 'شعار - هوية بصرية' : 'Logo & Visual Identity';
      case ProjectCategory.packaging:
        return isArabic ? 'مطبوعات وتغليفات' : 'Packaging';
      case ProjectCategory.advertising:
        return isArabic ? 'إعلانات' : 'Advertising';
      case ProjectCategory.artwork:
        return isArabic ? 'رسم' : 'Art Work';
    }
  }
}

/// One portfolio project — plain static data (not admin-editable, same
/// idea as kExperience/kEducation on the "Who am I" page): to add a new
/// project just add another [PortfolioProject] entry to `kProjects` in
/// who_am_i_screen.dart and drop its images into assets/images/.
///
/// Tapping a project in the grid opens [ProjectDetailScreen] — a
/// case-study page that leads with the title/description block, then
/// shows this project's photos in a distinctive 5-photo bento gallery
/// underneath. [fullDescription] is the longer write-up ([description]
/// stays short, for the grid caption only — the grid card itself doesn't
/// currently show it, but it's kept for a future compact caption/tooltip
/// use). Supply exactly 5 entries in [images] for the gallery to lay out
/// as intended (1 featured + 4 supporting shots) — fewer still work but
/// leave empty violet slots. [coverOverride] is optional: set it when a
/// 6th "packshot" photo should stand alone as the grid cover, kept out
/// of the 5-photo gallery entirely (otherwise the grid cover just falls
/// back to images.first, same as before).
class PortfolioProject {
  // Stable identifier used in the URL (e.g. '/my-works/project/:id') so
  // the project detail/lightbox routes can rebuild themselves straight
  // from the URL — no `extra` needed. Must stay the same across
  // rebuilds/hot-reloads for a given project (see kProjects), since it's
  // what makes browser/phone back-button navigation and page refresh
  // land on the right project instead of bouncing to '/my-works'.
  final String id;
  final String title;
  final ProjectCategory category;
  final String description;
  // The longer case-study write-up shown on the project's own detail
  // page. Falls back to [description] when left blank, so a project
  // with only a short blurb still shows something on its detail page.
  final String fullDescription;
  // Every photo for this project, in display order. Feeds the 5-photo
  // bento gallery on the detail page — and, when [coverOverride] is
  // empty, also doubles as the grid cover (images.first). Leave empty
  // and both the grid card and the detail page show a plain violet
  // gradient plate instead.
  final List<String> images;
  // Optional standalone cover photo for the grid card, kept separate
  // from [images] so it never takes up one of the 5 gallery slots (e.g.
  // a packaging shot used as the "face" of the project). Leave blank to
  // fall back to images.first, same as before.
  final String coverOverride;
  // Optional external link (e.g. the real Behance project page) —
  // shown as a "View on Behance" button on the detail page. Leave empty
  // to hide that button.
  final String url;

  const PortfolioProject({
    required this.id,
    required this.title,
    required this.category,
    this.description = '',
    this.fullDescription = '',
    this.images = const [],
    this.coverOverride = '',
    this.url = '',
  });

  String get coverImage =>
      coverOverride.trim().isNotEmpty ? coverOverride : (images.isNotEmpty ? images.first : '');
  String descriptionFor() => fullDescription.trim().isNotEmpty ? fullDescription : description;
}
