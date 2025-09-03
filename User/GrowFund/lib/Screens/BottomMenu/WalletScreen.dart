import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'WithdrawScreen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _lastPaidAmount = 0;
  late Razorpay _razorpay;
  double _balance = 12500;
  List<Map<String, dynamic>> _transactions = [
    {
      "title": "Deposit",
      "amount": "+₹5000",
      "date": "06 Apr 2025",
      "income": true,
    },
    {
      "title": "BC Monthly",
      "amount": "-₹1000",
      "date": "04 Apr 2025",
      "income": false,
    },
    {
      "title": "Interest Credit",
      "amount": "+₹150",
      "date": "31 Mar 2025",
      "income": true,
    },
    {
      "title": "BC Monthly",
      "amount": "-₹1000",
      "date": "04 Mar 2025",
      "income": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _showAmountInputDialog() {
    final TextEditingController _amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Enter Amount",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: "₹ ",
                    hintText: "Enter amount",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final amount = int.tryParse(_amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter valid amount")),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _startPayment(amount);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Proceed to Pay",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startPayment(int amountInRupees) {
    _lastPaidAmount = amountInRupees;

    var options = {
      'key': 'rzp_test_fbUlZhYwn46TsO',
      'amount': amountInRupees * 100,
      'name': 'GrowFund',
      'description': 'Wallet Top-up',
      'prefill': {'contact': '9876543210', 'email': 'user@example.com'},
      'theme': {'color': '#7E57C2'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _balance += _lastPaidAmount;
      _transactions.insert(0, {
        "title": "Wallet Top-up",
        "amount": "+₹$_lastPaidAmount",
        "date": _getTodayDate(),
        "income": true,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful! ₹$_lastPaidAmount added")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Payment Failed")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')} ${_monthName(now.month)} ${now.year}";
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade600,
        title: const Text(
          "My Wallet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        //centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Available Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${_balance.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FrostedButton(
                  icon: Iconsax.wallet_add,
                  label: "Add Money",
                  color: Colors.green,
                  onPressed: _showAmountInputDialog,
                ),
                FrostedButton(
                  icon: Iconsax.money_send,
                  label: "Withdraw",
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WithdrawScreen(
                          currentBalance: _balance,
                          onWithdraw: (amount, method) {
                            setState(() {
                              _balance -= amount;
                              _transactions.insert(0, {
                                "title": "Withdraw ($method)",
                                "amount": "-₹${amount.toStringAsFixed(0)}",
                                "date": _getTodayDate(),
                                "income": false,
                              });
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Iconsax.more_circle, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),

            // 👇 Make only this part scrollable
            Expanded(
              child: _transactions.isEmpty
                  ? const Center(
                child: Text(
                  "No transactions yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _transactions.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _TransactionItem(_transactions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;

  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.withOpacity(0.4),
                Colors.deepPurple.shade800.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class FrostedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const FrostedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Map txn;

  const _TransactionItem(this.txn);

  @override
  Widget build(BuildContext context) {
    bool isIncome = txn['income'] == true;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
          child: Icon(
            isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          txn['title'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(txn['date']),
        trailing: Text(
          txn['amount'],
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

/*
final List<Map<String, dynamic>> _transactions = [
  {
    "title": "Deposit",
    "amount": "+₹5000",
    "date": "06 Apr 2025",
    "income": true,
  },
  {
    "title": "BC Monthly",
    "amount": "-₹1000",
    "date": "04 Apr 2025",
    "income": false,
  },
  {
    "title": "Interest Credit",
    "amount": "+₹150",
    "date": "31 Mar 2025",
    "income": true,
  },
  {
    "title": "BC Monthly",
    "amount": "-₹1000",
    "date": "04 Mar 2025",
    "income": false,
  },
];
*/
