import 'package:flutter/material.dart';
import 'package:mobitrendz/screens/home_screen.dart';
import 'package:mobitrendz/screens/signin_screen.dart';
import 'dart:async';
import 'signup_screen.dart'; // Import Sign-Up Screen
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to Sign-Up Screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      startApp();
    });
  }

  void startApp() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(() => const SignInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/splash_logo.png', // Ensure this image is in assets
          width: 400,
        ),
      ),
    );
  }
}
