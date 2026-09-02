import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../models/about_me.dart';
import '../providers/language_controller.dart';
import '../services/about_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/shimmer_text.dart';

// ---------------------------------------------------------------------
// ✏️ Hardcoded "About me" copy — no longer pulled from the about_me
// table in Supabase. Edit the strings directly here (kBioIntro for the
// opening paragraph, kBioSections for the headed paragraphs below it) —
// same pattern as kExperience/kEducation further down (kProjects now
// lives in its own my_works_screen.dart, since Projects moved to the
// standalone "My Works" tab).
// ---------------------------------------------------------------------
String kBioIntro(bool isArabic) => isArabic
    ? 'رسامة ومصممة متخصصة في تصميم الإعلانات التجارية، حاصلة على درجة '
        'البكالوريوس في الفنون التطبيقية، قسم الإعلان. وُلدت عام ١٩٩٧ '
        'ميلادي وبدأت دراسة مجال التصميم والإعلان عام 2015، وبدأت العمل '
        'بشكل فعلي في المجال عام 2017.\n'
        'خلال مسيرتي المهنية، تنوعت خبراتي بين عدة مجالات وقطاعات، من '
        'بينها شركات التصميم المعماري، المطاعم، الحلويات، المستشفيات، '
        'الأزياء والإكسسوارات والتعليم؛ وهو ما منحني رؤية متنوعة لطبيعة '
        'العلامات التجارية واحتياجاتها البصرية وكيفية ظهورها لدى الجمهور '
        'المستهدف.'
    : "I'm an illustrator and designer specializing in commercial "
        'advertising. I hold a Bachelor of Applied Arts degree in '
        'Advertising. Born in 1997, I began studying design and '
        'advertising in 2015 and started working in the field in 2017.\n'
        'Throughout my career, my experience has spanned several sectors, '
        'including architectural design firms, restaurants, confectionery, '
        'hospitals, fashion and accessories, and education. This diverse '
        'experience has given me a broad perspective on the nature of '
        'brands, their visual needs, and how they present themselves to '
        'their target audience.';

/// One headed paragraph in the "About me" section, shown under the
/// intro (see [kBioIntro]) — e.g. "My vision:" / "My goal:".
class _BioSection {
  final String heading;
  final String body;
  const _BioSection({required this.heading, required this.body});
}

List<_BioSection> kBioSections(bool isArabic) => isArabic
    ? const [
        _BioSection(
          heading: 'من شغف الطفولة إلى صناعة الإعلان:',
          body: 'بدأت رحلتي، مثل كثير من الأطفال، بشغف بسيط تجاه الرسم؛ '
              'أقلام تتحرك بعفوية على الجدران، دون أفكار محدودة أو قواعد '
              'أو قيود؛ ومع الوقت، قادني هذا الشغف إلى كلية الفنون '
              'التطبيقية، حيث اكتشفت عالمًا مختلفًا من الفن، وتعلمت أن '
              'الرسم يمكن أن يتحول من مجرد تعبير عفوي إلى فكرة، ومفهوم، '
              'ورسالة، وتصميم نستهدف به شريحة كاملة من الجمهور لنقدم لهم '
              'احتياجاتهم بفكرة واضحة ومختصرة.',
        ),
        _BioSection(
          heading: 'رؤيتي:',
          body: 'ماذا لو جمعنا بين شغف طفولة لم يعرف القيود، وخبرة مصمم '
              'تعلم كيف يحوّل الأفكار إلى رسائل بصرية مصممة خصيصا لوظيفة '
              'تحقق الهدف؟',
        ),
        _BioSection(
          heading: 'هدفي:',
          body: 'الجمع بين الفكرة، الفن، والاستراتيجية لصناعة تصميم '
              'إعلاني لا يكتفي بأن يكون جميلًا، بل يُرى، ويُفهم، ويترك '
              'أثرًا ويؤدي وظيفته للعلامة التجارية ويزيد من انتشارها.',
        ),
      ]
    : const [
        _BioSection(
          heading: 'From childhood passion to advertising:',
          body: 'Like many children, my journey began with a simple '
              'passion for drawing; pens moving spontaneously across '
              'walls, without limited ideas, rules, or restrictions. '
              'Over time, this passion led me to the Faculty of Applied '
              'Arts, where I discovered a different world of art. I '
              'learned that drawing can transform from a spontaneous '
              'expression into an idea, a concept, a message, and a '
              'design that targets an entire segment of the audience, '
              'addressing their needs with a clear and concise message.',
        ),
        _BioSection(
          heading: 'My vision:',
          body: 'What if we combined the boundless passion of childhood '
              'with the expertise of a designer who has learned how to '
              'transform ideas into visually compelling messages '
              'tailored to a specific function and objective?',
        ),
        _BioSection(
          heading: 'My goal:',
          body: 'To combine concept, artistry, and strategy to create '
              'advertising designs that are not only beautiful but also '
              'visually appealing, understandable, impactful, and '
              'effective for the brand, thereby increasing its reach.',
        ),
      ];

