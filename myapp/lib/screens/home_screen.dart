import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestoreService = FirestoreService();
  final _notificationService = NotificationService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notificationService.initialize(context);
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Item'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _titleController,
            decoration: const InputDecoration(labelText: 'Judul')),
          TextField(controller: _descController,
            decoration: const InputDecoration(labelText: 'Deskripsi')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.addItem(ItemModel(
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
                userId: widget.user.uid,
                createdAt: DateTime.now(),
              ));
              _titleController.clear();
              _descController.clear();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Simpan')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bags Agent Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: StreamBuilder<List<ItemModel>>(
        stream: _firestoreService.getItems(widget.user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada item. Tap + untuk menambah!'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (_, i) {
              final item = snapshot.data![i];
              return ListTile(
                title: Text(item.title),
                subtitle: Text(item.description),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _firestoreService.deleteItem(item.id!)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add)),
    );
  }
}
