/// On mobile, MainShell's tab switches (_goTo) are plain setState calls,
/// not Navigator pushes or URL changes — so the browser's own history
/// stack never grows when the user moves between tabs, and there's
/// nothing for the phone's native back button/gesture to undo. The very
/// first back press just leaves the site entirely, no matter how many
/// tabs deep the user actually is (Home -> Shop -> Cart, one back press
/// and the whole app is gone).
///
/// This file is currently unused — see browser_tab_history_web.dart for
/// why. Kept in case a future rewrite wants it back.
export 'browser_tab_history_stub.dart'
    if (dart.library.html) 'browser_tab_history_web.dart';
