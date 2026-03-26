import 'package:flutter/material.dart';

class ProviderDetails extends StatelessWidget {

  final Map provider;

  const ProviderDetails({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Details"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Name: ${provider["name"]}"),
            const SizedBox(height: 10),

            Text("Email: ${provider["email"]}"),
            const SizedBox(height: 10),

            Text("Phone: ${provider["phno"]}"),
            const SizedBox(height: 10),

            Text("Service: ${provider["service"]}"),

          ],
        ),
      ),
    );
  }
}