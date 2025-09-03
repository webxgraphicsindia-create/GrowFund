import 'dart:convert';
import 'package:http/http.dart' as http;

import '../JsonModels/ProfileManager.dart';

class ApiService {

  static const String baseUrl = "https://grownfundapi.quickbill.site/api";
  static Future<Map<String, dynamic>> requestOtp(String email) async {
    final url = Uri.parse("$baseUrl/auth/send-otp");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return _processResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final url = Uri.parse("$baseUrl/auth/verify-otp");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      return _processResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  static Future<Map<String, dynamic>> createPassword({
    required String email,
    required String otp,
    required String password,
    String? name,
  }) async {
    final url = Uri.parse("$baseUrl/auth/create-password");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'name': name ?? 'User',
        }),
      );

      final result = _processResponse(response);
      if (result['success']) {
        /*final user = result['data']['user'];
        await ProfileManager.saveUser(
          token: result['data']['token'],
          userId: user['id'],
          name: user['name'],
          email: user['email'],
        );*/
      }

      return result;
    } catch (e) {
      return _handleException(e);
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final result = _processResponse(response);
      if (result['success']) {
        final user = result['data']['user'];
        await ProfileManager.saveUser(
          token: result['data']['token'],
          userId: 0, // Provide a default value or handle null case
          name: user['name'] ?? 'User',
          email: user['email'],
        );
      }

      return result;
    } catch (e) {
      return _handleException(e);
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
        Uri.parse('$baseUrl/logout'),
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

  // Helpers
 /* static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'status': response.statusCode,
        'data': data,
      };
    } catch (_) {
      print(
        'Failed to parse response: ${response.body}',
      );
      return {
        'success': false,
        'status': response.statusCode,
        'data': {'message': 'Failed to parse response'},
      };
    }
  }*/
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
  static Future<Map<String, dynamic>> requestForgotOtp(String email) async {
    final url = Uri.parse("$baseUrl/auth/forgot/request-otp");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final json = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': json['message'] ?? 'Unexpected error',
    };
  }

  static Future<Map<String, dynamic>> verifyForgotOtp(String email, String otp) async {
    final url = Uri.parse("$baseUrl/auth/forgot/verify-otp");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final json = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': json['message'] ?? 'Unexpected error',
    };
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/auth/forgot/reset-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': newPassword,
      }),
    );

    final json = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': json['message'] ?? 'Unexpected error',
    };
  }


  //Change password
  static Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    final token = await ProfileManager.getToken();
    final url = Uri.parse('$baseUrl/change-password');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      return _processResponse(response);
    } catch (e) {
      return _handleException(e);
    }
  }

  //Change Profile Details
  static Future<Map<String, dynamic>> editProfile({
    required String name,
    String? phone,
  }) async {
    final token = await ProfileManager.getToken();
    final url = Uri.parse('$baseUrl/edit-profile');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          if (phone != null) 'phone': phone,
        }),
      );

      final result = _processResponse(response);

      if (result['success']) {
        final updatedUser = result['data']['user'];
        await ProfileManager.saveUser(
          token: token ?? '',
          userId: updatedUser['id'],
          name: updatedUser['name'],
          email: updatedUser['email'],
        );
      }

      return result;
    } catch (e) {
      return _handleException(e);
    }
  }

  static Future<http.Response> getAllSchemas() async {
    final token = await ProfileManager.getToken();
    final uri = Uri.parse("$baseUrl/admin/getschemas");

    try {
      if (token == null)
      {
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
      }
      else
      {
        print("Failed to fetch schemas: Status code ${response.statusCode}, Body: ${response.body}");
        throw Exception("Failed to fetch schemas: ${response.statusCode}, ${response.body}");
      }
    }
    catch (e)
    {
      print("Error fetching schemas from $uri: $e");
      throw Exception("Error fetching schemas: $e");
    }

  }


}
