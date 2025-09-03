import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../API/API Service.dart';
import '../../JsonModels/Schema.dart';

class InvestFDPlanScreen extends StatefulWidget {
  const InvestFDPlanScreen({super.key});

  @override
  State<InvestFDPlanScreen> createState() => _InvestFDPlanScreenState();
}

class _InvestFDPlanScreenState extends State<InvestFDPlanScreen>
    with TickerProviderStateMixin {
  List<Schema> _schemas = [];
  bool _isLoading = true;
  String _errorMessage = '';

  late AnimationController _controller;
  late Razorpay _razorpay;
  final Color themeColor = const Color(0xFF004AAD);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handleError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchSchemas();
  }

  Future<void> _fetchSchemas() async {
    try {
      final response = await ApiService.getAllSchemas();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['schemas'];
        setState(() {
          _schemas = data.map((e) => Schema.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load FD plans.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Investment Successful! 🎉 ID: ${response.paymentId}"),
      backgroundColor: Colors.green,
    ));
    print(
      "Payment Successful! 🎉 ID: ${response.paymentId}"
    );
  }

  void _handleError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Payment Failed ❌\n${response.message}"),
      backgroundColor: Colors.red,
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("External Wallet: ${response.walletName}"),
    ));
  }

  void _startPayment(String title, String amount) {
    double amtDouble = double.parse(amount);
    int amtPaise = (amtDouble * 100).toInt();
    var options = {
      'key': 'rzp_test_fbUlZhYwn46TsO',
      'amount': amtPaise,
      'name': 'GrowFund',
      'description': '$title Investment',
      'prefill': {'contact': '7387784164', 'email': 'demo@growfund.com'},
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _showInvestConfirmation(
      BuildContext context, String title, String amount, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Confirm Investment", style: GoogleFonts.poppins()),
        content: Text(
          "Do you want to invest ₹$amount in \"$title\"?",
          style: GoogleFonts.poppins(fontSize: 15),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.poppins())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () {
              Navigator.pop(context);
              _startPayment(title, amount);
            },
            child: Text("Pay Now", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Dialog for creating a custom FD plan (optional).
  void _showCreateCustomPlanDialog(BuildContext context,
      Function(Map<String, dynamic>) onAddPlan) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedDuration = "1 Year";
    final List<String> durations = ["1 Year", "2 Years", "3 Years", "5 Years"];

    final Map<String, double> interestRates = {
      "1 Year": 6.5,
      "2 Years": 7.2,
      "3 Years": 8.1,
      "5 Years": 8.5,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final interestRate = interestRates[selectedDuration]!;
              final amount = double.tryParse(amountController.text) ?? 0;
              final years = int.parse(selectedDuration.split(" ").first);
              final maturity = amount + (amount * interestRate * years / 100);

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'lib/assets/Animation/fd_create.json',
                      height: 100,
                      repeat: true,
                      reverse: true,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Create Your Custom FD Plan",
                      style:
                      GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration:
                      const InputDecoration(labelText: "Plan Name", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Amount (₹)", border: OutlineInputBorder()),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedDuration,
                      items: durations
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => selectedDuration = value!),
                      decoration:
                      const InputDecoration(labelText: "Duration", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Interest: ${interestRate.toStringAsFixed(1)}%",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        Text("Maturity: ₹${maturity.toStringAsFixed(0)}",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel", style: GoogleFonts.poppins()),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            final amountText = amountController.text.trim();
                            if (name.isEmpty || amountText.isEmpty || double.tryParse(amountText) == null) return;

                            onAddPlan({
                              "title": name,
                              "price": "₹${amount.toStringAsFixed(0)}",
                              "interest": "${interestRate.toStringAsFixed(1)}%",
                              "duration": selectedDuration,
                              "maturity": "₹${maturity.toStringAsFixed(0)}",
                              "color": Colors.indigoAccent
                            });
                            Navigator.pop(context);
                          },
                          child: Text("Add Plan", style: GoogleFonts.poppins()),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Redesigned FD plan card widget
  Widget _buildFDCard(Schema schema, int index) {
    final colors = [
      Colors.teal,
      Colors.orange,
      Colors.deepPurple,
      Colors.indigo,
      Colors.green,
      Colors.redAccent,
      Colors.brown,
      Colors.pinkAccent,
      Colors.cyan,
      Colors.amber
    ];
    final color = colors[index % colors.length];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () =>
            _showInvestConfirmation(context, schema.name, schema.amount.toString(), color),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and indicator bar
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        schema.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // FD Plan details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoTile("Amount", "₹${schema.amount}"),
                    _infoTile("Interest", "${schema.roi}%"),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoTile("Duration", schema.duration),
                    _infoTile("Maturity", "₹${schema.maturityAmount}"),
                  ],
                ),
                const SizedBox(height: 12),
                // Invest button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    onPressed: () => _showInvestConfirmation(
                      context,
                      schema.name,
                      schema.amount.toString(),
                      color,
                    ),
                    icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
                    label: Text("Invest Now", style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A helper widget to build individual info rows.
  Widget _infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: Text("Invest in FD", style: GoogleFonts.poppins()),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: GoogleFonts.poppins()))
          : _schemas.isEmpty
          ? Center(child: Text("No FD Plans found.", style: GoogleFonts.poppins()))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              itemCount: _schemas.length,
              itemBuilder: (context, index) => _buildFDCard(_schemas[index], index),
            ),
          ),
          // Optionally, you can add a custom FD plan creation button here.
          // Uncomment to enable:
          /*
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showCreateCustomPlanDialog(context, (customPlan) {
                                setState(() {
                                  _schemas.add(
                                    Schema(
                                      name: customPlan['title'],
                                      amount: int.parse(customPlan['price']
                                          .toString()
                                          .replaceAll(RegExp(r'[^\d]'), '')),
                                      roi: double.parse(customPlan['interest']
                                          .toString()
                                          .replaceAll('%', '')),
                                      duration: customPlan['duration'],
                                      maturityAmount: int.parse(customPlan['maturity']
                                          .toString()
                                          .replaceAll(RegExp(r'[^\d]'), '')),
                                    ),
                                  );
                                });
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: Text("Create Custom Plan", style: GoogleFonts.poppins(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        )
                        */
        ],
      ),
    );
  }
}
