import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';

/// Pill button that opens the owner's Facebook page reviews tab in an
/// external browser/app. Previously lived at the bottom of the
/// Testimonials section; now stands alone since that section was removed.
class FacebookReviewsButton extends StatelessWidget {
  final bool isMobile;
  const FacebookReviewsButton({super.key, required this.isMobile});

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
