/// How a coupon takes money off: a percentage of the subtotal, or a flat
/// amount in EGP.
enum CouponType { percent, fixed }

/// Where a coupon stands right now (computed in the app from its fields).
enum CouponStatus { active, inactive, scheduled, expired, exhausted }

/// A discount code as the admin sees it — mirrors a row in `coupons`.
class Coupon {
  final String id;
  final String code;
  final CouponType type;
  final double value;
  final double minOrder;
  final double? maxDiscount;
  final int? maxUses;
  final int usedCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  const Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.minOrder = 0,
    this.maxDiscount,
    this.maxUses,
    this.usedCount = 0,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  factory Coupon.fromMap(Map<String, dynamic> map) {
    DateTime? date(dynamic v) => v == null ? null : DateTime.parse(v as String);
    return Coupon(
      id: map['id'] as String,
      code: map['code'] as String? ?? '',
      type: map['discount_type'] == 'fixed' ? CouponType.fixed : CouponType.percent,
      value: (map['discount_value'] as num).toDouble(),
      minOrder: (map['min_order'] as num?)?.toDouble() ?? 0,
      maxDiscount: (map['max_discount'] as num?)?.toDouble(),
      maxUses: (map['max_uses'] as num?)?.toInt(),
      usedCount: (map['used_count'] as num?)?.toInt() ?? 0,
      startDate: date(map['start_date']),
      endDate: date(map['end_date']),
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  /// The columns to write to Supabase (used for both insert and update).
  Map<String, dynamic> toMap() => {
        'code': code.trim().toUpperCase(),
        'discount_type': type == CouponType.fixed ? 'fixed' : 'percent',
        'discount_value': value,
        'min_order': minOrder,
        'max_discount': type == CouponType.percent ? maxDiscount : null,
        'max_uses': maxUses,
        'start_date': startDate == null ? null : formatDateOnly(startDate!),
        'end_date': endDate == null ? null : formatDateOnly(endDate!),
        'is_active': isActive,
      };

  CouponStatus get status {
    if (!isActive) return CouponStatus.inactive;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (startDate != null && today.isBefore(_dayOnly(startDate!))) {
      return CouponStatus.scheduled;
    }
    if (endDate != null && today.isAfter(_dayOnly(endDate!))) {
      return CouponStatus.expired;
    }
    if (maxUses != null && usedCount >= maxUses!) return CouponStatus.exhausted;
    return CouponStatus.active;
  }

  Coupon copyWith({bool? isActive}) => Coupon(
        id: id,
        code: code,
        type: type,
        value: value,
        minOrder: minOrder,
        maxDiscount: maxDiscount,
        maxUses: maxUses,
        usedCount: usedCount,
        startDate: startDate,
        endDate: endDate,
        isActive: isActive ?? this.isActive,
      );

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// 'yyyy-MM-dd' — the format Postgres `date` columns expect.
String formatDateOnly(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// A code the shopper has successfully applied to their cart. Holds just
/// enough to show a live discount in the cart; the server re-checks and
/// recalculates it for real when the order is placed.
class AppliedCoupon {
  final String code;
  final CouponType type;
  final double value;
  final double minOrder;
  final double? maxDiscount;

  const AppliedCoupon({
    required this.code,
    required this.type,
    required this.value,
    this.minOrder = 0,
    this.maxDiscount,
  });

  factory AppliedCoupon.fromMap(Map<String, dynamic> map) => AppliedCoupon(
        code: map['code'] as String,
        type: map['type'] == 'fixed' ? CouponType.fixed : CouponType.percent,
        value: (map['value'] as num).toDouble(),
        minOrder: (map['min_order'] as num?)?.toDouble() ?? 0,
        maxDiscount: (map['max_discount'] as num?)?.toDouble(),
      );

  /// Same maths as `validate_coupon` in supabase/coupons.sql, so the cart
  /// can update instantly as quantities change.
  double discountFor(double subtotal) {
    if (subtotal <= 0 || subtotal < minOrder) return 0;
    var d = type == CouponType.percent ? subtotal * value / 100 : value;
    if (type == CouponType.percent && maxDiscount != null && d > maxDiscount!) {
      d = maxDiscount!;
    }
    d = (d * 100).roundToDouble() / 100;
    return d > subtotal ? subtotal : d;
  }
}

/// The server's answer to "is this code OK for this cart?".
class CouponCheck {
  final bool valid;

  /// not_found | inactive | not_started | expired | exhausted | min_order
  final String reason;
  final double minOrder;
  final double discount;
  final AppliedCoupon? coupon;

  const CouponCheck({
    required this.valid,
    this.reason = '',
    this.minOrder = 0,
    this.discount = 0,
    this.coupon,
  });

  factory CouponCheck.fromMap(Map<String, dynamic> map) {
    final ok = map['valid'] == true;
    return CouponCheck(
      valid: ok,
      reason: map['reason'] as String? ?? '',
      minOrder: (map['min_order'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      coupon: ok ? AppliedCoupon.fromMap(map) : null,
    );
  }
}

/// Thrown by order creation when the applied code stopped being valid
/// between "Apply" and "Place order" (expired, used up, etc.).
class CouponException implements Exception {
  final String reason;
  final double minOrder;
  const CouponException(this.reason, {this.minOrder = 0});

  @override
  String toString() => 'CouponException($reason)';
}
