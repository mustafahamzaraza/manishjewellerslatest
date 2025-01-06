import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentListScreen extends StatefulWidget {
  @override
  _PaymentListScreenState createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  List<Map<String, dynamic>> payments = [];
  List<Map<String, dynamic>> filteredPayments = [];
  String selectedFilter = "All";
  final StreamController<List<Map<String, dynamic>>> _paymentsStreamController = StreamController<List<Map<String, dynamic>>>();

  String? newToken;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await getUserToken(); // Ensure the token is fetched first
    await fetchPayments(); // Fetch payments after the token is retrieved
  }

  Future<String?> getUserToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('user_token'); // Retrieve the token from SharedPreferences

      if (token != null) {
        print("Token found: $token");
        newToken = token; // Store it locally
        return token; // Return the token
      } else {
        print("No token found.");
        return null; // Return null if no token is found
      }
    } catch (e) {
      print("Error fetching token: $e");
      return null; // Handle error and return null
    }
  }

  @override
  void dispose() {
    _paymentsStreamController.close(); // Close the stream controller when the screen is disposed
    super.dispose();
  }

  // Fetch payments from the API and add them to the stream
  Future<void> fetchPayments() async {
    var headers = {
      'Authorization': 'Bearer $newToken',
    };


    var request = http.MultipartRequest('GET', Uri.parse('https://altaibagold.com/api/v1/installment-payment/user-installmnet-payment-history'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        print("Payment List $responseData");
        Map<String, dynamic> responseJson = json.decode(responseData);

        List<Map<String, dynamic>> apiData = [];
        for (var plan in responseJson['data']) {
          for (var payment in plan) {
            apiData.add({
              'id': payment['id'],
              'date': payment['payment_date'],
              'amount': payment['payment_done'].toString(),
              'method': payment['method'],
              'purchase_date': payment['purchase_date'],
              'planCode': payment['plan_code'],
              'installment': payment['installment'],
              'plan_amount' : payment['plan_amount'],
              'purchase_gold_weight' : payment['purchase_gold_weight'],
              'total_gold_purchase' : payment['total_gold_purchase']
            });
          }
        }

        // Add the new data to the stream
        _paymentsStreamController.sink.add(apiData);
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error fetching payments: $e");
    }
  }

  // Filter payments based on selected filter
  void filterPayments(String? filter) {
    setState(() {
      selectedFilter = filter ?? "All"; // Handle null value
      if (filter == "All") {
        filteredPayments = payments;
      } else {
        filteredPayments = payments.where((payment) => payment['id'].toString() == filter).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[800], // Gold color for the app bar
        title: Text("Payment History", style: TextStyle(color: Colors.white)),
        // actions: [
        //   DropdownButton<String>(
        //     value: selectedFilter,
        //     onChanged: filterPayments,
        //     items: <String>["All", "id"].map<DropdownMenuItem<String>>((String value) {
        //       return DropdownMenuItem<String>(
        //         value: value,
        //         child: Text(value),
        //       );
        //     }).toList(),
        //     style: TextStyle(color: Colors.black),
        //     dropdownColor: Colors.amber[50], // Light gold dropdown background
        //   ),
        // ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _paymentsStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No payments available.'));
          } else {
            payments = snapshot.data!;
            filteredPayments = payments; // Set filteredPayments to the full list initially

            return ListView.builder(
              itemCount: filteredPayments.length,
              itemBuilder: (context, index) {
                var payment = filteredPayments.reversed.toList()[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${payment['planCode']}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber[800]),
                        ),
                        SizedBox(height: 8),
                        Text('Purchase Date: ${payment['purchase_date']}'),
                        Text('Payment Date: ${payment['date']}'),
                        Text('Paid: Rs ${payment['plan_amount']}'),
                        Text('Gold Purchased: ${payment['purchase_gold_weight']} grams'),
                       // Text('Total Paid: \Rs ${payment['amount']}'),
                       // Text('Total Gold Purchased: ${payment['total_gold_purchase']} grams'),
                        Text('Method: ${payment['method']}'),
                        Text('Installment: ${payment['installment']}'),
                        SizedBox(height: 8),
                        Divider(color: Colors.amber),
                        Text('Plan Number: ${payment['id']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}



