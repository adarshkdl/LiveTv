import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/channel.dart';
import '../providers/tv_provider.dart';

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

  Future<void> _initPlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMsg = null;
    });

    _disposeControllers();

    final url = widget.channel.streamUrl;
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
      if (widget.channel.userAgent != null) {
        headers['User-Agent'] = widget.channel.userAgent!;
      }
      if (widget.channel.referrer != null) {
        headers['Referer'] = widget.channel.referrer!;
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
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(errorMessage,
                style: const TextStyle(color: Colors.white70)),
          );
        },
      );

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMsg = 'Stream unavailable. It may be offline or geo-restricted.';
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

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TvProvider>();
    final isFav = prov.isFavorite(widget.channel.id);
    final country = prov.getCountry(widget.channel.country);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ── Video player area ──────────────────────────────────────────
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildPlayer(),
          ),

          // ── Channel info ───────────────────────────────────────────────
          Expanded(
            child: Container(
              color: AppTheme.bg,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 20,
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
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip(
                            icon: Icons.circle,
                            label: 'LIVE',
                            color: AppTheme.live,
                          ),
                          if (country != null)
                            _infoChip(
                              label: '${country.flag}  ${country.name}',
                            ),
                          ...widget.channel.categories.map(
                            (c) => _infoChip(
                                label: c[0].toUpperCase() + c.substring(1)),
                          ),
                        ],
                      ),
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
                              const Text(
                                'Stream unavailable',
                                style: TextStyle(
                                    color: AppTheme.live,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _errorMsg ?? '',
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _initPlayer,
                                icon: const Icon(Icons.refresh_rounded,
                                    size: 16),
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
            ),
          ),
        ],
      ),
    );
  }

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
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                  style: TextStyle(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _initPlayer,
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.accent),
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

  Widget _infoChip({required String label, IconData? icon, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.accent).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: (color ?? AppTheme.accent).withValues(alpha: 0.3)),
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
}
