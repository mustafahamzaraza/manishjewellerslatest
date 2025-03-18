// import 'package:flutter/material.dart';
// import 'package:manishjeweleers/homescreen.dart';
// import 'package:manishjeweleers/new/ledger.dart';
// import 'package:manishjeweleers/utils/color.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// class PaymentHistoryList extends StatefulWidget {
//   const PaymentHistoryList({super.key});
//
//   @override
//   State<PaymentHistoryList> createState() => _PaymentHistoryListState();
// }
//
// class _PaymentHistoryListState extends State<PaymentHistoryList> {
//
//
//   @override
//   void initState() {
//     super.initState();
//     fetchPayments(); // Call API on widget initialization
//     print("initttttttt");
//   }
//
//
//   Future<String?> getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token'); // Returns the token or null if not found
//   }
//
// // Example usage in a different screen:
//   Future<void> payOffline(BuildContext context, String amount) async {
//     String? token = await getToken();
//     if (token != null) {
//       var headers = {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token', // Use the token in the Authorization header
//       };
//
//       var request = http.MultipartRequest('POST', Uri.parse('https://manish-jewellers.com/api/payments'));
//       request.fields.addAll({
//         'plan_amount': amount,
//         'plan_code': 'INR',
//         'plan_category': 'First Installment Plan',
//         'total_yearly_payment': '0',
//         'total_gold_purchase': '00',
//         'start_date': '2025-01-27',
//         'installment_id': '1',
//         'request_date': '2025-01-27',
//         'remarks': ''
//       });
//
//       request.headers.addAll(headers);
//
//       http.StreamedResponse response = await request.send();
//
//       if (response.statusCode == 201) {
//         print(await response.stream.bytesToString());
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => PaymentHistoryList(),
//           ),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "Payment Successful Successful!",
//               style: TextStyle(color: Colors.white),  // White text for visibility
//             ),
//             backgroundColor: Colors.black,  // Black background
//             duration: Duration(seconds: 2),
//           ),
//         );
//         print('yes');
//       }
//       else {
//         print(response.reasonPhrase);
//         print('no status ${response.statusCode}');
//       }
//
//
//     } else {
//       print('Token not found. User might need to log in again.');
//     }
//   }
//
//
//
//   final List<Map<String, String>> demoPayments = [
//     {
//       'planName': 'GP12',
//       'paymentDate': 'may 3rd',
//       'paymentTime': '10:30 AM',
//       'amountPaid': '3m ago',
//
//     },
//     {
//       'planName': 'GP18',
//       'paymentDate': '2025-01-12',
//       'paymentTime': '2:00 PM',
//       'amountPaid': '₹6000',
//       'paymentMethod': 'Cash',
//     },{
//       'planName': 'GP12',
//       'paymentDate': 'may 3rd',
//       'paymentTime': '10:30 AM',
//       'amountPaid': '3m ago',
//
//     },
//     {
//       'planName': 'GP18',
//       'paymentDate': '2025-01-12',
//       'paymentTime': '2:00 PM',
//       'amountPaid': '₹6000',
//       'paymentMethod': 'Cash',
//     },{
//       'planName': 'GP12',
//       'paymentDate': 'may 3rd',
//       'paymentTime': '10:30 AM',
//       'amountPaid': '3m ago',
//
//     },
//     {
//       'planName': 'GP18',
//       'paymentDate': '2025-01-12',
//       'paymentTime': '2:00 PM',
//       'amountPaid': '₹6000',
//       'paymentMethod': 'Cash',
//     },
//
//   ];
//
//   int _currentIndex = 0;
//
//   final List<String> imgList = [
//     'https://via.placeholder.com/600x400/FF5733/FFFFFF?text=Image+1',
//     'https://via.placeholder.com/600x400/33FF57/FFFFFF?text=Image+2',
//     'https://via.placeholder.com/600x400/3357FF/FFFFFF?text=Image+3',
//   ];
//
//
//
//
//
//   Future<void> fetchPayments() async {
//     String? token = await getToken();
//     if (token != null) {
//       var headers = {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//         // Use the token in the Authorization header
//       };
//       var request = http.MultipartRequest(
//         'GET',
//         Uri.parse('https://manish-jewellers.com/api/installment-payment/list'),
//       );
//       request.fields.addAll({
//         'plan_amount': '150.75',
//         'plan_code': 'INR',
//         'plan_category': 'First Installment Plan',
//         'total_yearly_payment': '0',
//         'total_gold_purchase': '100',
//         'start_date': '2025-01-28',
//         'installment_id': '1',
//         'request_date': '2025-01-28',
//         'remarks': '',
//       });
//       request.headers.addAll(headers);
//
//       try {
//         http.StreamedResponse response = await request.send();
//
//         if (response.statusCode == 200) {
//           // Print the response body to the console
//         //  print(await response.stream.bytesToString());
//           debugPrint("full response ${await response.stream.bytesToString()}");
//         } else {
//           // Print the error reason to the console
//           print('Error: ${response.reasonPhrase} status ${response.statusCode}');
//         }
//       } catch (e) {
//         print('Exception: $e ');
//       }
//
//     }
//     else{
//        print("no token");
//     }
//
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.textDark,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Column(
//             children: [
//
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 30,horizontal: 10),
//                 child: Row(
//                   children: [
//                     RichText(
//                       text: const TextSpan(
//                         text: '  Welcome back\n',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: '\t\tAlfredo Toress',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Spacer(),
//                     InkWell(
//                       onTap: (){
//                         fetchPayments();
//                         print('tapped');
//                       },
//                       child: CircleAvatar(
//                         radius: 30,
//                         backgroundImage:
//                         const AssetImage('assets/images/profile.jpg',),
//                         backgroundColor: AppColors.textDark,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//
//
//               CarouselSlider(
//                 options: CarouselOptions(
//                   enlargeCenterPage: true,
//                   autoPlay: true,
//                   aspectRatio: 16 / 9,
//                   viewportFraction: 0.8,
//                   onPageChanged: (index, reason) {
//                     setState(() {
//                       _currentIndex = index;
//                     });
//                   },
//                 ),
//                 items: imgList.map((item) {
//                   return Container(
//                     margin: EdgeInsets.symmetric(horizontal: 3),
//                     child: Card(
//                       color: AppColors.glowingGold,
//                       margin: const EdgeInsets.symmetric(vertical: 25),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 15, vertical: 10),
//                                 child: Row(
//                                   children: [
//                                     RichText(
//                                       text: const TextSpan(
//                                         text: '\$5000.50\n',
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 19,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         children: [
//                                           TextSpan(
//                                             text: 'Balance',
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.normal,
//                                               fontStyle: FontStyle.italic,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const Spacer(),
//                                     const Image(
//                                       image: AssetImage('assets/images/check.png'),
//                                       height: 50,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(height: 20,),
//                               const Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       "Start Date",
//                                       style: TextStyle(
//                                         color: AppColors.textLight,
//                                         fontSize: 14,
//                                         height: 1
//                                       ),
//                                     ),
//                                     Text(
//                                       "First Plan",
//                                       style: TextStyle(
//                                         color: AppColors.textLight,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14,
//                                         height: 1
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//
//                                   children: [
//                                     Text(
//                                       "End Date",
//                                       style: TextStyle(
//                                         color: AppColors.textLight,
//                                         fontSize: 12,
//                                         height: 1
//                                       ),
//                                     ),
//                                     Text(
//                                       "Monthly Avg \$100",
//                                       style: TextStyle(
//                                         color: AppColors.textLight,
//                                         fontSize: 12,
//                                         height: 1
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//
//
//
//
//               // Pagination dots
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: imgList.asMap().entries.map((entry) {
//                   return GestureDetector(
//                     child: Container(
//                       width: 8.0,
//                       height: 8.0,
//                       margin: EdgeInsets.symmetric(horizontal: 4.0),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: _currentIndex == entry.key
//                             ? Colors.black
//                             : Colors.black54,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   rowContainer("Payment","assets/images/a.png",(){
//
//                   }),
//                   rowContainer("Ledger","assets/images/b.png",(){
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => LedgerHistoryScreen()),
//                     );
//                   }),
//                   rowContainer("Loan","assets/images/c.png",(){}),
//                   rowContainer("Details","assets/images/d.png",(){}),
//                 ],
//               ),
//
//               //
//               //
//               //
//               //  // Search and transaction section
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Row(
//                   children: [
//                     SizedBox(width: 20,),
//                     Container(
//                       alignment: Alignment.center,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black, width: 1),
//                         borderRadius: BorderRadius.circular(10),
//                         color: Color(0xffcdcdcd),
//                       ),
//                       width: 280,
//                       child: TextFormField(
//                         decoration: const InputDecoration(
//                           hintText: 'Search here...',
//                           suffixIcon: Icon(Icons.search,color: Colors.black26,),
//                           border: InputBorder.none,
//                           hintStyle: TextStyle(color: Colors.black26)
//                           //contentPadding: EdgeInsets.symmetric(vertical: 0),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10,),
//                     const Image(
//                       image: AssetImage('assets/images/e.png'),
//                       height: 65,
//                       width: 65,
//                     ),
//                   ],
//                 ),
//               ),
//
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Transaction",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     RichText(
//                       text: const TextSpan(
//                         text: 'Sort by',
//                         style: TextStyle(
//                           color: AppColors.textLight,
//                           fontWeight: FontWeight.w400,
//                           fontSize: 13,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: '\tLatest',
//                             style: TextStyle(
//                               color: AppColors.textLight,
//                               fontSize: 13,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               // ListView inside Flexible to avoid overflow
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: demoPayments.length,
//                   itemBuilder: (context, index) {
//                     final payment = demoPayments[index];
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                       child: Column(
//                         children: [
//                           ListTile(
//                             leading: const Image(
//                               image: AssetImage('assets/images/circular.jpg'),
//                               height: 50,
//                             ),
//                             title: Text(
//                               payment['planName']!,
//                               style: const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text(
//                                 "${payment['paymentDate']} at ${payment['paymentTime']}"),
//                             trailing: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(payment['amountPaid']!),
//                                 Text(
//                                   payment['paymentMethod'] == 'Cash'
//                                       ? 'Cash'
//                                       : 'Online',
//                                   style: const TextStyle(
//                                     color: Colors.green,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Divider(color: AppColors.textLight,indent: 1,thickness: 1,endIndent: 1,),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   Widget rowContainer(String text,String image,VoidCallback ontap){
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return _paymentConfirmationDialog(context);
//               },
//             );
//
//
//           },
//           child: Container(
//             margin: EdgeInsets.symmetric(horizontal: 12,vertical:10),
//             //padding: EdgeInsets.symmetric(horizontal: 10,vertical:10),
//             height: 60,
//             width:  60,
//             decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15)
//                 ,image: DecorationImage(image: AssetImage(image),)
//             ),
//           ),
//         ),
//         Text(text,style: TextStyle(fontWeight: FontWeight.bold),)
//       ],
//     );
//   }
//
//   Widget _paymentConfirmationDialog(BuildContext context) {
//
//     String selectedPaymentMethod = 'Razorpay';
//
//     final TextEditingController _onlineController = TextEditingController();
//     final TextEditingController _offlineController = TextEditingController();
//
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: StatefulBuilder(
//         builder: (BuildContext context, StateSetter setState) {
//           return Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.glowingGold, // Background color
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Title and close button
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Payment\nConfirmation",
//                       style: TextStyle(
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context); // Close dialog
//                       },
//                       child: Icon(Icons.close),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//
//                 // Subheading
//                 Text(
//                   "First Loan",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//
//                 // Input instructions
//                 Text(
//                   "ENTER AMOUNT (MIN \$100)",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//
//                 // Amount input field
//                 // TextField(
//                 //   decoration: InputDecoration(
//                 //     filled: true,
//                 //     fillColor: Colors.white,
//                 //     border: OutlineInputBorder(
//                 //       borderRadius: BorderRadius.circular(8),
//                 //     ),
//                 //     hintText: "*****",
//                 //   ),
//                 //   keyboardType: TextInputType.number,
//                 // ),
//                 TextField(
//                   controller: selectedPaymentMethod == 'Razorpay'
//                       ? _onlineController
//                       : _offlineController,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     hintText: "*****",
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 SizedBox(height: 16),
//
//                 // Payment options
//                 Row(
//                   children: [
//                     // Razorpay option
//                     Row(
//                       children: [
//                         Radio<String>(
//                           value: 'Razorpay',
//                           groupValue: selectedPaymentMethod,
//                           onChanged: (value) {
//                             setState(() {
//                               selectedPaymentMethod = value!;
//                             });
//                           },
//                         ),
//                         Text("Razorpay"),
//                       ],
//                     ),
//                     SizedBox(width: 16),
//                     // Cash option
//                     Row(
//                       children: [
//                         Radio<String>(
//                           value: 'Cash',
//                           groupValue: selectedPaymentMethod,
//                           onChanged: (value) {
//                             setState(() {
//                               selectedPaymentMethod = value!;
//                             });
//                           },
//                         ),
//                         Text("Cash"),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//
//                 // Submit button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: () {
//                       if (selectedPaymentMethod == 'Cash') {
//                         String offlineAmount = _offlineController.text.trim();
//                         if (offlineAmount.isNotEmpty) {
//                           payOffline(context, offlineAmount);
//                         } else {
//                           print("Please enter a valid amount for offline payment");
//                         }
//                       } else {
//                         String onlineAmount = _onlineController.text.trim();
//                         if (onlineAmount.isNotEmpty) {
//                           print("Processing online payment with amount: $onlineAmount");
//                           // Add your online payment logic here.
//
//                           //no api
//
//                           Navigator.pop(context);
//                         } else {
//                           print("Please enter a valid amount for online payment");
//                         }
//                       }
//                     },
//                     child: Text(
//                       "Submit",
//                       style: TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//
// }