List<_TimelineEntry> kExperience(bool isArabic) => [
      _TimelineEntry(
        title: isArabic ? 'مصممة جرافيك أول' : 'Senior Graphic Designer',
        subtitle: isArabic ? "Aya's Graphique — عمل حر" : "Aya's Graphique — Freelance",
        period: isArabic ? '2022 — حتى الآن' : '2022 — Present',
        description: isArabic
            ? 'قيادة مشاريع الهوية البصرية والتغليف والطباعة من الفكرة '
                'وحتى الملفات الجاهزة للإنتاج.'
            : 'Leading brand identity, packaging and print design projects '
                'end to end, from concept to production-ready files.',
        highlights: isArabic
            ? const [
                'تصميم أكثر من 30 هوية بصرية كاملة لعملاء محليين وعرب',
                'إدارة علاقة العميل من أول جلسة الاستماع وحتى تسليم الملفات',
                'إشراف على مطبوعات المتجر: الدفاتر والتقويمات والمنتجات الورقية',
              ]
            : const [
                'Delivered 30+ full brand identities for local and regional clients',
                'Owned the client relationship end to end, from discovery to handoff',
                "Art-directed the store's own print line — notebooks, calendars, stationery",
              ],
      ),
      _TimelineEntry(
        title: isArabic ? 'مصممة جرافيك' : 'Graphic Designer',
        subtitle: isArabic ? 'اسم الاستوديو' : 'Studio Name',
        period: '2019 — 2022',
        description: isArabic
            ? 'تصميم المواد التسويقية والمحتوى الاجتماعي وتخطيطات الطباعة '
                'لمجموعة من العملاء المحليين.'
            : 'Designed marketing collateral, social content and '
                'print layouts for a range of local clients.',
        highlights: isArabic
            ? const [
                'تصميم محتوى سوشيال ميديا شهري لأكثر من 15 عميل',
                'تجهيز ملفات طباعة جاهزة للمطابع مع ضبط الألوان والقياسات',
              ]
            : const [
                'Produced monthly social content for 15+ client accounts',
                'Prepared print-ready files with accurate color and bleed setup',
              ],
      ),
      _TimelineEntry(
        title: isArabic ? 'متدربة تصميم جرافيك' : 'Graphic Design Intern',
        subtitle: isArabic ? 'وكالة إعلانية' : 'Advertising Agency',
        period: '2018 — 2019',
        description: isArabic
            ? 'أول خطوة احترافية — دعم فريق التصميم في الحملات الإعلانية '
                'وتنفيذ التعديلات السريعة تحت ضغط المواعيد.'
            : 'First professional step — supported the design team on ad '
                'campaigns and turned around quick revisions under deadline.',
        highlights: isArabic
            ? const ['المشاركة في تنفيذ حملتين إعلانيتين كاملتين']
            : const ['Contributed to two full ad campaign rollouts'],
      ),
    ];

List<_TimelineEntry> kEducation(bool isArabic) => [
      _TimelineEntry(
        title: isArabic ? 'بكالوريوس التصميم الجرافيكي' : 'B.A. in Graphic Design',
        subtitle: isArabic
            ? 'كلية الفنون التطبيقية، جامعة حلوان'
            : 'Faculty of Applied Arts, Helwan University',
        period: '2015 — 2019',
        description: isArabic
            ? 'تخرجت بمشروع تخرج في تصميم الهوية البصرية، بتقدير امتياز.'
            : 'Graduated with a brand-identity thesis project, with honors.',
      ),
      _TimelineEntry(
        title: isArabic ? 'شهادة احترافية في الـ UI/UX' : 'UI/UX Design Certificate',
        subtitle: isArabic ? 'منصة تدريب أونلاين' : 'Online Training Platform',
        period: '2020',
        description: '',
      ),
    ];

/// One certificate shown as a flip card under "Who am I" — [title] /
/// [issuer] / [date] print on the front face; tapping the card flips it
/// over (see [_CertificateFlipCard]) to reveal [content], the write-up
/// of what the certificate actually covers or was awarded for.
class _Certificate {
  final String title;
  final String issuer;
  final String date;
  final String content;
  // Optional real certificate image (asset path) — when set, the front
  // of the card shows this image full-bleed instead of the plain
  // icon/title mock-up. The back (flip side) still shows the write-up
  // in [content].
  final String? imageAsset;
  const _Certificate({
    required this.title,
    required this.issuer,
    required this.date,
    required this.content,
    this.imageAsset,
  });
}

