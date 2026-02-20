import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/tv_provider.dart';
import '../widgets/channel_card.dart';
import 'player_screen.dart';

class ChannelListScreen extends StatelessWidget {
  final String countryCode;
  final String countryName;
  final String flag;

  const ChannelListScreen({
    super.key,
    required this.countryCode,
    required this.countryName,
    required this.flag,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TvProvider>();
    final channels = prov.getChannelsForCountry(countryCode);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.bg,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  Text(flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      countryName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              sliver: SliverToBoxAdapter(
                child: Text(
                  '${channels.length} channels',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
            ),
            if (channels.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No channels available',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              )
            else
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
        ),
      ),
    );
  }
}
