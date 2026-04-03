import 'package:cloud_firestore/cloud_firestore.dart';
class RatingService {
  final _db = FirebaseFirestore.instance;
  Future<bool> hasReviewed(String agentId, String userId) async {
    final d = await _db.collection('reviews').where('agentId',isEqualTo:agentId).where('userId',isEqualTo:userId).get();
    return d.docs.isNotEmpty;
  }
  Future<void> submitReview({required String agentId,required String userId,required String userEmail,required double rating,required String comment}) async {
    final batch = _db.batch();
    batch.set(_db.collection('reviews').doc(),{'agentId':agentId,'userId':userId,'userEmail':userEmail,'rating':rating,'comment':comment,'createdAt':DateTime.now().toIso8601String()});
    final reviews = await _db.collection('reviews').where('agentId',isEqualTo:agentId).get();
    double total = rating;
    for (final d in reviews.docs) { total += (d.data()['rating']??0.0).toDouble(); }
    batch.update(_db.collection('agents').doc(agentId),{'rating':double.parse((total/(reviews.docs.length+1)).toStringAsFixed(1))});
    await batch.commit();
  }
  Stream<List<Map<String,dynamic>>> getReviews(String agentId) => _db.collection('reviews').where('agentId',isEqualTo:agentId).orderBy('createdAt',descending:true).snapshots().map((s)=>s.docs.map((d)=>{'id':d.id,...d.data()}).toList());
}
