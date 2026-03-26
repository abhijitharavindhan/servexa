import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'provider_details.dart';

class AdminProviderApproval extends StatefulWidget {
  const AdminProviderApproval({super.key});

  @override
  State<AdminProviderApproval> createState() => _AdminProviderApprovalState();
}

class _AdminProviderApprovalState extends State<AdminProviderApproval> {

  String searchText = "";

  /// OPEN CV
  Future<void> openCV(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No CV uploaded")),
      );
      return;
    }

    final Uri uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open CV")),
      );
    }
  }

  /// APPROVE PROVIDER
  Future approveProvider(String uid) async {

    await FirebaseFirestore.instance
        .collection("Provider_details")
        .doc(uid)
        .update({"isApproved": true});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Provider Approved"),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// REJECT PROVIDER
  Future rejectProvider(String uid) async {

    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reject Provider"),
          content: const Text(
              "Are you sure you want to reject this provider?"),
          actions: [

            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Reject"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {

      await FirebaseFirestore.instance
          .collection("Provider_details")
          .doc(uid)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Provider Rejected"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// DASHBOARD CARD
  Widget dashboardCard(String title, String value, IconData icon, Color color) {

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade50,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),

        child: Column(
          children: [

            Icon(icon, color: color, size: 28),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF2F6FF),

      /// APPBAR
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Provider Approvals",
          style: TextStyle(
            color: Colors.white,
              fontWeight: FontWeight.bold),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00ADEE),
                Color(0xFF0072FF)
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [

          /// DASHBOARD STATS
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Provider_details")
                .snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const SizedBox();
              }

              int total = snapshot.data!.docs.length;

              int approved = snapshot.data!.docs
                  .where((doc) => doc["isApproved"] == true)
                  .length;

              int pending = snapshot.data!.docs
                  .where((doc) => doc["isApproved"] == false)
                  .length;

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Row(
                  children: [

                    dashboardCard(
                      "Pending",
                      pending.toString(),
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),

                    dashboardCard(
                      "Approved",
                      approved.toString(),
                      Icons.verified,
                      Colors.green,
                    ),

                    dashboardCard(
                      "Total",
                      total.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                  ],
                ),
              );
            },
          ),

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade50,
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  )
                ],
              ),

              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search Provider...",
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 15),
                ),

                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
              ),
            ),
          ),

          /// PROVIDER LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("Provider_details")
                  .where("isApproved", isEqualTo: false)
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var providers = snapshot.data!.docs.where((doc) {

                  return doc["name"]
                      .toString()
                      .toLowerCase()
                      .contains(searchText);

                }).toList();

                if (providers.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Pending Providers",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(

                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),

                  itemCount: providers.length,

                  itemBuilder: (context, index) {

                    var data = providers[index];

                    return Container(

                      margin: const EdgeInsets.only(bottom: 14),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
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
                            horizontal: 16,
                            vertical: 10),

                        /// AVATAR
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor:
                          Colors.blue.shade100,
                          child: const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                        ),

                        /// NAME
                        title: Text(
                          data["name"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        /// DETAILS
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            const SizedBox(height: 4),

                            Text(
                              data["email"],
                              style:
                              const TextStyle(fontSize: 13),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                BorderRadius.circular(8),
                              ),

                              child: Text(
                                data["service"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),

                        /// OPEN DETAILS
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProviderDetails(
                                provider: data.data() as Map,
                              ),
                            ),
                          );
                        },

                        /// ACTION BUTTONS
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            /// CV
                            IconButton(
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.blue,
                              ),
                              onPressed: () =>
                                  openCV(data["cv"] ?? ""),
                            ),

                            /// APPROVE
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed: () =>
                                  approveProvider(data.id),
                            ),

                            /// REJECT
                            IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  rejectProvider(data.id),
                            ),
                          ],
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
    );
  }
}