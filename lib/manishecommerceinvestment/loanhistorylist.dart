import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../features/dashboard/screens/dashboard_screen.dart';
import '../utill/colornew.dart';
import 'getloan.dart';
import 'ledger.dart';
import 'loanhistorydetailed.dart';

class LoanHistoryList extends StatefulWidget {
  const LoanHistoryList({super.key});

  @override
  State<LoanHistoryList> createState() => _LoanHistoryListState();
}

class _LoanHistoryListState extends State<LoanHistoryList> {
  List<Map<String, dynamic>> paymentPlans = [];
  int _currentIndex = 0;
  TextEditingController _searchController = TextEditingController();

  String uname = '';

  @override
  void initState() {
    super.initState();
    fetchLoanPayments();
    fetchProfileData(newAddress: '');
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchLoanPayments() async {
    String? token = await getToken();
    if (token == null) return;

    var headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    var request = http.MultipartRequest(
      'GET',
      Uri.parse('https://manish-jewellers.com/api/v1/loan/list'),
    );

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('loan/list Response Body: $responseBody');
        try {
          var jsonData = jsonDecode(responseBody);
          debugPrint('Decoded Full JSON data: $jsonData');
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

  Future<void> fetchProfileData({required String newAddress}) async {
    String? token = await getToken();
    try {
      final response = await http.post(
        Uri.parse('http://manish-jewellers.com/api/v1/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "name": '',
          "email": '',
          "mobile_no": '',
          "address": ''
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('profile details $data');

        if (data['status'] == true) {
          setState(() {
            uname = data['data']['name'] ?? ''; // Default to empty string if null

          });
        } else {
          print("Profile fetch failed");
        }
      } else {
        print("API call failed");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                _buildCarousel(),
                _buildIndicators(),
                _buildQuickAccessRow(),
                _buildSearchSection(),
                _buildTransactionHeader(),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildTransactionList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashBoardScreen()),
              );
            },
            child: RichText(
              text: TextSpan(
                text: '  Welcome back\n',
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                    text: '\t\t${uname.toUpperCase()}',
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashBoardScreen()),
              );
            },
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/back.png'),
            ),
          ),
          // InkWell(
          //   onTap: fetchLoanPayments,
          //   child: CircleAvatar(
          //     radius: 30,
          //     backgroundImage: const AssetImage('assets/images/profile.jpg'),
          //     backgroundColor: AppColors.textDark,
          //   ),
          // ),
        ],
      ),
    );
  }


  Widget _buildCarousel() {
    if (paymentPlans.isEmpty) {
      // If there are no payment plans, show a default image or text
      return Center(
        child: Image.asset(
          'assets/images/bh.jpg',  // Default image
          fit: BoxFit.cover,
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        enlargeCenterPage: true,
        autoPlay: false,
        aspectRatio: 21 / 11,
        viewportFraction: 0.9,
        onPageChanged: (index, reason) => setState(() => _currentIndex = index),
      ),
      items: paymentPlans.map((plan) => _buildCarouselItem(plan)).toList(),
    );
  }





  Widget _buildCarouselItem(Map<String, dynamic> plan) {
    return Card(
      color: AppColors.glowingGold,
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Padding(
        padding: const EdgeInsets.only(left: 25,right: 20,top: 20,bottom: 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('₹${plan['loan_amount']}',
                          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold,height: 1)),
                      SizedBox(height: 5,),
                      Text('Balance', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic,height: 1)),
                    ],
                  ),
                  Image.asset(
                    'assets/images/checknew.png',  // Default image
                    fit: BoxFit.cover,height: 60,width: 60,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildDetailRow(plan['plan_start_date'], 'LNR ${plan['id']} '),
              _buildDetailRow(plan['plan_end_date'], 'EMI ₹${plan['emi_amount'].toStringAsFixed(0) ?? '0'}',),
              _buildDetailRow('', 'Total EMI Amount ₹${plan['emi_amount_remaining'].toStringAsFixed(0) ?? '0'}',),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(paymentPlans.length, (index) => _indicatorDot(index)),
    );
  }

  Widget _indicatorDot(int index) {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentIndex == index ? Colors.black : Colors.black54,
      ),
    );
  }

  Widget _buildQuickAccessRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Payment Button: Show the confirmation dialog
          _rowContainer('Payment', 'assets/images/a.png', () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return _paymentConfirmationDialog(context);
              },
            );
          }),

          // Ledger Button: Navigate to Ledger Screen
          _rowContainer('Ledger', 'assets/images/b.png', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LedgerHistoryScreen()),
            );
          }),

          // Loan Button: Navigate to Loan Screen (or implement loan action)
          _rowContainer('AuCred', 'assets/images/dc.png', () {
            var selectedPlan = paymentPlans[_currentIndex];
            var planId = selectedPlan['id'];
            print('idddddddd $planId');
            Future.delayed(const Duration(seconds: 5), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoanScreen(
                  id: planId,
                )), // Next screen after confirmation
              );
            });
          }),

          // Details Button: Navigate to Details Screen (or show information)
          _rowContainer('Details', 'assets/images/d.png', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoanHistoryDetailsList()),
            );
          }),
        ],
      ),
    );
  }


  Widget _rowContainer(String text, String image, VoidCallback ontap) {
    return Column(
      children: [
        GestureDetector(
          onTap: ontap, // Trigger the action passed as parameter
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(image: AssetImage(image)),
            ),
          ),
        ),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold,height: 1),
        ),
      ],
    );
  }
  // Widget _rowContainer(String text, String image, VoidCallback ontap) {
  //   return Column(
  //     children: [
  //       GestureDetector(
  //         onTap: ontap, // Trigger the action passed as parameter
  //         child: Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //           height: 50,
  //           width: 50,
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(15),
  //             image: DecorationImage(image: AssetImage(image)),
  //           ),
  //         ),
  //       ),
  //       Text(
  //         text,
  //         style: TextStyle(fontWeight: FontWeight.bold,height: 1),
  //       ),
  //     ],
  //   );
  // }


  Widget _paymentConfirmationDialog(BuildContext context) {

    String selectedPaymentMethod = 'Cash';



    final TextEditingController _onlineController = TextEditingController();
    final TextEditingController _offlineController = TextEditingController();

    // Assuming this is within your widget's build method
    var selectedPlan = paymentPlans[_currentIndex];
    double emiAmountRemaining = double.tryParse(
        selectedPlan['emi_amount_remaining'].toString()
    ) ?? 0.0;

    double emiAmount = double.tryParse(selectedPlan['emi_amount'].toStringAsFixed(0)) ?? 0.0;


    String formattedEmiAmount = emiAmount.toStringAsFixed(2);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glowingGold, // Background color
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and close button



                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment\nConfirmation",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close dialog
                      },
                      child: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Subheading
                Text(
                  "Dues",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),

                // Input instructions
                Text(
                  "ENTER AMOUNT",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 8),



                TextField(
                  controller: selectedPaymentMethod == 'Razorpay'
                      ? _onlineController
                      : _offlineController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "Amount Remaining $formattedEmiAmount",
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),

                // Payment options
                Row(
                  children: [
                    // Razorpay option
                    // Row(
                    //   children: [
                    //     Radio<String>(
                    //       value: 'Razorpay',
                    //       groupValue: selectedPaymentMethod,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           selectedPaymentMethod = value!;
                    //         });
                    //       },
                    //     ),
                    //     Text("Razorpay"),
                    //   ],
                    // ),
                    SizedBox(width: 16),
                    // Cash option
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Cash',
                          groupValue: selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value!;
                            });
                          },
                        ),
                        Text("Cash"),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Get the selected plan from your paymentPlans list.
                      var selectedPlan = paymentPlans[_currentIndex];
                      // Retrieve the remaining EMI amount and ensure it's parsed as a number.
                      double emiAmountRemaining = double.tryParse(selectedPlan['emi_amount'].toStringAsFixed(0)) ?? 0.0;

                      if (selectedPaymentMethod == 'Cash') {
                        String offlineAmount = _offlineController.text.trim();
                        if (offlineAmount.isNotEmpty) {
                          double offlineValue = double.tryParse(offlineAmount) ?? 0.0;
                          if (offlineValue == emiAmountRemaining) {
                            payOfflineLoan(context, offlineAmount);
                          } else {
                            print("Entered amount must be equal to the remaining EMI amount: $emiAmountRemaining");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Entered amount must be equal to $emiAmountRemaining"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          print("Please enter a valid amount for offline payment");
                        }
                      }

                   else {
                     //   String onlineAmount = _onlineController.text.trim();
                        // if (onlineAmount.isNotEmpty) {
                        //   double onlineValue = double.tryParse(onlineAmount) ?? 0.0;
                        //   if (onlineValue <= emiAmountRemaining) {
                        //     print("Processing online payment with amount: $onlineAmount");
                        //     // Add your online payment logic here.
                        //     Navigator.pop(context);
                        //   } else {
                        //     print("Entered amount exceeds the remaining EMI amount: $emiAmountRemaining");
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(
                        //         content: Text("Entered amount must be less or equal to $emiAmountRemaining"),
                        //         backgroundColor: Colors.red,
                        //       ),
                        //     );
                        //   }
                        // } else {
                        //   print("Please enter a valid amount for online payment");
                        // }
                      }
                    },

                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Future<void> payOfflineLoan(BuildContext context, String amount) async {
    String? token = await getToken();

    if (token == null) {
      print('Token not found. User might need to log in again.');
      return;
    }

    String getCurrentDate() {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    var selectedPlan = paymentPlans[_currentIndex];

    var planId = selectedPlan['id'];

    var months = selectedPlan['no_of_months'];


    // var emi = selectedPlan['total_no_of_emi'];
    // int emix = emi.toInt(); // safe if it's always a number

    String rawEmi = selectedPlan['total_no_of_emi'] ?? '0';
    int emix = double.tryParse(rawEmi)?.toInt() ?? 0;

//    var emi = selectedPlan['total_no_of_emi'];
    print('emi $emix');

    var installid = selectedPlan['plan_id'];

    var emiamountremain = selectedPlan['emi_amount_remaining'];

    var url = Uri.parse('https://manish-jewellers.com/api/v1/loan/confirm-payment');

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',  // JSON request
    };

    var body = jsonEncode({

    "loan_amount":double.tryParse(amount) ?? 0,
    "no_of_months":months,
    "no_of_emi":emix,
    "installment_id":installid,
    "loan_id": planId

    });

    try {
      print("Sending request to API...");
      print("Request Headers: $headers");
      print("Request Body: $body");

      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Loan ID: ${planId.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "EMI Payment Successful!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoanHistoryList(),
          ),
        );

        print('Payment Successful ✅');
      } else {
        print('Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }



  List<Map<String, dynamic>> getFilteredTransactions() {
    String searchQuery = _searchController.text.trim();
    DateTime? dateFilter = selectedDate;

    // Ensure that 'details' exists and is a List
    List<Map<String, dynamic>> transactions = [];
    if (paymentPlans.isNotEmpty && paymentPlans[_currentIndex]['details'] != null) {
      transactions = List<Map<String, dynamic>>.from(paymentPlans[_currentIndex]['details']);
    }

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
        // In the getFilteredTransactions method:
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


  Widget _buildSearchSection() {
    return Padding(
      padding: EdgeInsets.only(left: 15,bottom: 10,top: 5,right: 15),
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
                  //  border: OutlineInputBorder(),
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
              onTap: (){
                _selectDate(context);
              },
              child: const Image(image: AssetImage('assets/images/e.png'), height: 65, width: 65)),
        ],
      ),
    );
  }

  DateTime? selectedDate;

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

  Widget _buildTransactionList() {
    var filteredTransactions = getFilteredTransactions(); // Get filtered transactions based on search query and date filter

//    [{payment_amount: 299.00, payment_date: January 29th, 2025, payment_time: 10:55 AM, payment_status: null, payment_type: null

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final payment = filteredTransactions[index];
        return Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 37,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/handshake.png'),
              ),
              title: Text(
                _extractDate(payment['payment_date']),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _extractTime(payment['payment_date']),
                    style: const TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 4),  // Small space between time and payment type
                  Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: Text(
                      '${payment['payment_type'].toUpperCase()}',
                      style: const TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              trailing: Text(
                '₹${payment['payment_amount']??'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            // ListTile(
            //   contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   leading: CircleAvatar(
            //     backgroundImage: AssetImage('assets/images/umbrella.png'),
            //   ),
            //   title: Text(
            //     '${payment['payment_date']}',
            //     style: const TextStyle(fontWeight: FontWeight.bold),
            //   ),
            //   subtitle: Text(
            //     '${payment['payment_type']}', // Payment type displayed below the date
            //     style: const TextStyle(color: Colors.black54), // Optional: Adjust text color
            //   ),
            //   trailing: Text(
            //     '₹${payment['payment_amount'] ?? '100'}',
            //     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            //   ),
            // ),
            const Divider( // ✅ Adds a divider after each ListTile
              thickness: 1,
              color: Colors.black,
              indent: 15, // Optional: add padding on left
              endIndent: 15, // Optional: add padding on right
            ),
          ],
        );
      },
    );
  }

  // Widget _buildTransactionList() {
  //   var filteredTransactions = getFilteredTransactions(); // Get filtered transactions based on search query and date filter
  //
  //   return ListView.builder(
  //     itemCount: filteredTransactions.length,
  //     itemBuilder: (context, index) {
  //       final payment = filteredTransactions[index];
  //       return ListTile(
  //         leading: const Image(image: AssetImage('assets/images/circular.jpg'), height: 50),
  //         title: Text('₹${payment['payment_amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
  //         subtitle: Text(payment['payment_date']),
  //         trailing: Text(payment['payment_status'] == 'paid' ? 'Paid' : 'Pending', style: TextStyle(color: payment['payment_status'] == 'paid' ? Colors.green : Colors.red)),
  //       );
  //     },
  //   );
  // }

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

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 12,height: 1)),
          Text(value, style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12,height: 1)),
        ],
      ),
    );
  }
  // Widget _buildDetailRow(String title, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 5),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 9,height: 1)),
  //         Text(value, style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 9,height: 1)),
  //       ],
  //     ),
  //   );
  // }

}

String _extractDate(String dateTime) {
  List<String> parts = dateTime.split(' ');
  return '${parts[0]} ${parts[1]}, ${parts[2]}'; // Extracting "January 31st, 2025"
}

String _extractTime(String dateTime) {
  List<String> parts = dateTime.split(' ');
  return '${parts[3]} ${parts[4]}'; // Extracting "7:55 AM"
}


