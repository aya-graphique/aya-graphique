import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../providers/cart_provider.dart';
import '../providers/language_controller.dart';
import '../services/orders_repository.dart';
import '../services/settings_repository.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';
import '../widgets/animated_backdrop.dart';

enum PaymentMethod { cod, instapay, vodafoneCash }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phone1Ctrl = TextEditingController();
  final _phone2Ctrl = TextEditingController();
  final _senderInfoCtrl = TextEditingController();
  bool _placing = false;

  PaymentMethod _paymentMethod = PaymentMethod.cod;

  // Owner's WhatsApp number, the Vodafone Cash number, and the InstaPay
  // link, all set by the admin from the Store admin settings panel. Loaded
  // once on open.
  String _ownerWhatsapp = '';
  String _paymentNumber = '';
  String _instapayLink = '';

  @override
  void initState() {
    super.initState();
    _loadStoreContacts();
  }

  Future<void> _loadStoreContacts() async {
    final results = await Future.wait([
      SettingsRepository.fetchOwnerWhatsapp(),
      SettingsRepository.fetchPaymentNumber(),
      SettingsRepository.fetchInstapayLink(),
    ]);
    if (!mounted) return;
    setState(() {
      _ownerWhatsapp = results[0];
      _paymentNumber = results[1];
      _instapayLink = results[2];
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _phone1Ctrl.dispose();
    _phone2Ctrl.dispose();
    _senderInfoCtrl.dispose();
    super.dispose();
  }

  String get _paymentMethodValue {
    switch (_paymentMethod) {
      case PaymentMethod.cod:
        return 'cod';
      case PaymentMethod.instapay:
        return 'instapay';
      case PaymentMethod.vodafoneCash:
        return 'vodafone_cash';
    }
  }

  /// Builds the pre-filled WhatsApp message text for the order, in the same
  /// spirit as the email the notify-new-order function sends — just phrased
  /// for a chat instead of an inbox.
  String _buildWhatsAppMessage(CartProvider cart) {
    final buffer = StringBuffer();
    buffer.writeln('New order');
    buffer.writeln();
    buffer.writeln('Name: ${_nameCtrl.text.trim()}');
    buffer.writeln('Email: ${_emailCtrl.text.trim()}');
    buffer.writeln('Phone 1: ${_phone1Ctrl.text.trim()}');
    if (_phone2Ctrl.text.trim().isNotEmpty) {
      buffer.writeln('Phone 2: ${_phone2Ctrl.text.trim()}');
    }
    buffer.writeln('Address: ${_addressCtrl.text.trim()}');
    buffer.writeln();
    buffer.writeln('Items:');
    for (final line in cart.lines) {
      buffer.writeln('- ${line.quantity} x ${line.product.name} (${formatPrice(line.lineTotal)})');
    }
    buffer.writeln();
    buffer.writeln('Subtotal: ${formatPrice(cart.subtotal)}');
    buffer.writeln('Shipping: ${formatPrice(cart.shipping)}');
    buffer.writeln('Total: ${formatPrice(cart.total)}');
    buffer.writeln();
    switch (_paymentMethod) {
      case PaymentMethod.cod:
        buffer.writeln('Payment: Cash on delivery');
        break;
      case PaymentMethod.instapay:
        buffer.writeln('Payment: InstaPay');
        buffer.writeln('Paid from (InstaPay name): ${_senderInfoCtrl.text.trim()}');
        break;
      case PaymentMethod.vodafoneCash:
        buffer.writeln('Payment: Vodafone Cash');
        buffer.writeln('Paid from (Vodafone Cash number): ${_senderInfoCtrl.text.trim()}');
        break;
    }
    return buffer.toString();
  }

  /// Opens WhatsApp with the owner's chat pre-filled with the given
  /// message. No API/business account needed — this is just the public
  /// wa.me deep link, so the customer still has to tap Send themselves
  /// inside WhatsApp once it opens.
  Future<void> _openWhatsApp(String message) async {
    if (_ownerWhatsapp.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$_ownerWhatsapp?text=${Uri.encodeComponent(message)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.stringsRead.couldntOpenWhatsApp('$e'))),
      );
    }
  }

  /// Opens the store's InstaPay link so the customer lands straight in the
  /// InstaPay app (or its web fallback) to send the payment.
  Future<void> _openInstaPay() async {
    if (_instapayLink.isEmpty) return;
    final uri = Uri.parse(_instapayLink);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.stringsRead.couldntOpenInstaPay('$e'))),
      );
    }
  }

  /// Opens the phone's contacts/dialer with the store's Vodafone Cash
  /// number pre-filled, so the customer can save it (or dial it) to send
  /// the transfer.
  Future<void> _openVodafoneCashContact() async {
    if (_paymentNumber.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: _paymentNumber);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.stringsRead.couldntOpenContacts('$e'))),
      );
    }
  }

  Future<void> _placeOrder(CartProvider cart) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _placing = true);
    try {
      await OrdersRepository.create(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        phone1: _phone1Ctrl.text.trim(),
        phone2: _phone2Ctrl.text.trim(),
        paymentMethod: _paymentMethodValue,
        paymentSenderInfo: _paymentMethod == PaymentMethod.cod ? '' : _senderInfoCtrl.text.trim(),
        cart: cart,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.stringsRead.couldntPlaceOrder('$e'))),
      );
      return;
    }

    // The order is already safely saved at this point (it's in Supabase,
    // so it'll show up on the admin dashboard) — everything from here is a
    // bonus follow-up action and must never block checkout from completing
    // even if it fails or the app is missing on the customer's phone.
    //
    // Straight away, send the customer to the payment app itself so they
    // can actually pay. WhatsApp is *not* opened automatically here — it's
    // only opened when the customer taps "Open WhatsApp" on the next
    // screen, once they're done paying.
    if (_paymentMethod == PaymentMethod.instapay) {
      await _openInstaPay();
    } else if (_paymentMethod == PaymentMethod.vodafoneCash) {
      await _openVodafoneCashContact();
    }

    final whatsAppMessage = _buildWhatsAppMessage(cart);

    if (!mounted) return;
    setState(() => _placing = false);
    cart.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _OrderSuccessDialog(
        name: _nameCtrl.text.trim(),
        isCod: _paymentMethod == PaymentMethod.cod,
        onOpenWhatsApp: () => _openWhatsApp(whatsAppMessage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);
    AppFonts.forceArabic = context.watch<FontController>().arabicMode;

    return Directionality(
      textDirection: context.watch<LanguageController>().textDirection,
      child: Scaffold(
      backgroundColor: context.colors.bgDeep,
      body: AnimatedBackdrop(
        intensity: 0.5,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Material(
                      color: context.colors.surface.withOpacity(0.7),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.arrow_back_rounded, size: 20, color: context.colors.cream),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(context.strings.checkoutTitle, style: AppFonts.display(color: context.colors.cream, size: 26, weight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 28),
                isMobile
                    ? Column(
                        children: [
                          _ShippingForm(
                            formKey: _formKey,
                            nameCtrl: _nameCtrl,
                            emailCtrl: _emailCtrl,
                            addressCtrl: _addressCtrl,
                            phone1Ctrl: _phone1Ctrl,
                            phone2Ctrl: _phone2Ctrl,
                            senderInfoCtrl: _senderInfoCtrl,
                            paymentMethod: _paymentMethod,
                            onPaymentMethodChanged: (v) => setState(() => _paymentMethod = v),
                            paymentNumber: _paymentNumber,
                            instapayLink: _instapayLink,
                          ),
                          const SizedBox(height: 24),
                          _OrderReview(cart: cart, placing: _placing, onPlace: () => _placeOrder(cart)),
                        ],
                      )
                    : IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _ShippingForm(
                                formKey: _formKey,
                                nameCtrl: _nameCtrl,
                                emailCtrl: _emailCtrl,
                                addressCtrl: _addressCtrl,
                                phone1Ctrl: _phone1Ctrl,
                                phone2Ctrl: _phone2Ctrl,
                                senderInfoCtrl: _senderInfoCtrl,
                                paymentMethod: _paymentMethod,
                                onPaymentMethodChanged: (v) => setState(() => _paymentMethod = v),
                                paymentNumber: _paymentNumber,
                                instapayLink: _instapayLink,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 2,
                              child: _OrderReview(
                                  cart: cart, placing: _placing, onPlace: () => _placeOrder(cart)),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _ShippingForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phone1Ctrl;
  final TextEditingController phone2Ctrl;
  final TextEditingController senderInfoCtrl;
  final PaymentMethod paymentMethod;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;
  final String paymentNumber;
  final String instapayLink;

  const _ShippingForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.addressCtrl,
    required this.phone1Ctrl,
    required this.phone2Ctrl,
    required this.senderInfoCtrl,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    required this.paymentNumber,
    required this.instapayLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: context.colors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border(0.06)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.strings.shippingDetails, style: AppFonts.display(color: context.colors.cream, size: 18, weight: FontWeight.w700)),
            const SizedBox(height: 18),
            _Field(label: context.strings.fullName, controller: nameCtrl, validator: (v) => _required(context, v)),
            const SizedBox(height: 14),
            _Field(
              label: context.strings.email,
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => _email(context, v),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: context.strings.phoneNumber,
                    controller: phone1Ctrl,
                    keyboardType: TextInputType.phone,
                    validator: (v) => _required(context, v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: context.strings.altPhone,
                    controller: phone2Ctrl,
                    keyboardType: TextInputType.phone,
                    validator: (_) => null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Field(
              label: context.strings.shippingAddress,
              controller: addressCtrl,
              maxLines: 3,
              validator: (v) => _required(context, v),
            ),
            const SizedBox(height: 22),
            Text(context.strings.payment, style: AppFonts.display(color: context.colors.cream, size: 18, weight: FontWeight.w700)),
            const SizedBox(height: 12),
            _PaymentOption(
              label: context.strings.cod,
              subtitle: context.strings.codSubtitle,
              selected: paymentMethod == PaymentMethod.cod,
              onTap: () => onPaymentMethodChanged(PaymentMethod.cod),
              icon: Icons.payments_rounded,
              iconColor: context.colors.creamDim,
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              label: context.strings.instapay,
              subtitle: context.strings.instapaySubtitle,
              selected: paymentMethod == PaymentMethod.instapay,
              onTap: () => onPaymentMethodChanged(PaymentMethod.instapay),
              imagePath: 'assets/images/instapay_logo.png',
              iconColor: const Color(0xFF6C2EB5),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              label: context.strings.vodafoneCash,
              subtitle: context.strings.vodafoneCashSubtitle,
              selected: paymentMethod == PaymentMethod.vodafoneCash,
              onTap: () => onPaymentMethodChanged(PaymentMethod.vodafoneCash),
              imagePath: 'assets/images/vodafone_cash_logo.png',
              iconColor: const Color(0xFFE60000),
            ),
            if (paymentMethod == PaymentMethod.instapay) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.orchid.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.orchid.withOpacity(0.3)),
                ),
                child: instapayLink.isEmpty
                    ? Text(
                        context.strings.instapayNoLinkNotice,
                        style: AppFonts.body(size: 12.5, color: context.colors.creamDim),
                      )
                    : Text(
                        context.strings.instapayWithLinkNotice,
                        style: AppFonts.body(size: 12.5, color: context.colors.cream),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                context.strings.instapaySenderHint,
                style: AppFonts.body(size: 12.5, color: context.colors.creamDim),
              ),
              const SizedBox(height: 8),
              _Field(
                label: context.strings.instapaySenderLabel,
                controller: senderInfoCtrl,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.stringsRead.senderInfoRequired
                    : null,
              ),
            ],
            if (paymentMethod == PaymentMethod.vodafoneCash) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.orchid.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.orchid.withOpacity(0.3)),
                ),
                child: paymentNumber.isEmpty
                    ? Text(
                        context.strings.vodafoneNoNumberNotice,
                        style: AppFonts.body(size: 12.5, color: context.colors.creamDim),
                      )
                    : Text(
                        context.strings.vodafoneWithNumberNotice(paymentNumber),
                        style: AppFonts.body(size: 12.5, color: context.colors.cream),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                context.strings.vodafoneSenderHint,
                style: AppFonts.body(size: 12.5, color: context.colors.creamDim),
              ),
              const SizedBox(height: 8),
              _Field(
                label: context.strings.vodafoneSenderLabel,
                controller: senderInfoCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.stringsRead.senderInfoRequired
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // NOTE: these are Form validators, which Flutter calls in two very
  // different situations — (1) while the field is building/rebuilding
  // (fine to `watch` the provider then), and (2) synchronously from
  // `_formKey.currentState?.validate()` inside `_placeOrder`, which runs
  // from a button's onPressed handler, *outside* the widget build phase.
  // `context.strings` (and `isArabicLanguage`) use `context.watch`, which
  // asserts if it's ever called outside of build — that's exactly what
  // was crashing checkout on submit. Reading the language directly with
  // `context.read` here avoids subscribing to changes, which a one-off
  // validator call doesn't need anyway.
  String? _required(BuildContext context, String? v) =>
      (v == null || v.trim().isEmpty)
          ? AppText(context.languageController.isArabic).required
          : null;

  String? _email(BuildContext context, String? v) {
    final strings = AppText(context.languageController.isArabic);
    if (v == null || v.trim().isEmpty) return strings.required;
    if (!v.contains('@') || !v.contains('.')) return strings.invalidEmail;
    return null;
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color iconColor;
  final String? imagePath;

  const _PaymentOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.icon,
    required this.iconColor,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? context.colors.orchid : context.colors.border(0.08),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(imagePath!, fit: BoxFit.cover),
                    )
                  : Icon(icon, size: 26, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppFonts.body(size: 14, weight: FontWeight.w700, color: context.colors.cream)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppFonts.body(size: 12, color: context.colors.creamDim)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? context.colors.orchid : context.colors.creamDim,
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?) validator;

  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: AppFonts.body(size: 14.5, color: context.colors.cream),
      cursorColor: context.colors.orchid,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFonts.body(color: context.colors.creamDim, size: 13.5),
        filled: true,
        fillColor: context.colors.surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.orchid, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.danger, width: 1.2),
        ),
      ),
    );
  }
}

