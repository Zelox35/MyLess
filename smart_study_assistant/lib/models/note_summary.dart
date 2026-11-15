class NoteSummary {
  final String title;
  final String summary;
  final List<String> bulletPoints;
  final List<String> keyTopics;
  final DateTime timestamp;

  NoteSummary({
    required this.title,
    required this.summary,
    required this.bulletPoints,
    required this.keyTopics,
    required this.timestamp,
  });

  factory NoteSummary.fromJson(Map<String, dynamic> json) {
    return NoteSummary(
      title: json['title'] as String? ?? 'Ders Notu',
      summary: json['summary'] as String? ?? '',
      bulletPoints: (json['bullet_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      keyTopics: (json['key_topics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'bullet_points': bulletPoints,
      'key_topics': keyTopics,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
