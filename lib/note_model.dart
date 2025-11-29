class Note {
  final int? id;
  final String title;
  final String content;
  final String time;
  final int colorIndex;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.time,
    required this.colorIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'time': time,
      'colorIndex': colorIndex,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      time: map['time'],
      colorIndex: map['colorIndex'],
    );
  }
}
