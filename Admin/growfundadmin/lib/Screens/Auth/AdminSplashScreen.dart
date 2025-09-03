import 'dart:async';
import 'package:flutter/material.dart';
import 'package:growfundadmin/Screens/MainScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/ProfileManager.dart';
import 'AdminLoginScreen.dart';

class AdminSplashScreen extends StatefulWidget {
  const AdminSplashScreen({super.key});

  @override
  State<AdminSplashScreen> createState() => _AdminSplashScreenState();
}

class _AdminSplashScreenState extends State<AdminSplashScreen> {
  bool _visible = false;
  int _splashDelay = 4; // default seconds

  @override
  void initState() {
    super.initState();

    // Animate entry
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _visible = true);
    });

    // Run auth logic after splash delay
    _checkLoginAndAdjustSplash();
  }

  Future<void> _checkLoginAndAdjustSplash() async {
    bool isLoggedIn = await ProfileManager.isLoggedIn();
    if (isLoggedIn) {
      // Skip or shorten splash for logged in users.
      _splashDelay = 1; // e.g., 1 second if logged in
    }
    Timer(Duration(seconds: _splashDelay), _handleAuthFlow);
  }

  Future<void> _handleAuthFlow() async {
    bool isLoggedIn = await ProfileManager.isLoggedIn();

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
    } else {
      _goToMainScreen();
    }
  }

  void _goToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminMainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: _visible ? 1.0 : 0.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'lib/Assets/Animation/logo.json',
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'GrowFund Admin',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Admin Panel by BlueVision Softech',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
