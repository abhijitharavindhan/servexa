import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for formatting timestamps
import 'package:url_launcher/url_launcher.dart';

class ProviderHome extends StatefulWidget {
  const ProviderHome({super.key});

  @override
  State<ProviderHome> createState() => _ProviderHomeState();
}

class _ProviderHomeState extends State<ProviderHome>
    with SingleTickerProviderStateMixin {

  final user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  /// 🔥 GOOGLE MAP
  Future<void> openMap(double lat, double lng) async {
    final googleMapsAppUrl = Uri.parse(
        "comgooglemaps://?daddr=$lat,$lng&directionsmode=driving");
    final googleMapsWebUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng");

    if (await canLaunchUrl(googleMapsAppUrl)) {
      await launchUrl(googleMapsAppUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(googleMapsWebUrl)) {
      await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Maps")),
      );
    }
  }

  /// 🔥 COMPLETE JOB
  Future<void> completeJob(String id) async {
    await FirebaseFirestore.instance
        .collection("bookings")
        .doc(id)
        .update({"status": "Completed"});

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job Completed ✅")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Provider_details')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final name = data["name"] ?? "";
          final service = data["service"] ?? "";
          final image = data["profileImage"] ?? "";
          bool isOnline = data["isOnline"] ?? false;

          return Column(
            children: [

              /// 🔥 HEADER UI
              Container(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3A7BFF), Color(0xFF00C6FF)],
                  ),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: image.isNotEmpty
                              ? NetworkImage(image)
                              : null,
                          child: image.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Hi, $name 👋",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(service,
                                  style: const TextStyle(
                                      color: Colors.white70)),
                            ],
                          ),
                        ),
                        /// ONLINE SWITCH
                        Column(
                          children: [
                            Switch(
                              value: isOnline,
                              activeColor: Colors.green,
                              onChanged: (val) async {
                                await FirebaseFirestore.instance
                                    .collection('Provider_details')
                                    .doc(user!.uid)
                                    .update({"isOnline": val});
                              },
                            ),
                            Text(
                              isOnline ? "Online" : "Offline",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    /// 🔥 TAB BAR
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                        ),
                        labelColor: Colors.greenAccent,

                        unselectedLabelColor: Colors.red,
                        tabs: const [
                          Tab(text: "Pending"),
                          Tab(text: "Accepted"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// 🔥 TAB VIEW
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [

                    /// 🔥 PENDING JOBS
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("bookings")
                          .where("serviceName", isEqualTo: service)
                          .where("status", isEqualTo: "pending")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final jobs = snapshot.data!.docs;

                        if (jobs.isEmpty) return const Center(child: Text("No Jobs"));

                        return ListView.builder(
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final data = jobs[index].data() as Map<String, dynamic>;
                            return jobCard(data, jobs[index].id, false);
                          },
                        );
                      },
                    ),

                    /// 🔥 ACCEPTED JOBS
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("bookings")
                          .where("providerId", isEqualTo: user!.uid)
                          .where("status", isEqualTo: "accepted")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final jobs = snapshot.data!.docs;

                        if (jobs.isEmpty) return const Center(child: Text("No Accepted Jobs"));

                        return ListView.builder(
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final data = jobs[index].data() as Map<String, dynamic>;
                            return jobCard(data, jobs[index].id, true);
                          },
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  /// 🔥 JOB CARD WITH TIMESTAMP, COLORS, REJECT, AND MAP
  Widget jobCard(Map<String, dynamic> data, String id, bool isAccepted) {
    final lat = data["lat"];
    final lng = data["lng"];
    final customerName = data["customerName"] ?? "Unknown";
    final contact = data["contact"] ?? "";

    // Timestamp formatting
    final Timestamp? dateTimestamp = data["date"];
    String dateFormatted = "";
    String timeFormatted = "";
    if (dateTimestamp != null) {
      final dt = dateTimestamp.toDate();
      dateFormatted = DateFormat("dd MMM yyyy").format(dt);
      timeFormatted = DateFormat("hh:mm a").format(dt);
    }

    Color cardColor = Colors.white;
    if (!isAccepted && data["status"] == "pending") {
      cardColor = Colors.orange.shade50;
    } else if (isAccepted) {
      cardColor = Colors.blue.shade50;
    } else if (data["status"] == "rejected") {
      cardColor = Colors.red.shade50;
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data["serviceName"],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("👤 $customerName"),
          Text("📞 $contact"),
          Text("📅 $dateFormatted  ⏰ $timeFormatted"),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18),
              const SizedBox(width: 5),
              Expanded(child: Text(data["locationText"])),
            ],
          ),
          const SizedBox(height: 5),
          Text("💰 ₹${data["totalAmount"]}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!isAccepted) ...[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("bookings")
                          .doc(id)
                          .update({"status": "accepted","providerId": user!.uid});
                    },
                    child: const Text("Accept"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("bookings")
                          .doc(id)
                          .update({"status": "rejected"});
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Job Rejected ❌"))
                      );
                    },
                    child: const Text("Reject"),
                  ),
                ),
              ],
              if (isAccepted) ...[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {
                      openMap(lat, lng);
                    },
                    child: const Text("Navigate"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      completeJob(id);
                    },
                    child: const Text("Complete"),
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }
}