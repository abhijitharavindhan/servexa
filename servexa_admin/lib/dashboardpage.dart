import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:servexa_admin/addservices.dart';
import 'package:servexa_admin/usrlist.dart';

class Dashboardpage extends StatefulWidget {
  const Dashboardpage({super.key});

  @override
  State<Dashboardpage> createState() => _DashboardpageState();
}

class _DashboardpageState extends State<Dashboardpage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900],
            ),
          ),
          const SizedBox(height: 24),

          // Cards Row
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildStreamCard(
                title: 'Users',
                collection: 'Customer_details',
                color: Colors.blueAccent,
                icon: Icons.person,
              ),
              _buildStreamCard(
                title: 'Providers',
                collection: 'Provider_details',
                color: Colors.green,
                icon: Icons.store,
              ),
              _buildQuickActionCard(
                title: 'Add Service',
                icon: Icons.add_box,
                color: Colors.orangeAccent,
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>AddServicePage()));
                },
              ),
              // _buildQuickActionCard(
              //   title: 'View Users',
              //   icon: Icons.people,
              //   color: Colors.purpleAccent,
              //   onTap: () {
              //     Navigator.push(context,MaterialPageRoute(builder: (context)=>UsersPage()));
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }

  // Stream card for dynamic count
  Widget _buildStreamCard({
    required String title,
    required String collection,
    required Color color,
    required IconData icon,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }
        return _buildAnimatedCard(title: title, count: count, color: color, icon: icon);
      },
    );
  }

  // Animated card with count
  Widget _buildAnimatedCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return _buildCardUI(
          title: title,
          count: value,
          color: color,
          icon: icon,
        );
      },
    );
  }

  // Quick action card
  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: _buildCardUI(title: title, count: null, color: color, icon: icon),
    );
  }

  // Card UI
  Widget _buildCardUI({
    required String title,
    int? count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.white),
          const SizedBox(height: 12),
          if (count != null)
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}