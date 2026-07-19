import 'package:flutter/material.dart';
import '../../models/testimonial.dart';
import '../../services/testimonials_repository.dart';
import '../../theme/app_theme.dart';

/// Lets the owner moderate customer-submitted testimonials: approve a
/// pending one so it shows up in the storefront's "What people say"
/// section, unapprove one that's already live, or delete it outright.
/// Maps onto [TestimonialsSection] on the Home page.
class AdminTestimonialsScreen extends StatefulWidget {
  const AdminTestimonialsScreen({super.key});

  @override
  State<AdminTestimonialsScreen> createState() => _AdminTestimonialsScreenState();
}

class _AdminTestimonialsScreenState extends State<AdminTestimonialsScreen> {
  List<Testimonial> _testimonials = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final testimonials = await TestimonialsRepository.fetchAll();
    if (!mounted) return;
    setState(() {
      _testimonials = testimonials;
      _loading = false;
    });
  }

  Future<void> _approve(Testimonial t) async {
    try {
      await TestimonialsRepository.approve(t.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Couldn\'t approve: $e')));
    }
  }

  Future<void> _unapprove(Testimonial t) async {
    try {
      await TestimonialsRepository.unapprove(t.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Couldn\'t unapprove: $e')));
    }
  }

  Future<void> _delete(Testimonial t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        title: Text('Delete this comment?', style: AppFonts.body(size: 16, color: context.colors.cream)),
        content: Text('This can\'t be undone.', style: AppFonts.body(size: 13, color: context.colors.creamDim)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: AppFonts.body(size: 14, color: context.colors.creamDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: AppFonts.body(size: 14, color: context.colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await TestimonialsRepository.delete(t.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Couldn\'t delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    AppFonts.forceArabic = false;
    final pending = _testimonials.where((t) => !t.isApproved).toList();
    final approved = _testimonials.where((t) => t.isApproved).toList();

    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      appBar: AppBar(
        backgroundColor: context.colors.bgDeep,
        elevation: 0,
        title: Text('Testimonials', style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: context.colors.orchid))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
                children: [
                  Text(
                    'Comments customers submit from the storefront land here '
                    'first. Approve one to publish it in the "What people say" '
                    'section on the Home page.',
                    style: AppFonts.body(size: 13, color: context.colors.creamDim),
                  ),
                  const SizedBox(height: 20),
                  Text('PENDING (${pending.length})',
                      style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  if (pending.isEmpty)
                    _EmptyNote(text: 'No comments waiting for approval.')
                  else
                    ...pending.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TestimonialRow(
                            testimonial: t,
                            onApprove: () => _approve(t),
                            onDelete: () => _delete(t),
                          ),
                        )),
                  const SizedBox(height: 26),
                  Text('APPROVED (${approved.length})',
                      style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  if (approved.isEmpty)
                    _EmptyNote(text: 'Nothing published yet.')
                  else
                    ...approved.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TestimonialRow(
                            testimonial: t,
                            onUnapprove: () => _unapprove(t),
                            onDelete: () => _delete(t),
                          ),
                        )),
                ],
              ),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  final String text;
  const _EmptyNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border(0.08)),
      ),
      child: Text(text, style: AppFonts.body(size: 13, color: context.colors.creamDim)),
    );
  }
}

class _TestimonialRow extends StatelessWidget {
  final Testimonial testimonial;
  final VoidCallback? onApprove;
  final VoidCallback? onUnapprove;
  final VoidCallback onDelete;

  const _TestimonialRow({
    required this.testimonial,
    this.onApprove,
    this.onUnapprove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(testimonial.name,
                    style: AppFonts.body(size: 14.5, weight: FontWeight.w700, color: colors.cream)),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < testimonial.rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 14,
                    color: colors.orchid,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(testimonial.quote, style: AppFonts.body(size: 13.5, color: colors.creamDim)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onApprove != null)
                TextButton.icon(
                  onPressed: onApprove,
                  icon: Icon(Icons.check_circle_outline_rounded, size: 18, color: colors.success),
                  label: Text('Approve', style: AppFonts.body(size: 13, color: colors.success)),
                ),
              if (onUnapprove != null)
                TextButton.icon(
                  onPressed: onUnapprove,
                  icon: Icon(Icons.visibility_off_outlined, size: 18, color: colors.creamDim),
                  label: Text('Unpublish', style: AppFonts.body(size: 13, color: colors.creamDim)),
                ),
              TextButton.icon(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, size: 18, color: colors.danger),
                label: Text('Delete', style: AppFonts.body(size: 13, color: colors.danger)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
