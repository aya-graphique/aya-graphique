import 'package:flutter/material.dart';
import '../models/service_override.dart';

/// The design-services catalog: categories, items, pricing copy, and the
/// owner-override merge helper.
///
/// This used to live inside the storefront's own services page
/// (`graphical_services_screen.dart`), but that page was retired — the
/// storefront now only teases a handful of shop categories on the "Who am
/// I" page and sends shoppers to WhatsApp directly from there. This data
/// (and the merge helper below) is kept purely so the admin dashboard's
/// "Services" tab — where the owner edits this copy/pricing — still has
/// something to read and write. If that admin tab is ever retired too,
/// this file (and `services_repository.dart` / `ServiceOverride`) can go
/// with it.

/// A short bilingual string pair. `.t(isArabic)` picks the right one, and
/// passing that same string into `AppFonts.*(text: ...)` auto-switches the
/// typeface (Cairo for Arabic, Poppins for Latin) — see app_theme.dart.
class Bi {
  final String en;
  final String ar;
  const Bi(this.en, this.ar);
  String t(bool isArabic) => isArabic ? ar : en;
}

/// One bookable item inside a [ServiceCategory] (e.g. "Logo Design" inside
/// "Designing", or "Advertising Designs" inside "Private Workshop").
class ServiceItem {
  final Bi title;
  final Bi? subtitle;
  final Bi? description;
  final List<Bi> highlights;

  /// Each line is a full, ready-to-read price line, e.g. "10 designs =
  /// 14,000 L.E" or "15,000 L.E". Kept as separate lines rather
  /// than one string so tiered pricing lists out cleanly.
  final List<Bi> priceLines;

  /// Small follow-up note shown under the price, e.g. a discount note or
  /// "Click to open the brief form".
  final Bi? note;

  const ServiceItem({
    required this.title,
    this.subtitle,
    this.description,
    this.highlights = const [],
    this.priceLines = const [],
    this.note,
  });
}

/// One of the three top-level tracks on the services page: Mentoring,
/// Designing, and Private Workshop — each expands to reveal its own items.
///
/// To edit copy or pricing: change the entries in [kServiceCategories]
/// below. Nothing else in the file needs to change — numbering and layout
/// are generated from however many categories/items are here.
class ServiceCategory {
  final IconData icon;
  final Bi title;
  final Bi intro;
  final List<ServiceItem> items;

  const ServiceCategory({
    required this.icon,
    required this.title,
    required this.intro,
    required this.items,
  });
}

