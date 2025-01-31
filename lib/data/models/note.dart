class Note {
  final String id;
  final String name;
  final String content;

  Note({
    required this.id,
    required this.name,
    required this.content,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content': content,
    };
  }
  
  // hive library really complains without this
  static Note jsonWrapper(dynamic json) {
    return Note.fromJson(json as Map<String, dynamic>);
  }
}

// TODO: include creation date