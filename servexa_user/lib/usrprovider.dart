import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsrProvider extends ChangeNotifier {
  final CollectionReference custom = FirebaseFirestore.instance.collection('Customer_details');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();

  bool isLoading = false;

  void _setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('islogged', true);

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, 'btm');
      }
    } catch (e) {
      _showError(context, "Login Failed: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(BuildContext context) async {
    if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      _showError(context, "Please fill all fields");
      return;
    }

    _setLoading(true);

    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      await _firestore.collection('Customer_details').doc(cred.user!.uid).set({
        'name': name.text.trim(),
        'email': email.text.trim(),
        'uid': cred.user!.uid,
      });

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, 'login');
      }

    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? "Registration Failed");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('islogged', false);
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

}