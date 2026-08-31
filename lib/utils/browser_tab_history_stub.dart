// No-op fallback for non-web builds. This app targets web only (see
// README), but kept in sync with browser_tab_history_web.dart via the
// conditional export in browser_tab_history.dart, the same pattern
// web_ready_notifier.dart uses, so a stray non-web build target doesn't
// hard-fail on a missing dart:html.

void pushTabHistoryEntry() {}

void Function() listenForBack(void Function(int depth) onBack) => () {};
