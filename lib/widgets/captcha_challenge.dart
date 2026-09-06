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
/// Built entirely out of plain widgets (Stack/Positioned/Transform) rather
/// than a CustomPainter — CustomPainter/Canvas drawing is a common source
/// of renderer-specific glitches on Flutter Web (CanvasKit vs. Skwasm vs.
/// the HTML renderer can each handle a raw Canvas slightly differently),
/// so keeping this to ordinary widgets makes it behave the same everywhere
/// the rest of the app already renders correctly.
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
    // Seed off the code itself so the noise/rotation pattern stays put
    // across rebuilds that don't change the code (e.g. typing in the
    // answer field), and only changes when refresh() actually swaps it.
    final random = Random(_code.hashCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Write code',
            style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.4)),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: Row(
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // A handful of faint diagonal hairlines behind the
                  // letters — plain rotated Containers instead of
                  // canvas-drawn lines.
                  for (var i = 0; i < 4; i++)
                    Positioned(
                      top: random.nextDouble() * 44,
                      left: -10,
                      right: -10,
                      child: Transform.rotate(
                        angle: (random.nextDouble() - 0.5) * 0.6,
                        child: Container(
                          height: 1.2,
                          color: context.colors.orchid.withOpacity(0.22),
                        ),
                      ),
                    ),
                  // The distorted code itself: each letter individually
                  // sized, nudged and rotated.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final ch in _code.split(''))
                        Transform.translate(
                          offset: Offset(0, (random.nextDouble() - 0.5) * 10),
                          child: Transform.rotate(
                            angle: (random.nextDouble() - 0.5) * 0.5,
                            child: Text(
                              ch,
                              style: TextStyle(
                                color: context.colors.cream,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
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
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: 'Code',
                    hintStyle: AppFonts.body(size: 16, weight: FontWeight.w700, color: context.colors.creamDim)
                        .copyWith(letterSpacing: 2, color: context.colors.creamDim.withOpacity(0.18)),
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
      ],
    );
  }
}
