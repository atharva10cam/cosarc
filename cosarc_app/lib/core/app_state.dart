/// Single-writer flag set by [AppStartScreen] immediately before it navigates
/// away from the splash. The auth-state listener in [main.dart] reads this to
/// avoid racing with the splash and double-navigating on cold start.
///
/// This tiny file exists to break the potential circular import between
/// `main.dart` and `app_start_screen.dart`.
bool splashNavigationDone = false;
