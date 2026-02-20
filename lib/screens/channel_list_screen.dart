import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/tv_provider.dart';
import '../utils/responsive.dart';
import '../widgets/channel_card.dart';
import 'player_screen.dart';

class ChannelListScreen extends StatefulWidget {
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
  State<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TvProvider>();
    final all = prov.getChannelsForCountry(widget.countryCode);
    final channels = _query.isEmpty
        ? all
        : all
            .where((c) =>
                c.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    final hp = Responsive.hPadding(context);
    final cols = Responsive.gridCols(context);
    final spacing = Responsive.gridSpacing(context);

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
                  Text(widget.flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.countryName,
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
              // ── Search bar pinned below the title ──────────────────────
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hp, 0, hp, 8),
                  child: TextField(
                    controller: _controller,
                    onChanged: (v) => setState(() => _query = v.trim()),
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search channels…',
                      hintStyle:
                          const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.textMuted, size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppTheme.textMuted, size: 18),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.surface,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Channel count ─────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hp, 8, hp, 4),
              sliver: SliverToBoxAdapter(
                child: Text(
                  _query.isEmpty
                      ? '${all.length} channels'
                      : '${channels.length} of ${all.length} channels',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
            ),

            // ── Grid / empty state ────────────────────────────────────────
            if (channels.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    _query.isEmpty
                        ? 'No channels available'
                        : 'No channels match "$_query"',
                    style:
                        const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hp, 4, hp, 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
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
