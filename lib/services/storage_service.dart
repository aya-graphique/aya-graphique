import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Uploads product photos to the `product-images` Supabase Storage bucket
/// and hands back a public URL to store on the product row.
///
/// Requires the bucket + policies created in `supabase/schema.sql`
/// (search for "product-images").
class StorageService {
  static const String bucket = 'product-images';

  /// Bucket for the "Who am I" page's top slideshow photos. See
  /// `supabase/schema.sql` (search for "about-images").
  static const String aboutBucket = 'about-images';

  /// Bucket for the promotional banner strip on the Home page. See
  /// `supabase/schema.sql` (search for "home-banner-images").
  static const String homeBannerBucket = 'home-banner-images';

  static Future<String> uploadProductImage(Uint8List bytes, String fileName) {
    return _upload(bucket, bytes, fileName);
  }

  /// Category thumbnails reuse the `product-images` bucket — it's already
  /// public-read with authenticated write, and a dedicated bucket would
  /// just mean another policy set to keep in sync for no real benefit.
  static Future<String> uploadCategoryImage(Uint8List bytes, String fileName) {
    return _upload(bucket, bytes, fileName);
  }

  /// Same reasoning as [uploadCategoryImage] — the three fixed service
  /// category thumbnails (Mentoring / Designing / Private Workshop) reuse
  /// this same bucket rather than getting one of their own.
  static Future<String> uploadServiceCategoryImage(Uint8List bytes, String fileName) {
    return _upload(bucket, bytes, fileName);
  }

  /// Same reasoning as [uploadCategoryImage] — the owner-managed
  /// "Illustration & Art" circles reuse this same bucket rather than
  /// getting one of their own.
  static Future<String> uploadIllustrationArtImage(Uint8List bytes, String fileName) {
    return _upload(bucket, bytes, fileName);
  }

  static Future<String> uploadAboutImage(Uint8List bytes, String fileName) {
    return _upload(aboutBucket, bytes, fileName);
  }

  static Future<String> uploadHomeBannerImage(Uint8List bytes, String fileName) {
    return _upload(homeBannerBucket, _shrinkForBanner(bytes), fileName);
  }

  // Banner photos come straight off a phone camera (often 3000px+ wide,
  // several MB) but only ever display at a fraction of that size in the
  // banner strip — see HomeBannerSlideshow. Uploading them full-size is
  // what made both the upload itself and every later page load of the
  // banner strip slow. This caps width at 1600px (plenty for even a large
  // desktop hero) and re-encodes as JPEG at quality 85, which is usually a
  // 5-10x size drop for a typical photo with no visible quality loss.
  // Falls back to the original bytes if decoding fails for any reason
  // (e.g. an unusual format) so a bad image never blocks the upload.
  static Uint8List _shrinkForBanner(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;
      final resized = decoded.width > 1600 ? img.copyResize(decoded, width: 1600) : decoded;
      return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
    } catch (_) {
      return bytes;
    }
  }

  static Future<String> _upload(String bucketName, Uint8List bytes, String fileName) async {
    // Prefix with a timestamp so two uploads with the same original file
    // name (e.g. two photos both called "IMG_0001.jpg") never collide.
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = '${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await SupabaseService.client.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return SupabaseService.client.storage.from(bucketName).getPublicUrl(path);
  }
}
