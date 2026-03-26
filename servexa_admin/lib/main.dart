import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servexa_admin/Login.dart';
import 'package:servexa_admin/adminprovider.dart';
import 'package:servexa_admin/home.dart';
import 'package:servexa_admin/splasscreen.dart';

import 'firebase_options.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    Myapp(),
  );
}
class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context)=>Adminprovider(),
    child: MaterialApp(
      routes: {
        'login':(context)=>Login(),
        'home':(context)=>Home(),


      },
      debugShowCheckedModeBanner: false,
      home: Splasscreen(),
    ),);
  }
}
