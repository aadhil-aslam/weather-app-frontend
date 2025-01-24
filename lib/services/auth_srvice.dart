import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:weather_cast/services/api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiServices = ApiService();

  Future<UserCredential> authenticate({
    required String email,
    required String password,
    required bool isLogin,
  }) async {
    try {
      if (isLogin) {
        // Login
        return await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        // Sign up
        return await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> saveUserData(String uid, String email) async {
    final url = Uri.parse('${_apiServices.baseUrl}api/users/save');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Get the Firebase ID token
    final idToken = await user.getIdToken();
    print(idToken);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': uid,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        print('User data saved successfully!');
      } else {
        print('Error saving user data: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
