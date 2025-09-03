// utils/haptic_util.dart
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticUtil {
  static final HapticUtil _instance = HapticUtil._internal();
  bool _isHapticEnabled = true;

  factory HapticUtil() {
    return _instance;
  }

  HapticUtil._internal();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isHapticEnabled = prefs.getBool('haptic_enabled') ?? true;
  }

  Future<void> setHapticEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_enabled', value);
    _isHapticEnabled = value;
  }

  bool get isHapticEnabled => _isHapticEnabled;

  void vibrateLight() {
    if (_isHapticEnabled) HapticFeedback.lightImpact();
  }

  void vibrateMedium() {
    if (_isHapticEnabled) HapticFeedback.mediumImpact();
  }

  void vibrateHeavy() {
    if (_isHapticEnabled) HapticFeedback.heavyImpact();
  }
}
