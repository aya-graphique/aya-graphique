import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../models/service_override.dart';
import '../providers/language_controller.dart';
import '../services/services_repository.dart';
import '../services/settings_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_heading.dart';

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

class GraphicalServicesScreen extends StatefulWidget {
  final bool isMobile;

  const GraphicalServicesScreen({super.key, required this.isMobile});

  @override
  State<GraphicalServicesScreen> createState() => _GraphicalServicesScreenState();
}

class _GraphicalServicesScreenState extends State<GraphicalServicesScreen> {
  String _ownerWhatsapp = '';
  Map<String, ServiceOverride> _overrides = {};

  // Single-open accordion: which category is expanded, and which item
  // (identified as "categoryIndex-itemIndex") is expanded inside it.
  int? _openCategory = 0;
  String? _openItemKey;

  @override
  void initState() {
    super.initState();
    _loadWhatsapp();
    _loadOverrides();
  }

  Future<void> _loadWhatsapp() async {
    final number = await SettingsRepository.fetchOwnerWhatsapp();
    if (!mounted) return;
    setState(() => _ownerWhatsapp = number);
  }

  Future<void> _loadOverrides() async {
    final overrides = await ServicesRepository.fetchOverrides();
    if (!mounted) return;
    setState(() => _overrides = overrides);
  }

  void _toggleCategory(int index) {
    setState(() {
      if (_openCategory == index) {
        _openCategory = null;
      } else {
        _openCategory = index;
      }
      _openItemKey = null;
    });
  }

  void _toggleItem(String key) {
    setState(() => _openItemKey = _openItemKey == key ? null : key);
  }

