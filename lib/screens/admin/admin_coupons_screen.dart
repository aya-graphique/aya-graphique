import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import '../../models/coupon.dart';
import '../../services/coupons_repository.dart';
import '../../theme/app_theme.dart';

/// Discount codes: where the store owner creates, edits, pauses and
/// deletes the codes shoppers type in at checkout. Reads/writes the
/// `coupons` table (signed-in admin only — see supabase/coupons.sql).
class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  List<Coupon>? _coupons;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final coupons = await CouponsRepository.fetchAll();
      if (!mounted) return;
      setState(() {
        _coupons = coupons;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _openForm({Coupon? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colorsRead.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: _CouponForm(existing: existing),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _toggleActive(Coupon coupon) async {
    final next = !coupon.isActive;
    try {
      await CouponsRepository.setActive(coupon.id, next);
      if (!mounted) return;
      setState(() {
        _coupons = _coupons?.map((c) => c.id == coupon.id ? c.copyWith(isActive: next) : c).toList();
      });
    } catch (e) {
      _snack('Couldn\'t update the code: $e');
    }
  }

  Future<void> _delete(Coupon coupon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text('Delete ${coupon.code}?',
            style: AppFonts.body(size: 16, weight: FontWeight.w700, color: context.colors.cream)),
        content: Text(
          'The code stops working right away. Orders that already used it keep their discount. '
          'If you only want to pause it, switch it off instead.',
          style: AppFonts.body(size: 13.5, color: context.colors.creamDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel', style: AppFonts.body(size: 13.5, color: context.colors.creamDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Delete',
                style: AppFonts.body(size: 13.5, weight: FontWeight.w700, color: context.colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await CouponsRepository.delete(coupon.id);
      if (!mounted) return;
      setState(() => _coupons = _coupons?.where((c) => c.id != coupon.id).toList());
    } catch (e) {
      _snack('Couldn\'t delete the code: $e');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // The admin dashboard always stays in English (see AdminOrdersScreen).
    AppFonts.forceArabic = false;
    final coupons = _coupons ?? [];
    final liveCount = coupons.where((c) => c.status == CouponStatus.active).length;

    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      appBar: AppBar(
        backgroundColor: context.colors.bgDeep,
        elevation: 0,
        title: Text('Discount codes',
            style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: _load,
            icon: Icon(Icons.refresh_rounded, color: context.colors.creamDim),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: context.colors.violetPop,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('New code', style: AppFonts.label(size: 13, color: Colors.white, letterSpacing: 1.0)),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: context.colors.orchid))
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _load)
              : coupons.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sell_outlined, size: 44, color: context.colors.creamDim),
                            const SizedBox(height: 14),
                            Text(
                              'No discount codes yet.\nTap "New code" to create your first one.',
                              textAlign: TextAlign.center,
                              style: AppFonts.body(size: 14, color: context.colors.creamDim),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: context.colors.orchid,
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: coupons.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2, left: 4),
                              child: Text(
                                '$liveCount active · ${coupons.length} total',
                                style: AppFonts.body(size: 12.5, color: context.colors.creamDim),
                              ),
                            );
                          }
                          final coupon = coupons[i - 1];
                          return _CouponTile(
                            coupon: coupon,
                            onEdit: () => _openForm(existing: coupon),
                            onToggle: () => _toggleActive(coupon),
                            onDelete: () => _delete(coupon),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final text = error.toString();
    // The most likely first-run problem: the SQL hasn't been run yet.
    final missingTable = text.contains('coupons') &&
        (text.contains('42P01') || text.contains('PGRST205') || text.contains('does not exist') || text.contains('schema cache'));
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              missingTable
                  ? 'The coupons table isn\'t set up yet.\nRun supabase/coupons.sql in the Supabase SQL editor, then refresh.'
                  : 'Couldn\'t load discount codes: $text',
              textAlign: TextAlign.center,
              style: AppFonts.body(size: 13.5, color: context.colors.danger),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again',
                  style: AppFonts.body(size: 13.5, weight: FontWeight.w700, color: context.colors.orchidSoft)),
            ),
          ],
        ),
      ),
    );
  }
}

