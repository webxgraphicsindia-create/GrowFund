import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../JsonModels/ProfileManager.dart';
import '../MyMainScren.dart';
import 'LoginScreen.dart';

class MySplashscreen extends StatefulWidget {
  const MySplashscreen({super.key});

  @override
  State<MySplashscreen> createState() => _MySplashscreenState();
}

class _MySplashscreenState extends State<MySplashscreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _visible = true);
    });

    Timer(const Duration(seconds: 4), _handleAuthFlow);
  }

  Future<void> _handleAuthFlow() async {
    bool isLoggedIn = await ProfileManager.isLoggedIn();

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    bool biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (biometricEnabled) {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics || isDeviceSupported) {
        try {
          bool authenticated = await auth.authenticate(
            localizedReason: 'Authenticate to access GrowFund',
            options: const AuthenticationOptions(
              biometricOnly: false,
              stickyAuth: true,
              useErrorDialogs: true,
            ),
          );

          if (authenticated) {
            _goToMainScreen();
          } else {
            _showError("Authentication failed");
          }
        } catch (e) {
          _showError("Error: $e");
        }
      } else {
        _showError("Biometric not supported");
      }
    } else {
      _goToMainScreen(); // Biometric off, go directly
    }
  }

  void _goToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Authentication Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MySplashscreen()),
            ),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade400, Colors.indigo.shade900],
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
                          'lib/assets/Animation/Money.json',
                          height: 200,
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'GrowFund',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Created by BlueVision Softech',
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
