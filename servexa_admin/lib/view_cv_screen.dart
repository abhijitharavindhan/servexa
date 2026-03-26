import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewCVScreen extends StatelessWidget {
  final String pdfUrl;

  const ViewCVScreen({super.key, required this.pdfUrl});

  Future<void> openPDF(BuildContext context) async {
    if (pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No CV available")),
      );
      return;
    }

    final Uri uri = Uri.parse(pdfUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open CV")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider CV"),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Open CV"),
          onPressed: () => openPDF(context),
        ),
      ),
    );
  }
}