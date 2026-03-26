import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {

    /// Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("Permission status: ${settings.authorizationStatus}");

    /// Get FCM Token
    String? token = await _messaging.getToken();

    print("FCM TOKEN: $token");

    /// Save token to Firestore
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && token != null) {
      await FirebaseFirestore.instance
          .collection("Provider_details")
          .doc(user.uid)
          .set({
        "fcmToken": token,
        "role": "providers"
      }, SetOptions(merge: true));
    }

    /// Foreground notification listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      if (message.notification != null) {
        print("Title: ${message.notification!.title}");
        print("Body: ${message.notification!.body}");
      }

    });
  }
}