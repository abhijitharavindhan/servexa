import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servexa_provider/login.dart';
import 'package:servexa_provider/providerregistration.dart';
import 'package:servexa_provider/proprovider.dart';
import 'package:servexa_provider/splashscreen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Proprovider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Servexa Provider",
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),

        // Start with login
        home: const SplashScreen(),

        routes: {
          "login": (context) => const Login(),
          "proreg": (context) => const ProviderRegistration(),
        },
      ),
    );
  }
}