// ---------------------------------------------------------------------
// ✏️ عدّلي هنا يدويًا: كل شهادة جديدة ضيفيها كـ _Certificate في الليستة
// دي. title/issuer/date بيظهروا في وش الكارت؛ content هو اللي بيظهر
// لما اليوزر يدوس على الكارت ويعمل فليب — اكتبيه باختصار (2-3 جمل).
// ---------------------------------------------------------------------
List<_Certificate> kCertificates(bool isArabic) => isArabic
    ? const [
        _Certificate(
          title: 'دورة التصميم الجرافيكي الاحترافي',
          issuer: 'Creative Ideas',
          date: '01 / 06 / 2024',
          content: 'أتمت الدورة الاحترافية في التصميم الجرافيكي بنجاح، بمهارات '
              'قوية في مبادئ التصميم، بناء العلامة التجارية، ونظرية الألوان.',
          imageAsset: 'assets/images/certificates/certificate_graphic_design.png',
        ),
        _Certificate(
          title: 'اسم الشهادة الأولى',
          issuer: 'الجهة المانحة',
          date: '2023',
          content: 'وصف مختصر لمحتوى الشهادة: إيه اللي اتغطى فيها، وإيه '
              'المهارات أو الأدوات اللي اتعلمتيها من خلالها.',
        ),
        _Certificate(
          title: 'اسم الشهادة الثانية',
          issuer: 'الجهة المانحة',
          date: '2022',
          content: 'وصف مختصر لمحتوى الشهادة التانية.',
        ),
        _Certificate(
          title: 'اسم الشهادة الثالثة',
          issuer: 'الجهة المانحة',
          date: '2021',
          content: 'وصف مختصر لمحتوى الشهادة التالتة.',
        ),
        _Certificate(
          title: 'اسم الشهادة الرابعة',
          issuer: 'الجهة المانحة',
          date: '2020',
          content: 'وصف مختصر لمحتوى الشهادة الرابعة.',
        ),
      ]
    : const [
        _Certificate(
          title: 'Professional Graphic Design Course',
          issuer: 'Creative Ideas',
          date: '01 / 06 / 2024',
          content: 'Successfully completed the Professional Graphic Design '
              'Course, with strong skills in design principles, branding, '
              'and color theory.',
          imageAsset: 'assets/images/certificates/certificate_graphic_design.png',
        ),
        _Certificate(
          title: 'First Certificate Name',
          issuer: 'Issuing Organization',
          date: '2023',
          content: 'A short write-up of what the certificate covers — the '
              'skills or tools it represents.',
        ),
        _Certificate(
          title: 'Second Certificate Name',
          issuer: 'Issuing Organization',
          date: '2022',
          content: 'A short write-up of the second certificate.',
        ),
        _Certificate(
          title: 'Third Certificate Name',
          issuer: 'Issuing Organization',
          date: '2021',
          content: 'A short write-up of the third certificate.',
        ),
        _Certificate(
          title: 'Fourth Certificate Name',
          issuer: 'Issuing Organization',
          date: '2020',
          content: 'A short write-up of the fourth certificate.',
        ),
      ];

class _TimelineEntry {
  final String title;
  final String subtitle;
  final String period;
  final String description;
  // A few bullet-point specifics under the description — optional, empty
  // by default so short entries (like the education ones above) don't
  // need to supply any.
  final List<String> highlights;
  const _TimelineEntry({
    required this.title,
    required this.subtitle,
    required this.period,
    this.description = '',
    this.highlights = const [],
  });
}

/// A quick-read row of career stats under the headline — plain static
/// numbers (not admin-editable, same as [kExperience]/[kEducation] above)
/// meant to be tweaked directly in code as the real figures change.
class _StatItem {
  final String value;
  final String label;
  const _StatItem(this.value, this.label);
}

List<_StatItem> kStats(bool isArabic) => [
      _StatItem('8+', isArabic ? 'سنوات خبرة' : 'Years experience'),
      _StatItem('30+', isArabic ? 'مشروع هوية بصرية' : 'Brand projects'),
      _StatItem('98%', isArabic ? 'رضا العملاء' : 'Client satisfaction'),
      _StatItem('1000+', isArabic ? 'عدد المُتدربين' : 'Number of clients trained'),
    ];

/// Capitalizes the first letter of each word, leaving the rest of the word
/// untouched (so acronyms like "UI/UX" survive) and Arabic text untouched
/// entirely. Applied to the name and skill tags, which are admin-typed
/// free text — one admin entry like "packing" next to "Illustration" reads
/// as an inconsistency, so this guarantees a uniform look regardless of
/// how the text was typed in the dashboard.
String _capitalizeWords(String input) {
  if (input.trim().isEmpty || AppFonts.isArabic(input)) return input;
  return input
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class WhoAmIScreen extends StatefulWidget {
  final bool isMobile;
  final ScrollController? scrollController;

  /// When true, renders just the slideshow + profile content with no outer
  /// scroll view, no scroll controller, and no top nav-bar offset — for
  /// dropping this section straight into another scrollable page. Nothing
  /// currently does that (Home used to, but "Who am I" is a standalone
  /// tab now); kept around in case that's ever useful again. When false
  /// (today's only real case, the standalone "About" tab), it wraps
  /// itself in its own SingleChildScrollView using [scrollController].
  final bool embedded;

  const WhoAmIScreen({
    super.key,
    required this.isMobile,
    this.scrollController,
    this.embedded = false,
  });

  @override
  State<WhoAmIScreen> createState() => _WhoAmIScreenState();
}

class _WhoAmIScreenState extends State<WhoAmIScreen> {
  late Future<AboutMe> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = AboutRepository.fetchProfile();
  }

  Future<void> _openUrl(String raw) async {
    if (raw.trim().isEmpty) return;
    var value = raw.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsapp(String number) async {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$digits');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openEmail(String email) async {
    if (email.trim().isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email.trim());
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AboutMe>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: context.colors.orchid));
        }
        final profile = snapshot.data ?? const AboutMe();

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              // Same top offset as every other tab (home, search, services,
              // cart) so switching tabs doesn't cause the page content to
              // jump up/down under the fixed nav bar. Skipped when embedded
              // — the page embedding this section (HomeScreen) already
              // handles its own single top offset up at the sliders.
              if (!widget.embedded) SizedBox(height: widget.isMobile ? 90 : 110),
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 24 : 72),
                child: profile.isEmpty
                    ? Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: _EmptyProfileNotice(isMobile: widget.isMobile),
                        ),
                      )
                    : _Profile(
                        profile: profile,
                        isMobile: widget.isMobile,
                        onOpenUrl: _openUrl,
                        onOpenWhatsapp: _openWhatsapp,
                        onOpenEmail: _openEmail,
                      ),
              ),
              const SizedBox(height: 60),
            ],
        );

        if (widget.embedded) return content;

        return SingleChildScrollView(
          controller: widget.scrollController,
          child: content,
        );
      },
    );
  }
}

