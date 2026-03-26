import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _refreshBookings() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          "My Bookings",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .where("userId", isEqualTo: user!.uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Show loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Debug prints
          if (snapshot.hasData) {
            print("Booking docs count: ${snapshot.data!.docs.length}");
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              print("DOC ID: ${doc.id}");
              print("userId: ${data['userId']}");
              print("createdAt: ${data['createdAt']}");
              print("Full doc: $data");
            }
          } else if (snapshot.hasError) {
            print("Error fetching bookings: ${snapshot.error}");
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No bookings yet", style: TextStyle(fontSize: 16)),
            );
          }

          // Map bookings safely
          final bookings = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>?)
              .where((data) => data != null)
              .toList();

          return RefreshIndicator(
            onRefresh: _refreshBookings,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final bookingData = bookings[index]!;

                final Timestamp? dateTimestamp = bookingData["date"] as Timestamp?;
                final Timestamp? createdAtTimestamp = bookingData["createdAt"] as Timestamp?;

                final date = dateTimestamp?.toDate() ?? DateTime.now();
                final formattedDate = DateFormat("dd MMM yyyy").format(date);

                final createdAt = createdAtTimestamp?.toDate() ?? DateTime.now();
                final formattedCreatedAt =
                DateFormat("dd MMM yyyy 'at' hh:mm a").format(createdAt);

                final time = bookingData["time"] ?? "N/A";

                return BookingCard(
                  serviceName: bookingData["serviceName"] ?? "Service",
                  date: formattedDate,
                  time: time,
                  hours: bookingData["hours"]?.toString() ?? "1",
                  location: bookingData["locationText"] ?? "Unknown",
                  pricePerHour: bookingData["pricePerHour"]?.toString() ?? "0",
                  totalAmount: bookingData["totalAmount"]?.toString() ?? "0",
                  status: bookingData["status"] ?? "Pending",
                  createdAt: formattedCreatedAt,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String serviceName;
  final String date;
  final String time;
  final String hours;
  final String location;
  final String pricePerHour;
  final String totalAmount;
  final String status;
  final String createdAt;

  const BookingCard({
    super.key,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.hours,
    required this.location,
    required this.pricePerHour,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status.toLowerCase() == "ongoing"
        ? Colors.green
        : status.toLowerCase() == "rejected"
        ? Colors.red
        : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                serviceName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.black),
              const SizedBox(width: 4),
              Text("$date • $time", style: const TextStyle(color: Colors.black)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.black),
              const SizedBox(width: 4),
              Text("$hours Hours • ₹$pricePerHour/hr", style: const TextStyle(color: Colors.black)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.black),
              const SizedBox(width: 4),
              Expanded(child: Text(location, style: const TextStyle(color: Colors.black))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.attach_money, size: 16, color: Colors.black),
              const SizedBox(width: 4),
              Text("Total: ₹$totalAmount", style: const TextStyle(color: Colors.black)),
            ],
          ),
          const SizedBox(height: 6),
          Text("Booked on: $createdAt", style: const TextStyle(fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }
}