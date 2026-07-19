import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/supabase_config.dart';
import '../../models/home_banner.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/auth_service.dart';
import '../../services/categories_repository.dart';
import '../../services/orders_repository.dart';
import '../../services/products_repository.dart';
import '../../services/settings_repository.dart';
import '../../services/storage_service.dart';
import '../../services/testimonials_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency.dart';
import 'admin_home_banners_screen.dart';
import 'admin_illustration_art_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_product_form_screen.dart';
import 'admin_services_screen.dart';
import 'admin_testimonials_screen.dart';

/// The client's product management screen: everything they need to run
/// their own catalog without touching Supabase directly — add products,
/// edit price/category/stock/description, delete discontinued items, and
/// create brand new categories just by typing a new name in the form.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<Product>> _productsFuture;
  bool _isLive = true;

  List<CategoryItem> _categories = [];
  bool _loadingCategories = true;
  String? _uploadingCategoryImage;
  final _shippingController = TextEditingController();
  bool _loadingShipping = true;
  bool _savingShipping = false;
  String? _shippingError;

  final _notificationEmailController = TextEditingController();
  bool _loadingNotificationEmail = true;
  bool _savingNotificationEmail = false;
  String? _notificationEmailError;

  final _ownerWhatsappController = TextEditingController();
  bool _loadingOwnerWhatsapp = true;
  bool _savingOwnerWhatsapp = false;
  String? _ownerWhatsappError;

  final _paymentNumberController = TextEditingController();
  bool _loadingPaymentNumber = true;
  bool _savingPaymentNumber = false;
  String? _paymentNumberError;

  final _instapayLinkController = TextEditingController();
  bool _loadingInstapayLink = true;
  bool _savingInstapayLink = false;
  String? _instapayLinkError;

  int _pendingOrdersCount = 0;
  int _pendingTestimonialsCount = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
    _loadCategories();
    _loadShipping();
    _loadNotificationEmail();
    _loadOwnerWhatsapp();
    _loadPaymentNumber();
    _loadInstapayLink();
    _loadPendingOrdersCount();
    _loadPendingTestimonialsCount();
  }

  @override
  void dispose() {
    _shippingController.dispose();
    _notificationEmailController.dispose();
    _ownerWhatsappController.dispose();
    _paymentNumberController.dispose();
    _instapayLinkController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _productsFuture = ProductsRepository.fetchAll().then((products) {
        _isLive = ProductsRepository.lastFetchWasLive;
        return products;
      });
    });
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    final categories = await CategoriesRepository.fetchAllWithImages();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _loadingCategories = false;
    });
  }

  Future<void> _loadShipping() async {
    setState(() => _loadingShipping = true);
    final cost = await SettingsRepository.fetchShippingCost();
    if (!mounted) return;
    setState(() {
      _shippingController.text = cost.toStringAsFixed(2);
      _loadingShipping = false;
    });
  }

  Future<void> _saveShipping() async {
    final value = double.tryParse(_shippingController.text.trim());
    if (value == null || value < 0) {
      setState(() => _shippingError = 'Enter a valid shipping cost.');
      return;
    }
    setState(() {
      _savingShipping = true;
      _shippingError = null;
    });
    try {
      await SettingsRepository.updateShippingCost(value);
      if (!mounted) return;
      // Update the live cart immediately so the new fee applies without
      // needing a page reload.
      context.read<CartProvider>().applyShipping(value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shipping cost updated.')),
      );
    } catch (e) {
      setState(() => _shippingError = 'Couldn\'t save: $e');
    } finally {
      if (mounted) setState(() => _savingShipping = false);
    }
  }

  Future<void> _loadNotificationEmail() async {
    setState(() => _loadingNotificationEmail = true);
    final email = await SettingsRepository.fetchNotificationEmail();
    if (!mounted) return;
    setState(() {
      _notificationEmailController.text = email;
      _loadingNotificationEmail = false;
    });
  }

  Future<void> _saveNotificationEmail() async {
    final value = _notificationEmailController.text.trim();
    if (value.isNotEmpty && (!value.contains('@') || !value.contains('.'))) {
      setState(() => _notificationEmailError = 'Enter a valid email.');
      return;
    }
    setState(() {
      _savingNotificationEmail = true;
      _notificationEmailError = null;
    });
    try {
      await SettingsRepository.updateNotificationEmail(value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification email updated.')),
      );
    } catch (e) {
      setState(() => _notificationEmailError = 'Couldn\'t save: $e');
    } finally {
      if (mounted) setState(() => _savingNotificationEmail = false);
    }
  }

  Future<void> _loadOwnerWhatsapp() async {
    setState(() => _loadingOwnerWhatsapp = true);
    final value = await SettingsRepository.fetchOwnerWhatsapp();
    if (!mounted) return;
    setState(() {
      _ownerWhatsappController.text = value;
      _loadingOwnerWhatsapp = false;
    });
  }

  Future<void> _saveOwnerWhatsapp() async {
    final value = _ownerWhatsappController.text.trim();
    if (value.isNotEmpty && !RegExp(r'^[0-9]{8,15}$').hasMatch(value)) {
      setState(() => _ownerWhatsappError =
          'Digits only, with country code, no "+" or spaces (e.g. 201234567890).');
      return;
    }
    setState(() {
      _savingOwnerWhatsapp = true;
      _ownerWhatsappError = null;
    });
    try {
      await SettingsRepository.updateOwnerWhatsapp(value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp number updated.')),
      );
    } catch (e) {
      setState(() => _ownerWhatsappError = 'Couldn\'t save: $e');
    } finally {
      if (mounted) setState(() => _savingOwnerWhatsapp = false);
    }
  }

  Future<void> _loadPaymentNumber() async {
    setState(() => _loadingPaymentNumber = true);
    final value = await SettingsRepository.fetchPaymentNumber();
    if (!mounted) return;
    setState(() {
      _paymentNumberController.text = value;
      _loadingPaymentNumber = false;
    });
  }

  Future<void> _savePaymentNumber() async {
    setState(() {
      _savingPaymentNumber = true;
      _paymentNumberError = null;
    });
    try {
      await SettingsRepository.updatePaymentNumber(_paymentNumberController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vodafone Cash number updated.')),
      );
    } catch (e) {
      setState(() => _paymentNumberError = 'Couldn\'t save: $e');
    } finally {
      if (mounted) setState(() => _savingPaymentNumber = false);
    }
  }

  Future<void> _loadInstapayLink() async {
    setState(() => _loadingInstapayLink = true);
    final value = await SettingsRepository.fetchInstapayLink();
    if (!mounted) return;
    setState(() {
      _instapayLinkController.text = value;
      _loadingInstapayLink = false;
    });
  }

  Future<void> _saveInstapayLink() async {
    setState(() {
      _savingInstapayLink = true;
      _instapayLinkError = null;
    });
    try {
      await SettingsRepository.updateInstapayLink(_instapayLinkController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('InstaPay link updated.')),
      );
    } catch (e) {
      setState(() => _instapayLinkError = 'Couldn\'t save: $e');
    } finally {
      if (mounted) setState(() => _savingInstapayLink = false);
    }
  }

  Future<void> _setCategoryImage(String name) async {
    if (!SupabaseConfig.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect Supabase first (see lib/config/supabase_config.dart).')),
      );
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // loads bytes directly, works on web + mobile + desktop
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t read that file. Try a different photo.')),
      );
      return;
    }

    setState(() => _uploadingCategoryImage = name);
    try {
      final url = await StorageService.uploadCategoryImage(bytes, file.name);
      await CategoriesRepository.setImage(name, url);
      await _loadCategories();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t update category image: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploadingCategoryImage = null);
    }
  }

  Future<void> _deleteCategory(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        title: Text('Delete "$name"?', style: AppFonts.body(size: 16, color: context.colors.cream)),
        content: Text(
          'This deletes every product filed under "$name" too — not just '
          'the category. This can\'t be undone.',
          style: AppFonts.body(size: 13, color: context.colors.creamDim),
        ),
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
      await CategoriesRepository.delete(name);
      _loadCategories();
      // The category's products are gone from the database too now, so the
      // product list (and its "X products" count) needs refreshing, not
      // just the category chips.
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t delete category: $e')),
      );
    }
  }

  Future<void> _openForm({Product? product}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminProductFormScreen(existing: product)),
    );
    if (changed == true) _refresh();
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        title: Text('Delete "${product.name}"?', style: AppFonts.body(size: 16, color: context.colors.cream)),
        content: Text(
          'This can\'t be undone.',
          style: AppFonts.body(size: 13, color: context.colors.creamDim),
        ),
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
      await ProductsRepository.delete(product.id);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t delete: $e')),
      );
    }
  }

  Future<void> _loadPendingOrdersCount() async {
    final count = await OrdersRepository.countPending();
    if (!mounted) return;
    setState(() => _pendingOrdersCount = count);
  }

  Future<void> _openOrders() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
    );
    // The badge should reflect anything marked done/reopened while the
    // owner was on the Orders screen.
    _loadPendingOrdersCount();
  }

  Future<void> _loadPendingTestimonialsCount() async {
    final count = await TestimonialsRepository.countPending();
    if (!mounted) return;
    setState(() => _pendingTestimonialsCount = count);
  }

  Future<void> _openTestimonials() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminTestimonialsScreen()),
    );
    // The badge should reflect anything approved/deleted while the owner
    // was on the Testimonials screen.
    _loadPendingTestimonialsCount();
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  /// Below this width the dashboard swaps the AppBar's row of icons for a
  /// slide-out Drawer (hamburger menu) instead — there just isn't room for
  /// six icons across a phone-width AppBar.
  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < AppBreakpoints.mobile;

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: context.colors.bgDeep,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text('Store admin',
                  style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
            ),
            Divider(color: context.colors.border(0.1), height: 1),
            _DrawerTile(
              icon: Icons.view_carousel_outlined,
              label: 'Home banners',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminHomeBannersScreen()),
                );
              },
            ),
            _DrawerTile(
              icon: Icons.view_carousel_rounded,
              label: 'Most Ordered banners',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminHomeBannersScreen(
                      placement: HomeBannerPlacement.mostOrdered,
                      title: 'Most Ordered banners',
                    ),
                  ),
                );
              },
            ),
            _DrawerTile(
              icon: Icons.design_services_outlined,
              label: 'Services',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminServicesScreen()),
                );
              },
            ),
            _DrawerTile(
              icon: Icons.brush_outlined,
              label: 'Illustration & Art',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminIllustrationArtScreen()),
                );
              },
            ),
            _DrawerTile(
              icon: Icons.rate_review_outlined,
              label: 'Testimonials',
              badgeCount: _pendingTestimonialsCount,
              onTap: () {
                Navigator.of(context).pop();
                _openTestimonials();
              },
            ),
            _DrawerTile(
              icon: Icons.receipt_long_rounded,
              label: 'Orders',
              badgeCount: _pendingOrdersCount,
              onTap: () {
                Navigator.of(context).pop();
                _openOrders();
              },
            ),
            Divider(color: context.colors.border(0.1), height: 1),
            _DrawerTile(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              iconColor: context.colors.danger,
              onTap: () {
                Navigator.of(context).pop();
                _signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The storefront's Arabic-font toggle sets a global static flag
    // (AppFonts.forceArabic). The admin dashboard never offers that
    // toggle and always stays in English, so force it off here on every
    // build regardless of what a shopper picked on the storefront.
    AppFonts.forceArabic = false;
    final isMobile = _isMobile(context);
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      drawer: isMobile ? _buildDrawer(context) : null,
      appBar: AppBar(
        backgroundColor: context.colors.bgDeep,
        elevation: 0,
        title: Text('Store admin', style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
        actions: isMobile
            ? null
            : [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminHomeBannersScreen()),
            ),
            icon: Icon(Icons.view_carousel_outlined, color: context.colors.creamDim),
            tooltip: 'Home banners',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminHomeBannersScreen(
                  placement: HomeBannerPlacement.mostOrdered,
                  title: 'Most Ordered banners',
                ),
              ),
            ),
            icon: Icon(Icons.view_carousel_rounded, color: context.colors.creamDim),
            tooltip: 'Most Ordered banners',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminServicesScreen()),
            ),
            icon: Icon(Icons.design_services_outlined, color: context.colors.creamDim),
            tooltip: 'Services',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminIllustrationArtScreen()),
            ),
            icon: Icon(Icons.brush_outlined, color: context.colors.creamDim),
            tooltip: 'Illustration & Art',
          ),
          IconButton(
            onPressed: _openTestimonials,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.rate_review_outlined, color: context.colors.creamDim),
                if (_pendingTestimonialsCount > 0)
                  Positioned(
                    right: -4,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      decoration: BoxDecoration(
                        color: context.colors.danger,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: context.colors.bgDeep, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _pendingTestimonialsCount > 99 ? '99+' : '$_pendingTestimonialsCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Testimonials',
          ),
          IconButton(
            onPressed: _openOrders,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.receipt_long_rounded, color: context.colors.creamDim),
                if (_pendingOrdersCount > 0)
                  Positioned(
                    right: -4,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      decoration: BoxDecoration(
                        color: context.colors.danger,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: context.colors.bgDeep, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _pendingOrdersCount > 99 ? '99+' : '$_pendingOrdersCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Orders',
          ),
          IconButton(
            onPressed: _signOut,
            icon: Icon(Icons.logout_rounded, color: context.colors.creamDim),
            tooltip: 'Sign out',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: context.colors.violetPop,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add product',
            style: AppFonts.label(size: 13, color: Colors.white, letterSpacing: 1.0)),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: context.colors.orchid));
          }
          final products = snapshot.data ?? [];
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _StoreSettingsPanel(
                  loadingCategories: _loadingCategories,
                  categories: _categories,
                  onDeleteCategory: _deleteCategory,
                  onSetCategoryImage: _setCategoryImage,
                  uploadingCategoryImage: _uploadingCategoryImage,
                  shippingController: _shippingController,
                  loadingShipping: _loadingShipping,
                  savingShipping: _savingShipping,
                  shippingError: _shippingError,
                  onSaveShipping: _saveShipping,
                  notificationEmailController: _notificationEmailController,
                  loadingNotificationEmail: _loadingNotificationEmail,
                  savingNotificationEmail: _savingNotificationEmail,
                  notificationEmailError: _notificationEmailError,
                  onSaveNotificationEmail: _saveNotificationEmail,
                  ownerWhatsappController: _ownerWhatsappController,
                  loadingOwnerWhatsapp: _loadingOwnerWhatsapp,
                  savingOwnerWhatsapp: _savingOwnerWhatsapp,
                  ownerWhatsappError: _ownerWhatsappError,
                  onSaveOwnerWhatsapp: _saveOwnerWhatsapp,
                  paymentNumberController: _paymentNumberController,
                  loadingPaymentNumber: _loadingPaymentNumber,
                  savingPaymentNumber: _savingPaymentNumber,
                  paymentNumberError: _paymentNumberError,
                  onSavePaymentNumber: _savePaymentNumber,
                  instapayLinkController: _instapayLinkController,
                  loadingInstapayLink: _loadingInstapayLink,
                  savingInstapayLink: _savingInstapayLink,
                  instapayLinkError: _instapayLinkError,
                  onSaveInstapayLink: _saveInstapayLink,
                ),
              ),
              if (!_isLive)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.orchid.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.colors.orchid.withOpacity(0.35)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: context.colors.orchid, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your Supabase "products" table is empty or unreachable, so '
                            'the storefront has no products to show right now. Tap "Add '
                            'product" to create your first one.',
                            style: AppFonts.body(size: 12.5, color: context.colors.cream),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('No products yet — tap "Add product" to create your first one.',
                        style: AppFonts.body(color: context.colors.creamDim, size: 14)),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverList.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = products[i];
                      return _ProductRow(
                        product: p,
                        editable: _isLive,
                        onEdit: () => _openForm(product: p),
                        onDelete: () => _delete(p),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Store-wide settings the admin can change without touching Supabase or
/// code: which categories show up as options, and the flat shipping fee.
class _StoreSettingsPanel extends StatefulWidget {
  final bool loadingCategories;
  final List<CategoryItem> categories;
  final ValueChanged<String> onDeleteCategory;
  final ValueChanged<String> onSetCategoryImage;
  final String? uploadingCategoryImage;
  final TextEditingController shippingController;
  final bool loadingShipping;
  final bool savingShipping;
  final String? shippingError;
  final VoidCallback onSaveShipping;
  final TextEditingController notificationEmailController;
  final bool loadingNotificationEmail;
  final bool savingNotificationEmail;
  final String? notificationEmailError;
  final VoidCallback onSaveNotificationEmail;
  final TextEditingController ownerWhatsappController;
  final bool loadingOwnerWhatsapp;
  final bool savingOwnerWhatsapp;
  final String? ownerWhatsappError;
  final VoidCallback onSaveOwnerWhatsapp;
  final TextEditingController paymentNumberController;
  final bool loadingPaymentNumber;
  final bool savingPaymentNumber;
  final String? paymentNumberError;
  final VoidCallback onSavePaymentNumber;
  final TextEditingController instapayLinkController;
  final bool loadingInstapayLink;
  final bool savingInstapayLink;
  final String? instapayLinkError;
  final VoidCallback onSaveInstapayLink;

  const _StoreSettingsPanel({
    required this.loadingCategories,
    required this.categories,
    required this.onDeleteCategory,
    required this.onSetCategoryImage,
    required this.uploadingCategoryImage,
    required this.shippingController,
    required this.loadingShipping,
    required this.savingShipping,
    required this.shippingError,
    required this.onSaveShipping,
    required this.notificationEmailController,
    required this.loadingNotificationEmail,
    required this.savingNotificationEmail,
    required this.notificationEmailError,
    required this.onSaveNotificationEmail,
    required this.ownerWhatsappController,
    required this.loadingOwnerWhatsapp,
    required this.savingOwnerWhatsapp,
    required this.ownerWhatsappError,
    required this.onSaveOwnerWhatsapp,
    required this.paymentNumberController,
    required this.loadingPaymentNumber,
    required this.savingPaymentNumber,
    required this.paymentNumberError,
    required this.onSavePaymentNumber,
    required this.instapayLinkController,
    required this.loadingInstapayLink,
    required this.savingInstapayLink,
    required this.instapayLinkError,
    required this.onSaveInstapayLink,
  });

  @override
  State<_StoreSettingsPanel> createState() => _StoreSettingsPanelState();
}

class _StoreSettingsPanelState extends State<_StoreSettingsPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border(0.06)),
      ),
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
                  Icon(Icons.tune_rounded, color: context.colors.orchid, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Store settings',
                        style: AppFonts.body(size: 15, weight: FontWeight.w700, color: context.colors.cream)),
                  ),
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Shipping cost (EGP)', style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  if (widget.loadingShipping)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.colors.border(0.08)),
                            ),
                            child: TextField(
                              controller: widget.shippingController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: AppFonts.body(size: 14.5, color: context.colors.cream),
                              cursorColor: context.colors.orchid,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: widget.savingShipping ? null : widget.onSaveShipping,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                            decoration: BoxDecoration(
                              gradient: context.colors.violetGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: widget.savingShipping
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Save',
                                    style: AppFonts.label(size: 12.5, color: Colors.white, letterSpacing: 1.0)
                                        .copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  if (widget.shippingError != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.shippingError!, style: AppFonts.body(size: 12.5, color: context.colors.danger)),
                  ],
                  const SizedBox(height: 22),
                  Text('New-order notification email', style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    'Where you get emailed every time a customer places an order.',
                    style: AppFonts.body(size: 12, color: context.colors.creamDim),
                  ),
                  const SizedBox(height: 8),
                  if (widget.loadingNotificationEmail)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.colors.border(0.08)),
                            ),
                            child: TextField(
                              controller: widget.notificationEmailController,
                              keyboardType: TextInputType.emailAddress,
                              style: AppFonts.body(size: 14.5, color: context.colors.cream),
                              cursorColor: context.colors.orchid,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'you@example.com',
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: widget.savingNotificationEmail ? null : widget.onSaveNotificationEmail,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                            decoration: BoxDecoration(
                              gradient: context.colors.violetGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: widget.savingNotificationEmail
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Save',
                                    style: AppFonts.label(size: 12.5, color: Colors.white, letterSpacing: 1.0)
                                        .copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  if (widget.notificationEmailError != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.notificationEmailError!,
                        style: AppFonts.body(size: 12.5, color: context.colors.danger)),
                  ],
                  const SizedBox(height: 22),
                  Text('Your WhatsApp number', style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    'Where checkout sends the customer\'s order. Digits only with '
                    'country code, no "+" or spaces — e.g. 201234567890.',
                    style: AppFonts.body(size: 12, color: context.colors.creamDim),
                  ),
                  const SizedBox(height: 8),
                  if (widget.loadingOwnerWhatsapp)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.colors.border(0.08)),
                            ),
                            child: TextField(
                              controller: widget.ownerWhatsappController,
                              keyboardType: TextInputType.phone,
                              style: AppFonts.body(size: 14.5, color: context.colors.cream),
                              cursorColor: context.colors.orchid,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '201234567890',
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: widget.savingOwnerWhatsapp ? null : widget.onSaveOwnerWhatsapp,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                            decoration: BoxDecoration(
                              gradient: context.colors.violetGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: widget.savingOwnerWhatsapp
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Save',
                                    style: AppFonts.label(size: 12.5, color: Colors.white, letterSpacing: 1.0)
                                        .copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  if (widget.ownerWhatsappError != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.ownerWhatsappError!,
                        style: AppFonts.body(size: 12.5, color: context.colors.danger)),
                  ],
                  const SizedBox(height: 22),
                  Text('Vodafone Cash number',
                      style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    'When a customer chooses "Vodafone Cash" at checkout, we open '
                    'their Contacts app with this number ready to save. Leave '
                    'empty to hide that option.',
                    style: AppFonts.body(size: 12, color: context.colors.creamDim),
                  ),
                  const SizedBox(height: 8),
                  if (widget.loadingPaymentNumber)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.colors.border(0.08)),
                            ),
                            child: TextField(
                              controller: widget.paymentNumberController,
                              keyboardType: TextInputType.phone,
                              style: AppFonts.body(size: 14.5, color: context.colors.cream),
                              cursorColor: context.colors.orchid,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '01xxxxxxxxx',
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: widget.savingPaymentNumber ? null : widget.onSavePaymentNumber,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                            decoration: BoxDecoration(
                              gradient: context.colors.violetGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: widget.savingPaymentNumber
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Save',
                                    style: AppFonts.label(size: 12.5, color: Colors.white, letterSpacing: 1.0)
                                        .copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  if (widget.paymentNumberError != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.paymentNumberError!,
                        style: AppFonts.body(size: 12.5, color: context.colors.danger)),
                  ],
                  const SizedBox(height: 22),
                  Text('InstaPay link',
                      style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    'When a customer chooses "InstaPay" at checkout, we open this '
                    'link directly so it hands off to the InstaPay app (e.g. your '
                    'ipn.eg payment link). Leave empty to hide that option.',
                    style: AppFonts.body(size: 12, color: context.colors.creamDim),
                  ),
                  const SizedBox(height: 8),
                  if (widget.loadingInstapayLink)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.colors.border(0.08)),
                            ),
                            child: TextField(
                              controller: widget.instapayLinkController,
                              keyboardType: TextInputType.url,
                              style: AppFonts.body(size: 14.5, color: context.colors.cream),
                              cursorColor: context.colors.orchid,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'https://ipn.eg/S/yourstore/instapay/xxxxx',
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: widget.savingInstapayLink ? null : widget.onSaveInstapayLink,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                            decoration: BoxDecoration(
                              gradient: context.colors.violetGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: widget.savingInstapayLink
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Save',
                                    style: AppFonts.label(size: 12.5, color: Colors.white, letterSpacing: 1.0)
                                        .copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  if (widget.instapayLinkError != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.instapayLinkError!,
                        style: AppFonts.body(size: 12.5, color: context.colors.danger)),
                  ],
                  const SizedBox(height: 22),
                  Text('Categories', style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a category\'s photo to set the thumbnail shown on the storefront\'s '
                    'category circles. Deleting a category deletes every product filed under '
                    'it too, so double-check before you do.',
                    style: AppFonts.body(size: 12, color: context.colors.creamDim),
                  ),
                  const SizedBox(height: 10),
                  if (widget.loadingCategories)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                      ),
                    )
                  else if (widget.categories.isEmpty)
                    Text('No categories yet.', style: AppFonts.body(size: 13, color: context.colors.creamDim))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.categories
                          .map((c) => _CategoryTag(
                                category: c,
                                uploading: widget.uploadingCategoryImage == c.name,
                                onDelete: () => widget.onDeleteCategory(c.name),
                                onSetImage: () => widget.onSetCategoryImage(c.name),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final CategoryItem category;
  final bool uploading;
  final VoidCallback onDelete;
  final VoidCallback onSetImage;
  const _CategoryTag({
    required this.category,
    required this.uploading,
    required this.onDelete,
    required this.onSetImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: context.colors.border(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: uploading ? null : onSetImage,
            child: Tooltip(
              message: 'Set thumbnail photo',
              child: ClipOval(
                child: Container(
                  width: 26,
                  height: 26,
                  color: context.colors.surface,
                  child: uploading
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                        )
                      : category.imageUrl.isNotEmpty
                          ? Image.network(
                              category.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.image_outlined, size: 14, color: context.colors.creamDim),
                            )
                          : Icon(Icons.add_photo_alternate_outlined, size: 14, color: context.colors.creamDim),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(category.name, style: AppFonts.body(size: 12.5, color: context.colors.cream, text: category.name)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 15, color: context.colors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final bool editable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.product,
    required this.editable,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border(0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: context.colors.surfaceRaised,
                  child: Icon(Icons.menu_book_rounded, color: context.colors.creamDim, size: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                        size: 15, weight: FontWeight.w700, color: context.colors.cream, text: product.name)),
                const SizedBox(height: 3),
                Text(
                  product.hasDiscount
                      ? '${product.category} · ${formatPrice(product.discountedPrice)} (was ${formatPrice(product.price)}) · stock ${product.stock}'
                      : '${product.category} · ${formatPrice(product.price)} · stock ${product.stock}',
                  style: AppFonts.body(size: 12.5, color: context.colors.creamDim),
                ),
              ],
            ),
          ),
          if (editable) ...[
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_rounded, color: context.colors.orchid, size: 20),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded, color: context.colors.danger, size: 20),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('sample', style: AppFonts.label(size: 10, color: context.colors.creamDim)),
            ),
        ],
      ),
    );
  }
}

/// One row in the mobile Drawer navigation menu: an icon, a label, and an
/// optional small red count badge (mirrors the badges shown on the
/// AppBar icons on wider screens, e.g. pending orders/testimonials).
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final int badgeCount;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? context.colors.creamDim),
      title: Text(label, style: AppFonts.body(size: 15, color: context.colors.cream)),
      trailing: badgeCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              constraints: const BoxConstraints(minWidth: 22),
              decoration: BoxDecoration(
                color: context.colors.danger,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
