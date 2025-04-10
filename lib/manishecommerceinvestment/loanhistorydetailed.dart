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

class LoanHistoryDetailsList extends StatefulWidget {
  const LoanHistoryDetailsList({super.key});

  @override
  State<LoanHistoryDetailsList> createState() => _LoanHistoryDetailsListState();
}

class _LoanHistoryDetailsListState extends State<LoanHistoryDetailsList> {
  List<Map<String, dynamic>> paymentPlans = [];
  int _currentIndex = 0;
  TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    fetchLoanPayments();
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
        print('Response Body: $responseBody');
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              _buildHeader(),
              _buildCarousel(),
              _buildIndicators(),
              _buildQuickAccessRow(),
               SizedBox(height: 15,),
              //_buildProIndicators()
              _buildCarouselnew()
            ],
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
              text: const TextSpan(
                text: '  Credit\n',
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                    text: '\t\tDetails',
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
                      Text('₹${plan['loan_amount'].toString()}',
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
              _buildDetailRow(plan['plan_end_date'], 'EMI ₹${plan['emi_amount'].toStringAsFixed(0) ?? '0'}'),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Payment Button: Show the confirmation dialog
        _rowContainer('Payment', 'assets/images/da.png', () {

        }),

        // Ledger Button: Navigate to Ledger Screen
        _rowContainer('Ledger', 'assets/images/db.png', () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LedgerHistoryScreen()),
          );
        }),

        // Loan Button: Navigate to Loan Screen (or implement loan action)
        _rowContainer('AuCred', 'assets/images/dc.png', () {
          var selectedPlan = paymentPlans[_currentIndex];
          var planId = selectedPlan['id'];
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
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => LoanHistoryDetailList()),
          // );
        }),
      ],
    );
  }

  Widget _rowContainer(String text, String image, VoidCallback ontap) {
    return Column(
      children: [
        GestureDetector(
          onTap: ontap, // Trigger the action passed as parameter
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            height: 60,
            width: 60,
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






  //filter



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



  Widget _indicatorWithProgress(
      int index, double progress,
      int remainingEMI,
      int totalEMI,
      int remainingamount,
      int monthEmi
      ) {

    // int emiPaid = totalEMI - remainingEMI;

    int emiPaid = remainingEMI;

    return Align(
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double availableWidth = constraints.hasBoundedWidth ? constraints.maxWidth : screenWidth;
          double size = availableWidth * 0.5; // 70% of available width
          double circleSize = size * 0.9;

          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: circleSize,
                  height: circleSize,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: circleSize * 0.24, // proportional stroke
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.glowingGold),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
          //
          // int emiRemaining = int.tryParse(plan['emi_remaining'].toString()) ?? 0;
          // int totalEmi = int.tryParse(plan['total_no_of_emi'].toString()) ?? 1;
          // double emiAmountRemaining = double.tryParse(plan['emi_amount_remaining'].toString()) ?? 0.0;
          // double emiAmount = double.tryParse(plan['emi_amount'].toString()) ?? 0.0;
                    Text(
                      "Total EMI: $remainingamount",
                      style: TextStyle(
                        fontSize: size * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Current EMI $monthEmi",
                      style: TextStyle(
                        fontSize: size * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "EMI Paid $emiPaid / $totalEMI",
                      style: TextStyle(
                        fontSize: size * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

  }
  Widget _buildProIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(paymentPlans.length, (index) {
        var plan = paymentPlans[index];
        int totalEMI = plan['total_no_of_emi'] ?? 1; // Avoid division by zero
        int remainingEMI = plan['emi_remaining'] ?? 0;
        int monthEMI = (plan['emi_amount'] ?? 0.0).round();
        // int remainingAmount = plan['emi_amount_remaining'] ?? 0;
        int remainingAmount = (plan['emi_amount_remaining'] ?? 0.0).round();
        double progress = (totalEMI - remainingEMI) / totalEMI;

        return _indicatorWithProgress(index, progress, remainingEMI, totalEMI,remainingAmount,monthEMI);
      }),
    );
  }


  Widget _buildCarouselnew() {
    if (paymentPlans.isEmpty) {
      return Center(
        child: Image.asset(
          'assets/images/bh.jpg',
          fit: BoxFit.cover,
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        enlargeCenterPage: true,
        autoPlay: false,
        aspectRatio: 1.5,
        viewportFraction: 1.1,
        onPageChanged: (index, reason) => setState(() => _currentIndex = index),
      ),
      items: paymentPlans.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> plan = entry.value;
        return _buildCarouselItemnew(index, plan);
      }).toList(),
    );
  }

  Widget _buildCarouselItemnew(int index, Map<String, dynamic> plan) {

    int emiRemaining = int.tryParse(plan['emi_paid'].toString()) ?? 0;

    int totalEmi = double.tryParse(plan['total_no_of_emi'].toString())?.toInt() ?? 1;
    // int totalEmi = int.tryParse(plan['total_no_of_emi'].toString()) ?? 0;
    double emiAmountRemaining = double.tryParse(plan['emi_amount_remaining'].toString()) ?? 0.0;
    double emiAmount = double.tryParse(plan['emi_amount'].toString()) ?? 0.0;

    double progress = (emiRemaining / totalEmi).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            _indicatorWithProgress(
              index,
              progress,
              emiRemaining,
              totalEmi,
              emiAmountRemaining.toInt(),
              emiAmount.toInt(),
            ),
          ],
        ),
      ),
    );
  }










}


