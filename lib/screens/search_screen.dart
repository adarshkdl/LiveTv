import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/tv_provider.dart';
import '../widgets/channel_card.dart';
import '../widgets/loading_shimmer.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Consumer<TvProvider>(
          builder: (context, prov, _) {
            if (prov.loadState == LoadState.loading) {
              return const LoadingShimmer();
            }

            final results = prov.filteredChannels;
            final hasQuery = prov.searchQuery.isNotEmpty;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppTheme.bg,
                  title: const Text('Search',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700)),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(64),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TextField(
                        controller: _controller,
                        autofocus: false,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search channels…',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppTheme.textMuted),
                          suffixIcon: hasQuery
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      color: AppTheme.textMuted),
                                  onPressed: () {
                                    _controller.clear();
                                    prov.setSearch('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: prov.setSearch,
                      ),
                    ),
                  ),
                ),
                if (!hasQuery)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded,
                              size: 64, color: AppTheme.textMuted),
                          SizedBox(height: 16),
                          Text('Search for a channel',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  )
                else if (results.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('No channels found',
                          style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '${results.length} results',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final ch = results[i];
                          return ChannelCard(
                            channel: ch,
                            isFavorite: prov.isFavorite(ch.id),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PlayerScreen(channel: ch)),
                            ),
                            onFavoriteTap: () => prov.toggleFavorite(ch.id),
                          );
                        },
                        childCount: results.length,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
