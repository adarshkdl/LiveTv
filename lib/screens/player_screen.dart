import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/channel.dart';
import '../providers/tv_provider.dart';
import '../utils/responsive.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;

  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMsg;

  // Quality selection — index into widget.channel.streams (sorted best→worst).
  int _streamIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _initPlayer();
  }

  // Returns the stream to play based on selected index, falling back to the
  // channel's default streamUrl when the streams list is empty.
  String? get _activeUrl {
    final s = widget.channel.streams;
    if (s.isNotEmpty && _streamIndex < s.length) return s[_streamIndex].url;
    return widget.channel.streamUrl;
  }

  String? get _activeUserAgent {
    final s = widget.channel.streams;
    if (s.isNotEmpty && _streamIndex < s.length) return s[_streamIndex].userAgent;
    return widget.channel.userAgent;
  }

  String? get _activeReferrer {
    final s = widget.channel.streams;
    if (s.isNotEmpty && _streamIndex < s.length) return s[_streamIndex].referrer;
    return widget.channel.referrer;
  }

  Future<void> _initPlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMsg = null;
    });

    _disposeControllers();

    final url = _activeUrl;
    if (url == null || url.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMsg = 'No stream available for this channel';
      });
      return;
    }

    try {
      final headers = <String, String>{};
      if (_activeUserAgent != null) {
        headers['User-Agent'] = _activeUserAgent!;
      }
      if (_activeReferrer != null) {
        headers['Referer'] = _activeReferrer!;
      }

      _videoCtrl = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: headers,
      );

      await _videoCtrl!.initialize();

      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl!,
        autoPlay: true,
        looping: false,
        isLive: true,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: false,
        allowedScreenSleep: false,
        aspectRatio: _videoCtrl!.value.aspectRatio,
        errorBuilder: (context, errorMessage) => Center(
          child: Text(errorMessage,
              style: const TextStyle(color: Colors.white70)),
        ),
      );

      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMsg =
              'Stream unavailable. It may be offline or geo-restricted.';
        });
      }
    }
  }

  void _disposeControllers() {
    _chewieCtrl?.dispose();
    _chewieCtrl = null;
    _videoCtrl?.dispose();
    _videoCtrl = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TvProvider>();
    final isFav = prov.isFavorite(widget.channel.id);
    final country = prov.getCountry(widget.channel.country);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Responsive.isPhone(context)
          ? _buildPortraitLayout(context, prov, isFav, country)
          : _buildWideLayout(context, prov, isFav, country),
    );
  }

  // ── Phone: video on top, info panel below ─────────────────────────────────

  Widget _buildPortraitLayout(BuildContext context, TvProvider prov,
      bool isFav, dynamic country) {
    return Column(
      children: [
        AspectRatio(aspectRatio: 16 / 9, child: _buildPlayer()),
        Expanded(
          child: _buildInfoPanel(context, prov, isFav, country),
        ),
      ],
    );
  }

  // ── Tablet / Desktop: video left, info panel right ────────────────────────

  Widget _buildWideLayout(BuildContext context, TvProvider prov, bool isFav,
      dynamic country) {
    // video flex: 13/20 on desktop, 11/20 on tablet
    final videoFlex = Responsive.isDesktop(context) ? 13 : 11;
    final infoFlex = 20 - videoFlex;

    return Row(
      children: [
        Flexible(
          flex: videoFlex,
          child: ColoredBox(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AspectRatio(aspectRatio: 16 / 9, child: _buildPlayer()),
              ],
            ),
          ),
        ),
        Flexible(
          flex: infoFlex,
          child: _buildInfoPanel(context, prov, isFav, country),
        ),
      ],
    );
  }

  // ── Shared info panel ─────────────────────────────────────────────────────

  Widget _buildInfoPanel(BuildContext context, TvProvider prov, bool isFav,
      dynamic country) {
    final pad = Responsive.isPhone(context) ? 20.0 : 28.0;
    final titleSize = Responsive.isPhone(context) ? 20.0 : 22.0;

    return Container(
      color: AppTheme.bg,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title + favourite row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppTheme.textPrimary),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.channel.name,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? AppTheme.live : AppTheme.textMuted,
                    ),
                    onPressed: () =>
                        prov.toggleFavorite(widget.channel.id),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Info chips + quality selector
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _infoChip(
                      icon: Icons.circle,
                      label: 'LIVE',
                      color: AppTheme.live),
                  if (country != null)
                    _infoChip(
                        label: '${country.flag}  ${country.name}'),
                  ...widget.channel.categories.map(
                    (c) => _infoChip(
                        label: c[0].toUpperCase() + c.substring(1)),
                  ),
                  // Quality selector — only shown when > 1 stream available
                  if (widget.channel.streams.length > 1)
                    _qualityChip(context),
                ],
              ),

              // Error box
              if (_hasError) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.live.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.live.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stream unavailable',
                          style: TextStyle(
                              color: AppTheme.live,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(_errorMsg ?? '',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _initPlayer,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Player widget ─────────────────────────────────────────────────────────

  Widget _buildPlayer() {
    if (_isLoading) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  color: AppTheme.accent, strokeWidth: 2.5),
              SizedBox(height: 14),
              Text('Connecting to stream…',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    if (_hasError || _chewieCtrl == null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.signal_wifi_off_rounded,
                  color: Colors.white38, size: 48),
              const SizedBox(height: 12),
              const Text('Stream offline',
                  style:
                      TextStyle(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _initPlayer,
                icon: const Icon(Icons.refresh_rounded,
                    color: AppTheme.accent),
                label: const Text('Retry',
                    style: TextStyle(color: AppTheme.accent)),
              ),
            ],
          ),
        ),
      );
    }
    return Chewie(controller: _chewieCtrl!);
  }

  // ── Info chip ─────────────────────────────────────────────────────────────

  Widget _infoChip(
      {required String label, IconData? icon, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.accent).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: (color ?? AppTheme.accent).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 8, color: color ?? AppTheme.accent),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color ?? AppTheme.accentLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quality selector chip + bottom sheet ──────────────────────────────────

  String _qualityLabel(int index) {
    final streams = widget.channel.streams;
    if (index >= streams.length) return 'Auto';
    final q = streams[index].quality;
    return q != null && q.isNotEmpty ? q.toUpperCase() : 'Auto';
  }

  Widget _qualityChip(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQualitySheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hd_rounded, size: 14, color: AppTheme.accent),
            const SizedBox(width: 5),
            Text(
              _qualityLabel(_streamIndex),
              style: const TextStyle(
                color: AppTheme.accentLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded,
                size: 14, color: AppTheme.accent),
          ],
        ),
      ),
    );
  }

  void _showQualitySheet(BuildContext context) {
    final streams = widget.channel.streams;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Select Quality',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Divider(color: AppTheme.cardBorder, height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: streams.length,
                itemBuilder: (_, i) {
                  final label = _qualityLabel(i);
                  final isSelected = i == _streamIndex;
                  return ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? AppTheme.accent
                          : AppTheme.textMuted,
                      size: 20,
                    ),
                    title: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.accent
                            : AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      streams[i].title.isNotEmpty
                          ? streams[i].title
                          : streams[i].url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (i != _streamIndex) {
                        setState(() => _streamIndex = i);
                        _initPlayer();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
