import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProviderEarnings extends StatelessWidget {
  const ProviderEarnings({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Earnings"),
        centerTitle: true,
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .where("providerId", isEqualTo: user!.uid)
            .where("status", isEqualTo: "Completed") // ⚠️ case-sensitive
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          double total = 0;
          double todayTotal = 0;

          final today = DateTime.now();

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            double amount = (data["totalAmount"] ?? 0).toDouble();
            total += amount;

            /// 🔥 TODAY EARNINGS
            if (data["createdAt"] != null) {
              DateTime date =
              (data["createdAt"] as Timestamp).toDate();

              if (date.day == today.day &&
                  date.month == today.month &&
                  date.year == today.year) {
                todayTotal += amount;
              }
            }
          }

          return Column(
            children: [

              /// 🔥 TOP CARDS
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    /// TOTAL EARNINGS
                    _buildCard(
                      title: "Total Earnings",
                      value: "₹$total",
                      icon: Icons.account_balance_wallet,
                      colors: [Colors.blue, Colors.blueAccent],
                    ),

                    const SizedBox(height: 15),

                    /// TODAY EARNINGS
                    _buildCard(
                      title: "Today Earnings",
                      value: "₹$todayTotal",
                      icon: Icons.today,
                      colors: [Colors.green, Colors.teal],
                    ),

                    const SizedBox(height: 15),

                    /// TOTAL JOBS
                    _buildCard(
                      title: "Jobs Completed",
                      value: docs.length.toString(),
                      icon: Icons.work,
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// 🔥 JOB LIST TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Completed Jobs",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔥 JOB LIST
              Expanded(
                child: docs.isEmpty
                    ? const Center(child: Text("No earnings yet"))
                    : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final data =
                    docs[index].data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 6)
                        ],
                      ),
                      child: Row(
                        children: [

                          /// ICON
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.green),
                          ),

                          const SizedBox(width: 10),

                          /// DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["serviceName"] ?? "",
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                Text(
                                    "📍 ${data["locationText"] ?? ""}"),
                                Text(
                                    "⏰ ${data["time"] ?? ""}"),
                              ],
                            ),
                          ),

                          /// AMOUNT
                          Text(
                            "₹${data["totalAmount"]}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  /// 🔥 CARD UI
  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [

          Icon(icon, color: Colors.white, size: 30),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 5),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }
}