class _Profile extends StatelessWidget {
  final AboutMe profile;
  final bool isMobile;
  final ValueChanged<String> onOpenUrl;
  final ValueChanged<String> onOpenWhatsapp;
  final ValueChanged<String> onOpenEmail;

  const _Profile({
    required this.profile,
    required this.isMobile,
    required this.onOpenUrl,
    required this.onOpenWhatsapp,
    required this.onOpenEmail,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabicLanguage;
    final bio = kBioIntro(isArabic);
    final bioSections = kBioSections(isArabic);
    final certificates = kCertificates(isArabic);
    final experience = kExperience(isArabic);
    final education = kEducation(isArabic);
    final hasContact = profile.whatsapp.isNotEmpty ||
        profile.email.isNotEmpty ||
        profile.phone.isNotEmpty ||
        profile.portfolioUrl.isNotEmpty ||
        profile.cvUrl.isNotEmpty ||
        profile.instagramUrl.isNotEmpty ||
        profile.facebookUrl.isNotEmpty ||
        profile.tiktokUrl.isNotEmpty ||
        profile.linkedinUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header block — photo through the stats row — capped at a
        // readable width and centered on the screen regardless of
        // language. Everything below the divider (bio, skills, experience,
        // education, contact) is NOT capped — it spans the full available
        // width so it actually reaches the edge (flush right in Arabic,
        // flush left in English) instead of just the edge of a narrow
        // centered column.
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Portrait photo — same brand photo used on the splash screen,
            // in the same violet-gradient ring treatment as the audience/
            // service circles elsewhere. Falls back to the lettered initials
            // badge if the asset is missing.
            if (profile.fullNameFor(isArabic).isNotEmpty) ...[
              _PortraitAvatar(name: profile.fullNameFor(isArabic)),
              const SizedBox(height: 22),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 28, height: 2, color: context.colors.orchid),
                const SizedBox(width: 10),
                Text(context.strings.whoAmIEyebrow, style: AppFonts.label(text: context.strings.whoAmIEyebrow, color: context.colors.orchid, size: 14, weight: FontWeight.w700)),
                const SizedBox(width: 10),
                Container(width: 28, height: 2, color: context.colors.orchid),
              ],
            ).animate().fadeIn(duration: 500.ms),
            // 16px gap — matches the eyebrow-to-title spacing in SectionHeading,
            // which is what the Services page (and every other tab) uses, so
            // the two pages open with the same visual rhythm.
            const SizedBox(height: 16),
            if (profile.fullNameFor(isArabic).isNotEmpty)
              ShimmerHeadline(
                text: _capitalizeWords(profile.fullNameFor(isArabic)),
                textAlign: TextAlign.center,
                style: AppFonts.display(
                  color: context.colors.cream,
                  size: isMobile ? 40 : 64,
                  weight: FontWeight.w800,
                  height: 1.05,
                  text: profile.fullNameFor(isArabic),
                ),
              ),
            // Fixed brand slogan — always shown under the name, independent
            // of the admin-editable headline field below. Small tracked caps
            // read as a refined tagline rather than competing with the big
            // gradient name above it.
            const SizedBox(height: 10),
            // Text('SIMPLICITY MAKES IT ART',
            //   textAlign: TextAlign.center,
            //   style: AppFonts.label(text: 'SIMPLICITY MAKES IT ART', 
            //     color: context.colors.creamDim,
            //     size: isMobile ? 12.5 : 14,
            //     letterSpacing: 3,
            //   ).copyWith(fontWeight: FontWeight.w700),
            // ).animate().fadeIn(duration: 500.ms, delay: 80.ms),
            if (profile.headlineFor(isArabic).isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                profile.headlineFor(isArabic),
                textAlign: TextAlign.center,
                style: AppFonts.label(
                  color: context.colors.violetLight,
                  size: 16.5,
                  weight: FontWeight.w700,
                  letterSpacing: 1.4,
                  text: profile.headlineFor(isArabic),
                ),
              ),
            ],
            // Quick-read career stats — static figures (see kStats), kept
            // separate from the admin-editable fields above so they're easy
            // to tweak in code as the real numbers change.
            const SizedBox(height: 28),
            Center(child: _StatsRow(stats: kStats(isArabic))),
          ],
            ),
          ),
        ),
        // Everything from here down (divider onward) reverts to a plain
        // start-aligned column — flush right in Arabic, flush left in
        // English — instead of the centered header above it.
        Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 34),
          Center(child: _SectionDivider()),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: Text(
              bio,
              textAlign: TextAlign.start,
              style: AppFonts.body(
                color: context.colors.creamDim,
                size: isMobile ? 19 : 21,
                weight: FontWeight.w500,
                height: 1.55,
                text: bio,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          // Headed paragraphs (see kBioSections) — "From childhood
          // passion...", "My vision:", "My goal:" — left/right-aligned
          // with the rest of the page (not centered like the intro
          // above it), each heading in the same accent-violet weight
          // used for section headers elsewhere on this page.
          if (bioSections.isNotEmpty) ...[
            const SizedBox(height: 30),
            for (var i = 0; i < bioSections.length; i++) ...[
              if (i != 0) const SizedBox(height: 22),
              Text(
                bioSections[i].heading,
                style: AppFonts.body(
                  color: context.colors.violetLight,
                  size: isMobile ? 17 : 18.5,
                  weight: FontWeight.w800,
                  height: 1.4,
                  text: bioSections[i].heading,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bioSections[i].body,
                style: AppFonts.body(
                  color: context.colors.creamDim,
                  size: isMobile ? 16.5 : 18,
                  weight: FontWeight.w500,
                  height: 1.55,
                  text: bioSections[i].body,
                ),
              ),
            ],
          ],
        ],
        if (certificates.isNotEmpty) ...[
          const SizedBox(height: 40),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _MiniSectionHeader(label: context.strings.certificatesLabel),
                const SizedBox(height: 20),
                _CertificatesCarousel(certificates: certificates, isMobile: isMobile),
              ],
            ),
          ),
        ],
        if (experience.isNotEmpty) ...[
          const SizedBox(height: 32),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MiniSectionHeader(label: context.strings.experienceLabel),
                const SizedBox(height: 22),
                for (var i = 0; i < experience.length; i++) ...[
                  if (i != 0) const SizedBox(height: 14),
                  _TimelineCard(entry: experience[i]),
                ],
              ],
            ),
          ),
        ],
        if (education.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MiniSectionHeader(label: context.strings.educationLabel),
                const SizedBox(height: 22),
                for (var i = 0; i < education.length; i++) ...[
                  if (i != 0) const SizedBox(height: 14),
                  _TimelineCard(entry: education[i]),
                ],
              ],
            ),
          ),
        ],
        if (hasContact || profile.location.isNotEmpty) ...[
          const SizedBox(height: 32),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _MiniSectionHeader(label: context.strings.getInTouchLabel),
                const SizedBox(height: 22),
                if (hasContact)
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (profile.whatsapp.isNotEmpty)
                          _ContactButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: context.strings.whatsappLabel,
                            filled: true,
                            onTap: () => onOpenWhatsapp(profile.whatsapp),
                          ),
                        if (profile.email.isNotEmpty)
                          _ContactButton(
                            icon: Icons.mail_outline_rounded,
                            label: context.strings.emailLabel,
                            onTap: () => onOpenEmail(profile.email),
                          ),
                        if (profile.phone.isNotEmpty)
                          _ContactButton(
                            icon: Icons.call_outlined,
                            label: profile.phone,
                            onTap: () {},
                          ),
                        if (profile.portfolioUrl.isNotEmpty)
                          _ContactButton(
                            icon: Icons.link_rounded,
                            label: context.strings.portfolioLabel,
                            onTap: () => onOpenUrl(profile.portfolioUrl),
                          ),
                        if (profile.cvUrl.isNotEmpty)
                          _ContactButton(
                            icon: Icons.description_outlined,
                            label: context.strings.cvLabel,
                            onTap: () => onOpenUrl(profile.cvUrl),
                          ),
                        if (profile.instagramUrl.isNotEmpty)
                          _ContactButton(
                            icon: Icons.camera_alt_outlined,
                            label: context.strings.instagramLabel,
                            onTap: () => onOpenUrl(profile.instagramUrl),
                          ),
                        if (profile.facebookUrl.isNotEmpty)
                          _ContactButton(
                            icon: Icons.facebook_outlined,
                            label: context.strings.facebookLabel,
                            onTap: () => onOpenUrl(profile.facebookUrl),
                          ),
                        if (profile.tiktokUrl.isNotEmpty)
                          _ContactButton(
                            icon: Icons.music_note_outlined,
                            label: context.strings.tiktokLabel,
                            onTap: () => onOpenUrl(profile.tiktokUrl),
                          ),
                        if (profile.linkedinUrl.isNotEmpty)
                          _ContactButton(
                            icon: Icons.business_center_outlined,
                            label: context.strings.linkedinLabel,
                            onTap: () => onOpenUrl(profile.linkedinUrl),
                          ),
                      ],
                    ),
                  ),
                if (profile.location.isNotEmpty) ...[
                  if (hasContact) const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(Icons.place_outlined, size: 16, color: context.colors.creamDim),
                        const SizedBox(width: 6),
                        Text(profile.location,
                            style: AppFonts.body(size: 17, weight: FontWeight.w500, color: context.colors.creamDim, text: profile.location)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        ],
        ),
      ],
    );
  }
}

