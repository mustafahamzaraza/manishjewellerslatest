import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/di_container.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment/upimer.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:uuid/uuid.dart';
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

import '../gb.dart';




class MerchantApp extends StatefulWidget {
  const MerchantApp({super.key});

  @override
  State<MerchantApp> createState() => MerchantScreen();
}

class MerchantScreen extends State<MerchantApp> {

  String request = "";
  String appSchema = "";
  List<String> environmentList = <String>['SANDBOX', 'PRODUCTION'];
  bool enableLogs = true;
  Object? result;
  String environmentValue = 'SANDBOX';
  String merchantId = "MANISHJEWELUAT"; //testing
  String flowId = ""; // Pass the user id or the unique string
  String packageName = "com.phonepe.simulator";
  String requestorderId = '';
  String requestToken = '';

  @override
  void initState() {
    super.initState();
    getFlowId();
    initPhonePeSdk();
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
        Uri.parse('https://manish-jewellers.com/api/v1/online-payment'),
      );

      String getCurrentDate() {
        return DateFormat('yyyy-MM-dd').format(DateTime.now());
      }

      request.fields.addAll({
        'plan_amount': deductedAmount.toString(),
        'plan_code': "INR",
        'plan_category': "First Installment Plan",
        'total_yearly_payment': '0',
        'total_gold_purchase': '1.6',
        'start_date': getCurrentDate(),
        'installment_id': '0',
        'request_date': getCurrentDate(),
        'remarks': '',
        'no_of_months': '12'
      });

      print("API Request Fields: ${request.fields}");
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);
        print('$jsonResponse');

        requestorderId = jsonResponse['orderId'];
        requestToken = jsonResponse['token'];

        print('Order ID: $requestorderId');
        print('Token: $requestToken');

        // String paymentUrl = jsonResponse['redirectUrl'];
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => WebViewScreenTwo(redirectUrl: paymentUrl),
        //   ),
        // );


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



  void getFlowId(){
    var uuid = Uuid();
    flowId = uuid.v4();
  }


  void initPhonePeSdk() {

    PhonePePaymentSdk.init(environmentValue, merchantId, flowId, enableLogs)
        .then((isInitialized) => {
      setState(() {
        result = 'PhonePe SDK Initialized - $isInitialized';
      })
    })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }





  void startTransaction() async {



    try {

      Map<String, dynamic> payload = {
        "orderId": requestorderId,
        "merchantId": merchantId,
        "token": requestToken,
        "paymentMode": {"type": "PAY_PAGE"}
      };

      String request = jsonEncode(payload);
      print("Payment Request: $request");

      PhonePePaymentSdk.startTransaction(request, appSchema)
          .then((response) => {
        setState(() {
          if (response != null) {
            String status = response['status'].toString();
            String error = response['error'].toString();
            if (status == 'SUCCESS') {
              result = "Flow Completed - Status: Success!";
            } else {
              result =
              "Flow Completed - Status: $status and Error: $error";
            }
          } else {
            result = "Flow Incomplete";
          }
        })
      })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      handleError(error);
    }
  }


  void getInstalledApps() {
    if (Platform.isAndroid) {
      getInstalledUpiAppsForAndroid();
    } else {
      print("Develop Code");
    }
  }

  void getInstalledUpiAppsForAndroid() {
    PhonePePaymentSdk.getUpiAppsForAndroid()
        .then((apps) => {
      setState(() {
        if (apps != null) {
          Iterable l = json.decode(apps);
          List<UPIApp> upiApps = List<UPIApp>.from(
              l.map((model) => UPIApp.fromJson(model)));
          String appString = '';
          for (var element in upiApps) {
            appString +=
            "${element.applicationName} ${element.version} ${element.packageName}";
          }
          result = 'Installed Upi Apps - $appString';
        } else {
          result = 'Installed Upi Apps - 0';
        }
      })
    })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void handleError(error) {
    setState(() {
      if (error is Exception) {
        result = error.toString();
      } else {
        result = {"error": error};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Payment"),
                InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_rounded)),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(7),
              child: Column(
                children: <Widget>[

                  Text("MerchantId:"),
                  Text("$merchantId"),

                  SizedBox(height: 6,),

                  Text("FlowId:"),
                  Text("$flowId "),

                  SizedBox(height: 6,),
                  Text("Mode:"),
                  Text("$environmentValue "),

                  // Row(
                  //   children: <Widget>[
                  //     Checkbox(
                  //         value: enableLogs,
                  //         onChanged: (state) {
                  //           setState(() {
                  //             enableLogs = state!;
                  //           });
                  //         }),
                  //     const Text("Enable Logs")
                  //   ],
                  // ),
                  const SizedBox(height: 10),
                  // const Text(
                  //   'Warning: Init SDK is Mandatory to use all the functionalities*',
                  //   style: TextStyle(color: Colors.red),
                  // ),
                  // ElevatedButton(
                  //     onPressed: initPhonePeSdk, child: const Text('INIT SDK')),
                  // const SizedBox(width: 5.0),
                  // TextField(
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     hintText: 'request',
                  //   ),
                  //   onChanged: (text) {
                  //     request = text;
                  //   },
                  // ),



                  ElevatedButton(
                    onPressed: () {
                      _processRazorpayPayment(context, 1000, 1.6);
                    },
                    child: const Text('Pay'),
                  ),


                  const SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            child: ElevatedButton(
                                onPressed: startTransaction,
                                child: const Text('Start Transaction'))),
                        const SizedBox(width: 5.0),
                      ]),
                  ElevatedButton(
                      onPressed: getInstalledApps,
                      child: const Text('Get Installed Apps')),
                  Text("Result: \n $result")
                ],
              ),
            ),
          )),
    );
  }
}





