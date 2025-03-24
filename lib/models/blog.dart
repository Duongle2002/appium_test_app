class Blog {
  final String id;
  final String title;
  final String description;
  final String image;
  final DateTime date;
  final String content;

  Blog({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.content,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      date: DateTime.parse(json['date']),
      content: json['content'],
    );
  }
}