/// Portrait badge used at the top of the profile — the same brand photo
/// (assets/images/aya_portrait.png) shown on the splash screen, inside the
/// same violet-gradient ring treatment as the audience/service circles
/// elsewhere on the storefront. Falls back to a lettered initials badge if
/// the photo asset is missing.
class _PortraitAvatar extends StatelessWidget {
  final String name;
  const _PortraitAvatar({required this.name});

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const outer = 190.0;
    const photo = 184.0;
    return Container(
      width: outer,
      height: outer,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: colors.violetGradient),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surface),
        child: Center(
          child: ClipOval(
            child: Image.asset(
              'assets/images/aya_portrait.png',
              width: photo,
              height: photo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Text(_initials,
                style: AppFonts.display(text: _initials, color: colors.orchid, size: 60, weight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin centered gradient rule — same treatment used under the eyebrow
/// pills elsewhere (Services/Illustration Art/Available For) — dropped in
/// wherever this page needs a plain visual break between blocks.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, context.colors.border(0.14), Colors.transparent],
        ),
      ),
    );
  }
}

/// A bordered, softly-tinted container wrapped around each labelled block
/// (Skills / Experience / Education / Get in touch) so the page reads as a
/// set of distinct sections instead of one long run-on column of text.
class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    // Content now flows directly on the page — no boxed container.
    return SizedBox(width: double.infinity, child: child);
  }
}

