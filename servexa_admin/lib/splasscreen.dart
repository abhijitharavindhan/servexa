   import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servexa_admin/Login.dart';
import 'package:servexa_admin/adminprovider.dart';
import 'package:servexa_admin/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splasscreen extends StatefulWidget {
     const Splasscreen({super.key});
   
     @override
     State<Splasscreen> createState() => _SplasscreenState();
   }
   
   class _SplasscreenState extends State<Splasscreen> {
  @override
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogged = prefs.getBool('islogged') ?? false;

    if (isLogged) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      Future.delayed(const Duration(seconds: 4), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
    }
  }


  bool? finaldata ;
  Future getloggeddata()async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    var getdata = preferences.getBool('islogged');
    setState(() {
      finaldata = getdata;
    });


  }



     @override
     Widget build(BuildContext context) {
       return Scaffold(
         body: Container(
           width: double.infinity,
           // height: double.infinity,
           decoration: BoxDecoration(
             gradient: RadialGradient(
               center: Alignment.centerRight,
               colors: [Color(0xFF00C853), Color(0xFF00C853), Color(0xFF00ADEE)],
             ),
           ),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Image.asset('lib/images/logo.png'),
               Text(
                 'Servexa',
                 style: TextStyle(
                   fontWeight: FontWeight.bold,
                   color: Colors.white,
                   fontSize: 50,
                 ),
               ),
               Text(
                 'on-Demand Services,\n'
                     '  Delivered Smartly',
                 style: TextStyle(color: Colors.white, fontSize: 20),
               ),
             ],
           ),
         ),
       );


     }
   }
   