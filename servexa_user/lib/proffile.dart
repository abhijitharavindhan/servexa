import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servexa_user/usrprovider.dart';
import 'edit_profile.dart';
import 'login.dart';

class Proffile extends StatelessWidget {
  const Proffile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Consumer<UsrProvider>(
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),

          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Customer_details')
                .doc(user!.uid)
                .snapshots(),

            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("User data not found"));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              return Stack(
                children: [

                  /// GRADIENT HEADER
                  Container(
                    height: 300,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF3A7BFF),
                          Color(0xFF00C6FF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          const SizedBox(height: 20),

                          /// TITLE
                          const Text(
                            "My Profile",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// PROFILE IMAGE
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                data['name'] != null
                                    ? data['name'][0].toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 9),

                          /// NAME
                          Text(
                            data['name'] ?? "User",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // const SizedBox(height: ),

                          /// EMAIL
                          Text(
                            data['email'] ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// MENU CARD
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),

                            child: Column(
                              children: [

                                _tile(
                                  icon: CupertinoIcons.person,
                                  color: Colors.blue,
                                  title: "Edit Profile",
                                  onTap: () {

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const EditProfile(),
                                      ),
                                    );

                                  },
                                ),

                                _divider(),

                                _tile(
                                  icon: CupertinoIcons.settings,
                                  color: Colors.green,
                                  title: "Settings",
                                  onTap: () {},
                                ),

                                _divider(),

                                _tile(
                                  icon: Icons.location_on_outlined,
                                  color: Colors.orange,
                                  title: "Saved Addresses",
                                  onTap: () {},
                                ),

                                _divider(),

                                _tile(
                                  icon: Icons.support_agent,
                                  color: Colors.purple,
                                  title: "Help & Support",
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// LOGOUT BUTTON
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(

                                icon: const Icon(Icons.logout),
                                label: const Text("Logout"),

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),

                                onPressed: () {

                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(

                                      title: const Text(
                                          "Are you sure you want to logout?"),

                                      actions: [

                                        TextButton(
                                          onPressed: () {

                                            model.logout(context);

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                const Login(),
                                              ),
                                            );
                                          },
                                          child: const Text("Yes"),
                                        ),

                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("No"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// DIVIDER
  static Widget _divider() {
    return const Divider(height: 1);
  }

  /// MENU TILE
  static Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(

      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),

      onTap: onTap,
    );
  }
}