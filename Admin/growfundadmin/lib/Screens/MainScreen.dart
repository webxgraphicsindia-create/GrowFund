import 'package:flutter/material.dart';
import 'package:growfundadmin/Screens/Auth/AdminLoginScreen.dart';
import 'package:lottie/lottie.dart';

import '../API/API.dart';
import 'Menu/AllSchemaScreen.dart';
import 'Menu/CreateSchemaScreen.dart';
import 'Menu/dashboard_screen.dart';
import 'Menu/logout_screen.dart';
import 'Menu/payments_screen.dart';
import 'Menu/settings_screen.dart';
import 'Menu/users_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarOpen = true;

  final List<Widget> _pages = const [
    DashboardScreen(),
    UsersScreen(),
    CreateSchemaScreen(),
    AllSchemaScreen(),
    PaymentsScreen(),
    AdminSettingsScreen(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Users",
    "Create Schema",
    "All Schema",
    "Payments",
    "Settings",
  ];

  final List<IconData> _icons = [
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.add_chart_rounded, // Create Schema
    Icons.list_alt_rounded, // All Schema
    Icons.payment_rounded,
    Icons.settings_rounded,
  ];

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: _isSidebarOpen ? 240 : 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B1F3B), Color(0xFF1D2B53)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8),
              ],
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      _isSidebarOpen ? Icons.arrow_back : Icons.arrow_forward,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSidebarOpen = !_isSidebarOpen;
                      });
                    },
                  ),
                ),

                // Logo (conditionally visible)
                if (_isSidebarOpen)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'lib/Assets/Images/Logo.png',
                      width: 200,
                    ),
                  ),

                if (_isSidebarOpen)
                  const Text(
                    'GrowFund Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                const SizedBox(height: 30),

                // Sidebar Menu
                Expanded(
                  child: ListView.builder(
                    itemCount: _titles.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedIndex == index;
                      return Tooltip(
                        message: _titles[index],
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                isSelected
                                    ? Border(
                                      left: BorderSide(
                                        width: 4,
                                        color: Colors.white,
                                      ),
                                    )
                                    : null,
                          ),
                          child: ListTile(
                            leading: Icon(
                              _icons[index],
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                            title:
                                _isSidebarOpen
                                    ? Text(
                                      _titles[index],
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.white70,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    )
                                    : null,
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area with optional Lottie animation
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Container(
                key: ValueKey(_selectedIndex),
                //padding: const EdgeInsets.all(32),
                color: Color(0xFFF7F9FC), // Light neutral background
                child: _pages[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
