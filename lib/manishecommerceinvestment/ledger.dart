import 'dart:convert';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/pp.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../utill/colornew.dart';

class LedgerHistoryScreen extends StatefulWidget {
  const LedgerHistoryScreen({super.key});

  @override
  State<LedgerHistoryScreen> createState() => _LedgerHistoryScreenState();
}

class _LedgerHistoryScreenState extends State<LedgerHistoryScreen> {
  List<Map<String, dynamic>> paymentPlans = [];
  TextEditingController _searchController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchPayments() async {
    String? token = await getToken();
    if (token == null) return;

    var headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    var request = http.MultipartRequest('GET', Uri.parse('https://manish-jewellers.com/api/v1/installment-payment/list'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        try {
          var jsonData = jsonDecode(responseBody);
          if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
            setState(() {
              paymentPlans = List<Map<String, dynamic>>.from(jsonData['data']);
            });
          }
        } catch (jsonError) {
          print('Error decoding JSON: $jsonError');
        }
      } else {
        print('Error: Received non-200 response status');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredTransactions() {
    String searchQuery = _searchController.text.trim();
    DateTime? dateFilter = selectedDate;

    List<Map<String, dynamic>> transactions = [];
    // Flatten paymentPlans list
    paymentPlans.forEach((plan) {
      if (plan['details'] != null) {
        transactions.addAll(List<Map<String, dynamic>>.from(plan['details']));
      }
    });

    // Filter by amount
    if (searchQuery.isNotEmpty) {
      transactions = transactions.where((payment) {
        return payment['payment_amount'].toString().contains(searchQuery);
      }).toList();
    }

    // Filter by date if a date is selected
    if (dateFilter != null) {
      transactions = transactions.where((payment) {
        // Remove suffixes like "st", "nd", "rd", "th"
        String cleanedDateString = payment['payment_date'].replaceAllMapped(
          RegExp(r'(\d+)(st|nd|rd|th)'),
              (Match match) => match.group(1) ?? '',
        );

        try {
          // Parse the cleaned date string without time
          DateTime paymentDate = DateFormat("MMMM dd, yyyy").parse(cleanedDateString);

          // Compare the year, month, and day for both dates
          return paymentDate.year == dateFilter.year &&
              paymentDate.month == dateFilter.month &&
              paymentDate.day == dateFilter.day;
        } catch (e) {
          // If there is an error in parsing the date, log the raw date and handle it
          print("Error parsing date: $e. Raw date string: $cleanedDateString");
          return false;
        }
      }).toList();
    }

    return transactions;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var filteredTransactions = getFilteredTransactions(); // Get filtered transactions based on search query and date filter

    return Scaffold(
      backgroundColor: AppColors.textDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchSection(),
              _buildTransactionHeader(),
              Expanded(
                child:
                ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final payment = filteredTransactions[index];
                    return Column(
                      children: [
                        ListTile(
                          // leading: CircleAvatar(
                          //   backgroundColor: AppColors.yellowGold,
                          //   backgroundImage: AssetImage('assets/images/umbrella.png',),
                          //   // Local asset image
                          // ),
                      leading: Container(
                        decoration: BoxDecoration(
                         // color: AppColors.yellowAccentGold,
                           color: Color(0xffFFDE59),
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(image: AssetImage("assets/images/umbrella.png",))
                              
                        ),
                        height: 40,
                        width: 40,
                      )
                          ,
                          title: Text(
                            '${payment['payment_date']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(payment['payment_time']),
                              const SizedBox(width: 8), // Adds space between payment time and "Cash"
                              Text(payment['payment_type'].toString() ?? 'CASH',style: const TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                          trailing: Text(
                            '₹${payment['payment_amount']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const Divider( // ✅ Adds a divider after each ListTile
                          thickness: 1,
                          color: Colors.black,
                          indent: 15, // Optional: add padding on left
                          endIndent: 15, // Optional: add padding on right
                        ),
                      ],
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              text: '  Your\n',
              style: TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                  text: '\t\tLedger',
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentHistoryList()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.black),
                    borderRadius: BorderRadius.circular(30)
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                controller: _searchController, // Bind the controller to the field
                decoration: InputDecoration(
                  hintText: 'Search by amount...',
                  suffixIcon: Icon(Icons.search, color: Colors.black26),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), // Curve radius for the TextField
                    borderSide: BorderSide(color: Colors.black, width: 2), // Black border
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    // Trigger UI update on search text change
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: const Image(image: AssetImage('assets/images/e.png'), height: 65, width: 65)),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
     child:  Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         const Text(
           "Transaction",
           style: TextStyle(
             color: AppColors.textLight,
             fontSize: 13,
             fontWeight: FontWeight.bold,
           ),
         ),
         RichText(
           text: const TextSpan(
             text: 'Sort by',
             style: TextStyle(
               color: AppColors.textLight,
               fontWeight: FontWeight.w400,
               fontSize: 13,
             ),
             children: [
               TextSpan(
                 text: '\tLatest',
                 style: TextStyle(
                   color: AppColors.textLight,
                   fontSize: 13,
                   fontWeight: FontWeight.bold,
                 ),
               ),
             ],
           ),
         ),
       ],
     ),
    );
  }
}




