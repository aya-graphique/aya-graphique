import 'package:flutter/material.dart';
import '../providers/language_controller.dart';

/// All storefront-facing copy, in English and Arabic, in one place.
///
/// Scope note: this covers the storefront chrome (nav, headings, buttons,
/// form labels, messages). Product names/descriptions/categories come from
/// the database (the admin enters them) and are shown as-is in whichever
/// language they were entered in — translating arbitrary catalog content
/// automatically is out of scope here. The admin dashboard screens never
/// read from this class at all, so they always stay in English.
class AppText {
  final bool isArabic;
  const AppText(this.isArabic);

  String _t(String en, String ar) => isArabic ? ar : en;

  // Nav bar
  String get navHome => _t('Home', 'الرئيسية');
  String get navShop => _t('Shop', 'المتجر');
  String get navSearch => _t('Search', 'بحث');
  String get navCart => _t('Cart', 'السلة');
  String get navAbout => _t('Who am I', 'من أنا');
  String get navServices => _t('Services', 'الخدمات');

  // Home — hero
  String get heroEyebrow => _t('NOTEBOOKS & CALENDARS', 'دفاتر وتقويمات');
  String get heroSubtitle => _t(
        'A small, considered range of notebooks and calendars — dark '
        'illustrated covers, bright paper, and the kind of stitching that outlasts '
        'the ideas you put in them.',
        'مجموعة صغيرة ومختارة بعناية من الدفاتر والتقويمات — أغلفة داكنة， '
        'ورق فاتح، وتجليد يدوم أطول من الأفكار التي تكتبها فيه.',
      );
  // Home — marquee
  String get marqueeNotebooks => _t('NOTEBOOKS', 'دفاتر');
  String get marqueeCalendars => _t('YEARLY CALENDARS', 'تقويمات سنوية');
  String get marqueeBookmark => _t('BOOKMARK', 'فاصل كتب');
  String get marqueeStand => _t('CALENDAR STAND', 'حامل');

  // Home — collection section
  String get collectionEyebrow => _t('THE COLLECTION', 'المجموعة');
  String get collectionTitle =>
      _t('Notebooks worth\nreaching for.', 'دفاتر تستحق\nأن تمتد لها يدك.');
  String get collectionSubtitle => _t(
        'Paper stocks, bindings, and covers chosen the way we choose '
        'everything else here — deliberately.',
        'أنواع الورق والتجليد والأغلفة مختارة بعناية، تمامًا كما نختار '
        'كل شيء آخر هنا.',
      );
  String get categoryAll => _t('All', 'الكل');

  // Home — best sellers
  String get bestSellersEyebrow => _t('CUSTOMER FAVOURITES', 'الأكثر طلبًا');
  String get bestSellersTitle => _t('Best sellers', 'الأكثر مبيعًا');

  // Home — "most ordered" circles (below the "available for" card)
  String get mostRequestedEyebrow => _t('MOST ORDERED', 'الأكثر طلبًا');
  String get artisticProductsLabel => _t('Graphical Products', 'المنتجات الجرافيكية');

  // Home — service circles row
  String get homeServicesEyebrow => _t('SERVICES', 'الخدمات');

  // Home — illustration & art circles (owner-managed from the dashboard)
  String get illustrationArtEyebrow => _t('ILLUSTRATION & ART', 'رسومات وفنون توضيحية');


  // Home — testimonials
  String get testimonialsEyebrow => _t('TESTIMONIALS', 'التوصيات');
  String get testimonialsTitle => _t('What people say', 'ماذا يقول الناس');

  // Home — footer
  String get footerTagline =>
      _t('Notebooks & calendars, simplicity makes it art.', 'دفاتر وتقويمات، البساطة تصنع الفن.');
  String get storeAdmin => _t('Store admin →', 'إدارة المتجر ←');

