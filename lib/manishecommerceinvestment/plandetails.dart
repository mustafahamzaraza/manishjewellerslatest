import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment_webview.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/pp.dart';
import 'package:shared_preferences/shared_preferences.dart';// If you are using custom colors
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../features/gold/payment_webview.dart';
import '../utill/colornew.dart';
import 'gb.dart';



class PlanDetailScreen extends StatefulWidget {
  final int planId;

  const PlanDetailScreen({Key? key, required this.planId}) : super(key: key);

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {

 String? planName;
 String? planCat;

 final TextEditingController _offlineController = TextEditingController();
 final TextEditingController _onlineController = TextEditingController();

 String price22k = "Loading...";
 double goldPricePerGram = 0.0; // Will be updated from API
 String currentDateTime = "";

  String selectedPaymentMethod = 'Cash';


  Future<void> fetchGoldPrices() async {
   const String apiUrl = "https://manish-jewellers.com/api/goldPriceService";

   try {
     final response = await http.get(Uri.parse(apiUrl));
     if (response.statusCode == 200) {
       final data = json.decode(response.body);
       String dateTime = DateFormat("dd/MM/yyyy, hh:mm a").format(DateTime.now());

       print('response $data');
       setState(() {
         goldPricePerGram = double.tryParse(data['data']['price_gram']['22k_gst_included'].toString()) ?? 0.0;
         price22k = "${goldPricePerGram.toStringAsFixed(2)}";
         currentDateTime = dateTime;
       });

       // Recalculate gold weight with the new price
       _calculateGoldWeight();
     } else {
       setState(() {
         price22k = "Error fetching price";
         currentDateTime = "Error fetching time";
       });
     }
   } catch (e) {
     setState(() {
       price22k = "Error: ${e.toString()}";
       currentDateTime = "Error fetching time";
     });
   }
 }

 int? months;
  final StreamController<double> _goldWeightController = StreamController<double>.broadcast();  // Use broadcast here
  final StreamController<double> _deductedAmountController = StreamController<double>.broadcast();


 bool termsAccepted = false;





  double goldWeight = 0.0;

 double goldAcquired = 0.0;

 double effectiveAmount = 0.0;

 double enteredAmount = 0.0;

 @override
 void initState() {
   super.initState();
   GlobalPlan().setPlanDetails(widget.planId);
   fetchGoldPrices();

   // Listen for changes in the correct input field
   if (selectedPaymentMethod == 'Razorpay') {
     _onlineController.addListener(() {
       print("📝 Online Controller Updated: ${_onlineController.text}");
       _updateGoldCalculation(_onlineController.text);
     });
   } else {
     _offlineController.addListener(() {
       print("📝 Offline Controller Updated: ${_offlineController.text}");
       _updateGoldCalculation(_offlineController.text);
     });
   }

   // Set plan details
   if (widget.planId == 1) {
     planName = "First Installment Plan";
     planCat = "INR";
     months = 12;
   } else if (widget.planId == 2) {
     planName = "Second Installment Plan";
     planCat = "SNR";
     months = 18;
   } else {
     planName = "Third Installment Plan";
     planCat = "TNR";
     months = 24;
   }

   debugStreamValues(); // Debugging
 }


 void _calculateGoldWeight() {
   double enteredAmount = double.tryParse(_offlineController.text) ?? 0.0;
   if (goldPricePerGram > 0) {
     goldWeight = enteredAmount / goldPricePerGram;
     _goldWeightController.add(goldWeight);
   } else {
     goldWeight = 0.0;
     _goldWeightController.add(0.0);
   }
 }


 void _updateGoldCalculation(String value) {
   enteredAmount = double.tryParse(value)!;
   if (enteredAmount != null) {
     // double effectiveAmount;

     if (selectedPaymentMethod == 'Razorpay') {
       effectiveAmount = enteredAmount * 0.98; // Deduct 2% for online payments
     } else {
       effectiveAmount = enteredAmount; // No deduction for cash payments
     }

     _deductedAmountController.add(effectiveAmount);

     double goldPrice = double.tryParse(price22k.replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0;
     goldAcquired = effectiveAmount / goldPrice;
     _goldWeightController.add(goldAcquired);

     print("✅ Payment: $selectedPaymentMethod | Entered: $enteredAmount | Effective: $effectiveAmount | Gold: $goldAcquired");
   }
 }




 void debugStreamValues() {
   _deductedAmountController.stream.listen((data) {
     print("💰 Stream Debug: Deducted Amount Updated: $data");
   });

   _goldWeightController.stream.listen((data) {
     print("📏 Stream Debug: Gold Weight Updated: $data grams");
   });
 }



 void _startRazorpayPayment(BuildContext context) async {

   debugStreamValues();


   String currentInput = selectedPaymentMethod == 'Razorpay' ? _onlineController.text : _offlineController.text;
   _updateGoldCalculation(currentInput);

   await Future.delayed(Duration(milliseconds: 500)); // Give streams time to update

   print("⚡ Calling Razorpay payment function...");
   _processRazorpayPayment(context,enteredAmount,goldAcquired);
 }






 Future<String?> getToken() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   return prefs.getString('auth_token'); // Returns the token or null if not found
 }


 bool _isProcessingPayment = false; // Add this flag

 Future<void> _processRazorpayPayment(BuildContext context,double deductedAmount,double goldAcquiredtx) async {
   if (_isProcessingPayment) return; // Prevent multiple calls
   _isProcessingPayment = true;

   try {


     String? token = await getToken();
     var headers = {
       'Accept': 'application/json',
       'Authorization': 'Bearer $token'
     };

     var request = http.MultipartRequest(
       'POST',
       Uri.parse('https://manish-jewellers.com/api/online-payment'),
     );

     String getCurrentDate() {
       return DateFormat('yyyy-MM-dd').format(DateTime.now());
     }

     request.fields.addAll({
       'plan_amount': deductedAmount.toString(),
       'plan_code': planCat.toString(),
       'plan_category': planName.toString(),
       'total_yearly_payment': '0',
       'total_gold_purchase': goldAcquiredtx.toString(),
       'start_date': getCurrentDate(),
       'installment_id': '0',
       'request_date': getCurrentDate(),
       'remarks': '',
       'no_of_months': GlobalPlan().months.toString()
     });

     print("API Request Fields: ${request.fields}");
     request.headers.addAll(headers);

     http.StreamedResponse response = await request.send();
     if (response.statusCode == 200) {
       String responseBody = await response.stream.bytesToString();
       var jsonResponse = json.decode(responseBody);

       if (jsonResponse['status'] == true) {
         String paymentUrl = jsonResponse['message'];
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => WebViewScreenTwo(redirectUrl: paymentUrl),
           ),
         );
       } else {

         print("API Error Response: $jsonResponse");
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Failed to generate payment URL")),
         );
       }
     } else {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Error: ${response.reasonPhrase}")),
       );
     }
   } catch (e) {
     print("Error: $e");
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text("Network error. Please try again.")),
     );
   } finally {
     _isProcessingPayment = false; // Reset flag after execution
   }
 }





 Widget _paymentConfirmationDialog(BuildContext context) {


   return Dialog(
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(16),
     ),
     child: StatefulBuilder(
       builder: (BuildContext context, StateSetter setState) {
         return Container(
           padding: EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: AppColors.glowingGold,
             borderRadius: BorderRadius.circular(16),
           ),
           child: SingleChildScrollView(
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
                         Navigator.pop(context);
                       },
                       child: Icon(Icons.close),
                     ),
                   ],
                 ),
                 SizedBox(height: 16),
                 // Gold Price display
                 Text("Gold Price: $price22k", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 SizedBox(height: 20),
                 if (selectedPaymentMethod == "Cash")
                   StreamBuilder<double>(
                     stream: _goldWeightController.stream,
                     initialData: 0.0,
                     builder: (context, snapshot) {
                       return Text(
                         "Gold Acquired: ${snapshot.data!.toStringAsFixed(4)} grams",
                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                       );
                     },
                   ),
                 SizedBox(height: 10),
               //   // Amount TextField with dynamic hintText
                 TextField(
                   controller: selectedPaymentMethod == 'Razorpay' ? _onlineController : _offlineController,
                   decoration: InputDecoration(
                     filled: true,
                     fillColor: Colors.white,
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(8),
                     ),
                     hintText: selectedPaymentMethod == 'Cash'
                         ? "Add minimum amount 100"
                         : selectedPaymentMethod == 'Razorpay'
                         ? "Enter amount (2% Tax applies)"
                         : "Enter amount",
                   ),
                   keyboardType: TextInputType.number,
                   onChanged: (value) {
                     print("TextField onChanged called with value: $value");
                     _updateGoldCalculation(value);
                   },
                 ),
               //   SizedBox(height: 16),
               // //  When Razorpay is selected, show the deducted total and new gold weight
               //   if (selectedPaymentMethod == 'Razorpay') ...[
               //     StreamBuilder<double>(
               //       stream: _deductedAmountController.stream,
               //       initialData: 0.0,
               //       builder: (context, snapshot) {
               //         return Text(
               //           "Total: ${snapshot.data!.toStringAsFixed(2)}",
               //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
               //         );
               //       },
               //     ),
               //     SizedBox(height: 16),
               //     StreamBuilder<double>(
               //       stream: _goldWeightController.stream,
               //       initialData: 0.0,
               //       builder: (context, snapshot) {
               //         return Text(
               //           "Gold Acquired: ${snapshot.data!.toStringAsFixed(4)} grams",
               //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
               //         );
               //       },
               //     ),
               //   ],
                 SizedBox(height: 16),
                 // Payment Options
                 Wrap(
                   alignment: WrapAlignment.center,
                   spacing: 10, // Items के बीच gap
                   runSpacing: 10, // Lines के बीच gap
                   children: [
                     // Row(
                     //   mainAxisSize: MainAxisSize.min,
                     //   children: [
                     //     Radio<String>(
                     //       value: 'Razorpay',
                     //       groupValue: selectedPaymentMethod,
                     //       onChanged: (value) {
                     //         setState(() {
                     //           selectedPaymentMethod = value!;
                     //           _updateGoldCalculation(_onlineController.text);
                     //         });
                     //       },
                     //     ),
                     //     Text("Razorpay"),
                     //   ],
                     // ),
                     Row(
                       mainAxisSize: MainAxisSize.min,
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
                     // Row(
                     //   mainAxisSize: MainAxisSize.min,
                     //   children: [
                     //     Radio<String>(
                     //       value: 'Scan QR',
                     //       groupValue: selectedPaymentMethod,
                     //       onChanged: (value) {
                     //         setState(() {
                     //           selectedPaymentMethod = value!;
                     //         });
                     //        _showQRDialog(context);
                     //       },
                     //     ),
                     //     Text("Scan QR"),
                     //   ],
                     // ),
                   ],
                 ),
                 SizedBox(height: 16),
                 // Terms and Conditions Checkbox with clickable text
             
                 SizedBox(height: 16),
                 // Submit Button (only enabled if termsAccepted is true)
                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.black,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(8),
                       ),
                     ),
                     onPressed:  () {
                       if (selectedPaymentMethod == 'Cash') {
                         String offlineAmount = _offlineController.text.trim();
                         double? amount = double.tryParse(offlineAmount);
                         if (amount == null || amount < 100) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text("Amount must be greater than 100 for cash payments.")),
                           );
                           return;
                         } else {

                           payOffline(context, offlineAmount,planCat.toString(),planName.toString(), goldAcquired.toString()); // adjust as needed


                         }
                       }

                       // else if (selectedPaymentMethod == 'Razorpay') {
                       //   String onlineAmount = _onlineController.text.trim();
                       //   if (onlineAmount.isNotEmpty) {
                       //
                       //     // _updateGoldCalculation(_offlineController.text);
                       //     // Future.delayed(Duration(milliseconds: 300), () {
                       //     //   _processRazorpayPayment(context);
                       //     // });
                       //
                       //     _startRazorpayPayment(context);
                       //     //_processRazorpayPayment(context);
                       //     print('razorpay');
                       //   } else {
                       //     ScaffoldMessenger.of(context).showSnackBar(
                       //       SnackBar(content: Text("Please enter a valid amount for online payment")),
                       //     );
                       //   }
                       // }
                       //
                       // else if (selectedPaymentMethod == 'Scan QR') {
                       //
                       //   // Navigator.push(
                       //   //   context,
                       //   //   MaterialPageRoute(
                       //   //     builder: (context) => PaymentScreen(),
                       //   //   ),
                       //   // );
                       //
                       // }


                     },
                         // Button is disabled if terms are not accepted
                     child: Text(
                       "Submit",
                       style: TextStyle(color: Colors.white),
                     ),
                   ),
                 ),
               ],
             ),
           ),
         );
       },
     ),
   );
 }



 @override
 void dispose() {
   _offlineController.removeListener(_calculateGoldWeight);  // Properly remove the listener
   _offlineController.dispose();
   _goldWeightController.close();
   _deductedAmountController.close();
   _onlineController.dispose();

   super.dispose();
 }

  @override
  Widget build(BuildContext context) {
    // Define content for each plan



    String planTitle = '';
    String planDescription = '';
    String planDuration = '';
    String planDetails = '';
    String details2 = '';

    if (widget.planId == 1) {
      planTitle = 'First Plan';
      planDuration = '13 Months (12+1)';
      planDescription = 'Invest for 12 months, & we pay your 13th installment!';
      planDetails = "Details: Customers pay for 12 \nmonths and Manish Jewellers adds\n the installment.The amount added \nwill be based on the monthly \naverage of the customers's install\n-ments.";
      details2 = 'Example: If a customer pays \nRs10,000 per month for 12 months\nManish Jewellers will contribute \n Rs10,000 as the 13th installment.';// Example text for plan 1
    } else if (widget.planId == 2) {
      planTitle = 'Second Plan';
      planDuration = '20 Months (18+2)';
      planDescription = 'Invest for 18 months, & we pay your 19–20th installment!';
      planDetails = "Details: Customers pay for 18 months\nand Manish Jewellers add the \n installment.The amount added will be\n based on the monthly average of the \ncustomer's installments.";
      details2 = "Example: If a customer pays Rs10,000 \nper month for 18 months, Manish \nJewellers will contribute Rs10,000 \nas the 19th installment, and Rs10,000 \nas the 20th installment.";// Example text for plan 2
    } else {
      planTitle = 'Third Plan';
      planDuration = '28 Months (24+4)';
      planDescription = 'Invest for 24 months, & we pay your 25–28th installment!';
      planDetails = "Details: Customers pay for 24 months\nand Manish Jewellers add the \ninstallment.The amount added will be \nbased on the monthly average of the\n customer's installments."; // Example text for plan 3
      details2 = "Example: If a customer pays Rs10,000 \nper month for 24 months, Manish\n Jewellers will contribute 25th,26th,\n27th and 28th installment.\n(i.e. 10,000x4 =Rs40,0000)";
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Select",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      "Investment Plans",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              children: [
                 SizedBox(height: 20,),
                _buildPlanCard(context, planTitle, planDuration, planDescription, planDetails, details2),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: Container(
      //   decoration: const BoxDecoration(
      //     borderRadius: BorderRadius.only(topRight: Radius.circular(500),topLeft: Radius.circular(500),),
      //     color: Color(0xfff2f2f2),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.grey,
      //         offset: Offset(5.0, 10.0), //(x,y)
      //         blurRadius: 20.0,
      //       ),
      //     ],
      //   ),
      //   child: ClipRRect(
      //     borderRadius: const BorderRadius.only(topRight: Radius.circular(180),topLeft: Radius.circular(180),),
      //     child: BottomNavigationBar(
      //             type: BottomNavigationBarType.fixed,
      //             backgroundColor: AppColors.glowingGold, // Adjust your custom color
      //             selectedItemColor: Colors.blueGrey,
      //             unselectedItemColor: Colors.black54,
      //             showSelectedLabels: false,
      //             showUnselectedLabels: false,
      //       items: [
      //         BottomNavigationBarItem(
      //           icon: Transform.translate(
      //             offset: const Offset(0, 8), // Shift the icon downward by 8 pixels
      //             child: Padding(
      //                 padding: EdgeInsets.only(left: 30),
      //                 child: Image.asset('assets/images/home.png',fit: BoxFit.cover,width: 50,height: 50)),
      //           ),
      //           label: 'Home',
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Transform.translate(
      //             offset: const Offset(0, 8), // Shift the icon downward by 8 pixels
      //             child: Image.asset('assets/images/payment.png',fit: BoxFit.cover,width: 50,height: 50,),
      //           ),
      //           label: 'Earnings',
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Transform.translate(
      //             offset: const Offset(0, 8), // Shift the icon downward by 8 pixels
      //             child: Image.asset('assets/images/loan.png',fit: BoxFit.cover,width: 50,height: 50,),
      //           ),
      //           label: 'Payments',
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Transform.translate(
      //             offset: const Offset(0, 8), // Shift the icon downward by 8 pixels
      //             child: Image.asset('assets/images/noti.png',fit: BoxFit.cover,width: 50,height: 50,),
      //           ),
      //           label: 'Notifications',
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Transform.translate(
      //             offset: const Offset(0, 8), // Shift the icon downward by 8 pixels
      //             child: Padding(
      //                 padding: EdgeInsets.only(right: 30),
      //                 child: Image.asset('assets/images/pro.png',fit: BoxFit.cover,width: 50,height: 50,)),
      //           ),
      //           label: 'Profile',
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String title, String duration, String description, String details, String details2) {
    return GestureDetector(
      onTap: () {
        // Add your navigation logic if needed
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: MediaQuery.of(context).size.height/1.5,
            decoration: BoxDecoration(
              color: AppColors.glowingGold, // You can customize this color
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
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
                              Text(
                                title,
                                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,height: 1),
                              ),
                          SizedBox(height: 5,),
                          Text(
                             duration,
                            style: const TextStyle(fontSize: 14, color: Colors.black,),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.glowingGold,
                            backgroundImage: AssetImage('assets/images/check.png'),
                          ),
                          SizedBox(height: 15,),
                        ],
                      )
                    ],
                  ),
              
                  SizedBox(height: 8),
                  Text(
                    description,
                    softWrap: true,
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 12),
              
                  Row(
                    children: [
                     // Icon(Icons.circle,size: 7,color: Colors.black,),
                     //  SizedBox(width: 3,),
                      Expanded(
                        child: Text(
                          details,
                          softWrap: true,
                          style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black54),
                        ),
                      ),
              
                    ],
              
                  ),
              
                  const SizedBox(height: 10),
              
                  Row(
                    children: [
                      // Icon(Icons.circle,size: 7,color: Colors.black,),
                      // SizedBox(width: 3,),
                      Expanded(
                        child: Text(
                          details2,
                          softWrap: true,
                          style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black54),
                          textAlign: TextAlign.justify,
                        ),
                      ),
              
                    ],
              
                  ),
              
                  SizedBox(
                    height: 20,
                  ),
              
              
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Note: From the second installment onward, a minimum payment of 2500 is required and must be upheld as the average payment amount.",
                          softWrap: true, // This is enabled by default
                        style: TextStyle(fontSize: 10,color: Colors.black87),),
                      ),
                    ],
                  ),
              
                  SizedBox(height: 20,),


                  Row(
                    children: [
                      Checkbox(
                        value: termsAccepted,
                        onChanged: (bool? value) {
                          setState(() {
                            termsAccepted = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: "I agree to the ",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Terms and Conditions",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Terms and Conditions"),
                                          content: SingleChildScrollView(
                                            child: Text(
                                              "Manish Jewellers Terms and Conditions for Investment and Gold Credits Services\n\n"
                                                  "Effective Date: 02/07/2025\n\n"
                                                  "1. Introduction\n"
                                                  "By investing funds for the acquisition of gold and/or obtaining Gold Credits from Manish Jewellers, you (“Customer” or “Investor”) agree to be bound by the following Terms and Conditions. Please review these terms carefully. If you do not agree with any part of these Terms, please refrain from using our services.\n\n"
                                                  "2. Definitions\n"
                                                  "- Investment: The act of providing funds specifically for the acquisition of gold at prevailing market rates.\n"
                                                  "- Gold Acquired: The physical gold purchased or allocated as a result of the investment.\n"
                                                  "- Gold Credits: The credit facility provided by Manish Jewellers, which may be secured by the gold acquired.\n"
                                                  "- Collateral: Gold acquired through the investment that may be used to secure Gold Credits.\n\n"
                                                  "3. Investment and Gold Acquisition\n"
                                                  "- The funds provided as investment will be used exclusively for purchasing gold according to current market conditions.\n"
                                                  "- The actual quantity, purity, and weight of the gold acquired will be confirmed at the time of purchase and may be subject to market fluctuations.\n"
                                                  "- The Customer acknowledges that the price of gold is volatile, and the value of the gold acquired may change over time.\n\n"
                                                  "4. Gold Credits Terms\n"
                                                  "- Gold Credits approval is subject to the value and availability of the gold acquired as collateral.\n"
                                                  "- The maximum amount of Gold Credits, applicable rates, and terms will be determined based on the current market value of the gold and a credit evaluation performed by Manish Jewellers.\n"
                                                  "- The Customer agrees to furnish all required documentation and consent to necessary credit and financial checks.\n\n"
                                                  "5. Fees, Charges, and Repayment Terms for Gold Credits\n"
                                                  "- Fees will be charged on the outstanding Gold Credits balance at a rate established by Manish Jewellers, which may be adjusted in response to market conditions.\n"
                                                  "- Repayment terms, including schedules and any applicable charges, will be clearly communicated at the time of Gold Credits approval.\n"
                                                  "- Failure to adhere to the agreed terms may result in additional charges, an increase in rates, or, in extreme cases, the liquidation of the collateral.\n\n"
                                                  "6. Risk Disclosure\n"
                                                  "- Investing in gold and utilizing Gold Credits facilities involve inherent risks, including but not limited to market volatility, fluctuations in gold prices, and credit risks.\n"
                                                  "- Manish Jewellers does not guarantee the stability of gold prices or the future value of the investment, and the Customer accepts all associated risks.\n\n"
                                                  "7. Limitation of Liability\n"
                                                  "- Manish Jewellers shall not be liable for any direct, indirect, incidental, or consequential damages resulting from the use of our investment or Gold Credits services.\n"
                                                  "- Under no circumstances shall Manish Jewellers be responsible for any loss or damage arising from fluctuations in gold prices or other market conditions.\n\n"
                                                  "8. Amendments to Terms and Conditions\n"
                                                  "- Manish Jewellers reserves the right to modify or update these Terms and Conditions at any time without prior notice.\n"
                                                  "- Continued use of our services after any such modifications constitutes acceptance of the updated terms.\n\n"
                                                  "9. Governing Law and Dispute Resolution\n"
                                                  "- These Terms and Conditions shall be governed by and construed in accordance with the laws of [Insert Jurisdiction].\n"
                                                  "- Any disputes arising from or in connection with these Terms shall be subject to the exclusive jurisdiction of the courts in [Insert Jurisdiction] or resolved via arbitration, as agreed upon by the parties.\n\n"
                                                  "10. Customer Obligations\n"
                                                  "- The Customer agrees to provide accurate, complete, and timely information as required during the investment or Gold Credits application process.\n"
                                                  "- The Customer is responsible for maintaining the confidentiality of any credentials or personal data associated with their account.\n\n"
                                                  "11. Confidentiality and Privacy\n"
                                                  "- All personal and financial information provided will be handled in accordance with our Privacy Policy and applicable data protection laws.\n"
                                                  "- Manish Jewellers commits to protecting the confidentiality of the Customer’s information and will not disclose it to third parties without prior consent, except as required by law.\n\n"
                                                  "12. Miscellaneous\n"
                                                  "- These Terms and Conditions constitute the entire agreement between the Customer and Manish Jewellers regarding the subject matter herein.\n"
                                                  "- If any provision of these Terms is deemed invalid or unenforceable, the remaining provisions shall remain in full force and effect.\n"
                                                  "- By proceeding with an investment or Gold Credits application, the Customer confirms that they have read, understood, and agreed to these Terms and Conditions.",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("Close"),
                                            ),
                                          ],
                                        );
                                      },
                                    );


                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              
              
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                     // width: screenWidth * 0.8,
                      height: 40,
                      child: ElevatedButton(
              
                        onPressed: termsAccepted ? () {
              
              
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return _paymentConfirmationDialog(context);
                              },
                            );
              
                        }
                            : null,
              
                        // onPressed: ()  {
                        //
                        //  // payOffline();
                        //   showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       return _paymentConfirmationDialog(context);
                        //     },
                        //   );
                        //
                        //
                        //   ///
                        //
                        //
                        // },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
              
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.black,
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}

