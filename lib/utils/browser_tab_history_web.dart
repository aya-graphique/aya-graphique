import 'dart:html' as html;

/// See browser_tab_history.dart for why this exists. Currently unused —
/// main_shell.dart pushes a real (invisible) Navigator route per tab
/// switch instead (see _TabMarkerRoute there), since that's the approach
/// that's actually compatible with this app's plain MaterialApp/
/// Navigator 1.0 setup, and it's what lets several back presses in a row
/// each retrace one tab. Kept here in case a future rewrite wants to
/// talk to window.history directly again.
void pushTabHistoryEntry() {
  html.window.history.pushState(null, '', html.window.location.href);
}