/// The small bar-plus-label header used at the top of each [_SectionCard]
/// (and, before this redesign, inline in the timeline) — pulled out once
/// so every section title looks identical.
class _MiniSectionHeader extends StatelessWidget {
  final String label;
  const _MiniSectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 22, height: 2, color: context.colors.orchid),
        const SizedBox(width: 10),
        Text(label, style: AppFonts.label(text: label, color: context.colors.orchid, size: 16, weight: FontWeight.w700)),
      ],
    );
  }
}

/// A row of quick-read career numbers (see [kStats]) — separated by thin
/// vertical dividers on desktop, wrapping onto its own line per item on
/// narrow phones instead of ever squeezing three columns into one row.
class _StatsRow extends StatelessWidget {
  final List<_StatItem> stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(stats[i].value,
                    style: AppFonts.display(text: stats[i].value, color: colors.cream, size: 25, weight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(stats[i].label,
                  style: AppFonts.label(text: stats[i].label, color: colors.creamDim, size: 11.5, weight: FontWeight.w700, letterSpacing: 0.6),
                ),
              ],
            ),
            if (i != stats.length - 1) ...[
              const SizedBox(width: 28),
              Container(width: 1, height: 34, color: colors.border(0.14)),
            ],
          ],
        ],
      ),
    );
  }
}