  // Graphical Services
  String get servicesEyebrow => _t('GRAPHICAL SERVICES', 'خدمات جرافيكية');
  String get servicesTitle => _t('Design services,\non demand.', 'خدمات تصميم\nحسب الطلب.');
  String get servicesSubtitle => _t(
        'Beyond the shop — book a live design session, a full brand '
        'identity, or a ready-to-use content pack.',
        'أبعد من المتجر — احجز جلسة تصميم مباشرة، هوية بصرية كاملة، '
        'أو حزمة محتوى جاهزة للاستخدام.',
      );
  String get bookSession => _t('Book via WhatsApp', 'احجز عبر واتساب');
  String serviceBookingMessage(String serviceName) => _t(
        'Hi! I\'d like to book the "$serviceName" service. Could you '
        'tell me more about availability and pricing?',
        'أهلاً! أود حجز خدمة "$serviceName". ممكن أعرف أكتر عن '
        'المواعيد المتاحة والسعر؟',
      );
  String get servicesWhatsappNotSet => _t(
        'Booking isn\'t set up yet — the store hasn\'t added a WhatsApp '
        'number. Please check back soon.',
        'الحجز غير متاح حاليًا — لم يتم إضافة رقم واتساب بعد. '
        'برجاء المحاولة لاحقًا.',
      );

  // Search
  String get searchEyebrow => _t('FIND SOMETHING', 'ابحث عن شيء');
  String get searchTitle => _t('Search', 'بحث');
  String get allCategories => _t('All categories', 'كل الفئات');
  String get anyPrice => _t('Any price', 'أي سعر');
  String get price20to40 => _t('20 – 40 EGP', '20 – 40 ج.م');
  String get priceOver40 => _t('Over 40 EGP', 'أكثر من 40 ج.م');
  String resultsCount(int n) => _t(
        '$n result${n == 1 ? '' : 's'}',
        '$n نتيجة',
      );
  String get noResults =>
      _t('Nothing matches those filters yet.', 'لا توجد نتائج تطابق هذه الفلاتر بعد.');
  String get searchHint =>
      _t('Search notebooks, calendars …', 'ابحث عن دفاتر، تقويمات، وسوم…');

  // Cart
  String get cartEyebrow => _t('YOUR CART', 'سلتك');
  String get cartTitle => _t('Cart', 'السلة');
  String get orderSummary => _t('Order summary', 'ملخص الطلب');
  String get subtotal => _t('Subtotal', 'المجموع الفرعي');
  String get shipping => _t('Shipping', 'الشحن');
  String get total => _t('Total', 'الإجمالي');
  String get proceedToCheckout => _t('Proceed to checkout', 'إتمام الطلب');
  String get emptyCartTitle => _t('Your cart is empty', 'سلتك فارغة');
  String get emptyCartSubtitle => _t(
        'Add a notebook or two — they pair well together.',
        'أضف دفترًا أو اثنين — يتناسقان معًا بشكل رائع.',
      );
  String get browseNotebooks => _t('Browse notebooks', 'تصفح الدفاتر');

  // Product card / detail
  String get inStock => _t('In stock', 'متوفر');
  String get soldOut => _t('Sold out', 'نفدت الكمية');
  String get addToCart => _t('Add to cart', 'أضف إلى السلة');
  String addedToCart(String name) =>
      _t('Added "$name" to cart', 'تمت إضافة "$name" إلى السلة');
  String addedQtyToCart(int qty, String name) => _t(
        'Added $qty × "$name" to cart',
        'تمت إضافة $qty × "$name" إلى السلة',
      );

  // Checkout
  String get checkoutTitle => _t('Checkout', 'إتمام الشراء');
  String get shippingDetails => _t('Shipping details', 'بيانات الشحن');
  String get fullName => _t('Full name', 'الاسم الكامل');
  String get email => _t('Email', 'البريد الإلكتروني');
  String get phoneNumber => _t('Phone number', 'رقم الهاتف');
  String get altPhone => _t('Alt. phone (optional)', 'رقم هاتف بديل (اختياري)');
  String get shippingAddress => _t('Shipping address', 'عنوان الشحن');
  String get payment => _t('Payment', 'الدفع');

  String get cod => _t('Cash on delivery', 'الدفع عند الاستلام');
  String get codSubtitle =>
      _t('Pay the courier when your order arrives.', 'ادفع للمندوب عند وصول طلبك.');
  String get instapay => _t('InstaPay', 'إنستاباي');
  String get instapaySubtitle =>
      _t('We\'ll open InstaPay so you can send the total.', 'سنفتح إنستاباي لترسل قيمة الطلب.');
  String get vodafoneCash => _t('Vodafone Cash', 'فودافون كاش');
  String get vodafoneCashSubtitle => _t(
        'We\'ll open your Contacts with our number ready to save.',
        'سنفتح جهات الاتصال لديك برقمنا جاهزًا للحفظ.',
      );

