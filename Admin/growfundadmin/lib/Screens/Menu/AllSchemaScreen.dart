import 'package:flutter/material.dart';
import 'dart:convert';
import '../../API/API.dart';
import '../../models/Schema.dart';

class AllSchemaScreen extends StatefulWidget {
  const AllSchemaScreen({super.key});

  @override
  State<AllSchemaScreen> createState() => _AllSchemaScreenState();
}

class _AllSchemaScreenState extends State<AllSchemaScreen> {

  List<Schema> _schemas = [];
  String _searchQuery = '';
  String _selectedType = 'All';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
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
          _errorMessage = 'Failed to load schemas.';
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
  Widget build(BuildContext context) {
    final filteredSchemas = _schemas.where((schema) {
      final matchesSearch = schema.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == 'All' || schema.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList();

    final totalInvestment = filteredSchemas.fold<double>(0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Center(
        child: Container(
          width: 1000,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📦 All Schemas',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Search Schemas...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedType,
                    items: ['All', 'Monthly', 'Yearly'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedType = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, color: Colors.green),
                    const SizedBox(width: 12),
                    Text(
                      'Total Investment: ₹$totalInvestment',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : filteredSchemas.isEmpty
                    ? const Center(child: Text("No schemas found."))
                    : ListView.builder(
                  itemCount: filteredSchemas.length,
                  itemBuilder: (context, index) {
                    final schema = filteredSchemas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.stars, color: Colors.deepPurple),
                                const SizedBox(width: 8),
                                Text(
                                  schema.name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Edit action tapped!')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() => _schemas.removeAt(index));
                                  },
                                ),
                                TextButton(
                                  onPressed: () => _showSchemaDetailModal(context, schema),
                                  child: const Text("View More"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 20,
                              runSpacing: 10,
                              children: [
                                _schemaInfo("💰 Amount", '₹${schema.amount}'),
                                _schemaInfo("📈 ROI", schema.roi),
                                _schemaInfo("⏳ Duration", schema.duration),
                                _schemaInfo("📅 Start Date", schema.startDate),
                                _schemaInfo("🏷️ Type", schema.type),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _schemaInfo(String label, String? value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value ?? 'N/A', style: const TextStyle(color: Colors.black87)),
      ],
    );
  }

  void _showSchemaDetailModal(BuildContext context, Schema schema) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.30,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schema.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text("Amount: ₹${schema.amount}", style: const TextStyle(fontSize: 16)),
                Text("ROI: ${schema.roi}", style: const TextStyle(fontSize: 16)),
                Text("Duration: ${schema.duration}", style: const TextStyle(fontSize: 16)),
                Text("maturityAmount: ${schema.maturityAmount}", style: const TextStyle(fontSize: 16)),
                Text("Start Date: ${schema.startDate}", style: const TextStyle(fontSize: 16)),
                Text("Type: ${schema.type}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
