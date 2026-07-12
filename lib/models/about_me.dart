/// The owner's bio/portfolio profile shown on the "Who am I" page — filled
/// in from the admin dashboard so it can be sent as part of a proposal when
/// pitching for other design work. Singleton row (`id = 1` in `about_me`).
///
/// `headline`/`bio`/`skills` are the English (original) copy. The `*Ar`
/// fields are optional Arabic translations the admin can add later — if
/// left blank, [headlineFor]/[bioFor]/[skillsFor] fall back to the English
/// version so nothing breaks for stores that never fill them in.
/// fullName/email/phone/whatsapp/location/urls stay single-value on
/// purpose — a name, phone number or link isn't something you "translate".
/// instagramUrl/facebookUrl/tiktokUrl/linkedinUrl are optional social
/// links shown as extra buttons in "Get in touch" — leave any of them
/// blank and that button just doesn't show up.
class AboutMe {
  final String fullName;
  final String headline;
  final String headlineAr;
  final String bio;
  final String bioAr;
  final List<String> skills;
  final List<String> skillsAr;
  final String email;
  final String phone;
  final String whatsapp;
  final String location;
  final String portfolioUrl;
  final String cvUrl;
  final String instagramUrl;
  final String facebookUrl;
  final String tiktokUrl;
  final String linkedinUrl;

  const AboutMe({
    this.fullName = '',
    this.headline = '',
    this.headlineAr = '',
    this.bio = '',
    this.bioAr = '',
    this.skills = const [],
    this.skillsAr = const [],
    this.email = '',
    this.phone = '',
    this.whatsapp = '',
    this.location = '',
    this.portfolioUrl = '',
    this.cvUrl = '',
    this.instagramUrl = '',
    this.facebookUrl = '',
    this.tiktokUrl = '',
    this.linkedinUrl = '',
  });

  bool get isEmpty =>
      fullName.isEmpty && headline.isEmpty && bio.isEmpty && skills.isEmpty;

  /// The headline/bio/skills to show for the given language — Arabic
  /// translation if the admin added one, otherwise the English original.
  String headlineFor(bool isArabic) => isArabic && headlineAr.isNotEmpty ? headlineAr : headline;
  String bioFor(bool isArabic) => isArabic && bioAr.isNotEmpty ? bioAr : bio;
  List<String> skillsFor(bool isArabic) => isArabic && skillsAr.isNotEmpty ? skillsAr : skills;

  factory AboutMe.fromRow(Map<String, dynamic> row) => AboutMe(
        fullName: (row['full_name'] as String?) ?? '',
        headline: (row['headline'] as String?) ?? '',
        headlineAr: (row['headline_ar'] as String?) ?? '',
        bio: (row['bio'] as String?) ?? '',
        bioAr: (row['bio_ar'] as String?) ?? '',
        skills: ((row['skills'] as List?) ?? const [])
            .map((s) => s.toString())
            .where((s) => s.isNotEmpty)
            .toList(),
        skillsAr: ((row['skills_ar'] as List?) ?? const [])
            .map((s) => s.toString())
            .where((s) => s.isNotEmpty)
            .toList(),
        email: (row['email'] as String?) ?? '',
        phone: (row['phone'] as String?) ?? '',
        whatsapp: (row['whatsapp'] as String?) ?? '',
        location: (row['location'] as String?) ?? '',
        portfolioUrl: (row['portfolio_url'] as String?) ?? '',
        cvUrl: (row['cv_url'] as String?) ?? '',
        instagramUrl: (row['instagram_url'] as String?) ?? '',
        facebookUrl: (row['facebook_url'] as String?) ?? '',
        tiktokUrl: (row['tiktok_url'] as String?) ?? '',
        linkedinUrl: (row['linkedin_url'] as String?) ?? '',
      );

  Map<String, dynamic> toRow() => {
        'id': 1,
        'full_name': fullName,
        'headline': headline,
        'headline_ar': headlineAr,
        'bio': bio,
        'bio_ar': bioAr,
        'skills': skills,
        'skills_ar': skillsAr,
        'email': email,
        'phone': phone,
        'whatsapp': whatsapp,
        'location': location,
        'portfolio_url': portfolioUrl,
        'cv_url': cvUrl,
        'instagram_url': instagramUrl,
        'facebook_url': facebookUrl,
        'tiktok_url': tiktokUrl,
        'linkedin_url': linkedinUrl,
      };
}

/// A single photo in the "Who am I" page's top slideshow. The app figures
/// out each photo's real proportions on its own (from the image itself)
/// so it always displays at the right aspect ratio — nothing to type in.
class AboutSlide {
  final String id;
  final String imageUrl;
  final int sortOrder;

  const AboutSlide({
    required this.id,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  factory AboutSlide.fromRow(Map<String, dynamic> row) => AboutSlide(
        id: row['id'] as String,
        imageUrl: (row['image_url'] as String?) ?? '',
        sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      );
}
