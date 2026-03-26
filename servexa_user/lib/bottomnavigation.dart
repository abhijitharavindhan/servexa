import 'package:flutter/material.dart';
import 'package:servexa_user/home.dart';
import 'package:servexa_user/mybooking.dart';
import 'package:servexa_user/notification.dart';
import 'package:servexa_user/proffile.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int selected = 0;
  List pages = [Home(), MyBookingsPage(), Notifications(), Proffile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        currentIndex: selected,

        selectedItemColor: Color(0xFF00ADEE),
        // unselectedItemColor: Color(0xFF019A8A),
        unselectedItemColor: Colors.grey,
        onTap: (val) {
          setState(() {
            selected = val;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'My booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Proffile'),
        ],
      ),
      body: pages[selected],
    );
  }
}
