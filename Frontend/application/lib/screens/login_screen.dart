import 'dart:convert';
import 'package:application/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; 
import 'otp_screen.dart';
import '../api_service.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;
  bool isNationalIdEmpty = false;
  bool isPhoneEmpty = false;

  final ApiService apiService = ApiService();
  Future<void> loginUser() async {
    final String nationalId = nationalIdController.text.trim();
    final String phoneNumber = phoneController.text.trim();

    setState(() {
      isNationalIdEmpty = nationalId.isEmpty;
      isPhoneEmpty = phoneNumber.isEmpty;
    });

    if (isNationalIdEmpty || isPhoneEmpty) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await apiService.login(nationalId, phoneNumber,"3");

      if (response.statusCode == 200) {

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        _showErrorDialog("بيانات تسجيل الدخول غير صحيحة");
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
  Future<void> checkUser() async {
    final String nationalId = nationalIdController.text.trim();
    final String phoneNumber = phoneController.text.trim();

    setState(() {
      isNationalIdEmpty = nationalId.isEmpty;
      isPhoneEmpty = phoneNumber.isEmpty;
    });

    if (isNationalIdEmpty || isPhoneEmpty) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await apiService.checkUser(nationalId, phoneNumber);

      if (response.statusCode == 200) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const OtpScreen()),
        );
      } else  {
        _showErrorDialog("المستخدم غير موجود");
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }


  void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => Directionality( 
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text(
          "خطأ",
          textAlign: TextAlign.right,
        ),
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("حسناً"),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
      FocusScope.of(context).unfocus(); 
    },
    child: Scaffold(
    backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background_image.jpeg',
                fit: BoxFit.contain),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200),
                _buildTitle("تسجيل الدخول"),
                const SizedBox(height: 40),
                _buildLabel(" الهوية الوطنية"),
                const SizedBox(height: 10),
                _buildTextField(
                    nationalIdController, '111*********', isNationalIdEmpty),
                const SizedBox(height: 30),
                _buildLabel("رقم الجوال"),
                const SizedBox(height: 10),
                _buildPhoneNumberField(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
                const Spacer(),
                _buildBottomIndicator(),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }

  Widget _buildTitle(String text) {
    return Container(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 38, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, String hintText, bool isEmpty) {
  return Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: _inputBoxDecoration(isEmpty),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done, 
      textAlign: TextAlign.left,
      onSubmitted: (value) {
        FocusManager.instance.primaryFocus?.unfocus(); 
      },
    ),
  );
}


  Widget _buildPhoneNumberField() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _inputBoxDecoration(isPhoneEmpty),
      child: Row(
        children: [
          const Text('+966',
              style: TextStyle(fontSize: 16, color: Colors.black)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '5X XXX XXXX',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.left,
              // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : checkUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFBB040),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('المتابعة',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: 100,
        height: 5,
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  BoxDecoration _inputBoxDecoration(bool isEmpty) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
          color: isEmpty ? Colors.red : Colors.grey.shade400, width: 1),
    );
  }
}