  Future<void> _bookService(String title) async {
    debugPrint('[GraphicalServices] Book tapped for "$title", whatsapp="$_ownerWhatsapp"');
    try {
      // context.strings uses Provider's `watch`, which only works during a
      // widget's build phase — calling it from an event handler like this
      // one (after the build is long finished) throws an assertion. `read`
      // is the correct call here: we just need the current value once,
      // not to be rebuilt when it changes.
      final isArabic = context.read<LanguageController>().isArabic;
      final strings = AppText(isArabic);
      if (_ownerWhatsapp.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.servicesWhatsappNotSet)),
        );
        return;
      }
      final message = Uri.encodeComponent(strings.serviceBookingMessage(title));
      final uri = Uri.parse('https://wa.me/$_ownerWhatsapp?text=$message');
      debugPrint('[GraphicalServices] Launching $uri');
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('[GraphicalServices] launchUrl returned $launched');
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.couldntOpenWhatsApp('launchUrl returned false'))),
        );
      }
    } catch (e, st) {
      debugPrint('[GraphicalServices] Error booking service: $e\n$st');
      if (!mounted) return;
      final isArabic = context.read<LanguageController>().isArabic;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText(isArabic).couldntOpenWhatsApp('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.isMobile;
    final isArabic = context.watch<LanguageController>().isArabic;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 60, isMobile ? 120 : 150, isMobile ? 20 : 60, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            eyebrow: context.strings.servicesEyebrow,
            title: context.strings.servicesTitle,
            subtitle: context.strings.servicesSubtitle,
            boostArabicSize: false,
          ),
          const SizedBox(height: 44),
          Column(
            children: [
              for (var i = 0; i < kServiceCategories.length; i++) ...[
                RevealOnScroll(
                  child: _CategoryCard(
                    index: i,
                    category: kServiceCategories[i],
                    items: [
                      for (var j = 0; j < kServiceCategories[i].items.length; j++)
                        applyServiceOverride(kServiceCategories[i].items[j], _overrides[serviceItemKey(i, j)]),
                    ],
                    isMobile: isMobile,
                    isArabic: isArabic,
                    isOpen: _openCategory == i,
                    openItemKey: _openItemKey,
                    onToggle: () => _toggleCategory(i),
                    onToggleItem: _toggleItem,
                    onBook: _bookService,
                  ),
                ),
                if (i != kServiceCategories.length - 1) const SizedBox(height: 20),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// One of the 3 top-level tracks. Tapping the header expands/collapses the
/// list of items underneath it.
class _CategoryCard extends StatelessWidget {
  final int index;
  final ServiceCategory category;
  // The category's items with any owner-saved overrides already merged in
  // — pass this instead of reading category.items directly.
  final List<ServiceItem> items;
  final bool isMobile;
  final bool isArabic;
  final bool isOpen;
  final String? openItemKey;
  final VoidCallback onToggle;
  final ValueChanged<String> onToggleItem;
  final ValueChanged<String> onBook;

  const _CategoryCard({
    required this.index,
    required this.category,
    required this.items,
    required this.isMobile,
    required this.isArabic,
    required this.isOpen,
    required this.openItemKey,
    required this.onToggle,
    required this.onToggleItem,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.themeController.isDark;
    final numeral = (index + 1).toString().padLeft(2, '0');
    final title = category.title.t(isArabic);
    final intro = category.intro.t(isArabic);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceRaised.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.cream.withOpacity(isOpen ? 0.16 : 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 18 : 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    numeral,
                    style: AppFonts.display(
                      // Cream is near-white in dark mode, so a faint 0.14
                      // opacity still reads as a soft ghost numeral. In
                      // light mode cream is dark ink instead, and the same
                      // low opacity against a white card washes out almost
                      // entirely — so it needs a stronger opacity there to
                      // stay visible.
                      color: colors.cream.withOpacity(isDark ? 0.14 : 0.32),
                      size: isMobile ? 40 : 52,
                      weight: FontWeight.w800,
                      height: 1,
                      boostArabicSize: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: colors.violetGradient,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 21),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppFonts.display(
                            color: colors.cream,
                            size: isMobile ? 20 : 25,
                            weight: FontWeight.w700,
                            text: title,
                            boostArabicSize: false,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          intro,
                          style: AppFonts.body(color: colors.creamDim, size: 13.5, height: 1.6, text: intro, boostArabicSize: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: colors.creamDim, size: 26),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: isOpen
                ? Padding(
                    padding: EdgeInsets.fromLTRB(isMobile ? 14 : 22, 0, isMobile ? 14 : 22, isMobile ? 14 : 22),
                    child: Column(
                      children: [
                        for (var j = 0; j < items.length; j++) ...[
                          _ItemRow(
                            itemIndex: j,
                            item: items[j],
                            isMobile: isMobile,
                            isArabic: isArabic,
                            isOpen: openItemKey == '$index-$j',
                            onToggle: () => onToggleItem('$index-$j'),
                            onBook: onBook,
                          ),
                          if (j != items.length - 1) const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// One bookable item inside a category. Tapping it expands to reveal the
/// full description, highlights, and pricing, plus a WhatsApp booking
/// button.
class _ItemRow extends StatelessWidget {
  final int itemIndex;
  final ServiceItem item;
  final bool isMobile;
  final bool isArabic;
  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<String> onBook;

  const _ItemRow({
    required this.itemIndex,
    required this.item,
    required this.isMobile,
    required this.isArabic,
    required this.isOpen,
    required this.onToggle,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = item.title.t(isArabic);
    final subtitle = item.subtitle?.t(isArabic);
    final description = item.description?.t(isArabic);
    final note = item.note?.t(isArabic);
    final numeral = (itemIndex + 1).toString().padLeft(2, '0');

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cream.withOpacity(isOpen ? 0.14 : 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    numeral,
                    style: AppFonts.label(color: colors.violetPop, size: 12, letterSpacing: 1, boostArabicSize: false),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppFonts.body(
                            color: colors.cream,
                            size: 15.5,
                            weight: FontWeight.w700,
                            text: title,
                            boostArabicSize: false,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: AppFonts.body(color: colors.creamDim, size: 12.5, text: subtitle, boostArabicSize: false),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(Icons.expand_more_rounded, color: colors.creamDim, size: 22),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: isOpen
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 1, color: colors.cream.withOpacity(0.08)),
                        const SizedBox(height: 14),
                        if (description != null) ...[
                          Text(
                            description,
                            style: AppFonts.body(color: colors.creamDim, size: 13.5, height: 1.7, text: description, boostArabicSize: false),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (item.highlights.isNotEmpty) ...[
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final h in item.highlights)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: colors.violetPop.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    h.t(isArabic),
                                    style: AppFonts.body(color: colors.creamDim, size: 12, text: h.t(isArabic), boostArabicSize: false),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (item.priceLines.isNotEmpty) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final p in item.priceLines)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    p.t(isArabic),
                                    style: AppFonts.body(
                                      color: colors.orchid,
                                      size: 14,
                                      weight: FontWeight.w700,
                                      text: p.t(isArabic),
                                      boostArabicSize: false,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (note != null) ...[
                          Text(
                            note,
                            style: AppFonts.body(
                              color: colors.creamDim.withOpacity(0.75),
                              size: 12,
                              text: note,
                              boostArabicSize: false,
                            ).copyWith(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 14),
                        ],
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onBook(title),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: colors.violetGradient,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.violetPop.withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat_bubble_rounded, size: 15, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  context.strings.bookSession,
                                  style: AppFonts.label(size: 12, color: Colors.white, letterSpacing: 0.6, boostArabicSize: false)
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
