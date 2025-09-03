import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/ProfileManager.dart';

class ApiService {
  static const String baseUrl = "https://grownfundapi.quickbill.site/api";


  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/admin/login");

    print("Login URL: $url");
    print("Email: $email");
    print("Password: $password");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final result = _processResponse(response);
      print("Raw API result: $result");

      if (result['success'] == true) {
        // Access data from within the 'data' object.
        final data = result['data'];
        final token = data['token'];
        final admin = data['admin'];

        // Debug logging to check values
        print("Token from response: $token");
        print("Admin data: $admin");

        // Check each required field for null
        if (token == null) {
          print("Error: Token is null");
          throw Exception("Token is missing in API response.");
        }
        if (admin == null) {
          print("Error: Admin data is null");
          throw Exception("Admin data is missing in API response.");
        }
        if (admin['id'] == null || admin['name'] == null || admin['email'] == null) {
          print("Error: One of the admin fields is null. Admin: $admin");
          throw Exception("Incomplete admin data in API response.");
        }

        await ProfileManager.saveUser(
          token: token,
          userId: admin['id'],
          name: admin['name'],
          email: admin['email'],
        );

        print("Login successful - saved user data.");
      }

      return result;
    } catch (e) {
      print("Login Error: $e");
      return _handleException(e);
    }
  }
  static Future<List<Map<String, String>>> fetchUsers() async {
    final token = await ProfileManager.getToken(); // get the stored token

    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> users = json['users']['data'];

      return users.map<Map<String, String>>((user) {
        return {
          "name": user["name"] ?? '',
          "email": user["email"] ?? '',
          "phone": user["phone"] ?? 'N/A',
          "role": user["role"] ?? 'User',
          "status": user["email_verified_at"] != null ? "Active" : "Inactive",
          "registered": user["created_at"]?.split("T").first ?? '',
          "location": "N/A",
          "department": "N/A",
        };
      }).toList();
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      throw Exception("Failed to load users");
    }
  }


  static Future<Map<String, dynamic>> logout() async {

    try {
      final token = await ProfileManager.getToken();
      if (token == null) {
        return {
          'success': false,
          'status': 401,
          'data': {'message': 'Not logged in'},
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/admin/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await ProfileManager.clear();
      }

      return _processResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'status': response.statusCode,
        'data': data,
        'message': data['message'] ?? 'No message', // add this line
      };
    } catch (_) {
      return {
        'success': false,
        'status': response.statusCode,
        'data': {'message': 'Failed to parse response'},
        'message': 'Failed to parse response',
      };
    }
  }


  static Map<String, dynamic> _handleException(Object error) {
    return {
      'success': false,
      'status': 500,
      'data': {'message': error.toString()},
    };
  }


  // Function to submit the schema
  static Future<http.Response> submitSchema({
    required String name,
    required String description,
    required String amount,
    required String maturityAmount,
    required String roi,
    required String duration,
    required String type,
    required String startDate,
    File? file,
  }) async {
    var uri = Uri.parse("$baseUrl/admin/schema");

    try {
      // Get the stored token using ProfileManager
      final token = await ProfileManager.getToken();
      if (token == null) {
        throw Exception('Access token is missing');
      }

      var request = http.MultipartRequest('POST', uri);

      // Add fields to the request
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['amount'] = amount;
      request.fields['maturityAmount'] = maturityAmount;
      request.fields['roi'] = roi;
      request.fields['duration'] = duration;
      request.fields['type'] = type;
      request.fields['start_date'] = startDate;

      // Add the file if it's provided
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      // Add the authorization header with the token
      request.headers['Authorization'] = 'Bearer $token';

      // Send the request and get the response
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Check if the response is successful (status code 200)
      if (response.statusCode == 201) {
        return response; // Successfully submitted
      } else {
        throw Exception('Failed to submit schema: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print("Error occurred during API call: $e");
      throw Exception('Error occurred during API call: $e');
    }
  }

  static Future<http.Response> getAllSchemas() async {
    final token = await ProfileManager.getToken();
    final uri = Uri.parse("$baseUrl/admin/getschemas");

    try {
      if (token == null) {
        throw Exception("Access token not found.");
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        print("Failed to fetch schemas: Status code ${response.statusCode}, Body: ${response.body}");
        throw Exception("Failed to fetch schemas: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Error fetching schemas from $uri: $e");
      throw Exception("Error fetching schemas: $e");
    }
  }


}