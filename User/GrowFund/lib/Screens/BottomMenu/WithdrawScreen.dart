import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class WithdrawScreen extends StatefulWidget {
  final double currentBalance;
  final Function(double, String) onWithdraw;

  const WithdrawScreen({
    super.key,
    required this.currentBalance,
    required this.onWithdraw,
  });

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  String selectedMethod = 'UPI';

  void handleWithdraw() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0 || amount > widget.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid withdrawal amount")),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context); // Remove loading dialog

    // Show success animation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'lib/assets/Animation/Confirm Payment.json',
              width: 350,
              height: 350,
              repeat: false,
            ),
            const SizedBox(height: 12),
            const Text("Withdrawal Successful!",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    // Delay and go back after success
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context); // Pop success dialog

    widget.onWithdraw(amount, selectedMethod);
    Navigator.pop(context); // Pop WithdrawScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        title: const Text("Withdraw Funds"),
        backgroundColor: Colors.deepPurple.shade600,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 💳 Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade500, Colors.deepPurple.shade300],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Iconsax.wallet, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Available Balance", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        "₹${widget.currentBalance.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text("Enter amount to withdraw", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₹ ',
                filled: true,
                fillColor: Colors.white,
                hintText: "e.g. 500",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 30),

            const Text("Select Payment Method", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                ChoiceChip(
                  avatar: const Icon(Iconsax.send_2, size: 18),
                  label: const Text("UPI"),
                  selected: selectedMethod == "UPI",
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) => setState(() => selectedMethod = "UPI"),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  avatar: const Icon(Icons.account_balance, size: 18),
                  label: const Text("Bank Transfer"),
                  selected: selectedMethod == "Bank Transfer",
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (_) => setState(() => selectedMethod = "Bank Transfer"),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.arrow_up_1, color: Colors.white),
                onPressed: handleWithdraw,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                label: const Text("Confirm Withdrawal", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
