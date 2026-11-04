import '../config/supabase_config.dart';
import '../models/coupon.dart';
import 'supabase_service.dart';

/// Discount codes. The admin dashboard uses the CRUD methods (they need a
/// signed-in admin — see the RLS policies in supabase/coupons.sql). The
/// storefront only ever uses [validate] and [redeem], which call
/// server-side functions and never expose the coupons table itself.
class CouponsRepository {
  // ---------------------------------------------------------------- admin

  static Future<List<Coupon>> fetchAll() async {
    if (!SupabaseConfig.isConfigured) return [];
    final data = await SupabaseService.client
        .from('coupons')
        .select()
        .order('created_at', ascending: false);
    return (data as List)
        .map((row) => Coupon.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Throws a PostgrestException with code '23505' if the code already exists.
  static Future<void> create(Coupon coupon) async {
    await SupabaseService.client.from('coupons').insert(coupon.toMap());
  }

  static Future<void> update(String id, Coupon coupon) async {
    await SupabaseService.client.from('coupons').update(coupon.toMap()).eq('id', id);
  }

  static Future<void> setActive(String id, bool active) async {
    await SupabaseService.client.from('coupons').update({'is_active': active}).eq('id', id);
  }

  static Future<void> delete(String id) async {
    await SupabaseService.client.from('coupons').delete().eq('id', id);
  }

  // ------------------------------------------------------------ storefront

  /// Checks a code against the cart subtotal. Changes nothing.
  static Future<CouponCheck> validate(String code, double subtotal) async {
    final res = await SupabaseService.client.rpc(
      'validate_coupon',
      params: {'p_code': code.trim(), 'p_subtotal': subtotal},
    );
    return CouponCheck.fromMap(Map<String, dynamic>.from(res as Map));
  }

  /// Checks the code again and counts one use. Only call this when the
  /// order is actually being placed.
  static Future<CouponCheck> redeem(String code, double subtotal) async {
    final res = await SupabaseService.client.rpc(
      'redeem_coupon',
      params: {'p_code': code.trim(), 'p_subtotal': subtotal},
    );
    return CouponCheck.fromMap(Map<String, dynamic>.from(res as Map));
  }
}
