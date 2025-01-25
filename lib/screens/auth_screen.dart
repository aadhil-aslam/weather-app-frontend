import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather_cast/screens/main_screen.dart';
import 'package:http/http.dart' as http;
import 'package:weather_cast/services/auth_srvice.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;

  final _authService = AuthService();

  Future<void> _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Call authenticate from AuthService
      UserCredential userCredential = await _authService.authenticate(
        email: email,
        password: password,
        isLogin: _isLogin,
      );

      if (userCredential.user != null) {
        // Save user data to the backend
        if (!_isLogin)
          _authService.saveUserData(userCredential.user!.uid, email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isLogin
                  ? 'Logged in successfully!'
                  : 'Account created successfully!')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: EdgeInsets.only(top: 70, left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/weather-svgrepo-com.png",
              width: 180,
              height: 180,
            ),
            SizedBox(height: 50),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                fillColor: const Color(0xFFFFFFFF),
                isDense: true,
                border: OutlineInputBorder(),
                hintText: 'Enter Email',
                labelText: 'Email',
              ),
            ),
            SizedBox(
              height: 14.0,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  fillColor: const Color(0xFFFFFFFF),
                  isDense: true,
                  border: OutlineInputBorder(),
                  hintText: 'Enter Password',
                  labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                  child: TextButton(
                style: TextButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 106, 138, 165),
                    textStyle: const TextStyle(fontSize: 15)),
                onPressed: _authenticate,
                child: Text(_isLogin ? 'Login' : 'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ))
            ]),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                style: TextStyle(
                    color: const Color.fromARGB(255, 106, 138, 165),
                    fontWeight: FontWeight.w600),
                _isLogin
                    ? 'Create an account'
                    : 'Already have an account? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