  String get instapayNoLinkNotice => _t(
        'The store hasn\'t set an InstaPay link yet — place the '
        'order and we\'ll sort out payment with you on WhatsApp.',
        'لم يقم المتجر بتحديد رابط إنستاباي بعد — أكمل الطلب '
        'وسنتفق معك على الدفع عبر واتساب.',
      );
  String get instapayWithLinkNotice => _t(
        'Tap "Place order" and we\'ll open InstaPay for you, then '
        'send your order to us on WhatsApp. After paying, take a '
        'screenshot of the payment and send it in that WhatsApp chat.',
        'اضغط "تنفيذ الطلب" وسنفتح لك إنستاباي، ثم نرسل طلبك '
        'إلينا عبر واتساب. بعد الدفع، خد سكرين شوت من عملية '
        'الدفع وابعته في نفس شات الواتساب.',
      );
  String get vodafoneNoNumberNotice => _t(
        'The store hasn\'t set a Vodafone Cash number yet — place '
        'the order and we\'ll share it with you on WhatsApp.',
        'لم يقم المتجر بتحديد رقم فودافون كاش بعد — أكمل الطلب '
        'وسنرسله لك عبر واتساب.',
      );
  String vodafoneWithNumberNotice(String number) => _t(
        'Tap "Place order" and we\'ll open your Contacts with '
        '$number ready to save, then send your order to '
        'us on WhatsApp. After paying, take a screenshot of the '
        'payment and send it in that WhatsApp chat.',
        'اضغط "تنفيذ الطلب" وسنفتح لك جهات الاتصال برقم '
        '$number جاهزًا للحفظ، ثم نرسل طلبك إلينا عبر واتساب. '
        'بعد الدفع، خد سكرين شوت من عملية الدفع وابعته في نفس '
        'شات الواتساب.',
      );

  String get required => _t('Required', 'مطلوب');
  String get invalidEmail => _t('Enter a valid email', 'أدخل بريدًا إلكترونيًا صحيحًا');

  String get orderReview => _t('Order review', 'مراجعة الطلب');
  String get placeOrder => _t('Place order', 'تنفيذ الطلب');

  String get orderPlaced => _t('Order placed!', 'تم تنفيذ الطلب!');
  String thanksMessage(String name) => name.isEmpty
      ? _t(
          'Thanks for shopping with us. We opened WhatsApp with your '
          'order details — just tap Send to confirm with us.',
          'شكرًا لتسوقك معنا. لقد فتحنا واتساب مع تفاصيل طلبك — '
          'فقط اضغط إرسال لتأكيد الطلب معنا.',
        )
      : _t(
          'Thanks, $name — we opened WhatsApp with your order details. '
          'Just tap Send there to confirm with us.',
          'شكرًا لك يا $name — لقد فتحنا واتساب مع تفاصيل طلبك. '
          'فقط اضغط إرسال هناك لتأكيد الطلب معنا.',
        );
  String get instapayThanksNote => _t(
        'We also opened InstaPay for you — send the total there.',
        'كما فتحنا لك إنستاباي — أرسل قيمة الطلب من هناك.',
      );
  String vodafoneThanksNote(String number) => _t(
        'We also opened Contacts with $number ready to save — '
        'send your Vodafone Cash payment there.',
        'كما فتحنا جهات الاتصال برقم $number جاهزًا للحفظ — '
        'أرسل دفعة فودافون كاش من هناك.',
      );
  String get paymentScreenshotReminder => _t(
        'Important: your order won\'t be confirmed until you send a '
        'screenshot of your payment in the WhatsApp chat we opened.',
        'مهم: طلبك مش هيتأكد غير لما تبعت سكرين شوت من عملية '
        'الدفع في شات الواتساب اللي فتحناه لك.',
      );
  String get resendScreenshotOnWhatsApp => _t(
        'Open WhatsApp to send the screenshot',
        'افتح واتساب لإرسال السكرين شوت',
      );
  String get screenshotFollowUpMessage => _t(
        'Here\'s a screenshot of my payment for the order above.',
        'ده سكرين شوت من عملية الدفع بتاعة الطلب اللي فوق.',
      );
  String get backToShop => _t('Back to shop', 'العودة للمتجر');

