import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent_model.dart';
class ExploreService {
  final _db = FirebaseFirestore.instance;
  Stream<List<AgentModel>> getAgents({String? category, String? sortBy}) {
    Query q = _db.collection('agents');
    if (category != null && category != 'All') q = q.where('category', isEqualTo: category);
    if (sortBy == 'rating') {
      q = q.orderBy('rating', descending: true);
    } else if (sortBy == 'popular') q = q.orderBy('totalRuns', descending: true);
    else q = q.orderBy('createdAt', descending: true);
    return q.snapshots().map((s) => s.docs.map((d) => AgentModel.fromMap(d.id, d.data() as Map<String,dynamic>)).toList());
  }
  Future<void> publishAgent(AgentModel agent) => _db.collection('agents').add(agent.toMap());
}
