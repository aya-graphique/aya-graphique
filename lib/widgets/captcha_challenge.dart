import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A small, self-contained CAPTCHA — a distorted 5-character code the admin
/// has to retype before signing in. It exists purely as friction against
/// scripted/automated login attempts hitting the admin dashboard.
///
/// Deliberately not backed by an external service (reCAPTCHA, hCaptcha,
/// etc.): the code is generated and checked entirely on-device, so there's
/// no API key to configure and nothing calls out to a third party. This is
/// *not* a substitute for server-side protections like rate limiting or
/// account lockouts on the Supabase Auth side — it just raises the cost of
/// naive scripted attempts against the UI.
///
/// Usage: keep a `GlobalKey<CaptchaChallengeState>`, place
/// `CaptchaChallenge(key: yourKey)` in the form, and on submit check
/// `yourKey.currentState!.isValid` before doing anything else. Call
/// `.refresh()` after *every* attempt (right or wrong) so a code can never
/// be reused.
class CaptchaChallenge extends StatefulWidget {
  const CaptchaChallenge({super.key});

  @override
  State<CaptchaChallenge> createState() => CaptchaChallengeState();
}

class CaptchaChallengeState extends State<CaptchaChallenge> {
  // No 0/O/1/I — those are the pairs people most often misread on a
  // distorted, noisy background.
  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _codeLength = 5;

  final _random = Random();
  final _answerController = TextEditingController();
  late String _code = _generateCode();

  String _generateCode() =>
      List.generate(_codeLength, (_) => _chars[_random.nextInt(_chars.length)]).join();

  /// Whether the admin's current input matches the code shown right now.
  bool get isValid => _answerController.text.trim().toUpperCase() == _code;

  /// Swaps in a fresh code and clears whatever was typed. Call this after
  /// every submit attempt so a captcha answer is never reusable, and after
  /// a wrong password too so the same code isn't sitting there for a
  /// scripted retry loop to reuse.
  void refresh() {
    setState(() {
      _code = _generateCode();
      _answerController.clear();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Security check',
            style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.4)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 132,
              height: 52,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.border(0.08)),
              ),
              child: CustomPaint(
                painter: _CaptchaPainter(
                  code: _code,
                  accent: context.colors.orchid,
                  textColor: context.colors.cream,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              height: 52,
              child: Material(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: refresh,
                  child: Icon(Icons.refresh_rounded, color: context.colors.creamDim, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.border(0.08)),
                ),
                child: TextField(
                  controller: _answerController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(size: 16, weight: FontWeight.w700, color: context.colors.cream)
                      .copyWith(letterSpacing: 2),
                  cursorColor: context.colors.orchid,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: 'Code',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CaptchaPainter extends CustomPainter {
  _CaptchaPainter({required this.code, required this.accent, required this.textColor});

  final String code;
  final Color accent;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Seed off the code itself so the noise pattern stays put across
    // rebuilds that don't change the code (e.g. typing in the answer
    // field), and only changes when refresh() actually swaps the code.
    final random = Random(code.hashCode);

    final linePaint = Paint()
      ..color = accent.withOpacity(0.25)
      ..strokeWidth = 1.2;
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(0, random.nextDouble() * size.height),
        Offset(size.width, random.nextDouble() * size.height),
        linePaint,
      );
    }

    final dotPaint = Paint()..color = accent.withOpacity(0.35);
    for (var i = 0; i < 24; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        1.1,
        dotPaint,
      );
    }

    final letterWidth = size.width / code.length;
    for (var i = 0; i < code.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: code[i],
          style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final dx = letterWidth * i + (letterWidth - painter.width) / 2;
      final dy = (size.height - painter.height) / 2 + (random.nextDouble() - 0.5) * 8;
      final angle = (random.nextDouble() - 0.5) * 0.5; // roughly ±14°

      canvas.save();
      canvas.translate(dx + painter.width / 2, dy + painter.height / 2);
      canvas.rotate(angle);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CaptchaPainter oldDelegate) => oldDelegate.code != code;
}
