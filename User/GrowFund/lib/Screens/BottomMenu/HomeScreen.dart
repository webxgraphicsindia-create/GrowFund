import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../JsonModels/ProfileManager.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // FD contribution progress (update with real data later)
  double progress = 0.7;
  // For the FD Calculator
  double depositAmount = 50000;
  final double multiplier = 1.1; // Dummy multiplier: 10% returns
  bool _isHapticEnabled = false;

  // Rotating financial tip index
  int tipIndex = 0;
  final List<String> financialTips = [
    "Invest early, reap benefits later.",
    "Diversify your FD portfolio.",
    "Keep an eye on interest rate trends.",
  ];



  @override
  void initState() {
    super.initState();
    // Optionally cycle the tips every few seconds
    Future.delayed(Duration(seconds: 2), rotateTip);
    _loadHapticSetting();
  }

  Future<void> _loadHapticSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHapticEnabled = prefs.getBool('haptic_enabled') ?? true; // Default is true if not set
    });
  }

  void rotateTip() {
    setState(() {
      tipIndex = (tipIndex + 1) % financialTips.length;
    });
    Future.delayed(Duration(seconds: 5), rotateTip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove default back button.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Home Screen"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      backgroundColor: const Color(0xFFf4f6fa),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Real-time notifications banner
              _buildNotificationBanner(),
              const SizedBox(height: 16),
              // Greeting using ProfileManager
              FutureBuilder<String?>(
                future: ProfileManager.getName(),
                builder: (context, snapshot) {
                  final name = snapshot.data ?? "there";
                  return Text(
                    "👋 Hello, $name",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Rebranded welcome message for FD app
              Text(
                "Welcome to GrowFund FD",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.06, // 6% of screen width
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Lottie.asset('lib/assets/Animation/investment.json', height: 180),
              const SizedBox(height: 20),

              // FD Overview Dashboard
              _buildOverviewDashboard(),

              const SizedBox(height: 20),
              _buildGlassCard(),
              const SizedBox(height: 30),
              _buildReminderCard(),
              const SizedBox(height: 30),
              _buildStatsRow(),
              const SizedBox(height: 30),

              // Interactive FD Plans Carousel
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "📋 Your FD Plans",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _buildFDPlansCarousel(),

              const SizedBox(height: 30),
              // Mini FD Calculator Widget
              _buildCalculatorWidget(),

              const SizedBox(height: 30),
              // Quick Access Buttons for History and Renewal
              _buildQuickAccessButtons(),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Navigate to payment screen or perform FD contribution action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "💸 Make Payment",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Financial Tips Section
              _buildFinancialTip(),
              const SizedBox(height: 10),
              const Text(
                "“Discipline is the bridge between goals and accomplishment.”",
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Notification banner widget
  Widget _buildNotificationBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "Your FD matures in 5 days!",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      )
    );
  }

  // FD Overview Dashboard widget
  Widget _buildOverviewDashboard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _overviewItem("Invested", "₹1,50,000"),
            _overviewItem("Returns", "₹1,65,000"),
            _overviewItem("Active FD", "3"),
          ],
        ),
      ),
    );
  }

  Widget _overviewItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // Glass card that displays FD contribution progress.
  Widget _buildGlassCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "FD Contribution",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 14,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                  ),
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.deepPurple.withOpacity(0.1),
                          Colors.deepPurple.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${(value * 100).toInt()}%",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            "You're ${(progress * 100).toInt()}% done with your FD contribution.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Reminder card updated for FD maturity date.
  Widget _buildReminderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("FD Maturity Date", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 4),
              Text(
                "20 April 2025",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Stats row showing key FD details.
  Widget _buildStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _statCard("Total Months", "12", Icons.calendar_today_rounded, Colors.orange),
          _statCard("Deposit", "₹50,000", Icons.currency_rupee_rounded, Colors.green),
          _statCard("Maturity", "₹55,000", Icons.trending_up_rounded, Colors.blue),
        ].map((card) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: card,
        )).toList(),
      ),
    );
  }

  // Single stat card widget.
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      width: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // FD Plans Carousel: using a horizontal SingleChildScrollView.
  Widget _buildFDPlansCarousel() {
    List<Widget> planCards = [
      _schemeCard(
        "Golden FD Plan",
        "Invest a fixed amount of ₹50,000 and receive ₹55,000 after 1 year.",
        "Active",
        Colors.green,
      ),
      _schemeCard(
        "Smart Saver FD",
        "Invest ₹20,000 once and get ₹22,000 after 6 months.",
        "Upcoming",
        Colors.orange,
      ),
      _schemeCard(
        "Platinum FD Plan",
        "Invest ₹1,00,000 once to earn ₹1,10,000 in 12 months.",
        "Ongoing",
        Colors.blue,
      ),
      _schemeCard(
        "Starter FD Plan",
        "Invest ₹10,000 and secure returns of ₹11,000 after 6 months.",
        "Matured",
        Colors.redAccent,
      ),
    ];
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: planCards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(width: 300, child: planCards[index]);
        },
      ),
    );
  }

  // Mini FD Calculator Widget.
  Widget _buildCalculatorWidget() {
    double maturityAmount = depositAmount * multiplier;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FD Calculator",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text("Deposit Amount: ₹${depositAmount.toInt()}"),
          Slider(
            value: depositAmount,
            min: 10000,
            max: 200000,
            divisions: 19,
            label: "₹${depositAmount.toInt()}",
            onChanged: (value) {
              setState(() {
                depositAmount = value;
                if (_isHapticEnabled) {
                  HapticFeedback.lightImpact();
                }
              });
            },
          ),
          Text(
            "Projected Maturity: ₹${maturityAmount.toInt()}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  // Quick access buttons for FD History and Renewal.
  Widget _buildQuickAccessButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to FD History
          },
          icon: const Icon(Icons.history,color: Colors.white),
          label: const Text("FD History" , style: TextStyle(color: Colors.white), ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to FD Renewal
          },
          icon: const Icon(Icons.autorenew ,color: Colors.white),
          label: const Text("Renew FD",style: TextStyle(color: Colors.white) ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        ),
      ],
    );
  }

  // Financial Tips Section.
  Widget _buildFinancialTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              financialTips[tipIndex],
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // FD plan card (renamed from scheme card to reflect fixed deposit plans).
  Widget _schemeCard(String title, String description, String status, Color statusColor) {
    return SizedBox(
      height: 120, // Set a fixed height
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.account_balance, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
