import 'dart:html' as html;

/// Tells web/index.html's #pre_splash overlay that MainShell's first real
/// data (the product catalog) has actually arrived, so it's safe to fade
/// the overlay out. Deliberately not tied to Flutter's own
/// 'flutter-first-frame' event — that fires as soon as *any* frame paints,
/// which would be MainShell's loading spinner, not the finished home page,
/// and would make the hand-off from #pre_splash look like two splashes
/// back to back instead of one continuous one.
void notifyAppContentReady() {
  html.window.dispatchEvent(html.Event('app-content-ready'));
}
