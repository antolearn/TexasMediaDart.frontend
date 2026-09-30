class CurrentTerms {
  final String version;
  final String title;
  final String content;
  final DateTime effectiveUtc;

  const CurrentTerms({
    required this.version,
    required this.title,
    required this.content,
    required this.effectiveUtc,
  });

  factory CurrentTerms.fromJson(Map<String, dynamic> json) {
    return CurrentTerms(
      version: json['version'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      effectiveUtc: DateTime.parse(json['effectiveUtc'] as String),
    );
  }
}
