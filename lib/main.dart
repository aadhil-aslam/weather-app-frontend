import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generated by FlutterFire CLI
import 'services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase config
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ApiService _firebaseServices = ApiService();

  late bool isLoggedIn = true;

  CheckLogin() {
    if (_firebaseServices.getUserId() != null) {
      print(FirebaseAuth.instance.currentUser?.uid);
      isLoggedIn = true;
    } else {
      isLoggedIn = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => isLoggedIn ? MainScreen() : AuthScreen(),
        '/home': (context) => MainScreen(),
        '/login': (context) => AuthScreen(),
      },
    );
  }
}
