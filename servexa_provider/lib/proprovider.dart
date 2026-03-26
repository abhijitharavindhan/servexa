import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:servexa_provider/login.dart';
import 'package:servexa_provider/provider_home.dart';
import 'package:servexa_provider/provider_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Proprovider extends ChangeNotifier {

  /// Controllers
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController phno = TextEditingController();

  /// Services
  List<String> services = [];
  String? selectedService;

  /// CV
  File? cvFile;
  String? cvName;
  String? cvUrl;

  /// ---------------- REGISTER ----------------

  Future registerProvider(BuildContext context) async {

    try {

      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: pass.text.trim());

      String uid = user.user!.uid;

      /// Upload CV
      String? url = await uploadCV(uid);

      /// Save provider details
      await addProviderDetails(uid, url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration Successful"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()));

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration Failed : $e"),
          backgroundColor: Colors.red,
        ),
      );

    }

  }

  /// ---------------- UPLOAD CV ----------------

  Future<String?> uploadCV(String uid) async {

    if (cvFile == null) return null;

    try {

      final ref = FirebaseStorage.instance
          .ref()
          .child("provider_cvs")
          .child("$uid.pdf");

      UploadTask uploadTask = ref.putFile(cvFile!);

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;

    } catch (e) {

      print("CV Upload Error: $e");
      return null;

    }

  }

  /// ---------------- SAVE DETAILS ----------------

  Future addProviderDetails(String uid, String? url) async {

    final data = {
      'name': name.text.trim(),
      'email': email.text.trim(),
      'phno': phno.text.trim(),
      'service': selectedService ?? "",
      'cv': url ?? "",
      'isApproved': false,
      'isOnline': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('Provider_details')
        .doc(uid)
        .set(data);

    notifyListeners();
  }

  /// ---------------- LOGIN ----------------

  Future login(BuildContext context) async {

    try {

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text.trim(),
      );

      String uid = userCredential.user!.uid;

      var doc = await FirebaseFirestore.instance
          .collection('Provider_details')
          .doc(uid)
          .get();

      if (!doc.exists) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Provider not found")),
        );

        return;
      }

      bool approved = doc['isApproved'] ?? false;

      if (!approved) {

        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Waiting for admin approval"),
            backgroundColor: Colors.orange,
          ),
        );

        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('islogged', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProviderMain()),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Failed : $e"),
          backgroundColor: Colors.red,
        ),
      );

    }

  }

  /// ---------------- LOGOUT ----------------

  Future logout(BuildContext context) async {

    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('islogged', false);

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, 'login', (route) => false);
    }

  }

  /// ---------------- PICK CV ----------------

  Future pickCV() async {

    FilePickerResult? result =
    await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {

      cvFile = File(result.files.single.path!);
      cvName = result.files.single.name;

      notifyListeners();
    }

  }

  /// ---------------- FETCH SERVICES ----------------

  Future fetchServices() async {

    final snapshot = await FirebaseFirestore
        .instance
        .collection("services")
        .get();

    services = snapshot.docs
        .map((doc) => doc['name'].toString())
        .toList();

    notifyListeners();
  }

  void selectService(String? value) {

    selectedService = value;
    notifyListeners();

  }
}