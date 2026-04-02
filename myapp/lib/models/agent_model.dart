class AgentModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final double pricePerRun;
  final double rating;
  final int totalRuns;
  final String userId;
  final DateTime createdAt;

  AgentModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.pricePerRun,
    this.rating = 0.0,
    this.totalRuns = 0,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'category': category,
    'pricePerRun': pricePerRun,
    'rating': rating,
    'totalRuns': totalRuns,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AgentModel.fromMap(String id, Map<String, dynamic> map) => AgentModel(
    id: id,
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    category: map['category'] ?? 'Other',
    pricePerRun: (map['pricePerRun'] ?? 0.0).toDouble(),
    rating: (map['rating'] ?? 0.0).toDouble(),
    totalRuns: map['totalRuns'] ?? 0,
    userId: map['userId'] ?? '',
    createdAt: DateTime.parse(map['createdAt']),
  );
}
