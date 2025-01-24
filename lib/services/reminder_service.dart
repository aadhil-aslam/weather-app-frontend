import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weather_cast/services/api_service.dart';

class ReminderService {
  ApiService _apiServices = ApiService();

  Future<String?> getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

// Fetch reminders for a user
  Future<List<dynamic>> fetchReminders() async {
    final token = await getIdToken();
    final response = await http.get(
      Uri.parse('${_apiServices.baseUrl}api/reminders'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['reminders'];
    } else {
      throw Exception('Failed to load reminders');
    }
  }

// Create a reminder
  Future<void> createReminder(
      String title, String description, String time) async {
    final token = await getIdToken();
    final response = await http.post(
      Uri.parse('${_apiServices.baseUrl}api/reminders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'time': time,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create reminder');
    }
  }

// Update a reminder
  Future<void> updateReminder(
      String id, String title, String description, String time) async {
    final token = await getIdToken();
    final response = await http.put(
      Uri.parse('${_apiServices.baseUrl}api/reminders/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'time': time,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update reminder');
    }
  }

// Delete a reminder
  Future<void> deleteReminder(String id) async {
    final token = await getIdToken();
    final response = await http.delete(
      Uri.parse('${_apiServices.baseUrl}api/reminders/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete reminder');
    }
  }
}
