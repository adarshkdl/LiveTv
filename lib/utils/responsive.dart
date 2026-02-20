import 'package:flutter/material.dart';

/// Central breakpoints and layout helpers.
///
///  Phone   : width < 600
///  Tablet  : 600 ≤ width < 1200
///  Desktop / TV : width ≥ 1200
///
/// Smart TV notes
/// ─────────────
///  Android TV at 1080p  (density 2.0) → logical width ≈ 960 dp
///  Android TV at 1080p  (density 1.5) → logical width ≈ 1280 dp
///  Fire TV Stick 4K     (density 2.0) → logical width ≈ 960 dp
///
///  Because TV logical widths overlap the tablet/desktop range we detect TV
///  by combining width with the absence of pointer (hover) events. In
///  practice all large-screen layouts (NavigationRail + wide grid) already
///  work well on TV. The extra TV-specific helper is the overscan safe-area.
class Responsive {
  Responsive._();

  static const double _tabletBreak  = 600;
  static const double _desktopBreak = 1200;

  static double _w(BuildContext ctx) => MediaQuery.sizeOf(ctx).width;

  // ── Breakpoints ────────────────────────────────────────────────────────────

  static bool isPhone  (BuildContext ctx) => _w(ctx) < _tabletBreak;
  static bool isTablet (BuildContext ctx) =>
      _w(ctx) >= _tabletBreak && _w(ctx) < _desktopBreak;
  static bool isDesktop(BuildContext ctx) => _w(ctx) >= _desktopBreak;

  /// True on any large-screen device (tablet, desktop, or TV).
  static bool isWide(BuildContext ctx) => !isPhone(ctx);

  /// Approximate TV detection: large screen with no mouse pointer.
  /// Covers Android TV / Fire TV logical widths (≈ 800–1280 dp).
  static bool isTV(BuildContext ctx) {
    final w = _w(ctx);
    final noMouse = MediaQuery.of(ctx).navigationMode == NavigationMode.directional
        || !WidgetsBinding.instance.mouseTracker.mouseIsConnected;
    return w >= 800 && noMouse;
  }

  // ── Grid helpers ───────────────────────────────────────────────────────────

  /// Number of columns in a channel / country grid.
  static int gridCols(BuildContext ctx) {
    final w = _w(ctx);
    if (w < 480)  return 2;
    if (w < 600)  return 3;
    if (w < 900)  return 4;
    if (w < 1200) return 5;
    if (w < 1600) return 6;
    return 8;
  }

  /// Horizontal edge padding — grows on wide screens, adds overscan on TV.
  static double hPadding(BuildContext ctx) {
    if (isTV(ctx)) return 64; // TV overscan safe margin
    final w = _w(ctx);
    if (w < 600)  return 16;
    if (w < 1200) return 24;
    return 48;
  }

  /// Top/bottom overscan padding for TV (so content isn't cut at screen edges).
  static double vOverscan(BuildContext ctx) => isTV(ctx) ? 32 : 0;

  /// Card grid spacing grows slightly on wide screens.
  static double gridSpacing(BuildContext ctx) => isPhone(ctx) ? 10 : 14;

  // ── Navigation helpers ─────────────────────────────────────────────────────

  /// Use NavigationRail instead of BottomNavigationBar.
  static bool useRail(BuildContext ctx) => isWide(ctx);

  /// NavigationRail "extended" mode (labels always visible).
  static bool extendRail(BuildContext ctx) => isDesktop(ctx) || isTV(ctx);
}
