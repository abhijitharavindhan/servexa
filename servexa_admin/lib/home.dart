import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:servexa_admin/addservices.dart';
import 'package:servexa_admin/admin_provider_approval.dart';
import 'package:servexa_admin/adminprovider.dart';
import 'package:servexa_admin/dashboardpage.dart';
import 'package:servexa_admin/providerpage.dart';
import 'package:servexa_admin/sendnotiffication.dart';
import 'package:servexa_admin/usrlist.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int selectedIndex = 0;

  final pages = [
    Dashboardpage(),
    UsersPage(),
    Providerpage(),
    AdminProviderApproval(),
    AdminNotificationPage(),
    AddServicePage()
  ];

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Consumer<Adminprovider>(
      builder: (context, model, child) {

        return Scaffold(

          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "SERVEXA ADMIN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF00ADEE),
                    Color(0xFF0072FF)
                  ],
                ),
              ),
            ),
          ),

          drawer: Drawer(

            child: Column(
              children: [

                /// Beautiful Drawer Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF00ADEE),
                        Color(0xFF0072FF)
                      ],
                    ),
                  ),
                  child: Column(
                    children: [

                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 35,
                          color: Color(0xFF00ADEE),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Admin Panel",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        user?.email ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// Drawer Items

                _drawerItem(
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    index: 0
                ),

                _drawerItem(
                    icon: Icons.people,
                    title: "Users",
                    index: 1
                ),

                _drawerItem(
                    icon: Icons.handyman,
                    title: "Providers",
                    index: 2
                ),

                _drawerItem(
                    icon: Icons.verified,
                    title: "Approve Providers",
                    index: 3
                ),

                _drawerItem(
                    icon: Icons.notifications_active,
                    title: "Send Notification",
                    index: 4
                ),

                _drawerItem(
                    icon: Icons.add_box,
                    title: "Add Services",
                    index: 5
                ),

                const Spacer(),

                const Divider(),

                /// Logout Button
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {

                    showDialog(
                      context: context,
                      builder: (context) {

                        return AlertDialog(

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          title: const Text(
                            "Logout",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          content: const Text(
                              "Are you sure you want to logout?"
                          ),

                          actions: [

                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                model.logout(context);
                              },
                              child: const Text("Logout"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 10)

              ],
            ),
          ),

          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: pages[selectedIndex],
          ),
        );
      },
    );
  }

  /// Drawer Item Widget

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {

    bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      child: ListTile(

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),

        tileColor: isSelected
            ? const Color(0xFFE3F2FD)
            : Colors.transparent,

        leading: Icon(
          icon,
          color: isSelected
              ? const Color(0xFF0072FF)
              : Colors.grey[700],
        ),

        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.normal,
            color: isSelected
                ? const Color(0xFF0072FF)
                : Colors.black,
          ),
        ),

        onTap: () {
          setState(() {
            selectedIndex = index;
          });

          Navigator.pop(context);
        },
      ),
    );
  }
}