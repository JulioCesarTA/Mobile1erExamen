class Notice {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final String createdBy;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.createdBy,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      createdBy: (json['created_by'] ?? '').toString(),
    );
  }
}
