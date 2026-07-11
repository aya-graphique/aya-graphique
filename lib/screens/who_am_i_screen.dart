import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../models/about_me.dart';
import '../providers/language_controller.dart';
import '../services/about_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_text.dart';

/// A standalone bio/portfolio page: photo slideshow up top, then the
/// owner's own words underneath. Meant to be sent (or its link shared) as
/// part of a proposal when pitching for other design work — everything on
/// it is editable from the admin dashboard, no code changes needed.

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
      ),
    ];

List<_TimelineEntry> kEducation(bool isArabic) => [
      _TimelineEntry(
        title: isArabic ? 'بكالوريوس التصميم الجرافيكي' : 'B.A. in Graphic Design',
        subtitle: isArabic
            ? 'كلية الفنون التطبيقية، جامعة حلوان'
            : 'Faculty of Applied Arts, Helwan University',
        period: '2015 — 2019',
        description: '',
      ),
    ];

class _TimelineEntry {
  final String title;
  final String subtitle;
  final String period;
  final String description;
  const _TimelineEntry({
    required this.title,
    required this.subtitle,
    required this.period,
    this.description = '',
  });
}

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
  /// scroll view, no scroll controller, and no top nav-bar offset — used to
  /// drop this whole section straight into another scrollable page (see
  /// HomeScreen, which embeds it after the shop grid). When false (the
  /// standalone "About" tab), it wraps itself in its own
  /// SingleChildScrollView using [scrollController], same as before.
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
                padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 24 : 60),
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: widget.isMobile ? double.infinity : 720,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
            textAlign: TextAlign.center,
            style: AppFonts.display(
              color: context.colors.cream,
              size: isMobile ? 36 : 58,
              height: 1.05,
              text: profile.fullName,
            ),
          ),
        if (profile.headlineFor(context.isArabicLanguage).isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            profile.headlineFor(context.isArabicLanguage),
            textAlign: TextAlign.center,
            style: AppFonts.label(
              color: context.colors.violetLight,
              size: 15,
              letterSpacing: 1.4,
              text: profile.headlineFor(context.isArabicLanguage),
            ),
          ),
        ],
        if (profile.bioFor(context.isArabicLanguage).isNotEmpty) ...[
          const SizedBox(height: 26),
          Text(
            profile.bioFor(context.isArabicLanguage),
            textAlign: TextAlign.center,
            style: AppFonts.body(
              color: context.colors.creamDim,
              size: isMobile ? 17 : 18.5,
              text: profile.bioFor(context.isArabicLanguage),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
        ],
        if (profile.skillsFor(context.isArabicLanguage).isNotEmpty) ...[
          const SizedBox(height: 26),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: profile.skillsFor(context.isArabicLanguage)
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(100),
                        // Was a flat white border — invisible against a white
                        // surface in light mode. Cream adapts per theme.
                        border: Border.all(color: context.colors.cream.withOpacity(0.1)),
                      ),
                      child: Text(
                        _capitalizeWords(s),
                        style: AppFonts.body(
                          size: isMobile ? 17 : 18.5,
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
        Builder(builder: (context) {
          final experience = kExperience(context.isArabicLanguage);
          final education = kEducation(context.isArabicLanguage);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (experience.isNotEmpty || education.isNotEmpty) const SizedBox(height: 46),
              if (experience.isNotEmpty)
                _TimelineSection(eyebrow: context.strings.experienceLabel, entries: experience),
              if (experience.isNotEmpty && education.isNotEmpty) const SizedBox(height: 40),
              if (education.isNotEmpty)
                _TimelineSection(eyebrow: context.strings.educationLabel, entries: education),
            ],
          );
        }),
        const SizedBox(height: 46),
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
            ],
          ),
        ),
        if (profile.location.isNotEmpty) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final String eyebrow;
  final List<_TimelineEntry> entries;
  const _TimelineSection({required this.eyebrow, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 22, height: 2, color: context.colors.orchid),
            const SizedBox(width: 10),
            Text(eyebrow, style: AppFonts.label(color: context.colors.orchid, size: 14.5)),
          ],
        ),
        const SizedBox(height: 22),
        for (var i = 0; i < entries.length; i++) ...[
          _TimelineRow(entry: entries[i]),
          // A short connecting line between entries instead of the old
          // full-height line — simpler to center now that the dot sits
          // above the text rather than beside it.
          if (i != entries.length - 1) ...[
            const SizedBox(height: 8),
            Container(width: 2, height: 24, color: context.colors.cream.withOpacity(0.14)),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _TimelineEntry entry;
  const _TimelineRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: context.colors.violetPop,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 12),
        Text(entry.title,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              size: 20,
              weight: FontWeight.w700,
              color: context.colors.cream,
              text: entry.title,
            )),
        const SizedBox(height: 4),
        Text(entry.subtitle,
            textAlign: TextAlign.center,
            style: AppFonts.body(size: 17, color: context.colors.violetLight, text: entry.subtitle)),
        const SizedBox(height: 4),
        Text(entry.period,
            textAlign: TextAlign.center,
            style: AppFonts.label(size: 14, color: context.colors.creamDim, letterSpacing: 0.8)),
        if (entry.description.isNotEmpty) ...[
          const SizedBox(height: 9),
          Text(entry.description,
              textAlign: TextAlign.center,
              style: AppFonts.body(size: 17, color: context.colors.creamDim, text: entry.description)),
        ],
      ],
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
            color: filled ? Colors.transparent : context.colors.cream.withOpacity(0.12),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.cream.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.person_outline_rounded, size: 30, color: context.colors.creamDim),
          const SizedBox(height: 12),
          Text(
            context.strings.emptyProfileNotice,
            textAlign: TextAlign.center,
            style: AppFonts.body(size: 16, color: context.colors.creamDim),
          ),
        ],
      ),
    );
  }
}
