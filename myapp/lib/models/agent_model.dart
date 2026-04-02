class AgentModel {
  final String? id;
  final String title, description, category, userId;
  final double pricePerRun, rating;
  final int totalRuns;
  final DateTime createdAt;
  AgentModel({this.id, required this.title, required this.description, required this.category, required this.pricePerRun, this.rating=0.0, this.totalRuns=0, required this.userId, required this.createdAt});
  Map<String,dynamic> toMap() => {'title':title,'description':description,'category':category,'pricePerRun':pricePerRun,'rating':rating,'totalRuns':totalRuns,'userId':userId,'createdAt':createdAt.toIso8601String()};
  factory AgentModel.fromMap(String id, Map<String,dynamic> m) => AgentModel(id:id,title:m['title']??'',description:m['description']??'',category:m['category']??'Other',pricePerRun:(m['pricePerRun']??0.0).toDouble(),rating:(m['rating']??0.0).toDouble(),totalRuns:m['totalRuns']??0,userId:m['userId']??'',createdAt:DateTime.parse(m['createdAt']));
}
