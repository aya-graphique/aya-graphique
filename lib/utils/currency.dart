/// Central place for formatting money across the app. Everything is priced
/// and displayed in Egyptian Pounds (EGP) — change the symbol/format here
/// once and it updates everywhere the app shows a price.
String formatPrice(num amount) {
  return '${amount.toStringAsFixed(2)} EGP';
}
