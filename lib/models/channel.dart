class Channel {
  final String id;
  final String name;
  final List<String> altNames;
  final String country;
  final List<String> categories;
  final bool isNsfw;
  final String? logo;
  final String? website;
  final List<String> languages;

  // Set after matching with streams
  String? streamUrl;
  String? userAgent;
  String? referrer;

  Channel({
    required this.id,
    required this.name,
    required this.altNames,
    required this.country,
    required this.categories,
    required this.isNsfw,
    this.logo,
    this.website,
    required this.languages,
    this.streamUrl,
    this.userAgent,
    this.referrer,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      altNames: List<String>.from(json['alt_names'] as List? ?? []),
      country: json['country'] as String? ?? '',
      categories: List<String>.from(json['categories'] as List? ?? []),
      isNsfw: json['is_nsfw'] as bool? ?? false,
      logo: json['logo'] as String?,
      website: json['website'] as String?,
      languages: List<String>.from(json['languages'] as List? ?? []),
    );
  }

  String get displayCategory {
    if (categories.isEmpty) return 'General';
    return categories.first[0].toUpperCase() + categories.first.substring(1);
  }

  bool get hasStream => streamUrl != null && streamUrl!.isNotEmpty;
}
