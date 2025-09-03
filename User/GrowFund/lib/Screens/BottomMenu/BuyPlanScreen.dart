import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BuyPlanScreen extends StatefulWidget {
  const BuyPlanScreen({super.key});

  @override
  State<BuyPlanScreen> createState() => _BuyPlanScreenState();
}

class _BuyPlanScreenState extends State<BuyPlanScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> plans = [
    {"title": "Basic Plan", "price": "500", "color": Colors.green},
    {"title": "Pro Plan", "price": "1000", "color": Colors.orange},
    {"title": "Premium Plan", "price": "1500", "color": Colors.blueAccent},
  ];

  late AnimationController _controller;
  late Razorpay _razorpay;

  final Color themeColor = const Color(0xFF004AAD); // GrowFund Blue

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Successful! 🎉 ID: ${response.paymentId}"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed ❌\n${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet: ${response.walletName}"),
      ),
    );
  }

  void _startPayment(String title, String amount) {
    var options = {
      'key': 'rzp_test_PJL0CC8TQ0KHBq',
      'amount': int.parse(amount) * 100,
      'name': 'GrowFund',
      'description': '$title Purchase',
      'prefill': {'contact': '8975967158', 'email': 'demo@growfund.com'},
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _showBuyConfirmation(
      BuildContext context, String title, String amount, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Confirm Purchase", style: GoogleFonts.poppins()),
        content: Text(
          "Do you want to buy the \"$title\" plan for ₹$amount?",
          style: GoogleFonts.poppins(fontSize: 15),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () {
              Navigator.pop(context);
              _startPayment(title, amount);
            },
            child: const Text("Pay Now"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: Text("Buy Plan", style: GoogleFonts.poppins()),
        //centerTitle: true,
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 500 + index * 200),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    plan["color"].withOpacity(0.2),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: plan["color"].withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                title: Text(
                  plan["title"],
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                subtitle: Text(
                  "₹${plan["price"]}",
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showBuyConfirmation(
                    context,
                    plan["title"],
                    plan["price"],
                    plan["color"],
                  ),
                  child: const Text("Buy",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