  String couldntOpenWhatsApp(String err) =>
      _t('Couldn\'t open WhatsApp: $err', 'تعذر فتح واتساب: $err');
  String couldntOpenInstaPay(String err) =>
      _t('Couldn\'t open InstaPay: $err', 'تعذر فتح إنستاباي: $err');
  String couldntOpenContacts(String err) =>
      _t('Couldn\'t open Contacts: $err', 'تعذر فتح جهات الاتصال: $err');
  String couldntPlaceOrder(String err) =>
      _t('Couldn\'t place the order: $err', 'تعذر تنفيذ الطلب: $err');

  // Who am I — page chrome. Note: fullName, headline, bio, skills,
  // location and contact info all come from the admin dashboard as free
  // text, so they're shown exactly as the admin typed them (in whichever
  // language that was) — only the surrounding labels below are translated.
  String get whoAmIEyebrow => _t('WHO AM I?', 'من أنا');
  // Home's compact "available for" card (see OwnerIntroCard) — sits where
  // the embedded Services section used to, links down to the full "Who am
  // I" section below.
  String get viewFullProfile => _t('View full profile', 'شاهد الملف الشخصي كاملاً');

  // Home — shop preview section (teases the collection, hands off to the
  // standalone Shop tab)
  String get shopTheCollection => _t('Shop the collection', 'تسوق المجموعة');
  // The audience circles in that same card — each taps straight through
  // to the matching category on the Services tab (see OwnerIntroCard).
  String get availableForEyebrow => _t('AVAILABLE FOR', 'متاحة للعمل مع');
  String get restaurantOwnersLabel => _t('Restaurant owners', 'أصحاب المطاعم');
  String get hotelOwnersLabel => _t('Hotel owners', 'أصحاب الفنادق');
  String get companyOwnersLabel => _t('Company owners', 'أصحاب الشركات');
  String get brandingLabel => _t('Branding', 'الهوية التجارية');
  String get illustrationClientsLabel => _t('Illustration', 'الرسوم التوضيحية');
  String get creativityLabel => _t('Creativity', 'الإبداع');
  String get privateWorkshopIndividualsLabel =>
      _t('Individuals — private workshops', 'الأفراد — ورش فردية');
  String get aspiringDesignersLabel => _t('Aspiring designers', 'المصممون الطموحون');
  String get contentCreatorsLabel => _t('Content creators', 'صناع المحتوى');
  String get experienceLabel => _t('EXPERIENCE', 'الخبرات');
  String get educationLabel => _t('EDUCATION', 'التعليم');
  String get skillsLabel => _t('SKILLS', 'المهارات');
  String get getInTouchLabel => _t('GET IN TOUCH', 'تواصل معايا');
  String get whatsappLabel => _t('WhatsApp', 'واتساب');
  String get emailLabel => _t('Email', 'البريد الإلكتروني');
  String get portfolioLabel => _t('Portfolio', 'أعمالي');
  String get cvLabel => _t('CV', 'السيرة الذاتية');
  String get instagramLabel => _t('Instagram', 'إنستجرام');
  String get facebookLabel => _t('Facebook', 'فيسبوك');
  String get tiktokLabel => _t('TikTok', 'تيك توك');
  String get linkedinLabel => _t('LinkedIn', 'لينكدإن');
  String get emptyProfileNotice => _t(
        'This page is empty for now — add your name, bio, skills and '
        'photos from the admin dashboard\'s "Who am I" tab and they\'ll '
        'show up here.',
        'هذه الصفحة فارغة حاليًا — أضف اسمك ونبذتك ومهاراتك وصورك من '
        'تبويب "من أنا" في لوحة التحكم وستظهر هنا.',
      );
}

extension AppTextContextX on BuildContext {
  /// Storefront copy in the currently-selected language. Never use this
  /// inside admin/* screens — they should stay hardcoded in English.
  AppText get strings => AppText(isArabicLanguage);
}