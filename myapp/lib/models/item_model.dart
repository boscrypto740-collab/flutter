class ItemModel {
  final String? id;
  final String title;
  final String description;
  final String userId;
  final DateTime createdAt;

  ItemModel({
    this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ItemModel.fromMap(String id, Map<String, dynamic> map) => ItemModel(
    id: id,
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    userId: map['userId'] ?? '',
    createdAt: DateTime.parse(map['createdAt']),
  );
}