String _num(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

class _CouponTile extends StatelessWidget {
  final Coupon coupon;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _CouponTile({
    required this.coupon,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  String get _discountText {
    if (coupon.type == CouponType.fixed) return '${_num(coupon.value)} EGP off';
    final cap = coupon.maxDiscount == null ? '' : ' (up to ${_num(coupon.maxDiscount!)} EGP)';
    return '${_num(coupon.value)}% off$cap';
  }

  String get _rulesText {
    final parts = <String>[];
    parts.add(coupon.minOrder > 0 ? 'min order ${_num(coupon.minOrder)} EGP' : 'no minimum');
    final fmt = DateFormat('d MMM yyyy');
    if (coupon.startDate != null && coupon.endDate != null) {
      parts.add('${fmt.format(coupon.startDate!)} → ${fmt.format(coupon.endDate!)}');
    } else if (coupon.startDate != null) {
      parts.add('from ${fmt.format(coupon.startDate!)}');
    } else if (coupon.endDate != null) {
      parts.add('until ${fmt.format(coupon.endDate!)}');
    } else {
      parts.add('no end date');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = coupon.status;
    final (statusLabel, statusColor) = switch (status) {
      CouponStatus.active => ('Active', colors.success),
      CouponStatus.inactive => ('Paused', colors.creamDim),
      CouponStatus.scheduled => ('Scheduled', colors.orchidSoft),
      CouponStatus.expired => ('Expired', colors.danger),
      CouponStatus.exhausted => ('Used up', colors.danger),
    };
    final dim = status != CouponStatus.active;
    final maxUses = coupon.maxUses;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border(0.06)),
      ),
      child: Opacity(
        opacity: dim ? 0.75 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    coupon.code,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.display(color: colors.cream, size: 18, weight: FontWeight.w800)
                        .copyWith(letterSpacing: 1.2),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Copy code',
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: coupon.code));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied ${coupon.code}'), duration: const Duration(seconds: 1)),
                    );
                  },
                  icon: Icon(Icons.copy_rounded, size: 16, color: colors.creamDim),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(statusLabel,
                      style: AppFonts.body(size: 11.5, weight: FontWeight.w700, color: statusColor)),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 2),
            Text(_discountText,
                style: AppFonts.body(size: 14, weight: FontWeight.w600, color: colors.orchidSoft)),
            const SizedBox(height: 4),
            Text(_rulesText, style: AppFonts.body(size: 12.5, color: colors.creamDim)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  Text(
                    maxUses == null
                        ? 'Used ${coupon.usedCount} times'
                        : 'Used ${coupon.usedCount} / $maxUses',
                    style: AppFonts.body(size: 12.5, color: colors.cream),
                  ),
                  if (maxUses != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: (coupon.usedCount / maxUses).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: colors.surfaceRaised,
                          color: colors.orchid,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Switch(
                  value: coupon.isActive,
                  onChanged: (_) => onToggle(),
                  activeColor: colors.orchid,
                ),
                Text(coupon.isActive ? 'On' : 'Off',
                    style: AppFonts.body(size: 12.5, color: colors.creamDim)),
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  icon: Icon(Icons.edit_outlined, size: 20, color: colors.creamDim),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  icon: Icon(Icons.delete_outline_rounded, size: 20, color: colors.danger),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet form for creating a new code or editing an existing one.
class _CouponForm extends StatefulWidget {
  final Coupon? existing;
  const _CouponForm({this.existing});

  @override
  State<_CouponForm> createState() => _CouponFormState();
}

class _CouponFormState extends State<_CouponForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _value;
  late final TextEditingController _minOrder;
  late final TextEditingController _maxDiscount;
  late final TextEditingController _maxUses;
  late CouponType _type;
  DateTime? _start;
  DateTime? _end;
  bool _active = true;
  bool _saving = false;
  String? _serverError;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _code = TextEditingController(text: c?.code ?? '');
    _value = TextEditingController(text: c == null ? '' : _num(c.value));
    _minOrder = TextEditingController(text: (c == null || c.minOrder == 0) ? '' : _num(c.minOrder));
    _maxDiscount = TextEditingController(text: c?.maxDiscount == null ? '' : _num(c!.maxDiscount!));
    _maxUses = TextEditingController(text: c?.maxUses == null ? '' : '${c!.maxUses}');
    _type = c?.type ?? CouponType.percent;
    _start = c?.startDate;
    _end = c?.endDate;
    _active = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _code.dispose();
    _value.dispose();
    _minOrder.dispose();
    _maxDiscount.dispose();
    _maxUses.dispose();
    super.dispose();
  }

  double? _parse(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

  void _generate() {
    // No 0/O or 1/I so a code read out loud or typed on a phone can't be mixed up.
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    _code.text = List.generate(8, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<void> _pickDate({required bool start}) async {
    final now = DateTime.now();
    final initial = (start ? _start : _end) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() => start ? _start = picked : _end = picked);
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_start != null && _end != null && _end!.isBefore(_start!)) {
      setState(() => _serverError = 'The end date must be on or after the start date.');
      return;
    }

    final coupon = Coupon(
      id: widget.existing?.id ?? '',
      code: _code.text.trim().toUpperCase(),
      type: _type,
      value: _parse(_value.text)!,
      minOrder: _parse(_minOrder.text) ?? 0,
      maxDiscount: _type == CouponType.percent ? _parse(_maxDiscount.text) : null,
      maxUses: int.tryParse(_maxUses.text.trim()),
      startDate: _start,
      endDate: _end,
      isActive: _active,
    );

    setState(() => _saving = true);
    try {
      if (_editing) {
        await CouponsRepository.update(widget.existing!.id, coupon);
      } else {
        await CouponsRepository.create(coupon);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _serverError = e.code == '23505'
            ? 'A code named ${coupon.code} already exists. Pick another name.'
            : (e.code == '42P01' || e.code == 'PGRST205')
                ? 'The coupons table isn\'t set up yet. Run supabase/coupons.sql first.'
                : 'Couldn\'t save: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _serverError = 'Couldn\'t save: $e';
      });
    }
  }

  InputDecoration _decoration(String label, {String? hint, String? suffix}) {
    final colors = context.colors;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      labelStyle: AppFonts.body(color: colors.creamDim, size: 13.5),
      hintStyle: AppFonts.body(color: colors.creamDim.withOpacity(0.6), size: 13.5),
      suffixStyle: AppFonts.body(color: colors.creamDim, size: 13),
      isDense: true,
      filled: true,
      fillColor: colors.surfaceRaised,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.orchid, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.danger, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.danger, width: 1.4),
      ),
    );
  }

  TextStyle get _inputStyle => AppFonts.body(size: 14.5, color: context.colors.cream);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fmt = DateFormat('d MMM yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_editing ? 'Edit code' : 'New discount code',
                      style: AppFonts.display(color: colors.cream, size: 20, weight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: Icon(Icons.close_rounded, color: colors.creamDim),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Code + generator
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _code,
                    style: _inputStyle.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
                      LengthLimitingTextInputFormatter(24),
                      TextInputFormatter.withFunction(
                        (old, next) => next.copyWith(text: next.text.toUpperCase()),
                      ),
                    ],
                    decoration: _decoration('Code', hint: 'e.g. RAMADAN20'),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.length < 3) return 'At least 3 characters';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: OutlinedButton.icon(
                    onPressed: _generate,
                    icon: Icon(Icons.casino_outlined, size: 18, color: colors.orchidSoft),
                    label: Text('Generate',
                        style: AppFonts.body(size: 12.5, weight: FontWeight.w700, color: colors.orchidSoft)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      side: BorderSide(color: colors.border(0.15)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type
            Row(
              children: [
                Expanded(
                  child: _TypeOption(
                    label: 'Percentage',
                    icon: Icons.percent_rounded,
                    selected: _type == CouponType.percent,
                    onTap: () => setState(() => _type = CouponType.percent),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TypeOption(
                    label: 'Fixed amount',
                    icon: Icons.payments_outlined,
                    selected: _type == CouponType.fixed,
                    onTap: () => setState(() => _type = CouponType.fixed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _value,
              style: _inputStyle,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _decoration(
                _type == CouponType.percent ? 'Discount percentage' : 'Discount amount',
                suffix: _type == CouponType.percent ? '%' : 'EGP',
              ),
              validator: (v) {
                final n = _parse(v ?? '');
                if (n == null || n <= 0) return 'Enter a number above 0';
                if (_type == CouponType.percent && n > 100) return 'A percentage can\'t be above 100';
                return null;
              },
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minOrder,
                    style: _inputStyle,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _decoration('Minimum order', hint: 'None', suffix: 'EGP'),
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) return null;
                      final n = _parse(v!);
                      return (n == null || n < 0) ? 'Invalid amount' : null;
                    },
                  ),
                ),
                if (_type == CouponType.percent) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxDiscount,
                      style: _inputStyle,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _decoration('Max discount', hint: 'No cap', suffix: 'EGP'),
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) return null;
                        final n = _parse(v!);
                        return (n == null || n <= 0) ? 'Invalid amount' : null;
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _maxUses,
              style: _inputStyle,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _decoration('Max number of uses', hint: 'Unlimited'),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return null;
                final n = int.tryParse(v!.trim());
                return (n == null || n < 1) ? 'Enter 1 or more, or leave empty' : null;
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Starts',
                    value: _start == null ? null : fmt.format(_start!),
                    onTap: () => _pickDate(start: true),
                    onClear: () => setState(() => _start = null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Ends',
                    value: _end == null ? null : fmt.format(_end!),
                    onTap: () => _pickDate(start: false),
                    onClear: () => setState(() => _end = null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Leave the dates empty for a code that never expires. The end date is included.',
                style: AppFonts.body(size: 11.5, color: colors.creamDim)),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              activeColor: colors.orchid,
              title: Text('Active', style: AppFonts.body(size: 14.5, color: colors.cream)),
              subtitle: Text('Switch off to pause the code without deleting it.',
                  style: AppFonts.body(size: 12, color: colors.creamDim)),
            ),
            if (_serverError != null) ...[
              const SizedBox(height: 6),
              Text(_serverError!, style: AppFonts.body(size: 13, color: colors.danger)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: colors.violetGradient,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text(_editing ? 'Save changes' : 'Create code',
                            style: AppFonts.label(size: 13.5, color: Colors.white, letterSpacing: 1.0)
                                .copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _TypeOption({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? colors.orchid.withOpacity(0.14) : colors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colors.orchid : colors.border(0.08),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? colors.orchidSoft : colors.creamDim),
            const SizedBox(width: 8),
            Text(label,
                style: AppFonts.body(
                  size: 13.5,
                  weight: FontWeight.w700,
                  color: selected ? colors.cream : colors.creamDim,
                )),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const _DateField({required this.label, required this.value, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppFonts.body(size: 11.5, color: colors.creamDim)),
                  const SizedBox(height: 2),
                  Text(value ?? 'Not set',
                      style: AppFonts.body(
                        size: 13.5,
                        weight: FontWeight.w600,
                        color: value == null ? colors.creamDim : colors.cream,
                      )),
                ],
              ),
            ),
            if (value != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
                icon: Icon(Icons.close_rounded, size: 18, color: colors.creamDim),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.calendar_today_outlined, size: 16, color: colors.creamDim),
              ),
          ],
        ),
      ),
    );
  }
}