/// One experience/education entry, styled as a plain left-aligned card
/// (title + a period pill on the trailing side, subtitle, description, and
/// optional bullet highlights) — reads like a real CV line item, instead
/// of the old centered dot-and-line timeline.
class _TimelineCard extends StatelessWidget {
  final _TimelineEntry entry;
  const _TimelineCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.title,
                  style: AppFonts.body(
                    size: 20.5,
                    weight: FontWeight.w800,
                    color: colors.cream,
                    text: entry.title,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.violetPop.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(entry.period,
                  style: AppFonts.label(text: entry.period, size: 13.5, weight: FontWeight.w700, color: colors.orchid, letterSpacing: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(entry.subtitle,
              style: AppFonts.body(size: 17, weight: FontWeight.w600, color: colors.violetLight, text: entry.subtitle)),
          if (entry.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(entry.description,
                style: AppFonts.body(size: 17, weight: FontWeight.w500, height: 1.5, color: colors.creamDim, text: entry.description)),
          ],
          if (entry.highlights.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final h in entry.highlights)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(color: colors.orchid, shape: BoxShape.circle),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(h,
                          style: AppFonts.body(size: 16, weight: FontWeight.w500, height: 1.45, color: colors.creamDim, text: h)),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}


/// Lets a mouse/trackpad drag the certificates carousel on desktop web,
/// same fix as the home banner slideshow — by default Flutter's web
/// scroll behaviour only accepts touch/stylus drags.
class _CertDragScrollBehavior extends MaterialScrollBehavior {
  const _CertDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// A lighter, snappier drag feel for the certificates carousel — now
/// that each card is much bigger (A4-landscape sized), the default
/// [PageScrollPhysics] needs an almost full-width drag before it'll
/// commit to the next page. This scales the user's drag so a smaller,
/// quicker swipe is enough, and lowers the fling-velocity tolerance so
/// a fast flick counts sooner too.
class _FastCertPageScrollPhysics extends PageScrollPhysics {
  const _FastCertPageScrollPhysics({super.parent});

  @override
  _FastCertPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _FastCertPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Tolerance get tolerance => const Tolerance(velocity: 300, distance: 0.01);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(position, offset * 1.6);
  }
}

/// Certificates shown one at a time in a swipeable, snapping carousel —
/// a single centered card fills the page; swiping left/right moves to
/// the next or previous certificate. Each card is still the same flip
/// tile (see [_CertificateFlipCard]) — swiping moves between
/// certificates, tapping the card flips it in place to reveal its
/// write-up.
class _CertificatesCarousel extends StatefulWidget {
  final List<_Certificate> certificates;
  final bool isMobile;
  const _CertificatesCarousel({required this.certificates, required this.isMobile});

  @override
  State<_CertificatesCarousel> createState() => _CertificatesCarouselState();
}

class _CertificatesCarouselState extends State<_CertificatesCarousel> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // One certificate fills the full width at a time — no peek, no
    // side siblings; swipe moves cleanly to the next.
    _controller = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certs = widget.certificates;
    if (certs.isEmpty) return const SizedBox.shrink();

    // Matches the certificate image's own proportions (1492×1054), with
    // the resulting height clamped to the same 200–760 range as the
    // Home page's promo banners — so the card frames the certificate
    // without cropping it, instead of forcing a generic 16:9 ratio.
    const bannerAspectRatio = 1492 / 1054;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Sized down to 80% of the available width on desktop for a
        // cozier card — but on mobile that shrink (combined with the
        // already-narrow screen) was pushing the card height below
        // what the front face's content (icon, title, chips, blurb)
        // needs. Mobile keeps the full width, and its height floor is
        // raised past the ~240–270px the 1492×1054 ratio alone would
        // give — just enough for the (now shorter) description, so the
        // back face's real certificate photo isn't left with big empty
        // gutters above/below either.
        final cardWidth = widget.isMobile ? constraints.maxWidth : constraints.maxWidth * 0.8;
        final cardHeight = (cardWidth / bannerAspectRatio).clamp(widget.isMobile ? 360.0 : 200.0, 760.0);

        return Column(
          children: [
            Center(
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: ScrollConfiguration(
                  behavior: const _CertDragScrollBehavior(),
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: certs.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) {
                      return RevealOnScroll(
                        delay: Duration(milliseconds: 60 * (i % 6)),
                        offsetY: 22,
                        child: _CertificateFlipCard(certificate: certs[i]),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (certs.length > 1) ...[
              const SizedBox(height: 18),
              _CertProgressBar(width: cardWidth, page: _page, count: certs.length, colors: context.colors),
            ],
          ],
        );
      },
    );
  }
}

/// Replaces the old dot indicator under the certificates carousel: a
/// slim rounded track with a fill that animates to (page + 1) / count,
/// plus a small "x / N" label so the position is still explicit, not
/// just implied by the fill amount.
class _CertProgressBar extends StatelessWidget {
  final double width;
  final int page;
  final int count;
  final AppColors colors;
  const _CertProgressBar({required this.width, required this.page, required this.count, required this.colors});

  @override
  Widget build(BuildContext context) {
    final ratio = count == 0 ? 0.0 : (page + 1) / count;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: width,
            height: 5,
            color: colors.orchid.withOpacity(0.18),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                width: width * ratio.clamp(0.0, 1.0),
                height: 5,
                decoration: BoxDecoration(
                  color: colors.orchid,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${page + 1} / $count',
          // Forced LTR: inside an Arabic (RTL) paragraph, a bare
          // "1 / 5" string has no strong-direction anchor, so the
          // bidi algorithm was free to reorder it into "5 / 1". This
          // keeps the fraction reading left-to-right regardless of
          // the surrounding language.
          textDirection: TextDirection.ltr,
          style: AppFonts.label(
            text: '${page + 1} / $count',
            size: 12,
            weight: FontWeight.w600,
            color: colors.creamDim,
          ),
        ),
      ],
    );
  }
}

/// A single certificate tile that flips over on tap: the front shows
/// the certificate icon, title, issuer and date; tapping it plays a 3D
/// Y-axis flip to reveal the write-up on the back, and tapping again
/// flips it back — like turning a physical certificate card over.
class _CertificateFlipCard extends StatefulWidget {
  final _Certificate certificate;
  const _CertificateFlipCard({required this.certificate});

  @override
  State<_CertificateFlipCard> createState() => _CertificateFlipCardState();
}