class _OrderReview extends StatelessWidget {
  final CartProvider cart;
  final bool placing;
  final VoidCallback onPlace;

  const _OrderReview({required this.cart, required this.placing, required this.onPlace});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: context.colors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.strings.orderReview, style: AppFonts.display(color: context.colors.cream, size: 18, weight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...cart.lines.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${l.quantity} × ${l.product.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(color: context.colors.creamDim, size: 13.5, text: l.product.name)),
                    ),
                    Text(formatPrice(l.lineTotal),
                        style: AppFonts.body(size: 13.5, weight: FontWeight.w600, color: context.colors.cream)),
                  ],
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: context.colors.border(0.12), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.strings.total, style: AppFonts.body(color: context.colors.creamDim, size: 15)),
              Text(formatPrice(cart.total),
                  style: AppFonts.display(size: 20, weight: FontWeight.w700, color: context.colors.orchidSoft)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: (placing || cart.lines.isEmpty) ? null : onPlace,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: (cart.lines.isEmpty) ? null : context.colors.violetGradient,
                  color: (cart.lines.isEmpty) ? context.colors.surfaceRaised : null,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: placing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(
                          context.strings.placeOrder,
                          style: AppFonts.label(size: 13.5, color: Colors.white, letterSpacing: 1.2)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSuccessDialog extends StatelessWidget {
  final String name;
  final bool isCod;
  final VoidCallback onOpenWhatsApp;

  const _OrderSuccessDialog({
    required this.name,
    required this.isCod,
    required this.onOpenWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: context.colors.violetGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),
            Text(context.strings.orderPlaced, style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(
              context.strings.thanksMessage(name, isCod: isCod),
              textAlign: TextAlign.center,
              style: AppFonts.body(color: context.colors.creamDim, size: 14),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: onOpenWhatsApp,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: context.colors.violetGradient,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      context.strings.openWhatsApp,
                      textAlign: TextAlign.center,
                      style: AppFonts.label(size: 13, color: Colors.white, letterSpacing: 0.6)
                          .copyWith(fontWeight: FontWeight.w700, height: 1.3),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      context.strings.backToShop,
                      style: AppFonts.label(size: 13, color: context.colors.creamDim, letterSpacing: 1.2)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
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
