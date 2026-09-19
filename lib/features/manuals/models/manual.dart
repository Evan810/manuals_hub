class Manual {
  const Manual({
    required this.id,
    required this.title,
    required this.family,
    required this.category,
    required this.path,
    required this.entry,
    this.icon = '',
    this.chapterCount = 0,
  });

  final int id;
  final String title;
  final int family;
  final String category;
  final String path;
  final String entry;
  final String icon;
  final int chapterCount;

  factory Manual.fromMap(Map<String, Object?> map) {
    return Manual(
      id: map['id'] as int,
      title: map['title'] as String,
      family: map['family'] as int? ?? 0,
      category: map['category'] as String,
      path: map['path'] as String,
      entry: map['entry'] as String,
      icon: map['icon'] as String? ?? '',
      chapterCount: map['chapter_count'] as int? ?? 0,
    );
  }
}
