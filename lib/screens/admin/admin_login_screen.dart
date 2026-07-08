import 'package:flutter/material.dart';
import '../../config/supabase_config.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';

/// Entry point to the admin area. Reachable from the "Store admin" link in
/// the storefront footer. Anyone can open this screen, but they need the
/// admin email + password (created in Supabase Auth) to get past it — the
/// Supabase Row Level Security policies also block writes from anyone who
/// isn't signed in, so this is a real gate, not just a UI nicety.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    if (AuthService.isSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToDashboard());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await AuthService.signIn(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
    if (error == null) _goToDashboard();
  }

  @override
  Widget build(BuildContext context) {
    // The storefront's Arabic-font toggle sets a global static flag
    // (AppFonts.forceArabic). The admin dashboard never offers that
    // toggle and always stays in English, so force it off here on every
    // build regardless of what a shopper picked on the storefront.
    AppFonts.forceArabic = false;
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back_rounded, color: context.colors.creamDim),
                      alignment: Alignment.centerLeft,
                    )
                  else
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                      icon: Icon(Icons.storefront_rounded, size: 18, color: context.colors.creamDim),
                      label: Text('Back to store', style: AppFonts.body(size: 13, color: context.colors.creamDim)),
                      style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
                    ),
                  const SizedBox(height: 8),
                  ShaderMask(
                    // `shaderCallback` runs during paint, not build — so
                    // `context.colors` (which does `context.watch`) throws
                    // the same "listen from outside the widget tree"
                    // assertion we hit in checkout. `colorsRead` (a plain
                    // `read`, no subscription) is the non-throwing version.
                    shaderCallback: (rect) => context.colorsRead.violetGradient.createShader(rect),
                    child: Text("Aya's Graphique",
                        style: AppFonts.display(size: 26, weight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(height: 6),
                  Text('Store admin', style: AppFonts.label(color: context.colors.orchid, )),
                  const SizedBox(height: 28),
                  if (!SupabaseConfig.isConfigured)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: context.colors.danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.danger.withOpacity(0.4)),
                      ),
                      child: Text(
                        'Supabase isn\'t connected yet. Fill in lib/config/supabase_config.dart '
                        'with your project URL and anon key, then run the SQL in '
                        'supabase/schema.sql.',
                        style: AppFonts.body(size: 13, color: context.colors.cream),
                      ),
                    ),
                  _Field(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Password',
                    controller: _passwordController,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: context.colors.creamDim,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!, style: AppFonts.body(size: 13, color: context.colors.danger)),
                  ],
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _loading ? null : _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: context.colors.violetGradient,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Sign in',
                              style: AppFonts.label(
                                size: 14,
                                color: Colors.white,
                                letterSpacing: 1.6,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Admin accounts are created in the Supabase dashboard, under '
                    'Authentication → Users. There\'s no public sign-up here.',
                    textAlign: TextAlign.center,
                    style: AppFonts.body(size: 12, color: context.colors.creamDim),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _Field({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.4)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.cream.withOpacity(0.08)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            onSubmitted: onSubmitted,
            style: AppFonts.body(size: 14.5, color: context.colors.cream),
            cursorColor: context.colors.orchid,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}
