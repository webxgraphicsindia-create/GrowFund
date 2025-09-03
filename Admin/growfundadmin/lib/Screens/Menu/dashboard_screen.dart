import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../API/API.dart';
import '../../models/UserManager.dart';
import '../Auth/AdminLoginScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final UserManager userManager = UserManager();
  bool _isLoading = false;

  String getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d, y').format(now);
  }


  void _fetchUsers() async {
    try {
      await userManager.fetchUsers();
      setState(() {});
    } catch (e) {
      print("Error fetching users: $e");
    }
  }


  Future<void> handleLoginout() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.logout();

      if (result['success']) {
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
          Navigator.pushReplacement(context, createRoute(  AdminLoginScreen()));
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Lottie.asset(
            'lib/Assets/Animation/Confirm Payment.json',
            width: 150,
            height: 150,
            repeat: false,
          ),
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _fetchUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    int delay = 1,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.2 * delay),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(delay * 0.1, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActivityItem(
    String label,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(time),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Admin 👋",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getCurrentDate(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        "Download Report",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {

                      },
                    ),
                    GestureDetector(
                      onTapDown: (details) {
                        showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            details.globalPosition.dx,
                            details.globalPosition.dy,
                            0,
                            0,
                          ),
                          items: [
                            // Admin info (disabled header)
                            PopupMenuItem(
                              enabled: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Admin Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'admin@example.com',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Divider(),
                                ],
                              ),
                            ),

                            // Actions
                            const PopupMenuItem(
                              value: 'logout',
                              child: ListTile(
                                leading: Icon(Icons.logout, color: Colors.red),
                                title: Text('Logout', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                          ],
                        ).then((value) {
                       if (value == 'logout') {
                         handleLoginout();
                          }
                        });
                      },
                      child: Lottie.asset(
                        'lib/Assets/Animation/loginAnimation.json',
                        height: 80,
                      ),
                    ),

                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Stats Cards
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                buildStatCard(
                  icon: Icons.people,
                  title: "Total Users",
                  value: userManager.allUsers.length.toString(),
                  color: Colors.indigo,
                  delay: 1,
                ),
                buildStatCard(
                  icon: Icons.attach_money,
                  title: "Payments",
                  value: "₹12.4K",
                  color: Colors.green,
                  delay: 2,
                ),
                buildStatCard(
                  icon: Icons.bar_chart,
                  title: "Active Plans",
                  value: "58",
                  color: Colors.deepPurple,
                  delay: 3,
                ),
                buildStatCard(
                  icon: Icons.report,
                  title: "Issues",
                  value: "3",
                  color: Colors.orange,
                  delay: 4,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Recent Activity Section
            Text(
              "Recent Activity",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Column(
                children: [
                  buildActivityItem(
                    "User Raj registered",
                    "Today, 10:30 AM",
                    Icons.person_add,
                    Colors.indigo,
                  ),
                  buildActivityItem(
                    "Payment of ₹1200 received",
                    "Today, 9:00 AM",
                    Icons.payment,
                    Colors.green,
                  ),
                  buildActivityItem(
                    "Plan expired for User Priya",
                    "Yesterday, 6:00 PM",
                    Icons.warning,
                    Colors.orange,
                  ),
                ],
              ),
            ),
            // Graph Section
            const SizedBox(height: 40),
            Text(
              "User Growth - Last 7 Days",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Mon');
                            case 1:
                              return const Text('Tue');
                            case 2:
                              return const Text('Wed');
                            case 3:
                              return const Text('Thu');
                            case 4:
                              return const Text('Fri');
                            case 5:
                              return const Text('Sat');
                            case 6:
                              return const Text('Sun');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 4),
                        FlSpot(1, 5),
                        FlSpot(2, 3),
                        FlSpot(3, 7),
                        FlSpot(4, 6),
                        FlSpot(5, 8),
                        FlSpot(6, 9),
                      ],
                      isCurved: true,
                      color: Colors.indigo,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.indigo.withOpacity(0.2),
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
