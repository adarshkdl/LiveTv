import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app_theme.dart';
import '../models/channel.dart';

/// A channel card that works across touch (phone/tablet) and
/// D-pad (Smart TV / Android TV) input.
///
/// When the card gains keyboard/D-pad focus an accent border + glow
/// animates in, and pressing SELECT / Enter triggers [onTap].
class ChannelCard extends StatefulWidget {
  final Channel channel;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focused ? AppTheme.accent : AppTheme.cardBorder,
            width: _focused ? 2.5 : 0.5,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 0,
                  ),
                ]
              : const [],
        ),
        // ClipRRect so InkWell ripple stays inside the rounded card
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              // InkWell handles: tap (touch), click (mouse),
              // Enter / D-pad-Select (TV remote)
              onTap: widget.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo area ──────────────────────────────────────────
                  Expanded(
                    child: Stack(
                      children: [
                        _buildLogo(),

                        // Favourite button
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: widget.onFavoriteTap,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                widget.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 15,
                                color: widget.isFavorite
                                    ? AppTheme.live
                                    : Colors.white70,
                              ),
                            ),
                          ),
                        ),

                        // LIVE badge
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.live,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Channel name ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                    child: Text(
                      widget.channel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
      child: Container(
        color: AppTheme.surface,
        child: widget.channel.logo != null && widget.channel.logo!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.channel.logo!,
                fit: BoxFit.contain,
                placeholder: (_, __) => _initials(),
                errorWidget: (_, __, ___) => _initials(),
              )
            : _initials(),
      ),
    );
  }

  Widget _initials() {
    final letter = widget.channel.name.isNotEmpty
        ? widget.channel.name.trim()[0].toUpperCase()
        : '?';
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
