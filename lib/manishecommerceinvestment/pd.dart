import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
import 'package:carousel_slider/carousel_slider.dart';

import '../features/dashboard/screens/dashboard_screen.dart';
import '../utill/colornew.dart';

class InvestmentPaymentDetails extends StatefulWidget {
  const InvestmentPaymentDetails({super.key});

  @override
  State<InvestmentPaymentDetails> createState() =>
      _InvestmentPaymentDetailsState();
}

class _InvestmentPaymentDetailsState extends State<InvestmentPaymentDetails> {
  List<Map<String, dynamic>> paymentPlans = [];
  int _currentIndex = 0;
  // List<charts.Series<_ChartData, int>> graphData = [];

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
    var request = http.MultipartRequest(
      'GET',
      Uri.parse('https://manish-jewellers.com/api/installment-payment/list'),
    );

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseBody);
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          // Check if the widget is still mounted before updating the state
          if (mounted) {
            setState(() {
              paymentPlans = List<Map<String, dynamic>>.from(jsonData['data']);
           //   updateGraphData();
            });
          }
        }
      }
    } catch (e) {
      print('Exception: $e');
    }
  }




  // void updateGraphData() {
  //   if (paymentPlans.isEmpty) return;
  //
  //   List<Map<String, dynamic>> details =
  //   List<Map<String, dynamic>>.from(paymentPlans[_currentIndex]['details'] ?? []);
  //
  //   setState(() {
  //     graphData = [
  //       charts.Series<_ChartData, int>(
  //         id: 'Payments',
  //         colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //         domainFn: (_ChartData data, _) => data.index,
  //         measureFn: (_ChartData data, _) => data.payment,
  //         data: details.asMap().entries.map((entry) {
  //           int index = entry.key;
  //           double payment = double.tryParse(entry.value['payment_amount'].toString()) ?? 0;
  //           return _ChartData(index, payment);
  //         }).toList(),
  //       ),
  //     ];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              _buildHeader(),
              _buildCarousel(),
              _buildIndicators(),
               _buildQuickAccessRow(),
               SizedBox(height: 15,),
              _buildTransactionHeader(),
              _buildGraph(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
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

        }),

        // Loan Button: Navigate to Loan Screen (or implement loan action)
        _rowContainer('AuCred', 'assets/images/dc.png', () {

        }),

        // Details Button: Navigate to Details Screen (or show information)
        _rowContainer('Details', 'assets/images/d.png', () {

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
                text: '  Investment\n',
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
          //   onTap: fetchPayments,
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
                      Text('₹${plan['total_balance']}',
                          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold,height: 1)),
                      SizedBox(height: 5,),
                      Text('Balance', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic,height: 1)),
                      SizedBox(height: 5,),
                      Text('Gold Acquired ${plan['total_gold_purchase'].toString()} gm', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic,fontWeight: FontWeight.w700,height: 1)),
                    ],
                  ),
                  Image.asset(
                    'assets/images/check.png',  // Default image
                    fit: BoxFit.cover,height: 60,width: 60,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildDetailRow(plan['plan_start_date'], '${plan['plan_code']} ${plan['id']} '),
              _buildDetailRow(plan['plan_end_date'], 'Monthly ₹${plan['monthly_average'].toStringAsFixed(0)}'),
            ],
          ),
        ),
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




  // Widget _buildGraph() {
  //   List<_ChartData> chartData = _convertChartData();
  //
  //   return Expanded(
  //     child: Padding(
  //       padding: EdgeInsets.only(top: 0, left: 15, right: 15),
  //       child: charts.LineChart(
  //         [
  //           charts.Series<_ChartData, int>(
  //             id: 'Payments',
  //             colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //             domainFn: (data, _) => data.index,
  //             measureFn: (data, _) => data.payment,
  //             data: chartData,
  //           )
  //         ],
  //         animate: true,
  //         behaviors: [charts.ChartTitle('Weekly Payments')],
  //       ),
  //     ),
  //   );
  // }
  //
  // List<_ChartData> _convertChartData() {
  //   List<_ChartData> data = [];
  //   if (paymentPlans.isNotEmpty) {
  //     var chartWeekly = paymentPlans[0]['chart_weekly'] as List<dynamic>?;
  //     if (chartWeekly != null) {
  //       for (var i = 0; i < chartWeekly.length; i++) {
  //         var entry = chartWeekly[i];
  //         data.add(_ChartData(i, double.parse(entry['total_payment'].toString())));
  //       }
  //     }
  //   }
  //   return data;
  // }




  Widget _buildGraph() {
    List<_ChartData> chartData = _convertChartData();

    print("Chart Data Length: \${chartData.length}"); // Debugging line

    if (chartData.isEmpty) {
      return Center(child: Text("No data available")); // Prevent chart from rendering with empty data
    }

    return Expanded(
     child: Text(""),
      // child: Padding(
      //   padding: EdgeInsets.only(top: 0, left: 15, right: 15),
      //   child: charts.LineChart(
      //     [
      //       charts.Series<_ChartData, int>(
      //         id: 'Payments',
      //         colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      //         domainFn: (data, _) => data.index,
      //         measureFn: (data, _) => data.payment,
      //         data: chartData,
      //         strokeWidthPxFn: (_, __) => 3, // Thicker line
      //         insideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(
      //           fontSize: 14,
      //           color: charts.MaterialPalette.black,
      //         ),
      //       )
      //     ],
      //     animate: true,
      //     defaultRenderer: charts.LineRendererConfig(
      //       includePoints: true, // Show rounded data points
      //       radiusPx: 5.0, // Larger point size
      //     ),
      //     primaryMeasureAxis: charts.NumericAxisSpec(
      //       renderSpec: charts.GridlineRendererSpec(
      //         lineStyle: charts.LineStyleSpec(
      //           dashPattern: [4, 4], // Subtle grid lines
      //         ),
      //         labelStyle: charts.TextStyleSpec(
      //           fontSize: 12,
      //           color: charts.MaterialPalette.black,
      //         ),
      //       ),
      //     ),
      //     domainAxis: charts.NumericAxisSpec( // Changed to NumericAxisSpec
      //       renderSpec: charts.GridlineRendererSpec(
      //         labelStyle: charts.TextStyleSpec(
      //           fontSize: 14,
      //           color: charts.MaterialPalette.black,
      //         ),
      //         lineStyle: charts.LineStyleSpec(thickness: 2),
      //       ),
      //     ),
      //     behaviors: [charts.ChartTitle('Weekly Payments', titleStyleSpec: charts.TextStyleSpec(fontSize: 16, fontWeight: 'bold'))],
      //   ),
      // ),
    );
  }

  List<_ChartData> _convertChartData() {
    List<_ChartData> data = [];
    if (paymentPlans.isNotEmpty) {
      var chartWeekly = paymentPlans[0]['chart_weekly'] as List<dynamic>?;
      if (chartWeekly != null && chartWeekly.isNotEmpty) {
        for (var i = 0; i < chartWeekly.length; i++) {
          var entry = chartWeekly[i];
          double payment = double.tryParse(entry['total_payment'].toString()) ?? 0.0;
          data.add(_ChartData(i, payment));
        }
      }
    }
    return data;
  }




}


class _ChartData {
  final int index;
  final double payment;
  _ChartData(this.index, this.payment);
}

