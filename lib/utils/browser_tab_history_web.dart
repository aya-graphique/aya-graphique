import 'dart:html' as html;

/// Monotonically increasing "how many entries have we pushed" counter,
/// stored *inside* each pushState call (see below) rather than trusting
/// each popstate to mean exactly "one step back". Mobile browsers
/// (notably iOS Safari, and some Android back/forward-cache restores)
/// can fire an extra or stale popstate that doesn't correspond to a real
/// user back-press; if the listener just blindly popped one tab per
/// event, that alone was enough to desync the count from the browser's
/// real position and make back presses jump straight to Home instead of
/// stepping back one tab at a time. Reading the depth back out of
/// event.state instead makes every popstate self-correcting: callers
/// compare it against what they think the depth should be and adjust by
/// however many steps are actually needed, instead of always assuming 1.
int _depth = 0;

/// See browser_tab_history.dart for why this exists. Pushes one no-op
/// history entry (same URL, just a marker carrying the new depth) so the
/// browser's native back button/gesture has something of ours to pop
/// before it leaves the page.
void pushTabHistoryEntry() {
  _depth++;
  html.window.history.pushState(_depth, '', html.window.location.href);
}

/// Fires once per physical back (or forward) press, for as long as
/// there are entries [pushTabHistoryEntry] added still unpopped, passing
/// the absolute depth recorded at that point in history (0 once back at
/// the very first entry). Returns a function that cancels the
/// subscription.
void Function() listenForBack(void Function(int depth) onBack) {
  final subscription = html.window.onPopState.listen((event) {
    final state = event.state;
    final depth = state is int ? state : 0;
    _depth = depth;
    onBack(depth);
  });
  return subscription.cancel;
}
