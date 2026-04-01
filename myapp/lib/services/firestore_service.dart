import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ItemModel>> getItems(String userId) {
    return _db
      .collection('items')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
        .map((doc) => ItemModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> addItem(ItemModel item) async {
    await _db.collection('items').add(item.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _db.collection('items').doc(id).delete();
  }
}
