import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent_model.dart';

class ExploreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<AgentModel>> getAgents({String? category, String? sortBy}) {
    Query query = _db.collection('agents');
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    if (sortBy == 'rating') {
      query = query.orderBy('rating', descending: true);
    } else if (sortBy == 'popular') {
      query = query.orderBy('totalRuns', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }
    return query.snapshots().map((snap) => snap.docs
      .map((doc) => AgentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
      .toList());
  }

  Future<void> publishAgent(AgentModel agent) async {
    await _db.collection('agents').add(agent.toMap());
  }
}
