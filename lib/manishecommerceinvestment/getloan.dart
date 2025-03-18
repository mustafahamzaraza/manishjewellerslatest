import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/plandetails.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utill/colornew.dart';
import 'loanhistorylist.dart';


class LoanScreen extends StatefulWidget {
  final int id;
  const LoanScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  bool isLoading = true;
  Map<String, dynamic>? loanResponse;
  String errorMessage = '';
  double _loanAmount = 10;
  double _months = 1;
  String? inid;

  @override
  void initState() {
    super.initState();
    fetchLoanData(widget.id);
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchLoanData(int id) async {
    String? token = await getToken();
    if (token == null) return;
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var request = http.Request(
      'GET',
      Uri.parse('https://manish-jewellers.com/api/loan/request?installment_id=$id'),
    );
    request.headers.addAll(headers);
    inid = widget.id.toString();

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseBody);
        print('Res: $jsonData');
        setState(() {
          loanResponse = jsonData;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = response.reasonPhrase ?? 'An error occurred';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Exception: $e';
      });
    }
  }


  double calculateEMI(double principal, int months, double annualInterestRate) {
    double monthlyRate = annualInterestRate / 12 / 100;
    double numerator = principal * monthlyRate * pow(1 + monthlyRate, months);
    double denominator = pow(1 + monthlyRate, months) - 1;
    return (denominator == 0) ? principal : numerator / denominator;
  }




  double emi = 0.0;

  double monthlypay = 0.0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double principal = _loanAmount.round().toDouble();
    int months = _months.round();
    double annualInterestRate = 12; // example rate; replace with your actual rate

    emi = calculateEMI(principal, months, annualInterestRate);


    return Scaffold(
      backgroundColor: AppColors.textDark,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : loanResponse != null && loanResponse?['eligible'] == false
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sorry!!!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                'You are not eligible for a credits.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DashBoardScreen()),
                  );
                },
                child: Text('Back'),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          child:

          Column(
            children: [
              welcomeBackText(),
              cardContainer(),
              const SizedBox(height: 15),
              // Conditionally render based on loanResponse and isLoading
              if (loanResponse != null && !isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: textRow("Amount", "\Rs ${loanResponse?['max_loan_amount'] ?? '50000'}"),
                ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 17.0, // Thick track
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.black54,
                    thumbShape: CustomSliderThumb(), // Custom thumb
                  ),
                  child: Slider(
                    value: _loanAmount,
                    min: 10,
                    max: double.tryParse(loanResponse!['max_loan_amount'].toString()) ?? 50000.0,
                    divisions: 9,
                    label: "\Rs ${_loanAmount.round()}",
                    activeColor: Colors.black,
                    inactiveColor: Colors.black,
                    thumbColor: Colors.transparent, // Make it transparent since we will override it
                    onChanged: (double value) {
                      setState(() {
                        _loanAmount = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: minimumLoanAndMonthText("Min \Rs 10", "Max \Rs ${loanResponse!['max_loan_amount'].toString()}"),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: textRow("Number\nof Months", "${_months.round()} Months"),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 17.0, // Thick track
                    activeTrackColor: Colors.black,
                    inactiveTrackColor: Colors.black54,
                    thumbShape: CustomSliderThumb(), // Custom thumb
                  ),
                  child: Slider(
                    value: _months,
                    min: 1,
                    max: double.tryParse(loanResponse!['loan_duration'].toString()) ?? 0.0,
                    divisions: 23,
                    label: "${_months.round()} Months",
                    activeColor: Colors.black,
                    inactiveColor: Colors.black,
                    thumbColor: Colors.black,
                    onChanged: (double value) {
                      setState(() {
                        _months = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: minimumLoanAndMonthText("Min 1 Month", "Max ${loanResponse!['loan_duration'].toString()} Months"),
              ),
              const SizedBox(height: 10),
              listRowContainer(),
              const SizedBox(height: 30),
              SizedBox(
                width: screenWidth * 0.8, // 80% of the screen width
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // _showConfirmationDialog(context,
                    //     _loanAmount.round().toString(),
                    //     _months.round().toString(),
                    //     loanResponse?['emi_per_month'].toString() ?? '0',
                    //     inid ?? ''
                    // );
                    print('pressed');
                //    _paymentConfirmationDialog(context,  _loanAmount.round().toString(),_months.round().toString(),  loanResponse?['emi_per_month'].toString() ?? '0',  inid ?? '');

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _paymentConfirmationDialog(
                          context,
                          _loanAmount.round().toString(),
                          _months.round().toString(),
                           emi.toStringAsFixed(2) ?? '0',
                          inid ?? '',
                        );
                      },
                    );

                    print('emi $emi');

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Confirm & Apply",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),


        ),
      ),
    );
  }


  Widget welcomeBackText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashBoardScreen(),
                ),
              );
            },
            child: RichText(
              text: const TextSpan(
                text: 'Welcome back\n',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(
                    text: 'Alfredo Toress',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/man.jpeg'),
            backgroundColor: AppColors.textDark,
          ),
        ],
      ),
    );
  }

  Widget cardContainer() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 170,
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Card(
            color: AppColors.glowingGold,
            margin: const EdgeInsets.symmetric(vertical: 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Row(
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Gold Credits\n',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: 'Get Upto',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Image(
                          image: AssetImage('assets/images/check.png'),
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${loanResponse!['max_loan_amount']} in 10 mins",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Confirm & Apply",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -15,
          left: 0,
          right: 0,
          child: Center(
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              child: const Icon(
                Icons.arrow_downward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget textRow(String text, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          Text(amount, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget minimumLoanAndMonthText(String min, String max) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(min, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
          Text(max, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget listRowContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.glowingGold,
              ),
              height: 50,
              width: 50,
              child: Image.asset('assets/images/umbrella.png', fit: BoxFit.cover),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Access loanResponse directly without model
                    Text("${_loanAmount.round()}", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                    Text("Amount", style: TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${_months.round()} Months", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                    Text("Duration", style: TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                //    Text("\Rs ${loanResponse?['emi_per_month'] ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),

                    Text(
                        "₹ ${emi.toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                    Text("EMi", style: TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.textLight, indent: 5, thickness: 1, endIndent: 5),
        ],
      ),
    );
  }
}

class CustomSliderThumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(45, 45); // Big thumb size
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    // Black border
    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5; // Border thickness

    // White inner fill
    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw circles
    canvas.drawCircle(center, 30, fillPaint); // Inner white circle
    canvas.drawCircle(center, 30, borderPaint); // Outer black border
  }
}








Widget _paymentConfirmationDialog(BuildContext context,String lamount, String months, String emi ,String installid) {

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
                    "Credit\nDisbursed",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,height: 1
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

              Text('Amount: \Rs ${lamount}'),
              Text('Number of Months: ${months} Months'),
              Text('EMI: \Rs $emi'),
              SizedBox(height: 8),


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
                    payOfflineLoan(context, lamount, months ,emi , installid);
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







Future<void> payOfflineLoan(BuildContext context, String amount, String months, String emi,String id) async {


  try {
    String? token = await getToken();

    int emiValue = int.tryParse(emi) ?? 0;


    if (token != null) {
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $token', // Use the token in the Authorization header
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://manish-jewellers.com/api/loan/confirm-payment'),
      );

      request.fields.addAll({
        'loan_amount': amount,
        'no_of_months': months,
        'no_of_emi': months,
        'remarks': 'Yes',
        'installment_id': id,
        'loan_id': '0',
        'type': 'Loan Request'
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();


      if (response.statusCode == 200) {
        print('id $id');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Successfully acquired a credits",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 2),
          ),
        );

        print(await response.stream.bytesToString());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoanHistoryList(),
          ),
        );
      } else {




        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${response.reasonPhrase}",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 2),
          ),
        );

        print(await response.stream.bytesToString());
        print('id $id');
        print('Request failed with status: ${response.statusCode}');
        print('Reason: ${response.reasonPhrase}');
        print('headers $headers body ${request.fields}');
      }
    } else {
      print('Token not found. User might need to log in again.');
    }
  } catch (e) {
    print('Error occurred while processing loan payment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "An error occurred. Please try again.",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}


