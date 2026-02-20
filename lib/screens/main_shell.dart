import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';
import 'countries_screen.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    CountriesScreen(),
    FavoritesScreen(),
    SearchScreen(),
  ];

  static const _destinations = [
    (icon: Icons.home_rounded,      label: 'Home'),
    (icon: Icons.public_rounded,    label: 'Countries'),
    (icon: Icons.favorite_rounded,  label: 'Favorites'),
    (icon: Icons.search_rounded,    label: 'Search'),
  ];

  @override
  Widget build(BuildContext context) {
    if (Responsive.useRail(context)) {
      return _buildRailLayout(context);
    }
    return _buildBottomNavLayout();
  }

  // ── Phone: bottom navigation bar ─────────────────────────────────────────

  Widget _buildBottomNavLayout() {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: _destinations
            .map((d) => BottomNavigationBarItem(
                  icon: Icon(d.icon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }

  // ── Tablet / Desktop: navigation rail on the left ─────────────────────────

  Widget _buildRailLayout(BuildContext context) {
    final extended = Responsive.extendRail(context);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Row(
        children: [
          // Rail
          NavigationRail(
            extended: extended,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: AppTheme.surface,
            selectedIconTheme:
                const IconThemeData(color: AppTheme.accent),
            unselectedIconTheme:
                const IconThemeData(color: AppTheme.textMuted),
            selectedLabelTextStyle: const TextStyle(
                color: AppTheme.accent, fontWeight: FontWeight.w600),
            unselectedLabelTextStyle:
                const TextStyle(color: AppTheme.textMuted),
            labelType: extended
                ? NavigationRailLabelType.none   // labels are inline when extended
                : NavigationRailLabelType.selected,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: extended
                  ? Row(
                      children: [
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.live_tv_rounded,
                              size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Globe TV',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17),
                        ),
                      ],
                    )
                  : Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.live_tv_rounded,
                          size: 18, color: Colors.white),
                    ),
            ),
            destinations: _destinations
                .map((d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      label: Text(d.label),
                    ))
                .toList(),
          ),

          // Thin divider
          const VerticalDivider(
              width: 1, thickness: 1, color: AppTheme.cardBorder),

          // Content
          Expanded(
            child: IndexedStack(index: _index, children: _screens),
          ),
        ],
      ),
    );
  }
}
