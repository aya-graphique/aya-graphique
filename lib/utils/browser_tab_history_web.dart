import 'dart:html' as html;

/// See browser_tab_history.dart for why this exists. Pushes one no-op
/// history entry (same URL, just a marker) so the browser's native back
/// button/gesture has something of ours to pop before it leaves the page.
void pushTabHistoryEntry() {
  html.window.history.pushState(null, '', html.window.location.href);
}

/// Fires once per physical back press, for as long as there are entries
/// [pushTabHistoryEntry] added still unpopped. Returns a function that
/// cancels the subscription.
void Function() listenForBack(void Function() onBack) {
  final subscription = html.window.onPopState.listen((_) => onBack());
  return subscription.cancel;
}
