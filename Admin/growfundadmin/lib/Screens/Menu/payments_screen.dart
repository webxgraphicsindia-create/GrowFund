import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _filterType = 'All';

  List<Map<String, dynamic>> transactions = List.generate(50, (index) {
    final isIn = index % 2 == 0;
    final amount = (1000 + index * 100) + (index % 3) * 50;
    final date = DateTime(2025, 1 + (index % 12), 1 + (index % 28));
    return {
      'transactionId': 'TXN${1000 + index}',
      'userName': 'User ${index + 1}',
      'scheme': 'GrowFund ${isIn ? 'Monthly' : 'Annual'} Plan',
      'type': isIn ? 'IN' : 'OUT',
      'amount': amount,
      'date': date,
      'description': isIn
          ? 'FD Purchased - ₹$amount'
          : 'FD Expired - Return ₹$amount',
    };
  });

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2027),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    return transactions.where((tx) {
      final matchType = _filterType == 'All' || tx['type'] == _filterType;
      final matchDateStart =
          _startDate == null || !tx['date'].isBefore(_startDate!);
      final matchDateEnd =
          _endDate == null || !tx['date'].isAfter(_endDate!);
      final matchSearch = _searchQuery.isEmpty ||
          tx['transactionId']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          tx['userName']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          tx['scheme']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          tx['description']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchType && matchDateStart && matchDateEnd && matchSearch;
    }).toList();
  }

  void _exportToPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Transaction Report',
                  style: pw.TextStyle(fontSize: 24)),
            ),
            pw.Table.fromTextArray(
              headers: ['Txn ID', 'User', 'Scheme', 'Type', 'Amount', 'Date'],
              data: _filteredTransactions.map((tx) {
                return [
                  tx['transactionId'],
                  tx['userName'],
                  tx['scheme'],
                  tx['type'],
                  tx['amount'],
                  DateFormat('dd MMM yyyy').format(tx['date']),
                ];
              }).toList(),
              border: null,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellPadding: const pw.EdgeInsets.all(4),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Offset? _dragStart;

  void _handleDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dragStart != null) {
      final delta = _dragStart!.dy - details.globalPosition.dy;
      _scrollController.jumpTo(
        _scrollController.position.pixels + delta,
      );
      _dragStart = details.globalPosition;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragStart = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportToPdf,
        label: const Text("Export PDF",style: TextStyle(color: Colors.white),),
        icon: const Icon(Icons.picture_as_pdf,color: Colors.white,),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 🔍 Search Box
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by User, Txn ID, Scheme...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 📅 Filter Row
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                        : 'Select Date Range',
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _filterType,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'IN', child: Text('IN (FD Buy)')),
                    DropdownMenuItem(value: 'OUT', child: Text('OUT (FD Expired)')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterType = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 🖱️ Gesture Scroll List
            Expanded(
              child: Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    _scrollController.jumpTo(
                      _scrollController.offset + pointerSignal.scrollDelta.dy,
                    );
                  }
                },
                child: GestureDetector(
                  onVerticalDragStart: _handleDragStart,
                  onVerticalDragUpdate: _handleDragUpdate,
                  onVerticalDragEnd: _handleDragEnd,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = _filteredTransactions[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: tx['type'] == 'IN'
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: tx['type'] == 'IN'
                                ? Colors.green
                                : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tx['description'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '₹${tx['amount']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: tx['type'] == 'IN'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Date: ${DateFormat('dd MMM yyyy').format(tx['date'])}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 2),
                            Text('Txn ID: ${tx['transactionId']}',
                                style: const TextStyle(color: Colors.grey)),
                            Text('User: ${tx['userName']}',
                                style: const TextStyle(color: Colors.grey)),
                            Text('Scheme: ${tx['scheme']}',
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
