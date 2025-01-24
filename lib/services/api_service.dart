import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://localhost:5000/'; // backend URL

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? getUserId() {
    return _firebaseAuth.currentUser?.uid;
  }
}
