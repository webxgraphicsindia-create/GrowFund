import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../API/API Service.dart';
import 'LoginScreen.dart';
import 'package:flutter/services.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final Color lavender = const Color(0xFFE6E6FA);
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isPasswordVisible = false;
  final apiService = ApiService();
  bool isLoading = false;



  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }



  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        final tween = Tween(begin: begin, end: end);
        final fadeAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  void showSnackBarerror(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
  void showSnackBarsuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.green,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lavender,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                "GrowFund",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Lottie.asset(
              'lib/assets/Animation/loginAnimation.json',
              height: 180,
              repeat: true,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        enabled: !isOtpSent,
                        decoration: InputDecoration(
                          hintText: 'Enter your Gmail',
                          filled: true,
                          fillColor: lavender.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (isOtpSent && !isOtpVerified)
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'Enter OTP',
                            filled: true,
                            fillColor: lavender.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock_clock),
                          ),
                        ),
                      if (isOtpVerified)
                        Builder(
                          builder: (context) => TextField(
                            key: const ValueKey('passwordField'), // Important to trigger rebuild
                            controller: passwordController,
                            obscureText: !isPasswordVisible,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'Set Password',
                              filled: true,
                              fillColor: lavender.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      /*TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          keyboardType: TextInputType.text, // 👈 ensures abc keyboard
                          decoration: InputDecoration(
                            hintText: 'Set Password',
                            filled: true,
                            fillColor: lavender.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),*/
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                            setState(() => isLoading = true);

                            try {
                              if (!isOtpSent) {
                                final email = emailController.text.trim();
                                final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');

                                if (!emailRegex.hasMatch(email)) {
                                  showSnackBarerror("Please enter a valid Gmail address");
                                  setState(() => isLoading = false);
                                  return;
                                }
                                final response = await ApiService.requestOtp(email);
                                if (response['success']) {
                                  showSnackBarsuccess("OTP sent to $email");
                                  setState(() {
                                    isOtpSent = true;
                                  });
                                } else {
                                  showSnackBarerror(response['data']['message'] ?? "Failed to send OTP");
                                }
                              } else if (!isOtpVerified) {
                                final otp = otpController.text.trim();

                                if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
                                  showSnackBarerror("Please enter a valid 6-digit OTP");
                                  setState(() => isLoading = false);
                                  return;
                                }

                                final response = await ApiService.verifyOtp(emailController.text.trim(), otp);
                                if (response['success']) {
                                  showSnackBarsuccess("OTP verified");
                                  setState(() => isOtpVerified = true);
                                } else {
                                  showSnackBarerror(response['data']['message'] ?? "OTP verification failed");
                                }
                              } else {
                                final password = passwordController.text.trim();
                                final passwordRegex = RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
                                );

                                if (!passwordRegex.hasMatch(password)) {
                                  showSnackBarerror("Password must be 8+ characters, include upper, lower, number & special char");
                                  setState(() => isLoading = false);
                                  return;
                                }

                                final response = await ApiService.createPassword(
                                  email: emailController.text.trim(),
                                  otp: otpController.text.trim(),
                                  password: password,
                                );

                                if (response['success']) {
                                  showSnackBarsuccess("Signup successful! Redirecting to login...");
                                  Future.delayed(const Duration(seconds: 2), () {
                                    Navigator.pushReplacement(context, createRoute(const LoginScreen()));
                                  });
                                } else {
                                  showSnackBarerror(response['data']['message'] ?? "Signup failed");
                                }
                              }
                            } catch (e) {
                              showSnackBarerror("An error occurred. Please try again.");
                            }

                            setState(() => isLoading = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lavender,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: lavender,
                          ),
                          child: Text(
                            !isOtpSent
                                ? "Send OTP"
                                : !isOtpVerified
                                ? "Verify OTP"
                                : "Create Account",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?", style: TextStyle(fontSize: 16)),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(context, createRoute(const LoginScreen()));
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              "🇮🇳 Made with ❤️ in India",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "GrowFund • Empowering Dreams",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
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