void _showQRDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Container(
        color: AppColors.white90,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            color: AppColors.glowingGold,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Scan to Pay",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Image.asset(
                    'assets/images/qr.png', // Replace with your actual QR code image path
                    height: 200,
                    width: 200,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Scan this QR code to complete the payment.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Close"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token'); // Returns the token or null if not found
}

// Example usage in a different screen:
Future<void> payOffline(BuildContext context, String amount,String planCode,String planCategory,String goldwt) async {

  String? token = await getToken();

  String getCurrentDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  if (token != null) {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', // Use the token in the Authorization header
    };

    var request = http.MultipartRequest('POST', Uri.parse('https://manish-jewellers.com/api/payments'));
    request.fields.addAll({
      'plan_amount': amount,
      'plan_code': planCode,
      'plan_category': planCategory,
      'total_yearly_payment': '0',
      'total_gold_purchase': goldwt,
      'start_date': getCurrentDate().toString(),
      'installment_id': '0',
      'request_date': getCurrentDate().toString(),
      'remarks': '',
      'no_of_months': GlobalPlan().months.toString()
    });

    request.headers.addAll(headers);

    print('Request Fields: ${jsonEncode(request.fields)}');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {

      print("current Date = ${getCurrentDate().toString()}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Payment Successful!",
            style: TextStyle(color: Colors.white),  // White text for visibility
          ),
          backgroundColor: Colors.black,  // Black background
          duration: Duration(seconds: 2),
        ),
      );

      print(await response.stream.bytesToString());
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentHistoryList(),
        ),
      );

      print('yes');
    }
    else {
      print(response.reasonPhrase);
      print('no status ${response.statusCode}');
    }


  } else {
    print('Token not found. User might need to log in again.');
  }
}



 class RoundedCornerClipper extends CustomClipper<RRect> {
   @override
  RRect getClip(Size size) {
 return RRect.fromRectAndRadius(
 Rect.fromLTWH(0, 0, size.width, size.height),
 Radius.circular(20.0),
 );
}

@override
bool shouldReclip(CustomClipper<RRect> oldClipper) => false;
}




class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, 40); // Start lower on the left edge for a smoother curve

    final double controlPointX = size.width / 2;
    final double controlPointY = -40; // Make the curve dip lower for a pronounced effect

    path.quadraticBezierTo(
      controlPointX,
      controlPointY,
      size.width,
      40, // End lower on the right edge for symmetry
    );
    path.lineTo(size.width, size.height); // Line to the bottom right corner
    path.lineTo(0, size.height); // Line to the bottom left corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
