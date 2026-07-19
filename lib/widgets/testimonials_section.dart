import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../models/testimonial.dart';
import '../services/testimonials_repository.dart';
import '../theme/app_theme.dart';
import 'reveal_on_scroll.dart';
import 'section_heading.dart';

/// Customer quotes — pulled from Supabase's `testimonials` table (only the
/// ones the owner has approved, see [TestimonialsRepository.fetchApproved]).
/// Customers can add their own via the "Leave a comment" button below the
/// list; new submissions stay hidden here until approved from the admin
/// dashboard. Each card uses the same circle-avatar look as the icon
/// circles in [OwnerIntroCard] and the category circles above it, so it
/// stays visually consistent with the rest of the home page.
class TestimonialsSection extends StatefulWidget {
  final bool isMobile;
  const TestimonialsSection({super.key, required this.isMobile});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  List<Testimonial> _testimonials = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final testimonials = await TestimonialsRepository.fetchApproved();
    if (!mounted) return;
    setState(() {
      _testimonials = testimonials;
      _loading = false;
    });
  }

  Future<void> _openCommentForm() async {
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => const _LeaveCommentDialog(),
    );
    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.stringsRead.leaveACommentSuccess)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 24 : 60),
          child: Align(
            alignment: Alignment.center,
            child: RevealOnScroll(
              child: SectionHeading(
                eyebrow: context.strings.testimonialsEyebrow,
                title: context.strings.testimonialsTitle,
                titleSize: widget.isMobile ? 24 : 30,
                align: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_loading)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 24 : 60),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
              ),
            ),
          )
        else if (_testimonials.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 24 : 60),
            child: Center(
              child: Text(
                context.strings.noTestimonialsYet,
                textAlign: TextAlign.center,
                style: AppFonts.body(size: 14, color: context.colors.creamDim),
              ),
            ),
          )
        else
          SizedBox(
            height: widget.isMobile ? 225 : 205,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 24 : 60),
              scrollDirection: Axis.horizontal,
              itemCount: _testimonials.length,
              itemBuilder: (context, i) {
                final t = _testimonials[i];
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: 16),
                  child: RevealOnScroll(
                    delay: Duration(milliseconds: 80 * i),
                    child: _TestimonialCard(
                      name: t.name,
                      quote: t.quote,
                      rating: t.rating,
                      isMobile: widget.isMobile,
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 24 : 60),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _LeaveCommentButton(isMobile: widget.isMobile, onTap: _openCommentForm),
              _FacebookReviewsButton(isMobile: widget.isMobile),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pill button that opens [_LeaveCommentDialog] so a customer can submit
/// their own testimonial.
class _LeaveCommentButton extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onTap;
  const _LeaveCommentButton({required this.isMobile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 28, vertical: isMobile ? 12 : 14),
        decoration: BoxDecoration(
          color: colors.surfaceRaised.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: colors.border(0.16), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rate_review_outlined, color: colors.orchid, size: isMobile ? 18 : 20),
            const SizedBox(width: 8),
            Text(
              context.strings.leaveACommentButton,
              style: AppFonts.label(size: isMobile ? 13 : 15, color: colors.cream, letterSpacing: 0.3)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog form for submitting a new testimonial: name, comment, and a
/// star-rating picker. Pops `true` on successful submit so the caller can
/// show a confirmation snackbar.
class _LeaveCommentDialog extends StatefulWidget {
  const _LeaveCommentDialog();

  @override
  State<_LeaveCommentDialog> createState() => _LeaveCommentDialogState();
}

class _LeaveCommentDialogState extends State<_LeaveCommentDialog> {
  final _nameController = TextEditingController();
  final _quoteController = TextEditingController();
  int _rating = 5;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final quote = _quoteController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.strings.leaveACommentNameRequired);
      return;
    }
    if (quote.isEmpty) {
      setState(() => _error = context.strings.leaveACommentCommentRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await TestimonialsRepository.submit(name: name, quote: quote, rating: _rating);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = context.strings.leaveACommentError('$e'));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AlertDialog(
      backgroundColor: colors.surfaceRaised,
      title: Text(
        context.strings.leaveACommentTitle,
        style: AppFonts.display(color: colors.cream, size: 18, weight: FontWeight.w700),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.strings.leaveACommentYourName,
                style: AppFonts.label(color: colors.orchid, size: 11, letterSpacing: 1.2)),
            const SizedBox(height: 6),
            _DialogTextField(
              controller: _nameController,
              hint: context.strings.leaveACommentYourNameHint,
            ),
            const SizedBox(height: 16),
            Text(context.strings.leaveACommentYourComment,
                style: AppFonts.label(color: colors.orchid, size: 11, letterSpacing: 1.2)),
            const SizedBox(height: 6),
            _DialogTextField(
              controller: _quoteController,
              hint: context.strings.leaveACommentYourCommentHint,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Text(context.strings.leaveACommentRating,
                style: AppFonts.label(color: colors.orchid, size: 11, letterSpacing: 1.2)),
            const SizedBox(height: 6),
            Row(
              children: List.generate(5, (i) {
                final filled = i < _rating;
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 26,
                      color: colors.orchid,
                    ),
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: AppFonts.body(size: 12.5, color: colors.danger)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
          child: Text(context.strings.leaveACommentCancel, style: AppFonts.body(size: 14, color: colors.creamDim)),
        ),
        TextButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: colors.orchid),
                )
              : Text(context.strings.leaveACommentSubmit,
                  style: AppFonts.body(size: 14, weight: FontWeight.w700, color: colors.orchid)),
        ),
      ],
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _DialogTextField({required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border(0.08)),
      ),
      child: TextField(
        controller: controller,
        minLines: 1,
        maxLines: maxLines,
        style: AppFonts.body(size: 14.5, color: colors.cream),
        cursorColor: colors.orchid,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppFonts.body(size: 14, color: colors.creamDim),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
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
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 28, vertical: isMobile ? 12 : 14),
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
            Icon(Icons.facebook_rounded, color: Colors.white, size: isMobile ? 18 : 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.strings.successPartnersReviews,
                textAlign: TextAlign.center,
                maxLines: isMobile ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.label(size: isMobile ? 13 : 15, color: Colors.white, letterSpacing: 0.3)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
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
