class Post {
  final int id; // Change id to int
  final String username;
  final String content;
  final String? image;
  final DateTime? timestamp;

  Post({
    required this.id,
    required this.username,
    required this.content,
    this.image,
    this.timestamp,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      username: json['createdBy'] ?? 'Unknown User',
      content: json['content'] ?? '',
      image: json['image'],
      timestamp: DateTime.tryParse(json['createdAt'] ?? ''),
    );
  }
}
