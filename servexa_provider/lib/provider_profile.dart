import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'login.dart'; // 👈 IMPORTANT (your Login page)

class ProviderProfile extends StatefulWidget {
  const ProviderProfile({super.key});

  @override
  State<ProviderProfile> createState() => _ProviderProfileState();
}

class _ProviderProfileState extends State<ProviderProfile> {

  final user = FirebaseAuth.instance.currentUser;

  bool isLoading = false;
  bool isOnline = false;
  String imageUrl = "";

  /// 🔥 IMAGE PICK + UPLOAD
  Future<void> pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => isLoading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("provider_profiles")
          .child("${user!.uid}.jpg");

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        await ref.putData(bytes);
      } else {
        File file = File(picked.path);
        await ref.putFile(file);
      }

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("Provider_details")
          .doc(user!.uid)
          .update({"profileImage": url});

      setState(() => imageUrl = url);

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  /// 🔥 ONLINE TOGGLE
  Future<void> toggleOnline(bool value) async {
    setState(() => isOnline = value);

    await FirebaseFirestore.instance
        .collection("Provider_details")
        .doc(user!.uid)
        .update({"isOnline": value});
  }

  /// 🔥 LOGOUT (FIXED NAVIGATION)
  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {

              await FirebaseAuth.instance.signOut();

              Navigator.pop(context);

              /// 🔥 GUARANTEED NAVIGATION
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const Login()),
                    (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("Provider_details")
            .doc(user!.uid)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          imageUrl = data["profileImage"] ?? "";
          isOnline = data["isOnline"] ?? false;

          return SingleChildScrollView(
            child: Column(
              children: [

                /// HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [

                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : imageUrl.isEmpty
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.edit,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        data["name"] ?? "",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),

                      Text(
                        data["email"] ?? "",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// DETAILS
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      _buildTile(Icons.work, "Service",
                          data["service"] ?? ""),

                      _buildTile(Icons.phone, "Phone",
                          data["phno"] ?? ""),

                      _buildTile(Icons.verified, "Approved",
                          data["isApproved"] ? "Yes" : "No"),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8)
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Go Online",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Switch(
                              value: isOnline,
                              onChanged: toggleOnline,
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// LOGOUT BUTTON
                      ElevatedButton(
                        onPressed: showLogoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize:
                          const Size(double.infinity, 50),
                        ),
                        child: const Text("Logout"),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text("$title: ",
              style:
              const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}