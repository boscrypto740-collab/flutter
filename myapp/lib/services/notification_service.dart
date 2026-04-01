import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    await _requestPermission();
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    if (!context.mounted) return;
    _listenForeground(context);
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _listenForeground(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!context.mounted) return;
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.title ?? 'Notifikasi baru'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }
}