const List<ServiceCategory> kServiceCategories = [
  // 1 — Mentoring
  ServiceCategory(
    icon: Icons.support_agent_rounded,
    title: Bi('Mentoring', 'الإرشاد المهني'),
    intro: Bi(
      'One-on-one career guidance for designers and design students — '
      'portfolio direction, career decisions, and the practical questions '
      'a design degree doesn\'t always answer.',
      'إرشاد مهني فردي للمصممين وطلاب التصميم — توجيه بخصوص البورتفوليو، '
      'القرارات المهنية، والأسئلة العملية التي لا تُجيب عنها الدراسة '
      'الأكاديمية دائمًا.',
    ),
    items: [
      ServiceItem(
        title: Bi('1-on-1 Mentoring Session', 'جلسة إرشاد فردية'),
        subtitle: Bi('Career guidance & portfolio review', 'إرشاد مهني ومراجعة أعمال'),
        description: Bi(
          'A live video call to talk through your portfolio, your next '
          'career step, or a specific challenge you\'re facing as a '
          'designer — practical, personalised advice rather than generic '
          'tips.',
          'مكالمة فيديو مباشرة لمناقشة أعمالك، خطوتك المهنية القادمة، أو '
          'تحديًا معينًا تواجهه كمصمم — نصائح عملية ومخصصة لك، وليست '
          'نصائح عامة.',
        ),
        highlights: [
          Bi('45–60 min call', 'مدة الجلسة 45–60 دقيقة'),
          Bi('Portfolio & CV feedback', 'ملاحظات على البورتفوليو والسيرة الذاتية'),
          Bi('Personalised action plan', 'خطة عمل مخصصة'),
        ],
      ),
    ],
  ),

  // 2 — Designing
  ServiceCategory(
    icon: Icons.brush_rounded,
    title: Bi('Designing', 'التصميم'),
    intro: Bi(
      'Everything from a single logo to a full stationery, packaging, or '
      'advertising system — scoped and priced up front.',
      'من شعار واحد إلى نظام كامل من القرطاسية أو التغليف أو الإعلانات — '
      'بنطاق وسعر واضحين من البداية.',
    ),
    items: [
      ServiceItem(
        title: Bi('Logo Design', 'تصميم الشعار'),
        subtitle: Bi('New brand or rebranding', 'علامة تجارية جديدة أو إعادة تصميم'),
        highlights: [
          Bi('2 concept options', 'خياران للتصميم'),
          Bi('Moodboard', 'لوحة إلهام'),
          Bi('Brand guidelines', 'دليل استخدام الهوية'),
          Bi('Colour palette', 'لوحة ألوان'),
          Bi('Fonts', 'خطوط'),
        ],
        priceLines: [Bi('15,000 L.E', '15,000 ج.م')],
        note: Bi('Click "Book via WhatsApp" to open the brief form', 'اضغط "احجز عبر واتساب" لفتح استمارة البريف'),
      ),
      ServiceItem(
        title: Bi('Stationery', 'القرطاسية'),
        subtitle: Bi('Business cards, letterheads, ..etc', 'كروت شخصية، أوراق رسمية، ..إلخ'),
        highlights: [
          Bi('Business cards', 'كروت شخصية'),
          Bi('Letterheads', 'أوراق رسمية'),
          Bi('Envelopes (4 sizes)', 'مظاريف (4 مقاسات)'),
          Bi('Notepads', 'دفاتر ملاحظات'),
          Bi('Folders (A4 & A5)', 'فولدرات (A4 و A5)'),
          Bi('Brochure', 'بروشور'),
          Bi('Pens & pencils', 'أقلام'),
          Bi('Sticky notes', 'أوراق لاصقة'),
          Bi('Wall calendar', 'تقويم حائط'),
          Bi('Flyer', 'فلاير'),
          Bi('Desktop calendar', 'تقويم مكتبي'),
          Bi('Notebooks', 'دفاتر'),
          Bi('Invoice books', 'دفاتر فواتير'),
          Bi('Stamp', 'ختم'),
          Bi('Bookmarks', 'فواصل كتب'),
        ],
        priceLines: [Bi('8,000 L.E', '8,000 ج.م')],
        note: Bi('15 elements included · click "Book via WhatsApp" for designs', '15 عنصرًا مشمولة · اضغط "احجز عبر واتساب" لمشاهدة التصميمات'),
      ),
      ServiceItem(
        title: Bi('Packaging Design', 'تصميم التغليف'),
        subtitle: Bi('For sweets brands, restaurants, games', 'لعلامات الحلويات، المطاعم، والألعاب'),
        priceLines: [Bi('Starts from 1,450 L.E', 'يبدأ من 1,450 ج.م')],
      ),
      ServiceItem(
        title: Bi('Outdoor & Indoor', 'إعلانات خارجية وداخلية'),
        subtitle: Bi('Billboards, sussetta, banners, rollups, ..etc', 'بيل بورد، سوسيتة، بانر، رول أب، ..إلخ'),
        note: Bi('Size starts from 100 cm', 'المقاس يبدأ من 100 سم'),
        priceLines: [
          Bi('10 designs = 14,000 L.E', '10 تصميمات = 14,000 ج.م'),
          Bi('15 designs = 17,000 L.E', '15 تصميم = 17,000 ج.م'),
          Bi('25 designs = 26,500 L.E', '25 تصميم = 26,500 ج.م'),
          Bi('30 designs = 30,500 L.E', '30 تصميم = 30,500 ج.م'),
        ],
      ),
      ServiceItem(
        title: Bi('Digital Designs', 'تصميمات رقمية'),
        subtitle: Bi('Social media, website, apps, screens, ..etc', 'سوشيال ميديا، مواقع، تطبيقات، شاشات، ..إلخ'),
        priceLines: [
          Bi('10 designs = 4,000 L.E', '10 تصميمات = 4,000 ج.م'),
          Bi('15 designs = 5,000 L.E', '15 تصميم = 5,000 ج.م'),
          Bi('25 designs = 8,500 L.E', '25 تصميم = 8,500 ج.م'),
        ],
      ),
      ServiceItem(
        title: Bi('Illustration Art', 'رسوم توضيحية'),
        subtitle: Bi('For packaging printing & digital uses', 'للطباعة على التغليف والاستخدامات الرقمية'),
        note: Bi('Custom quote — book a call to discuss scope', 'عرض سعر مخصص — احجز مكالمة لمناقشة النطاق'),
      ),
      ServiceItem(
        title: Bi('Advertising Design', 'تصميم إعلاني'),
        subtitle: Bi('For social media and printing', 'للسوشيال ميديا والطباعة'),
        priceLines: [
          Bi('10 designs = 4,000 L.E', '10 تصميمات = 4,000 ج.م'),
          Bi('15 designs = 5,000 L.E', '15 تصميم = 5,000 ج.م'),
          Bi('25 designs = 8,500 L.E', '25 تصميم = 8,500 ج.م'),
        ],
      ),
      ServiceItem(
        title: Bi('Company Profile & Books', 'بروفايل الشركة والكتيبات'),
        priceLines: [Bi('Starts from 4,000 L.E', 'يبدأ من 4,000 ج.م')],
      ),
    ],
  ),

  // 3 — Private Workshop
  ServiceCategory(
    icon: Icons.school_rounded,
    title: Bi('Private Workshop', 'الورشة الفردية'),
    intro: Bi(
      'One-on-one training that bridges what the job market expects with '
      'what\'s taught academically at the Faculty of Applied Arts, '
      'Advertising Department. Subscribe to more than one track and get '
      '10% off.',
      'تهدف الورشة الفردية للجمع ما بين المهارات المطلوبة في سوق العمل '
      'والمهارات التي يتم تدريسها أكاديميًا بكلية الفنون التطبيقية، قسم '
      'الإعلان. عند الاشتراك في أكثر من تخصص تحصل على خصم 10%.',
    ),
    items: [
      ServiceItem(
        title: Bi('Advertising Designs', 'تصميم الإعلانات التجارية'),
        description: Bi(
          '7 individual, interactive training hours — live weekly on '
          'Google Meet and recorded — covering social media and '
          'advertising design in theory and practice: perspective, '
          'colour, type, composition, mass and space, and visual '
          'hierarchy, plus how it ties to marketing so you know which '
          'design fits which target audience. Hours are counted from '
          'your logged attendance time until the booked hours are used '
          'up.',
          '7 ساعات تدريبية فردية تفاعلية، مباشرة أسبوعيًا على جوجل ميت '
          'ومسجلة، يتم من خلالها تعلم تصميمات السوشيال ميديا والتصميمات '
          'الإعلانية نظريًا وعمليًا: اختيار المنظور والألوان والخطوط '
          'والدمج بين العناصر والتكوين والكتلة والفراغ والتدرج البصري، '
          'والربط بمجال التسويق لمعرفة التصميم المناسب حسب الفئة '
          'المستهدفة. يُحتسب الوقت بجمع مدة حضورك المسجلة حتى انتهاء عدد '
          'الساعات المحجوزة.',
        ),
        highlights: [
          Bi('7 training hours', '7 ساعات تدريبية'),
          Bi('Live weekly + recorded', 'مباشر أسبوعيًا + مسجل'),
          Bi('10% off for 2+ tracks', 'خصم 10% عند اشتراك أكثر من تخصص'),
        ],
        priceLines: [Bi('5,000 L.E', '5,000 ج.م')],
      ),
      ServiceItem(
        title: Bi('Visual Identity', 'تصميم الهويات البصرية'),
        description: Bi(
          '7 individual, interactive training hours — live weekly on '
          'Google Meet and recorded — covering logo design and its types, '
          'the golden ratio and grid systems in theory and practice, and '
          'turning an initial sketch into a digital design while applying '
          'colour, type, and composition rules. Also covers how to write '
          'and request a brief from a client, and how to design the '
          'pattern that extends a logo into a full visual identity. '
          'Hours are counted from your logged attendance time until the '
          'booked hours are used up.',
          '7 ساعات تدريبية فردية تفاعلية، مباشرة أسبوعيًا على جوجل ميت '
          'ومسجلة، يتم من خلالها تعلم تصميم الشعارات وأنواعها من حيث '
          'طريقة التصميم والتعرف على النسبة الذهبية والشبكية نظريًا '
          'وعمليًا، وتحويل السكتش المبدئي لتصميم رقمي مع تطبيق قواعد '
          'التصميم من حيث الألوان والخطوط والدمج بين العناصر والتكوين '
          'والكتلة والفراغ، وشرح البريف وطريقة طلبه من العميل، وطريقة '
          'تصميم الباترن للهوية البصرية المرتبطة بالشعار. يُحتسب الوقت '
          'بجمع مدة حضورك المسجلة حتى انتهاء عدد الساعات المحجوزة.',
        ),
        highlights: [
          Bi('7 training hours', '7 ساعات تدريبية'),
          Bi('Live weekly + recorded', 'مباشر أسبوعيًا + مسجل'),
          Bi('10% off for 2+ tracks', 'خصم 10% عند اشتراك أكثر من تخصص'),
        ],
        priceLines: [Bi('5,000 L.E', '5,000 ج.م')],
      ),
      ServiceItem(
        title: Bi('Packaging Designs', 'تصميم المطبوعات والأغلفة'),
        description: Bi(
          '7 individual, interactive training hours — live weekly on '
          'Google Meet and recorded — covering how to apply a logo to '
          'prints and packaging with a design that stays consistent with '
          'the brand\'s visual identity, including an explanation of '
          'die-cutting, in theory and practice, while applying colour, '
          'type, and composition rules. Hours are counted from your '
          'logged attendance time until the booked hours are used up.',
          '7 ساعات تدريبية فردية تفاعلية، مباشرة أسبوعيًا على جوجل ميت '
          'ومسجلة، يتم من خلالها تعلم تطبيق الشعارات على المطبوعات '
          'والأغلفة مع وضع تصميم مترابط مع الشعار ومناسب للهوية البصرية، '
          'مع شرح الإفراد (Diecut) نظريًا وعمليًا مع تطبيق قواعد التصميم '
          'من حيث الألوان والخطوط والدمج بين العناصر والتكوين والكتلة '
          'والفراغ. يُحتسب الوقت بجمع مدة حضورك المسجلة حتى انتهاء عدد '
          'الساعات المحجوزة.',
        ),
        highlights: [
          Bi('7 training hours', '7 ساعات تدريبية'),
          Bi('Live weekly + recorded', 'مباشر أسبوعيًا + مسجل'),
          Bi('10% off for 2+ tracks', 'خصم 10% عند اشتراك أكثر من تخصص'),
        ],
        priceLines: [Bi('5,000 L.E', '5,000 ج.م')],
      ),
    ],
  ),
];

