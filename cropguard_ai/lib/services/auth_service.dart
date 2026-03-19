import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    return await ApiService.signup(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }

  static Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    return await ApiService.verifyOTP(
      email: email,
      otp: otp,
    );
  }

  static Future<Map<String, dynamic>> resendOTP({
    required String email,
  }) async {
    return await ApiService.resendOTP(email: email);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await ApiService.login(
      email: email,
      password: password,
    );
  }

  static Future<void> logout() async {
    await ApiService.logout();
  }

  static Future<bool> isAuthenticated() async {
    return await ApiService.isAuthenticated();
  }

  static Future<String?> getToken() async {
    return await ApiService.getToken();
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
