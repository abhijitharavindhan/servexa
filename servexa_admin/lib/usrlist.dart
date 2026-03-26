import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  /// DELETE USER
  void deleteUser(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('Customer_details')
                  .doc(id)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  /// USER COUNT CARD
  Widget statCard(int totalUsers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50,
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.people, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                totalUsers.toString(),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Total Users",
                style: TextStyle(color: Colors.grey),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6FA),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            const Text(
              "Users Management",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// USER COUNT
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Customer_details')
                  .snapshots(),
              builder: (context, snapshot) {

                int totalUsers = 0;

                if (snapshot.hasData) {
                  totalUsers = snapshot.data!.docs.length;
                }

                return statCard(totalUsers);
              },
            ),

            const SizedBox(height: 20),

            /// USER LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Customer_details')
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No users found"));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {

                      final user = snapshot.data!.docs[index];
                      final data =
                      user.data() as Map<String, dynamic>;

                      String name = data['name'] ?? "User";
                      String email = data['email'] ?? "";

                      return Container(

                        margin: const EdgeInsets.only(bottom: 14),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade50,
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),

                        child: ListTile(

                          contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),

                          /// AVATAR
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor:
                            Colors.blue.shade100,
                            child: Text(
                              name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          /// NAME
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          /// EMAIL
                          subtitle: Text(email),

                          /// DELETE BUTTON
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                deleteUser(context, user.id);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}