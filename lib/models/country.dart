class Country {
  final String name;
  final String code;
  final String flag;
  final List<String> languages;

  const Country({
    required this.name,
    required this.code,
    required this.flag,
    required this.languages,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      flag: json['flag'] as String? ?? '',
      languages: List<String>.from(json['languages'] as List? ?? []),
    );
  }
}
