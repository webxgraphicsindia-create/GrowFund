import 'package:flutter/material.dart';
import 'package:growfund/Screens/BottomMenu/InvestFDPlanScreen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'BottomMenu/AllSchemaScreen.dart';
import 'BottomMenu/HomeScreen.dart';
import 'BottomMenu/SettingsScreen.dart';
import 'BottomMenu/WalletScreen.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final _screens = [
    HomeScreen(),
    InvestFDPlanScreen(),
    //AllSchemesScreen(),
    WalletScreen(),
   // HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _screens[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: Colors.deepPurple,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.auto_graph_rounded),
            title: const Text("FD Plans"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            title: const Text("Wallet"),
            selectedColor: Colors.teal,
          ),
         /* SalomonBottomBarItem(
            icon: const Icon(Icons.history),
            title: const Text("History"),
            selectedColor: Colors.orange,
          ),*/
          SalomonBottomBarItem(
            icon: const Icon(Icons.settings),
            title: const Text("Settings"),
            selectedColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}