/// On mobile, MainShell's tab switches (_goTo) are plain setState calls,
/// not Navigator pushes or URL changes — so the browser's own history
/// stack never grows when the user moves between tabs, and there's
/// nothing for the phone's native back button/gesture to undo. The very
/// first back press just leaves the site entirely, no matter how many
/// tabs deep the user actually is (Home -> Shop -> Cart, one back press
/// and the whole app is gone).
///
/// PopScope (already used in MainShell) covers a *native* Android app's
/// system back button, but a phone browser's back gesture doesn't route
/// through Flutter's Navigator at all here, since tab switches aren't
/// Navigator routes — it's a purely browser-level event. This file mirrors
/// _navHistory into the browser's own session history (one no-op state
/// entry pushed per tab switch, via [pushTabHistoryEntry]) so a physical
/// back press has something of ours to pop first; [listenForBack] is
/// notified each time that happens, and MainShell retraces one tab step
/// (_goBack) instead of leaving the page. Once every pushed entry has
/// been popped — i.e. back at Home — back presses fall through to their
/// normal browser behaviour, same as PopScope's canPop check.
export 'browser_tab_history_stub.dart'
    if (dart.library.html) 'browser_tab_history_web.dart';
