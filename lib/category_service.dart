import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

// Service class to handle category-related API calls
class CategoryService {
  // Static method to fetch categories from the backend API
  static Future<List<Map<String, dynamic>>> getCategories() async {
    // Construct the full API URL for fetching categories
    final url = Uri.parse('${AppConfig.baseUrl}/api/categories');

    try {
      // Make a GET request to the API
      final response = await http.get(url);

      // Debug print statements to log the request and response status
      print('GET ${url.toString()} → ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check if the response is successful (HTTP 200 OK)
      if (response.statusCode == 200) {
        // Parse the response body as JSON
        List<dynamic> data = jsonDecode(response.body);

        // Map the dynamic JSON list into a List of Map with id and name keys
        return data
            .map<Map<String, dynamic>>((item) => {
                  'id': item['id'],       // Extract category ID
                  'name': item['name'],   // Extract category name
                })
            .toList();
      } else {
        // If response is not OK, throw an exception indicating failure
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // Catch any exceptions during the HTTP request or JSON parsing
      print('Exception in getCategories(): $e');
      // Throw a generic network error exception for upstream handling
      throw Exception('Network error occurred');
    }
  }
}