/// The stable id an item's owner-editable override is stored under. Safe
/// to compute from position because categories/items are fixed in code —
/// only their copy and pricing can change from the dashboard.
String serviceItemKey(int categoryIndex, int itemIndex) => '$categoryIndex-$itemIndex';

/// Merges a saved [ServiceOverride] on top of an item's original hardcoded
/// copy. Each field is swapped in only once the owner has actually typed
/// something into it — an override that only fills in a new price, say,
/// leaves the title/description/highlights showing their original text.
ServiceItem applyServiceOverride(ServiceItem base, ServiceOverride? o) {
  if (o == null) return base;
  return ServiceItem(
    title: (o.title.isNotEmpty || o.titleAr.isNotEmpty)
        ? Bi(o.title.isNotEmpty ? o.title : base.title.en, o.titleAr.isNotEmpty ? o.titleAr : base.title.ar)
        : base.title,
    subtitle: (o.subtitle.isNotEmpty || o.subtitleAr.isNotEmpty)
        ? Bi(o.subtitle.isNotEmpty ? o.subtitle : (base.subtitle?.en ?? ''),
            o.subtitleAr.isNotEmpty ? o.subtitleAr : (base.subtitle?.ar ?? ''))
        : base.subtitle,
    description: (o.description.isNotEmpty || o.descriptionAr.isNotEmpty)
        ? Bi(o.description.isNotEmpty ? o.description : (base.description?.en ?? ''),
            o.descriptionAr.isNotEmpty ? o.descriptionAr : (base.description?.ar ?? ''))
        : base.description,
    highlights: o.highlights.isNotEmpty
        ? [
            for (var i = 0; i < o.highlights.length; i++)
              Bi(o.highlights[i], i < o.highlightsAr.length && o.highlightsAr[i].isNotEmpty ? o.highlightsAr[i] : o.highlights[i]),
          ]
        : base.highlights,
    priceLines: o.priceLines.isNotEmpty
        ? [
            for (var i = 0; i < o.priceLines.length; i++)
              Bi(o.priceLines[i], i < o.priceLinesAr.length && o.priceLinesAr[i].isNotEmpty ? o.priceLinesAr[i] : o.priceLines[i]),
          ]
        : base.priceLines,
    note: (o.note.isNotEmpty || o.noteAr.isNotEmpty)
        ? Bi(o.note.isNotEmpty ? o.note : (base.note?.en ?? ''), o.noteAr.isNotEmpty ? o.noteAr : (base.note?.ar ?? ''))
        : base.note,
  );
}
