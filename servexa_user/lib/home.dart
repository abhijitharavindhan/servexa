import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servexa_user/booking_page.dart';
import 'package:servexa_user/usrprovider.dart';
import 'package:servexa_user/widgets/service_card.dart';
import 'package:intl/intl.dart';

import 'mybooking.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final user = FirebaseAuth.instance.currentUser;
  String searchText = "";

  @override
  Widget build(BuildContext context) {

    return Consumer<UsrProvider>(
      builder: (context, model, child) {

        return Scaffold(

          backgroundColor: const Color(0xFFF6F8FB),

          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.blue,
            title: const Text(
              "Servexa",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),

          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Customer_details')
                .doc(user!.uid)
                .snapshots(),

            builder: (context, userSnapshot) {

              if (!userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var data = userSnapshot.data!.data() as Map<String, dynamic>?;

              return RefreshIndicator(

                onRefresh: () async {
                  setState(() {});
                },

                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// GREETING CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3A7BFF),
                              Color(0xFF00C6FF)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              data != null && data.containsKey('name')
                                  ? 'Hi ${data['name']} 👋'
                                  : 'Hi User 👋',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 4),

                            const Text(
                              "What service do you need today?",
                              style: TextStyle(color: Colors.white70),
                            ),

                            const SizedBox(height: 20),

                            /// SEARCH BAR
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value.toLowerCase();
                                  });
                                },
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.search, color: Colors.grey),
                                  hintText: "Search services...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// SERVICES TITLE
                      const Text(
                        "Popular Services",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// SERVICES GRID
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("services")
                            .where("isActive", isEqualTo: true)
                            .snapshots(),

                        builder: (context, snapshot) {

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text("No Services Available"));
                          }

                          var services = snapshot.data!.docs.where((doc) {

                            var name = doc["name"].toString().toLowerCase();
                            return name.contains(searchText);

                          }).toList();

                          return GridView.builder(

                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),

                            itemCount: services.length,

                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.9,
                            ),

                            itemBuilder: (context, index) {

                              var service = services[index];

                              return GestureDetector(

                                onTap: () {

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingPage(
                                        serviceName: service["name"],
                                        pricePerHour: service["pricePerHour"],
                                      ),
                                    ),
                                  );

                                },

                                child: ServiceCard(
                                  title: service["name"],
                                  subtitle: service["subtitle"],
                                  imageUrl: service["imageUrl"],
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      /// BOOKINGS TITLE
                      const Text(
                        "My Bookings",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// BOOKINGS LIST
                      StreamBuilder<QuerySnapshot>(

                        stream: FirebaseFirestore.instance
                            .collection("bookings")
                            .where("userId", isEqualTo: user!.uid)
                            .orderBy("createdAt", descending: true)
                            .snapshots(),

                        builder: (context, snapshot) {

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text(
                              "No bookings yet",
                              style: TextStyle(color: Colors.grey),
                            );
                          }

                          final bookings = snapshot.data!.docs;

                          return ListView.builder(

                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: bookings.length,

                            itemBuilder: (context, index) {

                              final bookingData = bookings[index].data() as Map<String, dynamic>;

                              final dateTimestamp = bookingData["date"] as Timestamp?;
                              final createdAtTimestamp = bookingData["createdAt"] as Timestamp?;

                              final date = dateTimestamp?.toDate() ?? DateTime.now();
                              final createdAt = createdAtTimestamp?.toDate() ?? DateTime.now();

                              final formattedDate =
                              DateFormat("dd MMM yyyy").format(date);

                              final formattedCreatedAt =
                              DateFormat("dd MMM yyyy 'at' hh:mm a").format(createdAt);

                              return BookingCard(
                                serviceName: bookingData["serviceName"] ?? "Service",
                                date: formattedDate,
                                time: bookingData["time"] ?? "N/A",
                                hours: bookingData["hours"]?.toString() ?? "1",
                                location: bookingData["locationText"] ?? "Unknown",
                                pricePerHour: bookingData["pricePerHour"]?.toString() ?? "0",
                                totalAmount: bookingData["totalAmount"]?.toString() ?? "0",
                                status: bookingData["status"] ?? "Pending",
                                createdAt: formattedCreatedAt,
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}