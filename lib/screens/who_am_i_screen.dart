import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../models/about_me.dart';
import '../providers/language_controller.dart';
import '../services/about_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_text.dart';

/// A standalone bio/portfolio page — the owner's own words, organized into
/// clear labelled sections (stats, bio, skills, experience, education,
/// contact). Meant to be sent (or its link shared) as part of a proposal
/// when pitching for other design work — the admin-editable fields
/// (name/headline/bio/skills/contact/location) are set from the admin
/// dashboard, no code changes needed. Deliberately photo-free — an
/// initials avatar stands in for a portrait (see [_InitialsAvatar]) rather
/// than wiring up owner photo uploads here.

/// Static content — not wired to the dashboard on purpose. Edit these
/// lists directly in code whenever the experience/education changes.
/// Each entry carries both an English and an Arabic version so it follows
/// the storefront language toggle the same way the dashboard-driven
/// content does.
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
      _StatItem('5+', isArabic ? 'سنوات خبرة' : 'Years experience'),
      _StatItem('30+', isArabic ? 'مشروع هوية بصرية' : 'Brand projects'),
      _StatItem('98%', isArabic ? 'رضا العملاء' : 'Client satisfaction'),
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
              if (!widget.embedded) SizedBox(height: widget.isMobile ? 120 : 150),
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 24 : 72),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: profile.isEmpty
                        ? _EmptyProfileNotice(isMobile: widget.isMobile)
                        : _Profile(
                            profile: profile,
                            isMobile: widget.isMobile,
                            onOpenUrl: _openUrl,
                            onOpenWhatsapp: _openWhatsapp,
                            onOpenEmail: _openEmail,
                          ),
                  ),
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
    final bio = profile.bioFor(isArabic);
    final skills = profile.skillsFor(isArabic);
    final experience = kExperience(isArabic);
    final education = kEducation(isArabic);
    final hasContact = profile.whatsapp.isNotEmpty ||
        profile.email.isNotEmpty ||
        profile.phone.isNotEmpty ||
        profile.portfolioUrl.isNotEmpty ||
        profile.cvUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Portrait photo — same brand photo used on the splash screen,
        // in the same violet-gradient ring treatment as the audience/
        // service circles elsewhere. Falls back to the lettered initials
        // badge if the asset is missing.
        if (profile.fullName.isNotEmpty) ...[
          _PortraitAvatar(name: profile.fullName),
          const SizedBox(height: 22),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 28, height: 2, color: context.colors.orchid),
            const SizedBox(width: 10),
            Text(context.strings.whoAmIEyebrow, style: AppFonts.label(color: context.colors.orchid, size: 14)),
            const SizedBox(width: 10),
            Container(width: 28, height: 2, color: context.colors.orchid),
          ],
        ).animate().fadeIn(duration: 500.ms),
        // 16px gap — matches the eyebrow-to-title spacing in SectionHeading,
        // which is what the Services page (and every other tab) uses, so
        // the two pages open with the same visual rhythm.
        const SizedBox(height: 16),
        if (profile.fullName.isNotEmpty)
          ShimmerHeadline(
            text: _capitalizeWords(profile.fullName),
            textAlign: TextAlign.start,
            style: AppFonts.display(
              color: context.colors.cream,
              size: isMobile ? 36 : 58,
              height: 1.05,
              text: profile.fullName,
            ),
          ),
        // Fixed brand slogan — always shown under the name, independent
        // of the admin-editable headline field below. Small tracked caps
        // read as a refined tagline rather than competing with the big
        // gradient name above it.
        const SizedBox(height: 10),
        Text(
          'SIMPLICITY MAKES IT ART',
          textAlign: TextAlign.start,
          style: AppFonts.label(
            color: context.colors.creamDim,
            size: isMobile ? 11 : 12.5,
            letterSpacing: 3,
          ).copyWith(fontWeight: FontWeight.w600),
        ).animate().fadeIn(duration: 500.ms, delay: 80.ms),
        if (profile.headlineFor(isArabic).isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            profile.headlineFor(isArabic),
            textAlign: TextAlign.start,
            style: AppFonts.label(
              color: context.colors.violetLight,
              size: 15,
              letterSpacing: 1.4,
              text: profile.headlineFor(isArabic),
            ),
          ),
        ],
        // Quick-read career stats — static figures (see kStats), kept
        // separate from the admin-editable fields above so they're easy
        // to tweak in code as the real numbers change.
        const SizedBox(height: 28),
        _StatsRow(stats: kStats(isArabic)),
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 34),
          _SectionDivider(),
          const SizedBox(height: 26),
          Text(
            bio,
            textAlign: TextAlign.start,
            style: AppFonts.body(
              color: context.colors.creamDim,
              size: isMobile ? 17 : 18.5,
              height: 1.55,
              text: bio,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
        ],
        if (skills.isNotEmpty) ...[
          const SizedBox(height: 40),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniSectionHeader(label: context.strings.skillsLabel),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  children: skills
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: BorderRadius.circular(100),
                              // Was a flat white border — invisible against a
                              // white surface in light mode. Cream adapts per
                              // theme.
                              border: Border.all(color: context.colors.border(0.1)),
                            ),
                            child: Text(
                              _capitalizeWords(s),
                              style: AppFonts.body(
                                size: isMobile ? 16 : 17,
                                weight: FontWeight.w600,
                                color: context.colors.cream,
                                text: s,
                                boostArabicSize: false,
                              ),
                            ),
                          ))
                      .toList(),
                ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniSectionHeader(label: context.strings.getInTouchLabel),
                const SizedBox(height: 22),
                if (hasContact)
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.start,
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
                      ],
                    ),
                  ),
                if (profile.location.isNotEmpty) ...[
                  if (hasContact) const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(Icons.place_outlined, size: 16, color: context.colors.creamDim),
                        const SizedBox(width: 6),
                        Text(profile.location,
                            style: AppFonts.body(size: 15.5, color: context.colors.creamDim, text: profile.location)),
                      ],
                    ),
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
              errorBuilder: (_, __, ___) => Text(
                _initials,
                style: AppFonts.display(color: colors.orchid, size: 56, weight: FontWeight.w800),
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
        Text(label, style: AppFonts.label(color: context.colors.orchid, size: 14.5)),
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
    return Wrap(
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 28,
      runSpacing: 16,
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(stats[i].value,
                  style: AppFonts.display(color: colors.cream, size: 26, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                stats[i].label,
                style: AppFonts.label(color: colors.creamDim, size: 11.5, letterSpacing: 0.6),
              ),
            ],
          ),
          if (i != stats.length - 1) Container(width: 1, height: 34, color: colors.border(0.14)),
        ],
      ],
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
                    size: 18.5,
                    weight: FontWeight.w700,
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
                child: Text(
                  entry.period,
                  style: AppFonts.label(size: 12, color: colors.orchid, letterSpacing: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(entry.subtitle,
              style: AppFonts.body(size: 15.5, color: colors.violetLight, text: entry.subtitle)),
          if (entry.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(entry.description,
                style: AppFonts.body(size: 15.5, height: 1.5, color: colors.creamDim, text: entry.description)),
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
                          style: AppFonts.body(size: 14.5, height: 1.45, color: colors.creamDim, text: h)),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
            Icon(icon, size: 17, color: filled ? Colors.white : context.colors.cream),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFonts.label(
                size: 15,
                color: filled ? Colors.white : context.colors.cream,
                letterSpacing: 0.8,
              ).copyWith(fontWeight: FontWeight.w600),
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
        Text(
          context.strings.emptyProfileNotice,
          textAlign: TextAlign.start,
          style: AppFonts.body(size: 16, color: context.colors.creamDim),
        ),
      ],
    );
  }
}
