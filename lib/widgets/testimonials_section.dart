import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/testimonials.dart';
import '../localization/app_strings.dart';
import '../providers/language_controller.dart';
import '../theme/app_theme.dart';
import 'reveal_on_scroll.dart';
import 'section_heading.dart';

/// Customer quotes — plain static data (see lib/data/testimonials.dart),
/// no backend needed. Each card uses the same circle-avatar look as the
/// icon circles in [OwnerIntroCard] and the category circles above it, so
/// it stays visually consistent with the rest of the home page.
class TestimonialsSection extends StatelessWidget {
  final bool isMobile;
  const TestimonialsSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (testimonials.isEmpty) return const SizedBox.shrink();
    final isArabic = context.isArabicLanguage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: RevealOnScroll(
              child: SectionHeading(
                eyebrow: context.strings.testimonialsEyebrow,
                title: context.strings.testimonialsTitle,
                titleSize: isMobile ? 24 : 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: isMobile ? 225 : 205,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
            scrollDirection: Axis.horizontal,
            itemCount: testimonials.length,
            itemBuilder: (context, i) {
              final t = testimonials[i];
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 16),
                child: RevealOnScroll(
                  delay: Duration(milliseconds: 80 * i),
                  child: _TestimonialCard(
                    name: t.name(isArabic),
                    quote: t.quote(isArabic),
                    rating: t.rating,
                    isMobile: isMobile,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
          child: Center(
            child: _FacebookReviewsButton(isMobile: isMobile),
          ),
        ),
      ],
    );
  }
}

/// Pill button under the testimonials list that opens the owner's
/// Facebook page reviews tab in an external browser/app.
class _FacebookReviewsButton extends StatelessWidget {
  final bool isMobile;
  const _FacebookReviewsButton({required this.isMobile});

  static final Uri _reviewsUri = Uri.parse(
    'https://www.facebook.com/aya.attia.abed97/reviews/?id=100068226772356&sk=reviews',
  );

  Future<void> _open(BuildContext context) async {
    try {
      final launched = await launchUrl(_reviewsUri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.stringsRead.couldntOpenFacebookReviews('launchUrl returned false'))),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.stringsRead.couldntOpenFacebookReviews('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: colors.violetGradient,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: colors.violetPop.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.facebook_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              context.strings.successPartnersReviews,
              style: AppFonts.label(size: 15, color: Colors.white, letterSpacing: 0.3)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String quote;
  final int rating;
  final bool isMobile;

  const _TestimonialCard({
    required this.name,
    required this.quote,
    required this.rating,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = name.trim().isNotEmpty ? name.trim()[0] : '?';

    return Container(
      width: isMobile ? 280 : 340,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceRaised.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border(0.16), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.violetPop.withOpacity(0.18),
                ),
                child: Text(
                  initial.toUpperCase(),
                  style: AppFonts.label(color: colors.orchid, size: 16, letterSpacing: 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    color: colors.cream,
                    size: 15.5,
                    weight: FontWeight.w700,
                    text: name,
                    boostArabicSize: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: 16,
                color: colors.orchid,
              );
            }),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              quote,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(
                color: colors.creamDim,
                size: 14,
                text: quote,
                boostArabicSize: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
