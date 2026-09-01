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
/// leave empty violet slots.
class PortfolioProject {
  final String title;
  final ProjectCategory category;
  final String description;
  // The longer case-study write-up shown on the project's own detail
  // page. Falls back to [description] when left blank, so a project
  // with only a short blurb still shows something on its detail page.
  final String fullDescription;
  // Every photo for this project, in display order. images.first is
  // used as the grid cover; the detail page shows all of them, one
  // full-width image after another, like scrolling a Behance case
  // study. Leave empty and both the grid card and the detail page show
  // a plain violet gradient plate instead.
  final List<String> images;
  // Optional external link (e.g. the real Behance project page) —
  // shown as a "View on Behance" button on the detail page. Leave empty
  // to hide that button.
  final String url;

  const PortfolioProject({
    required this.title,
    required this.category,
    this.description = '',
    this.fullDescription = '',
    this.images = const [],
    this.url = '',
  });

  String get coverImage => images.isNotEmpty ? images.first : '';
  String descriptionFor() => fullDescription.trim().isNotEmpty ? fullDescription : description;
}
