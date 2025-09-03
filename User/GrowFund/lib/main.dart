import 'package:flutter/material.dart';

import 'JsonModels/HapticUtil.dart';
import 'Screens/Auth/MySplashscreen.dart';

void main() {
   HapticUtil().init();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MySplashscreen(),
      //showPerformanceOverlay: true,
      debugShowCheckedModeBanner: false,
    );
  }
}