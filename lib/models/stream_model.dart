class StreamModel {
  final String? channelId;
  final String? feed;
  final String title;
  final String url;
  final String? quality;
  final String? userAgent;
  final String? referrer;

  const StreamModel({
    this.channelId,
    this.feed,
    required this.title,
    required this.url,
    this.quality,
    this.userAgent,
    this.referrer,
  });

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      channelId: json['channel'] as String?,
      feed: json['feed'] as String?,
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      quality: json['quality'] as String?,
      userAgent: json['user_agent'] as String?,
      referrer: json['referrer'] as String?,
    );
  }

  bool get isValid => url.isNotEmpty;
}
