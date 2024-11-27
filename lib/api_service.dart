// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = 'https://your-api-endpoint.com/create-user'; // Update with your API URL

  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        // Successfully created user
        return true;
      } else {
        // Handle failure response (you can show a message or log error)
        return false;
      }
    } catch (e) {
      print("Error creating user: $e");
      return false;
    }
  }
}
