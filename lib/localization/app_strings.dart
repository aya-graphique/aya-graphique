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
  String get navFavorites => _t('Saved', 'المحفوظات');
  String get navAbout => _t('Who am I', 'من أنا');
  String get navServices => _t('Services', 'الخدمات');
  String get navMyWorks => _t('My Works', 'اعمالي');

  // Home — hero
  String get heroEyebrow => _t('NOTEBOOKS & CALENDARS', 'دفاتر وتقويمات');
  String get heroSubtitle => _t(
        'A small, considered range of notebooks and calendars — dark '
        'illustrated covers, bright paper, and the kind of stitching that outlasts '
        'the ideas you put in them.',
        'مجموعة صغيرة ومختارة بعناية من الدفاتر والتقويمات — أغلفة داكنة， '
        'ورق فاتح، وتجليد يدوم أطول من الأفكار التي تكتبها فيه.',
      );
  // Home — welcome hero (the very first section on Home: portrait +
  // greeting + the two "view my work" / "explore the shop" buttons)
  String get heroWelcomePillName => _t('Aya Attia', 'ايه عطية');
  String get heroWelcomeTitleMain => _t('Simply', 'ببساطة!');
  String get heroWelcomeTitleAccent => _t('A design for an ART', 'تصميم للفن؛');
  String get heroWelcomeSubtitle =>
      _t("Aya Attia Abed is an Egyptian Arab advertising and visual identity designer and illustrator with a Bachelor of Applied Arts in the Advertising Department and founder of the personal brand Aya's Graphique for commercial design services and the sale of hand-drawn products.","آية عطية عابد؛ مصممة إعلانات وهويات بصرية ورسامة مصرية عربية حاصلة على بكالريوس الفنون التطبيقية لقسم الإعلان ومؤسسة للعلامةز التجارية الشخصية Aya's Graphique لخدمات التصميم التجاري ولبيع المنتجات المرسومة يدوياً.");
  String get heroWelcomePrimaryButton => _t('View my work', 'عرض أعمالي');
  String get heroWelcomeSecondaryButton => _t('Explore the shop', 'استكشف المتجر');
  // Home — marquee
  String get marqueeNotebooks => _t('NOTEBOOKS', 'دفاتر');
  String get marqueeCalendars => _t('YEARLY CALENDARS', 'تقويمات سنوية');
  String get marqueeDigitalArt => _t('DIGITAL ART', 'رسم رقمي');
  String get marqueeKidsGamesPrint =>
      _t('PRINTED KIDS GAMES', 'تصميم ألعاب أطفال مطبوعة');
  String get marqueeCommercialPrint =>
      _t('COMMERCIAL PRINTS', 'تصميم مطبوعات تجارية');
  String get marqueeBranding => _t('FULL BRAND IDENTITY', 'هوية تجارية متكاملة');
  String get marqueeLogo => _t('LOGO', 'شعار');
  String get marqueeAds => _t('COMMERCIAL ADS DESIGN', 'تصميم الإعلانات التجارية');
  String get marqueeWorkshops =>
      _t('ONE-ON-ONE WORKSHOPS', 'ورش تعليمية فردية');

  // Home — second marquee (under products)
  String get marqueeCalendarsShort => _t('CALENDARS', 'تقويمات');
  String get marqueeNotebooksShort => _t('NOTEBOOKS', 'دفاتر');
  String get marqueeBookmarksShort => _t('BOOKMARKS', 'فواصل كتب');
  String get marqueeGamesShort => _t('GAMES', 'ألعاب');

  // Home — collection section
  String get collectionEyebrow => _t('THE PRODUCTS', 'المنتجات');
  String get collectionTitle =>
      _t('Art expresses you in every moment\nbetween your hands and accompanies you forever. ','فن يعبر عنك في كل لحظة بين يديك ويرافقك إلى الأبد.');
  String get collectionSubtitle => _t(
        'Choose the art that expresses you;'
        'For you and your loved ones.',
        'أختر الفن الذي يعبر عنك؛ '
        'لك ولمن تُحب.',
      );
  String get categoryAll => _t('All', 'الكل');

  // Home — "most ordered" circles (below the "available for" card)
  String get mostRequestedEyebrow => _t('MOST ORDERED', 'الأكثر طلبًا');
  String get artisticProductsLabel => _t('Printed Designs', 'التصاميم المطبوعة');

  // Home — service circles row
  String get homeServicesEyebrow => _t('Design Services', 'خدمات التصميم ');
  String get homeServicesSubtitle => _t(
        'Professional design paths tailored to your goals, from mentoring to full branding',
        'مسارات تصميم احترافية تناسب أهدافك، من الإرشاد المهني إلى الهوية الكاملة',
      );

  // Home — illustration & art circles (owner-managed from the dashboard)
  String get illustrationArtEyebrow => _t('Skills & Arts', 'مهارات وفنون');
  String get illustrationArtSubtitle => _t(
        'Creative tools and artistic skills that turn ideas into a magical visual reality',
        'أدوات إبداعية ومهارات فنية نطور بها الأفكار إلى واقع بصري ساحر',
      );


  // Home — Facebook reviews button
  String get successPartnersReviews => _t('Voices of Our Success Partners!', 'آراء شركاء النجاح !');
  String couldntOpenFacebookReviews(String err) =>
      _t('Couldn\'t open Facebook reviews: $err', 'تعذر فتح صفحة الآراء على فيسبوك: $err');

  // Home — footer
  String get footerTagline =>
      _t('Simplicity makes it art', 'Simplicity makes it art');
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
  String get estimatedDelivery =>
      _t('Estimated delivery: 2–4 business days', 'التوصيل المتوقع خلال 2–4 أيام عمل');
  String get youMightAlsoLike => _t('You might also like', 'قد يعجبك أيضًا');
  String get removeItem => _t('Remove', 'حذف');
  String get emptyCartTitle => _t('Your cart is empty', 'سلتك فارغة');
  String get emptyCartSubtitle => _t(
        'Add a notebook or two — they pair well together.',
        'أضف دفترًا أو اثنين — يتناسقان معًا بشكل رائع.',
      );
  String get browseNotebooks => _t('Browse notebooks', 'تصفح الدفاتر');

  // Product card / detail
  String get inStock => _t('In stock', 'متوفر');
  String get soldOut => _t('Sold out', 'نفدت الكمية');
  String get saleBadge => _t('Sale', 'خصم');
  String get newArrivalBadge => _t('New Arrival', 'وصل حديثاً');
  String get saveProduct => _t('Save', 'حفظ');
  String get savedProduct => _t('Saved', 'تم الحفظ');
  String get shareProduct => _t('Share', 'مشاركة');
  String get addedToSaved => _t('Added to your saved items', 'أُضيف إلى المحفوظات');
  String get removedFromSaved => _t('Removed from your saved items', 'أُزيل من المحفوظات');
  String get shareLinkCopied => _t('Product link copied', 'تم نسخ رابط المنتج');
  String get favoritesEyebrow => _t('SAVED FOR LATER', 'محفوظ للاحقاً');
  String get favoritesTitle => _t('Wishlist', 'المفضلة');
  String get favoritesEmptyTitle => _t('Nothing saved yet', 'لا يوجد شيء محفوظ بعد');
  String get favoritesEmptySubtitle =>
      _t('Tap the heart on any notebook to save it here.', 'اضغط على أيقونة القلب في أي منتج لحفظه هنا.');
  String get favoritesBrowseCta => _t('Browse notebooks', 'تصفح المنتجات');
  String get addToCart => _t('Add to cart', 'أضف إلى السلة');
  String addedToCart(String name) =>
      _t('Added "$name" to cart', 'تمت إضافة "$name" إلى السلة');
  String addedQtyToCart(int qty, String name) => _t(
        'Added $qty × "$name" to cart',
        'تمت إضافة $qty × "$name" إلى السلة',
      );
  String get continueShopping => _t('Continue shopping', 'إكمال التسوق');

  // Checkout
  String get checkoutTitle => _t('Checkout', 'إتمام الشراء');
  String get shippingDetails => _t('Shipping details', 'بيانات الشحن');
  String get fullName => _t('Full name', 'الاسم الكامل');
  String get email => _t('Email', 'البريد الإلكتروني');
  String get phoneNumber => _t('Phone number', 'رقم الهاتف');
  String get altPhone => _t('Alt. phone (optional)', 'رقم هاتف بديل (اختياري)');
  String get shippingAddress => _t('Shipping address', 'عنوان الشحن');
  String get payment => _t('Payment', 'الدفع');

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
        'Enter the InstaPay name you\'ll pay from below. Tap "Place '
        'order" and we\'ll open InstaPay for you to send the total — '
        'then use the "Open WhatsApp" button to confirm the order with us.',
        'اكتب اسم إنستاباي اللي هتحول منه تحت. اضغط "تنفيذ الطلب" '
        'وسنفتح لك إنستاباي لترسل قيمة الطلب — بعد كده استخدم زرار '
        '"افتح واتساب" لتأكيد الطلب معنا.',
      );
  String get vodafoneNoNumberNotice => _t(
        'The store hasn\'t set a Vodafone Cash number yet — place '
        'the order and we\'ll share it with you on WhatsApp.',
        'لم يقم المتجر بتحديد رقم فودافون كاش بعد — أكمل الطلب '
        'وسنرسله لك عبر واتساب.',
      );
  String vodafoneWithNumberNotice(String number) => _t(
        'Enter the Vodafone Cash number you\'ll transfer from '
        'below. Tap "Place order" and we\'ll open your Contacts with '
        '$number ready to save — then use the "Open WhatsApp" button '
        'to confirm the order with us.',
        'اكتب رقم فودافون كاش اللي هتحول منه تحت. اضغط "تنفيذ '
        'الطلب" وسنفتح لك جهات الاتصال برقم $number جاهزًا للحفظ — '
        'بعد كده استخدم زرار "افتح واتساب" لتأكيد الطلب معنا.',
      );

  String get instapaySenderLabel => _t('Your InstaPay name or number', 'اسم إنستاباي أو الرقم المحوّل منه');
  String get vodafoneSenderLabel => _t('Your Vodafone Cash number', 'رقم فودافون كاش اللي هتحول منه');
  String get instapaySenderHint => _t(
        'To respond to your order instantly, enter the number you transferred from or the sender name',
        'للاستجابة لطلبك بشكل فوري اكتب الرقم الذي تم تحويل منه المبلغ او اسم المرسل',
      );
  String get vodafoneSenderHint => _t(
        'To respond to your order instantly, enter the number you transferred from',
        'للاستجابة لطلبك بشكل فوري اكتب الرقم الذي تم تحويل منه المبلغ',
      );
  String get instapaySenderPlaceholder => _t('InstaPay name or number', 'اسم إنستاباي أو الرقم المحوّل منه');
  String get vodafoneSenderPlaceholder => _t('Vodafone Cash number', 'رقم فودافون كاش');
  String get senderInfoRequired => _t(
        'Enter the name/number you\'ll pay from',
        'اكتب الاسم أو الرقم اللي هتحول منه',
      );

  String get required => _t('Required', 'مطلوب');
  String get invalidEmail => _t('Enter a valid email', 'أدخل بريدًا إلكترونيًا صحيحًا');

  String get orderReview => _t('Order review', 'مراجعة الطلب');
  String get placeOrder => _t('Place order', 'تنفيذ الطلب');

  String get orderPlaced => _t('Order placed!', 'تم استلام طلبك!');
  String thanksMessage(String name) {
    final who = name.isEmpty ? _t('Thanks for shopping with us', 'شكرًا لتسوقك معنا') : _t('Thanks, $name', 'شكرًا لك يا $name');
    return _t(
      '$who! To confirm receipt of your order and get an instant response, please send a screenshot of the transfer on WhatsApp.',
      '$who! لتأكيد استلام الطلب والاستجابة بشكل فوري قم بإرسال صورة التحويل على واتساب.',
    );
  }
  String get openWhatsApp => _t(
        'Instant confirmation via WhatsApp',
        'تأكيد فوري عبر الواتساب',
      );
  String get backToShop => _t('Back to shop', 'العودة للتسوق');

  String couldntOpenWhatsApp(String err) =>
      _t('Couldn\'t open WhatsApp: $err', 'تعذر فتح واتساب: $err');
  String couldntOpenInstaPay(String err) =>
      _t('Couldn\'t open InstaPay: $err', 'تعذر فتح إنستاباي: $err');
  String couldntOpenContacts(String err) =>
      _t('Couldn\'t open Contacts: $err', 'تعذر فتح جهات الاتصال: $err');
  String couldntPlaceOrder(String err) =>
      _t('Couldn\'t place the order: $err', 'تعذر تنفيذ الطلب: $err');
  String get whoAmIEyebrow => _t('WHO AM I?', 'من أنا');
  // the embedded Services section used to, links down to the full "Who am
  // I" section below.
  String get viewFullProfile => _t('View full profile', 'شاهد الملف الشخصي كاملاً');

  // Home — shop preview section (teases the collection, hands off to the
  // standalone Shop tab)
  String get shopTheCollection => _t('Shop the collection', 'تسوق المجموعة');
  String get swipeProductsHint => _t('Swipe to see products', 'اسحب لعرض المنتجات');
  String get availableForEyebrow => _t('AVAILABLE FOR', 'متاحة للعمل مع');
  String get restaurantOwnersLabel => _t('Restaurant owners', 'أصحاب المطاعم');
  String get hotelOwnersLabel => _t('Hotel owners', 'أصحاب الفنادق');
  String get companyOwnersLabel => _t('Company owners', 'أصحاب الشركات');
  String get brandingLabel => _t('Branding', 'الهوية التجارية');
  String get illustrationClientsLabel => _t('Illustration', 'الرسوم التوضيحية');
  String get creativityLabel => _t('Creativity', 'الإبداع');
  String get privateWorkshopIndividualsLabel =>
      _t('Individuals — private workshops', 'الأفراد — ورش فردية');
  String get aspiringDesignersLabel => _t('Aspiring designers', 'المصممين الطموحين');
  String get contentCreatorsLabel => _t('Content creators', 'صناع المحتوى');
  String get projectsLabel => _t('PROJECTS', 'المشاريع');
  String get myWorksEyebrow => _t('MY WORKS', 'اعمالي');
  String get myWorksTitle => _t('A closer look at my work.', 'نظرة أقرب على أعمالي.');
  String get myWorksSubtitle => _t(
        'A selection of brand identity, packaging, advertising and '
        'illustration projects — tap any cover for the full case study.',
        'مجموعة مختارة من مشاريع الهوية التجارية والتغليف والإعلانات '
        'والرسوم التوضيحية',
      );
  String get clientsEyebrow => _t('CLIENTS', 'العملاء');
  String get clientsTitle => _t('Brands I\'ve worked with.', 'ثقة عملائي.');
  String get experienceLabel => _t('EXPERIENCE', 'الخبرات');
  String get educationLabel => _t('EDUCATION', 'التعليم');
  String get skillsLabel => _t('SKILLS', 'المهارات');
  String get certificatesLabel => _t('CERTIFICATES', 'الشهادات');
  String get tapToFlipHint => _t('View certificate', 'اعرض الشهادة');
  String get getInTouchLabel => _t('GET IN TOUCH', 'تواصل معايا');
  String get whatsappLabel => _t('WhatsApp', 'واتساب');
  String get contactNowLabel => _t('Contact now!', 'تواصل الآن!');
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
  AppText get strings => AppText(isArabicLanguage);
  AppText get stringsRead => AppText(languageController.isArabic);
}