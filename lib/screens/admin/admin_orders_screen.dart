import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/orders_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';

enum _OrderFilter { all, pending, completed }

/// Where the store owner actually sees orders customers have placed.
/// Reads straight from Supabase's `orders` + `order_items` tables (RLS only
/// allows this for a signed-in admin), newest first. Lets the owner mark an
/// order done once it's been fulfilled/shipped, and filter by that status.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Order>? _orders;
  bool _loading = true;
  Object? _error;
  _OrderFilter _filter = _OrderFilter.all;

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
      final orders = await OrdersRepository.fetchAll();
      if (!mounted) return;
      setState(() {
        _orders = orders;
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

  Future<void> _toggleCompleted(Order order) async {
    await OrdersRepository.setCompleted(order.id, !order.isCompleted);
    if (!mounted) return;
    // Patch the change straight into the cached list instead of a full
    // refetch, so the toggle feels instant.
    setState(() {
      _orders = _orders
          ?.map((o) => o.id == order.id ? o.copyWith(isCompleted: !order.isCompleted) : o)
          .toList();
    });
  }

  Future<void> _deleteOrder(Order order) async {
    await OrdersRepository.delete(order.id);
    if (!mounted) return;
    setState(() {
      _orders = _orders?.where((o) => o.id != order.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // The storefront's Arabic-font toggle sets a global static flag
    // (AppFonts.forceArabic). The admin dashboard never offers that
    // toggle and always stays in English, so force it off here on every
    // build regardless of what a shopper picked on the storefront.
    AppFonts.forceArabic = false;
    final orders = _orders ?? [];
    final pendingCount = orders.where((o) => !o.isCompleted).length;
    final visibleOrders = switch (_filter) {
      _OrderFilter.all => orders,
      _OrderFilter.pending => orders.where((o) => !o.isCompleted).toList(),
      _OrderFilter.completed => orders.where((o) => o.isCompleted).toList(),
    };

    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      appBar: AppBar(
        backgroundColor: context.colors.bgDeep,
        elevation: 0,
        title: Text('Orders', style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: _load,
            icon: Icon(Icons.refresh_rounded, color: context.colors.creamDim),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: context.colors.orchid))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Couldn\'t load orders: $_error',
                      textAlign: TextAlign.center,
                      style: AppFonts.body(size: 13.5, color: context.colors.danger),
                    ),
                  ),
                )
              : orders.isEmpty
                  ? Center(
                      child: Text('No orders yet — they\'ll show up here as customers check out.',
                          style: AppFonts.body(size: 14, color: context.colors.creamDim)),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected: _filter == _OrderFilter.all,
                                onTap: () => setState(() => _filter = _OrderFilter.all),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: pendingCount == 0 ? 'Pending' : 'Pending ($pendingCount)',
                                selected: _filter == _OrderFilter.pending,
                                onTap: () => setState(() => _filter = _OrderFilter.pending),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Completed',
                                selected: _filter == _OrderFilter.completed,
                                onTap: () => setState(() => _filter = _OrderFilter.completed),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: visibleOrders.isEmpty
                              ? Center(
                                  child: Text(
                                    _filter == _OrderFilter.pending
                                        ? 'No pending orders — you\'re all caught up.'
                                        : 'No orders here yet.',
                                    style: AppFonts.body(size: 14, color: context.colors.creamDim),
                                  ),
                                )
                              : RefreshIndicator(
                                  color: context.colors.orchid,
                                  onRefresh: _load,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                                    itemCount: visibleOrders.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                                    itemBuilder: (context, i) => _OrderTile(
                                      order: visibleOrders[i],
                                      onToggleCompleted: _toggleCompleted,
                                      onDeleteOrder: _deleteOrder,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? context.colors.violetGradient : null,
          color: selected ? null : context.colors.surfaceRaised,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? Colors.transparent : context.colors.cream.withOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: AppFonts.label(color: context.colors.orchid, size: 11.5, letterSpacing: 0.4)
              .copyWith(color: selected ? Colors.white : context.colors.creamDim, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _OrderTile extends StatefulWidget {
  final Order order;
  final Future<void> Function(Order order) onToggleCompleted;
  final Future<void> Function(Order order) onDeleteOrder;
  const _OrderTile({required this.order, required this.onToggleCompleted, required this.onDeleteOrder});

  @override
  State<_OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<_OrderTile> {
  bool _expanded = false;
  bool _toggling = false;
  bool _deleting = false;

  Future<void> _handleToggle() async {
    setState(() => _toggling = true);
    try {
      await widget.onToggleCompleted(widget.order);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t update order: $e')),
      );
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text('Delete this order?', style: AppFonts.body(size: 16, weight: FontWeight.w700, color: context.colors.cream)),
        content: Text(
          'This permanently removes the order and its items from the database. This can\'t be undone.',
          style: AppFonts.body(size: 13.5, color: context.colors.creamDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel', style: AppFonts.body(size: 13.5, color: context.colors.creamDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Delete', style: AppFonts.body(size: 13.5, weight: FontWeight.w700, color: context.colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      await widget.onDeleteOrder(widget.order);
      // No setState after this: on success the parent removes this order
      // from its list, which unmounts this tile entirely.
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t delete order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: o.isCompleted ? context.colors.success.withOpacity(0.25) : context.colors.cream.withOpacity(0.06),
        ),
      ),
      child: Opacity(
        opacity: o.isCompleted ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  o.fullName.isEmpty ? 'Unnamed customer' : o.fullName,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.body(size: 15, weight: FontWeight.w700, color: context.colors.cream),
                                ),
                              ),
                              if (o.isCompleted) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.check_circle_rounded, size: 15, color: context.colors.success),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(o.email, style: AppFonts.body(size: 12.5, color: context.colors.creamDim)),
                          const SizedBox(height: 2),
                          Text(_formatDate(o.createdAt),
                              style: AppFonts.body(size: 11.5, color: context.colors.creamDim)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatPrice(o.total),
                            style: AppFonts.body(size: 15, weight: FontWeight.w700, color: context.colors.orchidSoft)),
                        const SizedBox(height: 4),
                        Text('${o.items.length} item${o.items.length == 1 ? '' : 's'}',
                            style: AppFonts.body(size: 11.5, color: context.colors.creamDim)),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: context.colors.creamDim,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: context.colors.cream.withOpacity(0.12), height: 1),
                    const SizedBox(height: 12),
                    Text('Phone', style: AppFonts.label(color: context.colors.orchid, size: 10.5, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text(
                      o.phone2.isEmpty ? o.phone1 : '${o.phone1}  ·  ${o.phone2}',
                      style: AppFonts.body(size: 13, color: context.colors.cream),
                    ),
                    const SizedBox(height: 16),
                    Text('Payment', style: AppFonts.label(color: context.colors.orchid, size: 10.5, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text(
                      switch (o.paymentMethod) {
                        'instapay' => 'InstaPay',
                        'vodafone_cash' => 'Vodafone Cash',
                        'transfer' => 'Vodafone Cash / InstaPay transfer', // legacy orders
                        _ => 'Cash on delivery',
                      },
                      style: AppFonts.body(size: 13, color: context.colors.cream),
                    ),
                    const SizedBox(height: 16),
                    Text('Shipping address', style: AppFonts.label(color: context.colors.orchid, size: 10.5, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text(o.address, style: AppFonts.body(size: 13, color: context.colors.cream)),
                    const SizedBox(height: 16),
                    Text('Items', style: AppFonts.label(color: context.colors.orchid, size: 10.5, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    ...o.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${item.quantity} × ${item.productName}',
                                    style: AppFonts.body(size: 13, color: context.colors.cream)),
                              ),
                              Text(formatPrice(item.lineTotal),
                                  style: AppFonts.body(size: 13, color: context.colors.creamDim)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                    Divider(color: context.colors.cream.withOpacity(0.12), height: 1),
                    const SizedBox(height: 8),
                    _summaryRow('Subtotal', formatPrice(o.subtotal)),
                    _summaryRow('Shipping', formatPrice(o.shipping)),
                    _summaryRow('Total', formatPrice(o.total), emphasize: true),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _toggling ? null : _handleToggle,
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: o.isCompleted ? null : context.colors.violetGradient,
                            color: o.isCompleted ? context.colors.surfaceRaised : null,
                            borderRadius: BorderRadius.circular(100),
                            border: o.isCompleted
                                ? Border.all(color: context.colors.cream.withOpacity(0.1))
                                : null,
                          ),
                          child: Center(
                            child: _toggling
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    o.isCompleted ? 'Mark as pending' : 'Mark as done',
                                    style: AppFonts.label(
                                      size: 12.5,
                                      color: o.isCompleted ? context.colors.creamDim : Colors.white,
                                      letterSpacing: 1.0,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if (o.isCompleted) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _deleting ? null : _handleDelete,
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: context.colors.danger.withOpacity(0.4)),
                            ),
                            child: Center(
                              child: _deleting
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.danger),
                                    )
                                  : Text(
                                      'Delete order',
                                      style: AppFonts.label(size: 12.5, color: context.colors.danger, letterSpacing: 1.0)
                                          .copyWith(fontWeight: FontWeight.w700),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppFonts.body(size: 12.5, color: context.colors.creamDim)),
          Text(
            value,
            style: AppFonts.body(
              size: 12.5,
              weight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color: emphasize ? context.colors.cream : context.colors.creamDim,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${local.day}, ${local.year} · $hour:$minute $ampm';
  }
}
