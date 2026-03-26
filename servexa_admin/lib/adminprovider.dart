import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servexa_admin/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Adminprovider extends ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();

  /// Notification controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  String role = "users"; // users / providers / all

  bool isLoading = false;

  void _setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  /// ---------------- ADMIN LOGIN ----------------
  Future<void> adminLogin(BuildContext context) async {
    _setLoading(true);

    try {

      const String adminEmail = "admin@servexa.com";
      const String adminPassword = "Admin@123";

      if (email.text.trim() == adminEmail &&
          pass.text.trim() == adminPassword) {

        final SharedPreferences preferences =
        await SharedPreferences.getInstance();

        await preferences.setBool('islogged', true);

        email.clear();
        pass.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Home()),
        );

      } else {

        _showError(context, "Invalid Admin Credentials");

      }

    } catch (e) {

      _showError(context, "Login failed: ${e.toString()}");

    } finally {

      _setLoading(false);

    }
  }

  /// ---------------- SEND NOTIFICATION ----------------
  Future<void> sendNotification(BuildContext context) async {

    try {

      await _firestore.collection("notifications").add({

        "title": titleController.text.trim(),
        "subtitle": messageController.text.trim(),
        "role": role,
        "date": DateTime.now().toString().split(" ")[0],
        "time": TimeOfDay.now().format(context),
        "timestamp": FieldValue.serverTimestamp(),

      });

      titleController.clear();
      messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Notification Sent Successfully"),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {

      _showError(context, "Error sending notification: $e");

    }

  }

  /// ---------------- LOGOUT ----------------
  Future<void> logout(BuildContext context) async {

    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    await preferences.setBool('islogged', false);

    await _auth.signOut();

    Navigator.pushReplacementNamed(context, 'login');

  }

  void _showError(BuildContext context, String msg) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );

  }

}