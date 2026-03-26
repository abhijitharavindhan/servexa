import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_picker_page.dart';

class BookingPage extends StatefulWidget {
  final String serviceName;
  final int pricePerHour;

  const BookingPage({
    super.key,
    required this.serviceName,
    required this.pricePerHour,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  LatLng? selectedLocation;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int hours = 1;
  bool isLoading = false;

  final TextEditingController locationController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  int get totalPrice => hours * widget.pricePerHour;

  // 📅 Pick Date
  Future<void> pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
      initialDate: DateTime(now.year, now.month, now.day),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        selectedTime = null;
      });
    }
  }

  // ⏰ Pick Time
  Future<void> pickTime() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select date first")),
      );
      return;
    }

    final now = DateTime.now();

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final selectedDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        time.hour,
        time.minute,
      );

      if (selectedDate!.year == now.year &&
          selectedDate!.month == now.month &&
          selectedDate!.day == now.day &&
          selectedDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot select past time")),
        );
        return;
      }

      setState(() => selectedTime = time);
    }
  }

  // 📦 Booking
  Future<void> bookService() async {
    if (selectedDate == null ||
        selectedTime == null ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final now = DateTime.now();

    final current = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    final selectedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    if (!selectedDateTime.isAfter(current)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select future time")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection("bookings").add({
        "userId": user?.uid,
        "serviceName": widget.serviceName,
        "pricePerHour": widget.pricePerHour,
        "hours": hours,
        "totalAmount": totalPrice,
        "date": Timestamp.fromDate(selectedDate!),
        "time": selectedTime!.format(context),
        "locationText": locationController.text,
        "latitude": selectedLocation?.latitude,
        "longitude": selectedLocation?.longitude,
        "status": "pending",
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Successful")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  void increaseHours() => setState(() => hours++);
  void decreaseHours() {
    if (hours > 1) setState(() => hours--);
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(widget.serviceName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCard(
                    title: "Date",
                    icon: Icons.calendar_today,
                    child: ElevatedButton(
                      onPressed: pickDate,
                      child: Text(selectedDate == null
                          ? "Select"
                          : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCard(
                    title: "Time",
                    icon: Icons.access_time,
                    child: ElevatedButton(
                      onPressed: pickTime,
                      child: Text(selectedTime == null
                          ? "Select"
                          : selectedTime!.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildCard(
              title: "Working Hours",
              icon: Icons.timer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: decreaseHours,
                      icon: const Icon(Icons.remove_circle, color: Colors.red)),
                  Text("$hours Hrs",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: increaseHours,
                      icon:
                      const Icon(Icons.add_circle, color: Colors.green)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildCard(
              title: "Location",
              icon: Icons.location_on,
              child: TextField(
                controller: locationController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Pick location from map",
                  suffixIcon: const Icon(Icons.map, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MapPickerPage()),
                  );

                  if (result != null) {
                    setState(() {
                      selectedLocation =
                          LatLng(result["lat"], result["lng"]);
                      locationController.text = result["address"];
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.greenAccent, Colors.green],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Amount",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("₹$totalPrice",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : bookService,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Confirm Booking",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}