class _CertificateFlipCardState extends State<_CertificateFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _flipped = !_flipped);
    if (_flipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cert = widget.certificate;
    return Semantics(
      button: true,
      label: cert.title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * 3.14159265359;
              final showBack = angle > 3.14159265359 / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0016)
                  ..rotateY(angle),
                child: showBack
                    ? _CertificateBack(certificate: cert)
                    : _CertificateFront(certificate: cert),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CertificateFront extends StatelessWidget {
  final _Certificate certificate;
  const _CertificateFront({required this.certificate});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: colors.cardGradient,
        border: Border.all(color: colors.orchid.withOpacity(0.28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 22, offset: const Offset(0, 10)),
          BoxShadow(color: colors.orchid.withOpacity(0.12), blurRadius: 30, spreadRadius: -6),
        ],
      ),
      child: Stack(
        children: [
          // Faint oversized watermark of the medal icon in the corner —
          // a decorative touch that echoes an actual paper certificate's
          // seal without competing with the real content.
          Positioned(
            top: -18,
            right: -18,
            child: Icon(
              Icons.workspace_premium_outlined,
              size: 110,
              color: colors.orchid.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main content stays centered and scrolls if it overflows,
              // while the "view certificate" hint is pinned to the very
              // bottom of the card via the Expanded + bottom-aligned hint
              // below — a clear, deliberate drop to the card's edge.
              Expanded(
                child: Align(
                  alignment: const Alignment(0, -0.35),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: colors.violetGradient,
                            boxShadow: [
                              BoxShadow(color: colors.orchid.withOpacity(0.45), blurRadius: 22, spreadRadius: 1),
                            ],
                          ),
                          child: const Icon(Icons.workspace_premium_outlined, color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          certificate.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(text: certificate.title, size: 21, weight: FontWeight.w800, color: colors.cream, height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 34,
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: colors.violetGradient,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _CertMetaChip(icon: Icons.apartment_rounded, label: certificate.issuer, colors: colors),
                            _CertMetaChip(icon: Icons.event_rounded, label: certificate.date, colors: colors),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          certificate.content,
                          textAlign: TextAlign.center,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(text: certificate.content, size: 15, weight: FontWeight.w500, color: colors.creamDim, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _TapToFlipHint(colors: colors, label: context.strings.tapToFlipHint),
            ],
          ),
        ],
      ),
    );
  }
}

/// A light "tap to flip" hint printed under the description — plain
/// text with a small icon, not a heavy button, just enough to tell the
/// user the card can be flipped to see the real certificate.
class _TapToFlipHint extends StatelessWidget {
  final AppColors colors;
  final String label;
  const _TapToFlipHint({required this.colors, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.touch_app_outlined, size: 14, color: colors.orchid.withOpacity(0.85)),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppFonts.label(text: label, size: 12.5, weight: FontWeight.w700, color: colors.orchid.withOpacity(0.85)),
        ),
      ],
    );
  }
}

/// Small rounded pill used on the certificate front for the issuer and
/// date — a tidier alternative to plain stacked text lines.
class _CertMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColors colors;
  const _CertMetaChip({required this.icon, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceRaised.withOpacity(colors.isDark ? 0.6 : 1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: colors.orchid.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.orchid),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(text: label, size: 12.5, weight: FontWeight.w600, color: colors.creamDim),
          ),
        ],
      ),
    );
  }
}

class _CertificateBack extends StatelessWidget {
  final _Certificate certificate;
  const _CertificateBack({required this.certificate});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Mirrored back-face — flipped again here so its own content reads
    // normally once the outer Transform has rotated the whole tile 180°.
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159265359),
      child: _CertificateBackContent(certificate: certificate),
    );
  }
}

/// The back face's actual content — split out so the real-certificate
/// image path and the plain text write-up fallback stay easy to tell
/// apart at a glance.
class _CertificateBackContent extends StatelessWidget {
  final _Certificate certificate;
  const _CertificateBackContent({required this.certificate});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Real certificate image on file — show it full-bleed on the back
    // of the card.
    if (certificate.imageAsset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop fill behind the image — needed now that the
            // image uses BoxFit.contain (shows the whole certificate,
            // uncropped) instead of cover, which can leave letterbox
            // gutters on the sides or top/bottom depending on how the
            // card's box ratio compares to the real certificate's.
            Container(
              decoration: BoxDecoration(
                gradient: colors.cardGradient,
                border: Border.all(color: colors.orchid.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 9)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(certificate.imageAsset!, fit: BoxFit.contain),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: colors.violetGradientWide,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 9)),
        ],
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              certificate.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(text: certificate.title, size: 16.5, weight: FontWeight.w800, color: Colors.white, height: 1.3),
            ),
            const SizedBox(height: 10),
            Text(
              certificate.content,
              style: AppFonts.body(text: certificate.content, size: 13.5, weight: FontWeight.w500, color: Colors.white.withOpacity(0.9), height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}


class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: filled ? context.colors.violetGradient : null,
          color: filled ? null : context.colors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: filled ? Colors.transparent : context.colors.border(0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: filled ? Colors.white : context.colors.cream),
            const SizedBox(width: 7),
            Text(label,
              style: AppFonts.label(text: label, 
                size: 13.5,
                color: filled ? Colors.white : context.colors.cream,
                letterSpacing: 0.6,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProfileNotice extends StatelessWidget {
  final bool isMobile;
  const _EmptyProfileNotice({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.person_outline_rounded, size: 30, color: context.colors.creamDim),
        const SizedBox(height: 12),
        Text(context.strings.emptyProfileNotice,
          textAlign: TextAlign.start,
          style: AppFonts.body(text: context.strings.emptyProfileNotice, size: 17.5, weight: FontWeight.w500, color: context.colors.creamDim),
        ),
      ],
    );
  }
}
