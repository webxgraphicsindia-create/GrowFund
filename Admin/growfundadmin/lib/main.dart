import 'package:flutter/material.dart';

import 'Screens/Auth/AdminSplashScreen.dart';

void main() {

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AdminSplashScreen(),
      //showPerformanceOverlay: true,
      debugShowCheckedModeBanner: false,
    );
  }
}