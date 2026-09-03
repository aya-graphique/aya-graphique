int _routeSeq = 0;

/// Generates a unique [RouteSettings] name for a Navigator.push call.
///
/// Nearly every push in this app (ProductDetailScreen, ProjectDetailScreen,
/// CheckoutScreen, the project lightbox, the admin sub-pages...) used to be
/// pushed with no RouteSettings at all. On Flutter Web, two anonymous (or
/// identically-named) routes pushed back to back can look like the *same*
/// entry to the browser-history layer that the physical/browser back
/// button talks to — which is exactly what lets a single back press
/// overshoot and pop more than one route at once (e.g. My Works -> a
/// project -> its photo lightbox -> back once correctly closes the
/// lightbox, but back again skips the project page entirely and exits the
/// site) instead of stepping back through them one at a time.
///
/// Giving every push its own distinct name — the same fix already used for
/// MainShell's tab-marker routes (see _TabMarkerRoute in main_shell.dart)
/// — avoids that everywhere else in the app too. `label` is only for
/// readability if you ever inspect the URL/history; it doesn't need to be
/// unique on its own, the counter guarantees that.
String uniqueRouteName(String label) => '/__route-$label-${_routeSeq++}';
