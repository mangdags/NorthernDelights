import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:northern_delights_app/screens/home_screen.dart';
import 'package:northern_delights_app/screens/signin_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root
  @override
  Widget build(BuildContext context) {
    User? getCurrentUser() {
      return FirebaseAuth.instance.currentUser;
    }

      return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vigan Delights',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: HomeScreen(),

      initialRoute: getCurrentUser() != null ? 'home_screen' : 'signin_screen',
       routes: {
         'signin_screen': (context) => SigninScreen(),
         'home_screen': (context) => HomeScreen(),
       }
    );
  }
}
