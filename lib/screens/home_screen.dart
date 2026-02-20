import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/tv_provider.dart';
import '../widgets/channel_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_view.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            if (prov.loadState == LoadState.error) {
              return ErrorView(
                  message: prov.errorMessage ?? 'Unknown error',
                  onRetry: prov.initialize);
            }
            return _buildContent(prov);
          },
        ),
      ),
    );
  }

  Widget _buildContent(TvProvider prov) {
    final categories = ['All', ...prov.availableCategories];
    final channels = prov.filteredChannels;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.bg,
          title: Row(
            children: [
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
              const Text('Globe TV',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: _CategoryBar(categories: categories, provider: prov),
          ),
        ),
        if (channels.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text('No channels found',
                  style: TextStyle(color: AppTheme.textMuted)),
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${channels.length} channels',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final ch = channels[i];
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
                childCount: channels.length,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final List<String> categories;
  final TvProvider provider;

  const _CategoryBar(
      {required this.categories, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isAll = cat == 'All';
          final selected = isAll
              ? provider.selectedCategory == null
              : provider.selectedCategory == cat;
          return FilterChip(
            label: Text(isAll ? 'All' : _fmt(cat)),
            selected: selected,
            onSelected: (_) =>
                provider.setCategory(isAll ? null : cat),
            backgroundColor: AppTheme.card,
            selectedColor: AppTheme.accent,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
                color: selected ? AppTheme.accent : AppTheme.cardBorder),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }

  String _fmt(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
