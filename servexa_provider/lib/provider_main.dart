import 'package:flutter/material.dart';
import 'provider_home.dart';
import 'provider_jobs.dart';
import 'provider_earnings.dart';
import 'provider_profile.dart';

class ProviderMain extends StatefulWidget {
  const ProviderMain({super.key});

  @override
  State<ProviderMain> createState() => _ProviderMainState();
}

class _ProviderMainState extends State<ProviderMain> {
  int currentIndex = 0;

  final pages = const [
    ProviderHome(),
    ProviderJobs(),
    ProviderEarnings(),
    ProviderProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.work), label: "Jobs"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: "Earnings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}