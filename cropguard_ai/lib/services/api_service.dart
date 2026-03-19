import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Change this to your computer's IP address
  static const String baseUrl = 'http://192.168.17.115:5000';
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone ?? '',
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return {
          'success': true,
          'email': email,
          'message': data['message'] ?? 'OTP sent to your email',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Signup failed',
          'code': data['code'] ?? 'SIGNUP_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
        'code': 'CONNECTION_ERROR',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final token = data['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        return {
          'success': true,
          'token': token,
          'user': data['user'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'OTP verification failed',
          'code': data['code'] ?? 'VERIFY_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
        'code': 'CONNECTION_ERROR',
      };
    }
  }

  static Future<Map<String, dynamic>> resendOTP({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP resent',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Resend OTP failed',
          'code': data['code'] ?? 'RESEND_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
        'code': 'CONNECTION_ERROR',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final token = data['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        return {
          'success': true,
          'token': token,
          'user': data['user'] ?? {},
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login failed',
          'code': data['code'] ?? 'LOGIN_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
        'code': 'CONNECTION_ERROR',
      };
    }
  }

  static Future<Map<String, dynamic>> predictDisease(
    List<int> imageBytes,
    String filename,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated',
          'code': 'NO_TOKEN',
        };
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: filename,
        ),
      );

      final streamResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamResponse);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'analysis_id': data['analysis_id'],
          'disease': data['disease'] ?? 'Unknown',
          'clean_name': data['clean_name'] ?? 'Unknown',
          'confidence': data['confidence'] ?? 0.0,
          'gemini_data': data['gemini_data'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Prediction failed',
          'code': data['code'] ?? 'PREDICT_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
        'code': 'CONNECTION_ERROR',
      };
    }
  }

  static Future<Map<String, dynamic>> getAnalysisHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated',
          'code': 'NO_TOKEN',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/analysis/history?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'results': data['results'] ?? [],
          'total': data['total'] ?? 0,
          'page': data['page'] ?? 1,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch history',
          'code': data['code'] ?? 'HISTORY_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
        'code': 'CONNECTION_ERROR',
      };
    }
  }

  static Future<Map<String, dynamic>> rescan(
    int analysisId,
    List<int> imageBytes,
    String filename,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated',
          'code': 'NO_TOKEN',
        };
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/rescan/$analysisId'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: filename,
        ),
      );

      final streamResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamResponse);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'analysis_id': data['analysis_id'],
          'disease': data['disease'] ?? 'Unknown',
          'clean_name': data['clean_name'] ?? 'Unknown',
          'confidence': data['confidence'] ?? 0.0,
          'gemini_data': data['gemini_data'] ?? {},
          'message': 'Rescan completed',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Rescan failed',
          'code': data['code'] ?? 'RESCAN_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
        'code': 'CONNECTION_ERROR',
      };
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated',
          'code': 'NO_TOKEN',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch profile',
          'code': data['code'] ?? 'PROFILE_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
        'code': 'CONNECTION_ERROR',
      };
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();
      if (token == null) {
        // Just clear local token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('jwt_token');
        return {'success': true};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      // Clear token regardless of response
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');

      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      // Still clear token on error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      return {
        'success': true,
        'message': 'Logged out locally',
      };
    }
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
