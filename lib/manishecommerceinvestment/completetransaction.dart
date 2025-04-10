import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utill/colornew.dart';

class TransactionDetailsPage extends StatefulWidget {
  const TransactionDetailsPage({Key? key}) : super(key: key);

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  final StreamController<List<dynamic>> _transactionController = StreamController();

  @override
  void initState() {
    super.initState();
    fetchTransactionDetails();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Returns the token or null if not found
  }

  Future<void> fetchTransactionDetails() async {
    String? token = await getToken();
    if (token == null) return;

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var request = http.MultipartRequest(
      'GET',
      Uri.parse('https://manish-jewellers.com/api/v1/installment-payment/list'),
    );

    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      _transactionController.add(data['data']);
    } else {
      _transactionController.addError('Failed to load transactions');
    }
  }

  @override
  void dispose() {
    _transactionController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.glowingGold,
        title: Text('Transaction Details', style: TextStyle(color: AppColors.backgroundDark)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _transactionController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transaction data found.'));
          }

          final transactions = snapshot.data!;



          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final details = tx['details'] as List<dynamic>;
              final planStatus = tx['plan_status'] == 1 ? 'Active' : 'Inactive';


              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                shadowColor: Colors.amber.shade100,
                color: const Color(0xFFFFFAF0), // Light creamy gold
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.card_membership, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Plan: ${tx['plan_code']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B6914), // Golden brown
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.amber),
                      _infoRow('Category', tx['plan_category']),
                      _infoRow('Plan No.', tx['plan_number']),
                      _infoRow('Start Date', tx['plan_start_date']),
                      _infoRow('End Date', tx['plan_end_date']),
                      _infoRow('Total Balance', '₹${tx['total_balance']}'),
                      _infoRow('Gold Purchased', '${tx['total_gold_purchase']} gm'),
                      _infoRow('Status', planStatus, valueColor: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        'Installment Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF8B6914),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...details.map((detail) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.amber.shade100),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.shade50,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow('Amount', '₹${detail['payment_amount']}'),
                            _infoRow('Method', detail['method'] ?? 'N/A'),
                            _infoRow('Status', detail['Payment_status'] ?? 'N/A'),
                            _infoRow('Installment', detail['installment']),
                            _infoRow('Gold Weight', '${detail['purchase_gold_weight']} gm'),
                            _infoRow('Date', detail['payment_date']),
                            _infoRow('Time', detail['payment_time']),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              );

              //   Card(
              //   margin: const EdgeInsets.all(12),
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              //   elevation: 6,
              //   color: const Color(0xFFFFF8DC),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         _infoRow('Plan Code', tx['plan_code']),
              //         _infoRow('Category', tx['plan_category']),
              //         _infoRow('Plan N0.', tx['plan_number']),
              //         _infoRow('Start Date', tx['plan_start_date']),
              //         _infoRow('End Date', tx['plan_end_date']),
              //         _infoRow('Total Balance', '₹${tx['total_balance']}'),
              //         _infoRow('Gold Purchased', '${tx['total_gold_purchase']} gm'),
              //         _infoRow('Status', planStatus, valueColor: Colors.green),
              //         const SizedBox(height: 12),
              //         const Text('Installment Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              //         ...details.map((detail) => Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             const Divider(),
              //             _infoRow('Amount', '₹${detail['payment_amount']}'),
              //             _infoRow('Method', detail['method'] ?? 'N/A'),
              //             _infoRow('Status', detail['Payment_status'] ?? 'N/A'),
              //             _infoRow('Installment', detail['installment']),
              //             _infoRow('Gold Weight', '${detail['purchase_gold_weight']} gm'),
              //             _infoRow('Date', detail['payment_date']),
              //             _infoRow('Time', detail['payment_time']),
              //           ],
              //         )),
              //       ],
              //     ),
              //   ),
              // );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor),
          ),
        ],
      ),
    );
  }
}
