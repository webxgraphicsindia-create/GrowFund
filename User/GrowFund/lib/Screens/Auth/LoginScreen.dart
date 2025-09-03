import 'package:flutter/material.dart';
import 'package:growfund/Screens/MyMainScren.dart';
import 'package:growfund/Screens/Auth/SignUpScreen.dart';
import 'package:growfund/Screens/Auth/ForgotPasswordSheet.dart';
import 'package:lottie/lottie.dart';
import '../../API/API Service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final Color lavender = const Color(0xFFE6E6FA);
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

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
    passwordController.dispose();
    super.dispose();
  }

  // API Login Method
  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(email, password);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login successful!"), backgroundColor:Colors.green,));
        //_showSnackBar("Login successful!");
        Navigator.pushReplacement(context, createRoute(const MainScreen()));
      } else {
        final message = result['data']['message'] ?? "Login failed!";
        _showSnackBar(message);
      }
    } catch (e) {
      _showSnackBar("An error occurred. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }




  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lavender,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text("GrowFund",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),
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
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -5))],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          filled: true,
                          fillColor: lavender.withOpacity(0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: lavender.withOpacity(0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lavender,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: false,
                              barrierLabel: "ForgotPassword",
                              transitionDuration: const Duration(milliseconds: 400),
                              pageBuilder: (_, __, ___) => const SizedBox.shrink(),
                              transitionBuilder: (_, animation, __, ___) {
                                final curvedValue = Curves.easeInOut.transform(animation.value) - 1.0;
                                return Transform.scale(
                                  scale: 1 + curvedValue * 0.05,
                                  child: Opacity(opacity: animation.value, child: const ForgotPasswordDialog()),
                                );
                              },
                            );
                          },
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.blueGrey,fontSize: 16)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?" , style: TextStyle(fontSize: 16) ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(context, createRoute(const SignupScreen()));
                            },
                            child: const Text("Sign Up", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Colors.indigo)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Center(
                        child: Column(
                          children: [
                            Text("🇮🇳 Made with ❤️ in India", style: TextStyle(color: Colors.grey,fontSize: 18)),
                            Text("GrowFund • Empowering Dreams", style: TextStyle(fontStyle: FontStyle.italic,fontSize: 17)),
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
