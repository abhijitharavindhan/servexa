import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});

  @override
  State<AdminNotificationPage> createState() =>
      _AdminNotificationPageState();
}

class _AdminNotificationPageState
    extends State<AdminNotificationPage> {

  final TextEditingController _titleController =
  TextEditingController();
  final TextEditingController _bodyController =
  TextEditingController();

  String _role = "users";

  Future<void> sendNotification() async {

    if (_titleController.text.isEmpty ||
        _bodyController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields")),
      );
      return;
    }

    try {

      await FirebaseFirestore.instance
          .collection("notifications")
          .add({

        "title": _titleController.text,
        "subtitle": _bodyController.text,
        "role": _role,
        "date": DateTime.now().toString().split(" ")[0],
        "time": TimeOfDay.now().format(context),
        "timestamp": FieldValue.serverTimestamp()

      });

      _titleController.clear();
      _bodyController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Notification Sent Successfully"),backgroundColor: Colors.green,),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error : $e"),backgroundColor: Colors.red,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF4F6FA),

      body: SingleChildScrollView(

        child: Column(
          children: [

            /// TOP HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 60, bottom: 40),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2979FF),
                    Color(0xFF00C853)
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: Column(
                children: const [

                  Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 45,
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Send Notification",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Notify users or providers instantly",
                    style: TextStyle(
                        color: Colors.white70),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// FORM CARD
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20),

              child: Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey
                          .withOpacity(.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Create Notification",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// ROLE DROPDOWN
                    DropdownButtonFormField<String>(
                      value: _role,
                      items: const [

                        DropdownMenuItem(
                            value: 'users',
                            child:
                            Text('Send to Users')),

                        DropdownMenuItem(
                            value: 'providers',
                            child: Text(
                                'Send to Providers')),
                      ],

                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _role = val;
                          });
                        }
                      },

                      decoration: InputDecoration(
                        labelText: "Select Audience",
                        prefixIcon:
                        const Icon(Icons.group),
                        filled: true,
                        fillColor:
                        Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// TITLE
                    TextField(
                      controller: _titleController,

                      decoration: InputDecoration(
                        labelText:
                        "Notification Title",
                        prefixIcon:
                        const Icon(Icons.title),
                        filled: true,
                        fillColor:
                        Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// MESSAGE
                    TextField(
                      controller: _bodyController,
                      maxLines: 3,

                      decoration: InputDecoration(
                        labelText:
                        "Notification Message",
                        prefixIcon: const Icon(
                            Icons.message),
                        filled: true,
                        fillColor:
                        Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// SEND BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton.icon(

                        onPressed: sendNotification,

                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),

                        label: const Text(
                          "Send Notification",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold),
                        ),

                        style: ElevatedButton
                            .styleFrom(
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(14),
                          ),

                          backgroundColor:
                          Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}