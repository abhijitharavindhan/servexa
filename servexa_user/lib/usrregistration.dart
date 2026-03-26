import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servexa_user/usrprovider.dart';

class Usrregistration extends StatefulWidget {
  const Usrregistration({super.key});

  @override
  State<Usrregistration> createState() => _UsrregistrationState();
}

class _UsrregistrationState extends State<Usrregistration> {



  @override
  Widget build(BuildContext context) {
   return Consumer<UsrProvider>(builder: (context , model ,child){
     return Scaffold(
       backgroundColor: Color(0xFFFEFEFE),
       body: SingleChildScrollView(
         scrollDirection: Axis.vertical,
         child: Center(
           child: Column(
             children: [
               Row(
                 children: [
                   IconButton(
                     onPressed: () => Navigator.pop(context),
                     icon: const Icon(CupertinoIcons.arrow_left),
                   ),
                   Expanded(
                     child: Image.asset('lib/images/title.jpeg', height: 200),
                   ),
                 ],
               ),

               SizedBox(
                 child: Container(
                   width: 400,
                   height: 500,
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(16),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.blueGrey,
                         spreadRadius: 1,
                         blurRadius: 6,
                       ),
                     ],
                   ),
                   child: Column(
                     children: [
                       Align(
                         alignment: Alignment.topLeft,
                         child: Padding(
                           padding: const EdgeInsets.all(15),
                           child: const Text(
                             'Name',
                             style: TextStyle(
                               fontSize: 15,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                       ),

                       SizedBox(
                         width: 365,
                         height: 50,
                         child: TextField(
                           controller: model.name,
                           decoration: InputDecoration(
                             hint: Text(
                               'Name',
                               style: TextStyle(color: Colors.grey),
                             ),
                             border: OutlineInputBorder(),
                           ),
                         ),
                       ),

                       Align(
                         alignment: Alignment.topLeft,
                         child: Padding(
                           padding: const EdgeInsets.all(15),
                           child: const Text(
                             'Email',
                             style: TextStyle(
                               fontSize: 15,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                       ),

                       SizedBox(
                         width: 365,
                         height: 50,
                         child: TextField(
                           controller: model.email,
                           decoration: InputDecoration(
                             hint: Text(
                               'Email',
                               style: TextStyle(color: Colors.grey),
                             ),
                             border: OutlineInputBorder(),
                           ),
                         ),
                       ),

                       SizedBox(height: 20),
                       Align(
                         alignment: Alignment.topLeft,
                         child: Padding(
                           padding: const EdgeInsets.all(15),
                           child: const Text(
                             'password',
                             style: TextStyle(
                               fontSize: 15,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                       ),

                       SizedBox(
                         height: 50,
                         width: 365,
                         child: TextField(
                           controller: model.password,
                           obscureText: true,
                           decoration: InputDecoration(
                             hint: Text(
                               'Password',
                               style: TextStyle(color: Colors.grey),
                             ),
                             suffix: IconButton(
                               onPressed: () {},
                               icon: Icon(CupertinoIcons.eye),
                             ),
                             border: OutlineInputBorder(),
                           ),
                         ),
                       ),

                       SizedBox(height: 30),
                       SizedBox(
                         height: 50,
                         width: 360,
                         child: ElevatedButton(
                           style: ButtonStyle(
                             shape: WidgetStatePropertyAll(
                               RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(10),
                               ),
                             ),
                             backgroundColor: WidgetStatePropertyAll(
                               Color(0xFF019A8A),
                             ),
                           ),

                           // Use model.name, model.email, model.password controllers instead of local ones
                           onPressed: () => model.register(context), // Unified logic
                           child: Text(
                             'Register',
                             style: TextStyle(color: Colors.white),
                           ),
                         ),
                       ),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text('Already have an account?'),
                           TextButton(
                             onPressed: () {
                               Navigator.pushNamed(context, 'login');
                             },
                             child: Text(
                               'Login',
                               style: TextStyle(color: Color(0xFF00C853)),
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                 ),
               ),
             ],
           ),
         ),
       ),
     );

   });
  }
}
