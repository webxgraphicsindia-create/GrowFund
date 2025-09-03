import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../API/API Service.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Add this to your State

  int currentPage = 0;
  final Color lavender = const Color(0xFFE6E6FA);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void nextPage() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    try {
      final email = _emailController.text.trim();

      if (currentPage == 0) {
        final result = await ApiService.requestForgotOtp(email);
        if (result['success']) {
          setState(() => currentPage++);
          showMessage(result['message']);
        } else {
          showError(result['message']);
        }

      } else if (currentPage == 1) {
        final result = await ApiService.verifyForgotOtp(email, _otpController.text.trim());
        if (result['success']) {
          setState(() => currentPage++);
          showMessage(result['message']);
        } else {
          showError(result['message']);
        }

      } else if (currentPage == 2) {
        final result = await ApiService.resetPassword(email, _passwordController.text);
        if (result['success']) {
          showMessage(result['message']);
          Navigator.pop(context);
        } else {
          showError(result['message']);
        }
      }

    } catch (e) {
      showError('Something went wrong. Please try again.');
    }
  }


  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }



  void backPage() {
    FocusScope.of(context).unfocus();
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    } else {
      Navigator.pop(context); // Exit on first step
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        backPage();
        return false;
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 140,
                            child: Lottie.asset(
                              currentPage == 0
                                  ? 'lib/assets/Animation/gmail.json'
                                  : currentPage == 1
                                  ? 'lib/assets/Animation/otp.json'
                                  : 'lib/assets/Animation/password.json',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentPage == 0
                                ? 'Enter your Gmail'
                                : currentPage == 1
                                ? 'Verify OTP'
                                : 'Create New Password',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (currentPage == 0)
                            TextFormField(
                              controller: _emailController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Enter Gmail',
                                filled: true,
                                fillColor: lavender.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email cannot be empty';
                                }
                                if (!RegExp(r'\S+@\S+\.\S+')
                                    .hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                          if (currentPage == 1)
                            TextFormField(
                              controller: _otpController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              maxLengthEnforcement:
                              MaxLengthEnforcement.enforced,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'Enter OTP',
                                filled: true,
                                fillColor: lavender.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length != 6) {
                                  return 'Enter valid 6-digit OTP';
                                }
                                return null;
                              },
                            ),
                          if (currentPage == 2)
                            TextFormField(
                              controller: _passwordController,
                              textAlign: TextAlign.center,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: 'Create Password',
                                filled: true,
                                fillColor: lavender.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password cannot be empty';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
                                  return 'Include at least one lowercase letter';
                                }
                                if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                                  return 'Include at least one uppercase letter';
                                }
                                if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                                  return 'Include at least one number';
                                }
                                if (!RegExp(r'^(?=.*[!@#\$&*~])').hasMatch(value)) {
                                  return 'Include at least one special character';
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lavender,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 14),
                            ),
                            child: Text(
                              currentPage == 2 ? 'Reset Password' : 'Next',
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (currentPage > 0)
                            TextButton(
                              onPressed: backPage,
                              child: const Text(
                                '← Back',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.close, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
