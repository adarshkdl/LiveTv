import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/tv_provider.dart';
import '../utils/responsive.dart';
import '../widgets/channel_card.dart';
import 'player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Consumer<TvProvider>(
          builder: (context, prov, _) {
            final favs = prov.favoriteChannels;
            final hp = Responsive.hPadding(context);
            final cols = Responsive.gridCols(context);
            final spacing = Responsive.gridSpacing(context);

            return CustomScrollView(
              slivers: [
                const SliverAppBar(
                  pinned: true,
                  backgroundColor: AppTheme.bg,
                  title: Text('Favorites',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700)),
                ),
                if (favs.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 64, color: AppTheme.textMuted),
                          SizedBox(height: 16),
                          Text('No favorites yet',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
                          Text('Tap the heart on any channel to save it',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hp, 8, hp, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final ch = favs[i];
                          return ChannelCard(
                            channel: ch,
                            isFavorite: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PlayerScreen(channel: ch)),
                            ),
                            onFavoriteTap: () => prov.toggleFavorite(ch.id),
                          );
                        },
                        childCount: favs.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
