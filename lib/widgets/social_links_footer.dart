import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';

/// Small "Follow us" strip with Instagram + Facebook icon buttons.
/// Meant to sit at the very bottom of every page's scrollable content,
/// right before the final bottom padding.
class SocialLinksFooter extends StatelessWidget {
  final bool isMobile;
  const SocialLinksFooter({super.key, required this.isMobile});

  static final Uri _instagramUri = Uri.parse(
    'https://www.instagram.com/ayas_graphique?igsi=MWVmNmNpMTExaWR4aA%3D%3D&utm_source=qr',
  );
  static final Uri _facebookUri = Uri.parse(
    'https://www.facebook.com/share/1ZAmX9ByH1/?mibextid=wwXIfr',
  );

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.strings.followUsLabel,
          style: AppFonts.label(
            text: context.strings.followUsLabel,
            size: 13,
            color: colors.creamDim,
            letterSpacing: 1.2,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SocialIconButton(
              icon: FontAwesomeIcons.instagram,
              tooltip: context.strings.instagramLabel,
              onTap: () => _open(context, _instagramUri),
            ),
            const SizedBox(width: 16),
            _SocialIconButton(
              icon: FontAwesomeIcons.facebookF,
              tooltip: context.strings.facebookLabel,
              onTap: () => _open(context, _facebookUri),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _SocialIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: colors.violetGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.violetPop.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
