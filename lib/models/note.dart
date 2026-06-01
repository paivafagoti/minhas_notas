class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  static Note fromMap(Map<String, Object?> map) {
    return Note(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int?) ?? 0,
      ),
    );
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
