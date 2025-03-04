import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  final String apiUrl = "http://8.213.22.228/api";
Future<http.Response> checkUser(String nationalId, String phoneNumber) async {
  final Uri url = Uri.parse('$apiUrl/checkUser');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "NationalID": nationalId,
        "PhoneNumber": phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData.containsKey('Volunteers')) {  
        Map<String, dynamic> user = responseData['Volunteers'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        await prefs.setString("NationalID", user['NationalID'].toString());
        await prefs.setString("PhoneNumber", user['PhoneNumber'].toString());
        await prefs.setString("code", user['code'].toString());
      } else {
        throw Exception("User data not found in response.");
      }
    } else {
      throw Exception("Failed to check user. Status code: ${response.statusCode}");
    }

    return response;
  } catch (e) {
    throw Exception("خطأ في الاتصال: ${e.toString()}");
  }
}


 
Future<http.Response> login(String nationalId, String phoneNumber, String code) async {
  final Uri url = Uri.parse('$apiUrl/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "NationalID": nationalId,
        "PhoneNumber": phoneNumber,
        "code": code,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('token') && responseData.containsKey('user')) {
        String token = responseData['token'];
        Map<String, dynamic> user = responseData['user'];

        String arabicName = user['ArabicName'] ?? '';
        String firstName = user['FirstName'] ?? '';
        String status = user['VolunteerRole'] ?? '';

        // Store in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('ArabicName', arabicName);
        await prefs.setString('firstName', firstName);
        await prefs.setString('status', status);
      } else {
        throw Exception("Unexpected API response format.");
      }
    } else {
      print("Login failed: ${response.body}"); // Debugging purpose
      throw Exception("Login failed with status code: ${response.statusCode}");
    }

    return response;
  } on SocketException {
    throw Exception("لا يوجد اتصال بالإنترنت. الرجاء التحقق من الشبكة.");
  } on FormatException {
    throw Exception("خطأ في تنسيق البيانات المستلمة من الخادم.");
  } catch (e) {
    throw Exception("خطأ غير متوقع: $e");
  }
}

  // التحقق من التوكن عند تشغيل التطبيق
  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) return false;

    final Uri url = Uri.parse('$apiUrl/check-auth');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  Future<http.Response> checkin(String token) async {
    final Uri url = Uri.parse('$apiUrl/check-in');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
      );
      return response;
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }

  Future<http.Response> checkOut(String token) async {
    final Uri url = Uri.parse('$apiUrl/check-out');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
      );
      return response;
    } catch (e) {
      throw Exception("خطأ في الاتصال: $e");
    }
  }
}
