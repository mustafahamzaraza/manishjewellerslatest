import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/gold/paymentlistscreen.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cont/paymentcontroller.dart';
import 'paymentdetailsscreen.dart'; // Assuming this is your details screen

class PurchasedPlansList extends StatefulWidget {
  const PurchasedPlansList({super.key});

  @override
  State<PurchasedPlansList> createState() => _PurchasedPlansListState();
}

class _PurchasedPlansListState extends State<PurchasedPlansList> {
  List<Map<String, dynamic>> purchasedPlans = [];
  bool isLoading = true;
  bool isError = false;
  String? newToken;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await getUserToken(); // Ensure the token is fetched first
    await fetchPlans(); // Fetch plans after the token is retrieved
  }

  Future<String?> getUserToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('user_token');
      if (token != null) {
        newToken = token;
        return token;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching token: $e");
      return null;
    }
  }

  Future<void> fetchPlans() async {
    try {
      var headers = {
        'Authorization': 'Bearer $newToken',
      };

      var request = http.MultipartRequest(
        'GET',
        Uri.parse('https://altaibagold.com/api/v1/installment-payment/list'),
      );

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseData =
        jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;

       // debugPrint('Response Data: $responseData');


        String prettyResponse = JsonEncoder.withIndent('  ').convert(responseData);

        // Print the entire response
        debugPrint('Response Data:\n$prettyResponse');


        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            purchasedPlans = List<Map<String, dynamic>>.from(responseData['data']);
            isLoading = false;
          });

          for (var plan in responseData['data']) {
            var details = plan['details'];
            if (details != null && details is List) {
              for (var detail in details) {
                // Extract purchase_gold_weight
                var purchaseGoldWeight = detail['purchase_gold_weight'];
                print('Purchase Gold Weight: $purchaseGoldWeight');
              }
            }
          }



        } else {
          throw Exception("Failed to fetch data");
        }
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (error) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchased Plans"),
        backgroundColor: Colors.amber[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Failed to load data."),
            ElevatedButton(
              onPressed: fetchPlans,
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: purchasedPlans.length,
        itemBuilder: (context, index) {
          final plan = purchasedPlans.reversed.toList()[index];


          var purchaseGoldWeight = 0.0; // Initialize purchaseGoldWeight as double

          // Extract purchase_gold_weight from the first entry in the details
          var details = plan['details'];
          if (details != null && details is List && details.isNotEmpty) {
            var weight = details[0]['purchase_gold_weight'];

            // Convert the weight to double if it's a string
            if (weight is String) {
              purchaseGoldWeight = double.tryParse(weight) ?? 0.0; // Try parsing to double, default to 0.0 if parsing fails
            } else if (weight is double) {
              purchaseGoldWeight = weight; // If already a double, use it as is
            }
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Plan Number", plan['id'].toString()),
                  _buildDetailRow("Plan Code", plan['plan_code']),
                  _buildDetailRow("Purchase Date", plan['purchase_date']),
                  _buildDetailRow("Pending Installments", "${plan['pending_installments']}"),
                  _buildDetailRow("Purchase Gold Weight", "${purchaseGoldWeight.toStringAsFixed(2)} grams"),
                  _buildDetailRow("Total Gold Purchased", "${plan['total_gold_purchase']} grams"),
                  _buildDetailRow("Selected Carat", plan['selected_carat']),
                  _buildDetailRow("Payment Done", "Rs ${plan['payment_done']?.toString()}"),
                  _buildDetailRow("Payment Remaining", "Rs ${plan['payment_remaining']?.toString()}"),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        if (plan['payment_remaining'] > 0 )



                        ElevatedButton.icon(

                          onPressed: () {
                            print("Navigating to PaymentDetailsScreen with the following details:");
                            print("Plan Code: ${plan['plan_code']}");
                            print("Selected Carat: ${plan['selected_carat']}");
                            print("Plan Amount: ${int.tryParse(plan['plan_amount'].toString()) ?? 0}");
                            print("Gold Amount: ${double.tryParse(plan['total_gold_purchase'].toString()) ?? 0.0}");
                            print("Payment Done: ${plan['payment_done'].toString()}");
                            print("Payment Remaining: ${plan['payment_remaining'].toString()}");
                            print("ID: ${plan['id']}");
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PaymentDetailsScreen(
                            //         selectedPlan: plan['plan_code'],
                            //         selectedCategory: plan['selected_carat'],
                            //         planAmount: int.tryParse(plan['plan_amount'].toString()) ?? 0, // Convert to int
                            //         goldAmount: double.tryParse(plan['total_gold_purchase'].toString()) ?? 0.0, // Convert to double
                            //         paymentDone: plan['payment_done'].toString(),
                            //         paymentRemaining: plan['payment_remaining'].toString(),
                            //         id: plan['id'],
                            //     ),
                            //   ),
                            // );


                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentDetailsScreen(
                                  selectedPlan: plan['plan_code'],
                                  selectedCategory: plan['selected_carat'],
                                  planAmount: int.tryParse(plan['plan_amount'].toString()) ?? 0,
                                  goldAmount: double.tryParse(plan['total_gold_purchase'].toString()) ?? 0.0,
                                  paymentDone: plan['payment_done'].toString(),
                                  paymentRemaining: plan['payment_remaining'].toString(),
                                  id: plan['id'],
                                ),
                              ),
                            ).then((_) {
                              // After navigating back, update the controller
                              final controller = Provider.of<PaymentDetailsController>(context, listen: false);
                              controller.updatePaymentDone(double.tryParse(plan['payment_done'].toString()) ?? 0.0);
                              print('vallllll ${double.tryParse(plan['payment_done'].toString())}');
                            });





                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[600],
                          ),
                          icon: const Icon(Icons.payment, color: Colors.white),
                          label: const Text("Settle Dues", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ) else Text(""),





                        ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentListScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                        ),
                        icon: const Icon(Icons.history, color: Colors.white),
                        label: const Text("Payment History", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}




