import 'package:flutter/material.dart';
import '../../API/API Service.dart';
import '../../JsonModels/Schema.dart';
import 'BuyPlanScreen.dart';

class AllSchemesScreen extends StatefulWidget {
  const AllSchemesScreen({super.key});

  @override
  _AllSchemesScreenState createState() => _AllSchemesScreenState();
}

class _AllSchemesScreenState extends State<AllSchemesScreen> {
  late Future<List<Schema>> _schemas;

  @override
  void initState() {
    super.initState();
    _schemas = ApiService.getAllSchemas() as Future<List<Schema>>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("All BC Schemes"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: FutureBuilder<List<Schema>>(
        future: _schemas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Schemes Available'));
          } else {
            final schemes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                return _schemeCard(
                  context,
                  scheme.name,
                  scheme.description,
                  scheme.type, // You can modify this to show status (Live, Upcoming, etc.)
                  Colors.orange, // Customize this as per your scheme status
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _schemeCard(
      BuildContext context,
      String title,
      String desc,
      String status,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, size: 32, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 6),
                    Text(desc,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  _showBuyConfirmation(context, title, color);
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Buy Now" ,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showBuyConfirmation(BuildContext context, String title, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Confirm Purchase"),
        content: Text("Do you want to buy the \"$title\" plan?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BuyPlanScreen()),
              );
            },
            child: const Text("Confirm"),
          )
        ],
      ),
    );
  }
}
