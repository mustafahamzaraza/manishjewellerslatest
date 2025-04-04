// import 'package:flutter/material.dart';
// import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment/phonepg.dart';
//
//
// class CheckoutPage extends StatefulWidget {
//   const CheckoutPage({super.key});
//
//   @override
//   State<CheckoutPage> createState() => _CheckoutPageState();
// }
//
// class _CheckoutPageState extends State<CheckoutPage> {
//   TextEditingController textEditingController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Checkout"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: textEditingController,
//               decoration: InputDecoration(
//                   hintText: "Enter amount", border: OutlineInputBorder()),
//             ),
//             ElevatedButton(
//                 onPressed: () {
//                   PhonepePg(context: context, amount: int.parse(textEditingController.text)).init();
//                 },
//                 child: const Text("Check out"))
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment/upimer.dart';
// // import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
// //
// //
// // class MerchantApp extends StatefulWidget {
// //   const MerchantApp({super.key});
// //
// //   @override
// //   State<MerchantApp> createState() => MerchantScreen();
// // }
// //
// // class MerchantScreen extends State<MerchantApp> {
// //   String request = "";
// //   String appSchema = "flutterDemoApp";
// //
// //   Map<String, String> headers = {};
// //   List<String> environmentList = <String>['SANDBOX', 'PRODUCTION'];
// //   bool enableLogs = true;
// //   Object? result;
// //   String environmentValue = 'SANDBOX';
// //   String merchantId = "MANISHJEWELUAT";
// //   String flowId = ""; // Pass the user id or the unique string
// //   String packageName = "com.phonepe.simulator";
// //
// //   void initPhonePeSdk() {
// //     PhonePePaymentSdk.init(environmentValue, merchantId, flowId, enableLogs)
// //         .then((isInitialized) => {
// //       setState(() {
// //         result = 'PhonePe SDK Initialized - $isInitialized';
// //       })
// //     })
// //         .catchError((error) {
// //       handleError(error);
// //       return <dynamic>{};
// //     });
// //   }
// //
// //   void startTransaction() async {
// //     try {
// //       PhonePePaymentSdk.startTransaction(request, appSchema)
// //           .then((response) => {
// //         setState(() {
// //           if (response != null) {
// //             String status = response['status'].toString();
// //             String error = response['error'].toString();
// //             if (status == 'SUCCESS') {
// //               result = "Flow Completed - Status: Success!";
// //             } else {
// //               result =
// //               "Flow Completed - Status: $status and Error: $error";
// //             }
// //           } else {
// //             result = "Flow Incomplete";
// //           }
// //         })
// //       })
// //           .catchError((error) {
// //         handleError(error);
// //         return <dynamic>{};
// //       });
// //     } catch (error) {
// //       handleError(error);
// //     }
// //   }
// //
// //   void getInstalledUpiAppsForiOS() {
// //     PhonePePaymentSdk.getInstalledUpiAppsForiOS()
// //         .then((apps) => {
// //       setState(() {
// //         result = 'getUPIAppsInstalledForIOS - $apps';
// //
// //         // For Usage
// //         List<String> stringList = apps
// //             ?.whereType<
// //             String>() // Filters out null and non-String elements
// //             .toList() ??
// //             [];
// //
// //         // Check if the string value 'Orange' exists in the filtered list
// //         String searchString = 'PHONEPE';
// //         bool isStringExist = stringList.contains(searchString);
// //
// //         if (isStringExist) {
// //           print('$searchString app exist in the device.');
// //         } else {
// //           print('$searchString app does not exist in the list.');
// //         }
// //       })
// //     })
// //         .catchError((error) {
// //       handleError(error);
// //       return <dynamic>{};
// //     });
// //   }
// //
// //   void getInstalledApps() {
// //     if (Platform.isAndroid) {
// //       getInstalledUpiAppsForAndroid();
// //     } else {
// //       getInstalledUpiAppsForiOS();
// //     }
// //   }
// //
// //   void getInstalledUpiAppsForAndroid() {
// //     PhonePePaymentSdk.getUpiAppsForAndroid()
// //         .then((apps) => {
// //       setState(() {
// //         if (apps != null) {
// //           Iterable l = json.decode(apps);
// //           List<UPIApp> upiApps = List<UPIApp>.from(
// //               l.map((model) => UPIApp.fromJson(model)));
// //           String appString = '';
// //           for (var element in upiApps) {
// //             appString +=
// //             "${element.applicationName} ${element.version} ${element.packageName}";
// //           }
// //           result = 'Installed Upi Apps - $appString';
// //         } else {
// //           result = 'Installed Upi Apps - 0';
// //         }
// //       })
// //     })
// //         .catchError((error) {
// //       handleError(error);
// //       return <dynamic>{};
// //     });
// //   }
// //
// //   void handleError(error) {
// //     setState(() {
// //       if (error is Exception) {
// //         result = error.toString();
// //       } else {
// //         result = {"error": error};
// //       }
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //           appBar: AppBar(
// //             title: const Text('Flutter Merchant Demo App'),
// //           ),
// //           body: SingleChildScrollView(
// //             child: Container(
// //               margin: const EdgeInsets.all(7),
// //               child: Column(
// //                 children: <Widget>[
// //                   TextField(
// //                     decoration: const InputDecoration(
// //                       border: OutlineInputBorder(),
// //                       hintText: 'Merchant Id',
// //                     ),
// //                     onChanged: (text) {
// //                       merchantId = text;
// //                     },
// //                   ),
// //                   TextField(
// //                     decoration: const InputDecoration(
// //                       border: OutlineInputBorder(),
// //                       hintText: 'Flow Id',
// //                     ),
// //                     onChanged: (text) {
// //                       flowId = text;
// //                     },
// //                   ),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                     children: <Widget>[
// //                       const Text('Select the environment'),
// //                       DropdownButton<String>(
// //                         value: environmentValue,
// //                         icon: const Icon(Icons.arrow_downward),
// //                         elevation: 16,
// //                         underline: Container(
// //                           height: 2,
// //                           color: Colors.black,
// //                         ),
// //                         onChanged: (String? value) {
// //                           setState(() {
// //                             environmentValue = value!;
// //                             if (environmentValue == 'PRODUCTION') {
// //                               packageName = "com.phonepe.app";
// //                             } else if (environmentValue == 'SANDBOX') {
// //                               packageName = "com.phonepe.simulator";
// //                             }
// //                           });
// //                         },
// //                         items: environmentList
// //                             .map<DropdownMenuItem<String>>((String value) {
// //                           return DropdownMenuItem<String>(
// //                             value: value,
// //                             child: Text(value),
// //                           );
// //                         }).toList(),
// //                       )
// //                     ],
// //                   ),
// //                   Visibility(
// //                       maintainSize: false,
// //                       maintainAnimation: false,
// //                       maintainState: false,
// //                       visible: Platform.isAndroid,
// //                       child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: <Widget>[
// //                             const SizedBox(height: 10),
// //                             Text("Package Name: $packageName"),
// //                           ])),
// //                   const SizedBox(height: 10),
// //                   Row(
// //                     children: <Widget>[
// //                       Checkbox(
// //                           value: enableLogs,
// //                           onChanged: (state) {
// //                             setState(() {
// //                               enableLogs = state!;
// //                             });
// //                           }),
// //                       const Text("Enable Logs")
// //                     ],
// //                   ),
// //                   const SizedBox(height: 10),
// //                   const Text(
// //                     'Warning: Init SDK is Mandatory to use all the functionalities*',
// //                     style: TextStyle(color: Colors.red),
// //                   ),
// //                   ElevatedButton(
// //                       onPressed: initPhonePeSdk, child: const Text('INIT SDK')),
// //                   const SizedBox(width: 5.0),
// //                   TextField(
// //                     decoration: const InputDecoration(
// //                       border: OutlineInputBorder(),
// //                       hintText: 'request',
// //                     ),
// //                     onChanged: (text) {
// //                       request = text;
// //                     },
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: <Widget>[
// //                         Expanded(
// //                             child: ElevatedButton(
// //                                 onPressed: startTransaction,
// //                                 child: const Text('Start Transaction'))),
// //                         const SizedBox(width: 5.0),
// //                       ]),
// //                   ElevatedButton(
// //                       onPressed: getInstalledApps,
// //                       child: const Text('Get Installed Apps')),
// //                   Text("Result: \n $result")
// //                 ],
// //               ),
// //             ),
// //           )),
// //     );
// //   }
// // }
// //
// //
// //
// //
// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment/upimer.dart';
// // // import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
// // //
// // //
// // // class MerchantApp extends StatefulWidget {
// // //   const MerchantApp({super.key});
// // //
// // //   @override
// // //   State<MerchantApp> createState() => MerchantScreen();
// // // }
// // //
// // // class MerchantScreen extends State<MerchantApp> {
// // //   String request = "";
// // //   String appSchema = "flutterDemoApp";
// // //
// // //   Map<String, String> headers = {};
// // //   List<String> environmentList = <String>['SANDBOX', 'PRODUCTION'];
// // //   bool enableLogs = true;
// // //   Object? result;
// // //   String environmentValue = 'SANDBOX';
// // //   String merchantId = "";
// // //   String flowId = ""; // Pass the user id or the unique string
// // //   String packageName = "com.phonepe.simulator";
// // //
// // //   void initPhonePeSdk() {
// // //     PhonePePaymentSdk.init(environmentValue, merchantId, flowId, enableLogs)
// // //         .then((isInitialized) => {
// // //       setState(() {
// // //         result = 'PhonePe SDK Initialized - $isInitialized';
// // //       })
// // //     })
// // //         .catchError((error) {
// // //       handleError(error);
// // //       return <dynamic>{};
// // //     });
// // //   }
// // //
// // //   void startTransaction() async {
// // //     try {
// // //       PhonePePaymentSdk.startTransaction(request, appSchema)
// // //           .then((response) => {
// // //         setState(() {
// // //           if (response != null) {
// // //             String status = response['status'].toString();
// // //             String error = response['error'].toString();
// // //             if (status == 'SUCCESS') {
// // //               result = "Flow Completed - Status: Success!";
// // //             } else {
// // //               result =
// // //               "Flow Completed - Status: $status and Error: $error";
// // //             }
// // //           } else {
// // //             result = "Flow Incomplete";
// // //           }
// // //         })
// // //       })
// // //           .catchError((error) {
// // //         handleError(error);
// // //         return <dynamic>{};
// // //       });
// // //     } catch (error) {
// // //       handleError(error);
// // //     }
// // //   }
// // //
// // //   void getInstalledUpiAppsForiOS() {
// // //     PhonePePaymentSdk.getInstalledUpiAppsForiOS()
// // //         .then((apps) => {
// // //       setState(() {
// // //         result = 'getUPIAppsInstalledForIOS - $apps';
// // //
// // //         // For Usage
// // //         List<String> stringList = apps
// // //             ?.whereType<
// // //             String>() // Filters out null and non-String elements
// // //             .toList() ??
// // //             [];
// // //
// // //         // Check if the string value 'Orange' exists in the filtered list
// // //         String searchString = 'PHONEPE';
// // //         bool isStringExist = stringList.contains(searchString);
// // //
// // //         if (isStringExist) {
// // //           print('$searchString app exist in the device.');
// // //         } else {
// // //           print('$searchString app does not exist in the list.');
// // //         }
// // //       })
// // //     })
// // //         .catchError((error) {
// // //       handleError(error);
// // //       return <dynamic>{};
// // //     });
// // //   }
// // //
// // //   void getInstalledApps() {
// // //     if (Platform.isAndroid) {
// // //       getInstalledUpiAppsForAndroid();
// // //     } else {
// // //       getInstalledUpiAppsForiOS();
// // //     }
// // //   }
// // //
// // //   void getInstalledUpiAppsForAndroid() {
// // //     PhonePePaymentSdk.getUpiAppsForAndroid()
// // //         .then((apps) => {
// // //       setState(() {
// // //         if (apps != null) {
// // //           Iterable l = json.decode(apps);
// // //           List<UPIApp> upiApps = List<UPIApp>.from(
// // //               l.map((model) => UPIApp.fromJson(model)));
// // //           String appString = '';
// // //           for (var element in upiApps) {
// // //             appString +=
// // //             "${element.applicationName} ${element.version} ${element.packageName}";
// // //           }
// // //           result = 'Installed Upi Apps - $appString';
// // //         } else {
// // //           result = 'Installed Upi Apps - 0';
// // //         }
// // //       })
// // //     })
// // //         .catchError((error) {
// // //       handleError(error);
// // //       return <dynamic>{};
// // //     });
// // //   }
// // //
// // //   void handleError(error) {
// // //     setState(() {
// // //       if (error is Exception) {
// // //         result = error.toString();
// // //       } else {
// // //         result = {"error": error};
// // //       }
// // //     });
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       home: Scaffold(
// // //           appBar: AppBar(
// // //             title: const Text('Flutter Merchant Demo App'),
// // //           ),
// // //           body: SingleChildScrollView(
// // //             child: Container(
// // //               margin: const EdgeInsets.all(7),
// // //               child: Column(
// // //                 children: <Widget>[
// // //                   TextField(
// // //                     decoration: const InputDecoration(
// // //                       border: OutlineInputBorder(),
// // //                       hintText: 'Merchant Id',
// // //                     ),
// // //                     onChanged: (text) {
// // //                       merchantId = text;
// // //                     },
// // //                   ),
// // //                   TextField(
// // //                     decoration: const InputDecoration(
// // //                       border: OutlineInputBorder(),
// // //                       hintText: 'Flow Id',
// // //                     ),
// // //                     onChanged: (text) {
// // //                       flowId = text;
// // //                     },
// // //                   ),
// // //                   Row(
// // //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // //                     children: <Widget>[
// // //                       const Text('Select the environment'),
// // //                       DropdownButton<String>(
// // //                         value: environmentValue,
// // //                         icon: const Icon(Icons.arrow_downward),
// // //                         elevation: 16,
// // //                         underline: Container(
// // //                           height: 2,
// // //                           color: Colors.black,
// // //                         ),
// // //                         onChanged: (String? value) {
// // //                           setState(() {
// // //                             environmentValue = value!;
// // //                             if (environmentValue == 'PRODUCTION') {
// // //                               packageName = "com.phonepe.app";
// // //                             } else if (environmentValue == 'SANDBOX') {
// // //                               packageName = "com.phonepe.simulator";
// // //                             }
// // //                           });
// // //                         },
// // //                         items: environmentList
// // //                             .map<DropdownMenuItem<String>>((String value) {
// // //                           return DropdownMenuItem<String>(
// // //                             value: value,
// // //                             child: Text(value),
// // //                           );
// // //                         }).toList(),
// // //                       )
// // //                     ],
// // //                   ),
// // //                   Visibility(
// // //                       maintainSize: false,
// // //                       maintainAnimation: false,
// // //                       maintainState: false,
// // //                       visible: Platform.isAndroid,
// // //                       child: Row(
// // //                           mainAxisAlignment: MainAxisAlignment.center,
// // //                           children: <Widget>[
// // //                             const SizedBox(height: 10),
// // //                             Text("Package Name: $packageName"),
// // //                           ])),
// // //                   const SizedBox(height: 10),
// // //                   Row(
// // //                     children: <Widget>[
// // //                       Checkbox(
// // //                           value: enableLogs,
// // //                           onChanged: (state) {
// // //                             setState(() {
// // //                               enableLogs = state!;
// // //                             });
// // //                           }),
// // //                       const Text("Enable Logs")
// // //                     ],
// // //                   ),
// // //                   const SizedBox(height: 10),
// // //                   const Text(
// // //                     'Warning: Init SDK is Mandatory to use all the functionalities*',
// // //                     style: TextStyle(color: Colors.red),
// // //                   ),
// // //                   ElevatedButton(
// // //                       onPressed: initPhonePeSdk, child: const Text('INIT SDK')),
// // //                   const SizedBox(width: 5.0),
// // //                   TextField(
// // //                     decoration: const InputDecoration(
// // //                       border: OutlineInputBorder(),
// // //                       hintText: 'request',
// // //                     ),
// // //                     onChanged: (text) {
// // //                       request = text;
// // //                     },
// // //                   ),
// // //                   const SizedBox(height: 10),
// // //                   Row(
// // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                       children: <Widget>[
// // //                         Expanded(
// // //                             child: ElevatedButton(
// // //                                 onPressed: startTransaction,
// // //                                 child: const Text('Start Transaction'))),
// // //                         const SizedBox(width: 5.0),
// // //                       ]),
// // //                   ElevatedButton(
// // //                       onPressed: getInstalledApps,
// // //                       child: const Text('Get Installed Apps')),
// // //                   Text("Result: \n $result")
// // //                 ],
// // //               ),
// // //             ),
// // //           )),
// // //     );
// // //   }
// // // }
// //
// //
// //
// //
// //
// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment/upimer.dart';
// // // import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
// // // import 'dart:math';
// // //
// // //
// // // class MerchantApp extends StatefulWidget {
// // //   const MerchantApp({super.key});
// // //
// // //   @override
// // //   State<MerchantApp> createState() => MerchantScreen();
// // // }
// // //
// // // class MerchantScreen extends State<MerchantApp> {
// // //   String request = "";
// // //   String appSchema = "flutterDemoApp";
// // //
// // //   Map<String, String> headers = {};
// // //   List<String> environmentList = <String>['SANDBOX', 'PRODUCTION'];
// // //   bool enableLogs = true;
// // //   Object? result;
// // //   String environmentValue = 'SANDBOX';
// // //   String merchantId = "MANISHJEWELUAT";
// // //   String flowId = ""; // Pass the user id or the unique string
// // //   String packageName = "com.phonepe.simulator";
// // //
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     generateFlowId(); // Generate a unique flowId on app start
// // //   }
// // //
// // //   void generateFlowId() {
// // //     final random = Random();
// // //     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
// // //     setState(() {
// // //       flowId = List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();
// // //     });
// // //   }
// // //
// // //
// // //
// // //
// // //
// // //
// // //   void initPhonePeSdk() {
// // //     PhonePePaymentSdk.init(environmentValue, merchantId, flowId, enableLogs)
// // //         .then((isInitialized) => {
// // //       setState(() {
// // //         result = 'PhonePe SDK Initialized - $isInitialized';
// // //       })
// // //     })
// // //         .catchError((error) {
// // //       handleError(error);
// // //       return <dynamic>{};
// // //     });
// // //   }
// // //
// // //
// // //   void startTransaction() async {
// // //
// // //     //https://manish-jewellers.com/payment/callback/
// // //     //"callbackUrl": "https://your-callback-url.com",
// // //
// // //
// // // ///    String transactionId = "TXN${DateTime.now().millisecondsSinceEpoch}";
// // //
// // //     String transactionId = "MT${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999)}";
// // //     String order = "TN${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999)}";
// // //
// // //
// // //     String requestBody = jsonEncode({
// // //       "merchantId": merchantId,
// // //       "transactionId": transactionId, // Unique transaction ID
// // //       "amount": "50000", // Amount in paise (₹500)
// // //       "flow": "DEFAULT", // Payment flow
// // //       "callbackUrl": "https://manish-jewellers.com/payment/callback/$order",
// // //       "mobileNumber": "9131242063",
// // //     });
// // //
// // //     try {
// // //       PhonePePaymentSdk.startTransaction(requestBody, appSchema).then((response) {
// // //         setState(() {
// // //           if (response != null) {
// // //             String status = response['status'].toString();
// // //             String error = response['error'].toString();
// // //             print('Request:::: $requestBody');
// // //             if (status == 'SUCCESS') {
// // //               result = "Flow Completed - Status: Success!";
// // //             } else {
// // //               result = "Flow Completed - Status: $status and Error: $error";
// // //             }
// // //           } else {
// // //             result = "Flow Incomplete";
// // //           }
// // //         });
// // //       }).catchError((error) {
// // //         handleError(error);
// // //       });
// // //     } catch (error) {
// // //       handleError(error);
// // //     }
// // //   }
// // //
// // //
// // //
// // //   // void startTransaction() async {
// // //   //   try {
// // //   //     PhonePePaymentSdk.startTransaction(request, appSchema)
// // //   //         .then((response) => {
// // //   //       setState(() {
// // //   //         if (response != null) {
// // //   //           String status = response['status'].toString();
// // //   //           String error = response['error'].toString();
// // //   //           if (status == 'SUCCESS') {
// // //   //             result = "Flow Completed - Status: Success!";
// // //   //           } else {
// // //   //             result =
// // //   //             "Flow Completed - Status: $status and Error: $error";
// // //   //           }
// // //   //         } else {
// // //   //           result = "Flow Incomplete";
// // //   //         }
// // //   //       })
// // //   //     })
// // //   //         .catchError((error) {
// // //   //       handleError(error);
// // //   //       return <dynamic>{};
// // //   //     });
// // //   //   } catch (error) {
// // //   //     handleError(error);
// // //   //   }
// // //   // }
// // //
// // //
// // //
// // //
// // //
// // //
// // //   void getInstalledUpiAppsForiOS() {
// // //     PhonePePaymentSdk.getInstalledUpiAppsForiOS()
// // //         .then((apps) => {
// // //       setState(() {
// // //         result = 'getUPIAppsInstalledForIOS - $apps';
// // //
// // //         // For Usage
// // //         List<String> stringList = apps
// // //             ?.whereType<
// // //             String>() // Filters out null and non-String elements
// // //             .toList() ??
// // //             [];
// // //
// // //         // Check if the string value 'Orange' exists in the filtered list
// // //         String searchString = 'PHONEPE';
// // //         bool isStringExist = stringList.contains(searchString);
// // //
// // //         if (isStringExist) {
// // //           print('$searchString app exist in the device.');
// // //         } else {
// // //           print('$searchString app does not exist in the list.');
// // //         }
// // //       })
// // //     })
// // //         .catchError((error) {
// // //       handleError(error);
// // //       return <dynamic>{};
// // //     });
// // //   }
// // //
// // //   void getInstalledApps() {
// // //     if (Platform.isAndroid) {
// // //       getInstalledUpiAppsForAndroid();
// // //       print('request ${request}');
// // //     } else {
// // //       getInstalledUpiAppsForiOS();
// // //     }
// // //   }
// // //
// // //   void getInstalledUpiAppsForAndroid() {
// // //     PhonePePaymentSdk.getUpiAppsForAndroid()
// // //         .then((apps) => {
// // //       setState(() {
// // //         if (apps != null) {
// // //           Iterable l = json.decode(apps);
// // //           List<UPIApp> upiApps = List<UPIApp>.from(
// // //               l.map((model) => UPIApp.fromJson(model)));
// // //           String appString = '';
// // //           for (var element in upiApps) {
// // //             appString +=
// // //             "${element.applicationName} ${element.version} ${element.packageName}";
// // //           }
// // //           result = 'Installed Upi Apps - $appString';
// // //         } else {
// // //           result = 'Installed Upi Apps - 0';
// // //         }
// // //       })
// // //     })
// // //         .catchError((error) {
// // //       handleError(error);
// // //       return <dynamic>{};
// // //     });
// // //   }
// // //
// // //   void handleError(error) {
// // //     setState(() {
// // //       if (error is Exception) {
// // //         result = error.toString();
// // //       } else {
// // //         result = {"error": error};
// // //       }
// // //     });
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       home: Scaffold(
// // //           appBar: AppBar(
// // //             title: const Text('Payment Gateway'),
// // //           ),
// // //           body: SingleChildScrollView(
// // //             child: Container(
// // //               margin: const EdgeInsets.all(7),
// // //               child: Column(
// // //                 children: <Widget>[
// // //                   TextField(
// // //                     decoration: const InputDecoration(
// // //                       border: OutlineInputBorder(),
// // //                       hintText: 'Merchant Id',
// // //                     ),
// // //                     onChanged: (text) {
// // //                       merchantId = text;
// // //                     },
// // //                   ),
// // //                   TextField(
// // //                     decoration: const InputDecoration(
// // //                       border: OutlineInputBorder(),
// // //                       hintText: 'Flow Id',
// // //                     ),
// // //                     onChanged: (text) {
// // //                       flowId = text;
// // //                     },
// // //                   ),
// // //                   Row(
// // //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // //                     children: <Widget>[
// // //                       const Text('Select the environment'),
// // //                       DropdownButton<String>(
// // //                         value: environmentValue,
// // //                         icon: const Icon(Icons.arrow_downward),
// // //                         elevation: 16,
// // //                         underline: Container(
// // //                           height: 2,
// // //                           color: Colors.black,
// // //                         ),
// // //                         onChanged: (String? value) {
// // //                           setState(() {
// // //                             environmentValue = value!;
// // //                             if (environmentValue == 'PRODUCTION') {
// // //                               packageName = "com.phonepe.app";
// // //                             } else if (environmentValue == 'SANDBOX') {
// // //                               packageName = "com.phonepe.simulator";
// // //                             }
// // //                           });
// // //                         },
// // //                         items: environmentList
// // //                             .map<DropdownMenuItem<String>>((String value) {
// // //                           return DropdownMenuItem<String>(
// // //                             value: value,
// // //                             child: Text(value),
// // //                           );
// // //                         }).toList(),
// // //                       )
// // //                     ],
// // //                   ),
// // //                   Visibility(
// // //                       maintainSize: false,
// // //                       maintainAnimation: false,
// // //                       maintainState: false,
// // //                       visible: Platform.isAndroid,
// // //                       child: Row(
// // //                           mainAxisAlignment: MainAxisAlignment.center,
// // //                           children: <Widget>[
// // //                             const SizedBox(height: 10),
// // //                             Text("Package Name: $packageName"),
// // //                           ])),
// // //                   const SizedBox(height: 10),
// // //                   Row(
// // //                     children: <Widget>[
// // //                       Checkbox(
// // //                           value: enableLogs,
// // //                           onChanged: (state) {
// // //                             setState(() {
// // //                               enableLogs = state!;
// // //                             });
// // //                           }),
// // //                       const Text("Enable Logs")
// // //                     ],
// // //                   ),
// // //                   const SizedBox(height: 10),
// // //                   const Text(
// // //                     'Warning: Init SDK is Mandatory to use all the functionalities*',
// // //                     style: TextStyle(color: Colors.red),
// // //                   ),
// // //                   ElevatedButton(
// // //                       onPressed: initPhonePeSdk, child: const Text('INIT SDK')),
// // //                   const SizedBox(width: 5.0),
// // //                   TextField(
// // //                     decoration: const InputDecoration(
// // //                       border: OutlineInputBorder(),
// // //                       hintText: 'request',
// // //                     ),
// // //                     onChanged: (text) {
// // //                       request = text;
// // //                     },
// // //                   ),
// // //                   const SizedBox(height: 10),
// // //                   Row(
// // //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                       children: <Widget>[
// // //                         Expanded(
// // //                             child: ElevatedButton(
// // //                                 onPressed: startTransaction,
// // //                                 child: const Text('Start Transaction'))),
// // //                         const SizedBox(width: 5.0),
// // //                       ]),
// // //                   ElevatedButton(
// // //                       onPressed: getInstalledApps,
// // //                       child: const Text('Get Installed Apps')),
// // //                   Text("Result: \n $result")
// // //                 ],
// // //               ),
// // //             ),
// // //           )),
// // //     );
// // //   }
// // // }
// // //
// // //
