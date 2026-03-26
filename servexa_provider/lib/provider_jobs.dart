import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProviderJobs extends StatelessWidget {
  const ProviderJobs({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      /// 🔥 MODERN APPBAR
      appBar: AppBar(
        title: const Text("Available Jobs"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A7BFF), Color(0xFF00C6FF)],
            ),
          ),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Provider_details')
            .doc(user!.uid)
            .get(),
        builder: (context, providerSnapshot) {
          if (!providerSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final providerData =
          providerSnapshot.data!.data() as Map<String, dynamic>;

          String service = providerData['service'];

          /// 🔥 STREAM JOBS
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("bookings")
                .where("serviceName", isEqualTo: service)
                .where("status", isEqualTo: "pending")
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final jobs = snapshot.data!.docs;

              /// 🔥 EMPTY UI
              if (jobs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off, size: 80, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("No Jobs Available",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final data =
                  jobs[index].data() as Map<String, dynamic>;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          /// 🔥 HEADER ROW
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data["serviceName"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              /// STATUS BADGE
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Pending",
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// 🔥 DETAILS
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 18, color: Colors.blue),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(data["locationText"]),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 18, color: Colors.green),
                              const SizedBox(width: 5),
                              Text(data["time"]),
                            ],
                          ),

                          const SizedBox(height: 5),

                          Row(
                            children: [
                              const Icon(Icons.currency_rupee,
                                  size: 18, color: Colors.black),
                              const SizedBox(width: 5),
                              Text(
                                "${data["totalAmount"]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          /// 🔥 BUTTONS
                          Row(
                            children: [

                              /// ACCEPT
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection("bookings")
                                        .doc(jobs[index].id)
                                        .update({
                                      "status": "accepted",
                                      "providerId": user.uid
                                    });
                                  },
                                  child: const Text("Accept"),
                                ),
                              ),

                              const SizedBox(width: 10),

                              /// REJECT
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection("bookings")
                                        .doc(jobs[index].id)
                                        .update({
                                      "status": "rejected"
                                    });
                                  },
                                  child: const Text("Reject"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}