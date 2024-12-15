import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://127.0.0.1:5000'; // Flask backend URL

  // Fetch user details
  Future<Map<String, dynamic>> getUser(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/get_user?user_id=$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user: ${response.body}');
    }
  }

  // Create a new user
  Future<Map<String, dynamic>> createUser(String userId, String userName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_user'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_id': userId, 'user_name': userName}),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  // Add a product
  Future<Map<String, dynamic>> addProduct(String productId, String productName, String ownerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_product'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'product_id': productId, 'product_name': productName, 'owner_id': ownerId}),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add product: ${response.body}');
    }
  }

  // Check product details
  Future<Map<String, dynamic>> checkProduct(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/check_product?product_id=$productId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch product: ${response.body}');
    }
  }
}
