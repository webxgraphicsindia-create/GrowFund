import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👉 for haptic feedback
import 'package:growfund/Screens/SettingFragments/AboutUs.dart';
import 'package:growfund/Screens/SettingFragments/HelpCenter.dart';
import 'package:growfund/Screens/SettingFragments/PrivacyPolicyScreen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../API/API Service.dart';
import '../../JsonModels/HapticUtil.dart';
import '../Auth/LoginScreen.dart';
import '../SettingFragments/ChangePasswordScreen.dart';
import '../SettingFragments/EditProfileScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool _biometricEnabled = false;
  bool _hapticEnabled = false;
  bool _notificationEnabled = false;
  bool _emailEnabled = false;
  final String _hapticKey = 'haptic_enabled';

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadHapticSetting();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _hapticEnabled = prefs.getBool('haptic_enabled') ?? true; // default ON
      _notificationEnabled = prefs.getBool('push_notifications') ?? true;
      _emailEnabled = prefs.getBool('email_notifications') ?? true;
    });
  }

  Future<void> _loadHapticSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hapticEnabled = prefs.getBool(_hapticKey) ?? true;
    });
  }

  Future<void> _toggleHaptic(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_enabled', newValue);
    setState(() => _hapticEnabled = newValue);
    _triggerHaptic(newValue);
    _showSnackBar("Haptic feedback ${newValue ? 'enabled' : 'disabled'}");
  }

  void _triggerHaptic(bool newValue) {
    HapticUtil().setHapticEnabled(newValue);
    setState(() => _hapticEnabled = newValue);
    HapticUtil().vibrateLight(); // 👉 good feedback
    _showSnackBar("Haptic feedback ${newValue ? 'enabled' : 'disabled'}");
  }

  Future<void> _toggleBiometric(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    final canCheck = await auth.canCheckBiometrics;
    final isSupported = await auth.isDeviceSupported();

    if (!canCheck || !isSupported) {
      _showSnackBar("Biometric not supported on this device");
      return;
    }

    if (newValue) {
      try {
        final authenticated = await auth.authenticate(
          localizedReason: "Enable biometric login",
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (authenticated) {
          await prefs.setBool('biometric_enabled', true);
          setState(() => _biometricEnabled = true);
          //_triggerHaptic(true); // Haptic on success
          _showSnackBar("Biometric login enabled");
        } else {
          _showSnackBar("Authentication failed");
        }
      } catch (e) {
        _showSnackBar("Error: $e");
      }
    } else {
      await prefs.setBool('biometric_enabled', false);
      setState(() => _biometricEnabled = false);
     // _triggerHaptic(false); // Haptic on disable
      _showSnackBar("Biometric login disabled");
    }
  }

  Future<void> _toggleEmailNotification(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications', newValue);
    setState(() => _emailEnabled = newValue);
    _triggerHaptic(true); // Optional feedback
    _showSnackBar("Email notifications ${newValue ? 'enabled' : 'disabled'}");
  }

  Future<void> _togglePushNotification(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', newValue);
    setState(() => _notificationEnabled = newValue);
    _triggerHaptic(true); // Optional feedback
    _showSnackBar("Push notifications ${newValue ? 'enabled' : 'disabled'}");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
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

  void _showLogoutSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
          Navigator.pushReplacement(context, createRoute(const LoginScreen()));
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Lottie.asset(
            'lib/assets/Animation/Confirm Payment.json',
            width: 150,
            height: 150,
            repeat: false,
          ),
        );
      },
    );
  }

  Future<void> handleLoginout() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.logout();

      if (result['success']) {
        _triggerHaptic(true); // 👉 Feedback on logout
        _showSnackBar("Logout successful!");
        _showLogoutSuccessAnimation();
      } else {
        _showSnackBar(result['message'] ?? "Logout failed!");
      }
    } catch (e) {
      _showSnackBar("An error occurred. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Profile"),
          _settingsTile(
            icon: Icons.person_outline,
            title: "Edit Profile",
            subtitle: "Update name, email, and phone",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditProfileScreen()),
            ),
          ),
          const SizedBox(height: 4),
          _settingsTile(
            icon: Icons.lock_outline,
            title: "Change Password",
            subtitle: "Update your login credentials",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
            ),
          ),
          const SizedBox(height: 4),
          _sectionTitle("Notifications"),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined, color: Colors.deepPurple),
            title: const Text("Push Notification"),
            subtitle: const Text("Manage notification Settings"),
            value: _notificationEnabled,
            onChanged: (value) => _togglePushNotification(value),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            tileColor: Colors.white,
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            secondary: const Icon(Icons.mail_outline, color: Colors.deepPurple),
            title: const Text("Email Alerts"),
            subtitle: const Text("Enable or disable email updates"),
            value: _emailEnabled,
            onChanged: (value) => _toggleEmailNotification(value),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            tileColor: Colors.white,
          ),
          const SizedBox(height: 16),
          _sectionTitle("Feedback"),
          _settingsTile(
            icon: Icons.star_rate_outlined,
            title: "Rate Us",
            subtitle: "Share your experience on Play Store",
            onTap: () {
              const url = 'https://play.google.com/store/apps/details?id=com.your.package';
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
          ),
          const SizedBox(height: 4),
          _settingsTile(
            icon: Icons.share_outlined,
            title: "Share App",
            subtitle: "Tell your friends about GrowFund",
            onTap: () {
              Share.share("Check out GrowFund App! 💰📈\nhttps://play.google.com/store/apps/details?id=com.your.package");
            },
          ),
          const SizedBox(height: 16),
          _sectionTitle("Security"),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint, color: Colors.deepPurple),
                  title: const Text("Biometric Login"),
                  subtitle: const Text("Use fingerprint to unlock app"),
                  value: _biometricEnabled,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  onChanged: (value) => _toggleBiometric(value),
                  tileColor: Colors.white,
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration, color: Colors.deepPurple),
                  title: const Text("Haptic Feedback"),
                  subtitle: const Text("Enable touch vibration feedback"),
                  value: _hapticEnabled,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  tileColor: Colors.white,
                  onChanged: (value) => _toggleHaptic(value),

                ),
          const SizedBox(height: 4),
          _settingsTile(
            icon: Icons.help_outline,
            title: "Help Center",
            subtitle: "Get help and contact support",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
            ),
          ),
          const SizedBox(height: 4),
          _settingsTile(
            icon: Icons.info_outline,
            title: "About Us",
            subtitle: "Learn more about GrowFund",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
            ),
          ),
          const SizedBox(height: 4),
          _settingsTile(
            icon: Icons.policy_outlined,
            title: "Privacy Policy",
            subtitle: "Review our privacy policy",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: handleLoginout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white )),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0), // Adjust as needed
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0), // Adds horizontal padding to the whole tile
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      tileColor: Colors.white,
    );
  }
}
