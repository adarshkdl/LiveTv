import 'package:flutter/material.dart';

/// Central breakpoints and layout helpers.
///
///  Phone   : width < 600
///  Tablet  : 600 ≤ width < 1200
///  Desktop : width ≥ 1200
class Responsive {
  Responsive._();

  static const double _tabletBreak = 600;
  static const double _desktopBreak = 1200;

  static double _w(BuildContext ctx) => MediaQuery.sizeOf(ctx).width;

  static bool isPhone(BuildContext ctx) => _w(ctx) < _tabletBreak;
  static bool isTablet(BuildContext ctx) =>
      _w(ctx) >= _tabletBreak && _w(ctx) < _desktopBreak;
  static bool isDesktop(BuildContext ctx) => _w(ctx) >= _desktopBreak;

  /// Number of columns in a channel / country grid.
  static int gridCols(BuildContext ctx) {
    final w = _w(ctx);
    if (w < 480) return 2;
    if (w < 600) return 3;
    if (w < 900) return 4;
    if (w < 1200) return 5;
    if (w < 1600) return 6;
    return 8;
  }

  /// Horizontal edge padding that grows on wider screens.
  static double hPadding(BuildContext ctx) {
    final w = _w(ctx);
    if (w < 600) return 16;
    if (w < 1200) return 24;
    return 48;
  }

  /// Card grid spacing grows slightly on wide screens.
  static double gridSpacing(BuildContext ctx) => isPhone(ctx) ? 10 : 14;

  /// Whether to show NavigationRail instead of BottomNavigationBar.
  static bool useRail(BuildContext ctx) => !isPhone(ctx);

  /// Whether the NavigationRail should be in "extended" (label-always-visible) mode.
  static bool extendRail(BuildContext ctx) => isDesktop(ctx);
}
