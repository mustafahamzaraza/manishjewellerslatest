import 'dart:async';
import 'dart:convert';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment_webview.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/pd.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../features/dashboard/screens/dashboard_screen.dart';
import '../utill/colornew.dart';
import 'drawer.dart';
import 'gb.dart';
import 'getloan.dart';
import 'ledger.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment/payment_status.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment_webview.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/pp.dart';
import 'package:shared_preferences/shared_preferences.dart';// If you are using custom colors
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../features/gold/payment_webview.dart';
import '../utill/colornew.dart';
import 'gb.dart';
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

class PaymentHistoryList extends StatefulWidget {
  const PaymentHistoryList({super.key});

  @override
  State<PaymentHistoryList> createState() => _PaymentHistoryListState();
}

class _PaymentHistoryListState extends State<PaymentHistoryList> {


  String request = "";
  String appSchema = "";
  List<String> environmentList = <String>['SANDBOX', 'PRODUCTION'];
  bool enableLogs = true;
  Object? result;

  String environmentValue = 'PRODUCTION';
  String merchantId = "M22J5SI2LQ62U";
  //String environmentValue = 'SANDBOX';
  //String merchantId = "MANISHJEWELUAT"; //testing


  String flowId = ""; // Pass the user id or the unique string
  String packageName = "com.phonepe.simulator";
  String requestorderId = '';
  String requestToken = '';
  String requestMerchantOrderId = '';



  List<Map<String, dynamic>> paymentPlans = [];
  int _currentIndex = 0;
  TextEditingController _searchController = TextEditingController();


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? planName;
  String? planCode;

  final TextEditingController _offlineController = TextEditingController();
  final TextEditingController _onlineController = TextEditingController();

  String price22k = "Loading...";
  double goldPricePerGram = 0.0; // Will be updated from API
  String currentDateTime = "";

  String selectedPaymentMethod = 'Cash';

  String uname = '';





  Future<void> fetchGoldPrices() async {
    const String apiUrl = "https://manish-jewellers.com/api/v1/goldPriceService";

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




  List<Map<String, dynamic>> advertisements = [];
  bool isLoading = true;
  int _currentIndexoffer = 0;


  @override
  void initState() {
    super.initState();
     fetchPayments();
 //   GlobalPlan().setPlanDetails(widget.planId);
     fetchGoldPrices();
    _offlineController.addListener(_calculateGoldWeight);
     fetchProfileData(newAddress: '');
    fetchAdvertisements();
    getFlowId();
    initPhonePeSdk();
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

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentStatusPage(
                    id: requestMerchantOrderId,
                  ), // Replace with your widget
                ),
              );

              print('passing id $requestMerchantOrderId');
              //requestMerchantOrderId
            } else {

              result = "Flow Completed - Status: $status and Error: $error";
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentStatusPage(
                    id: requestMerchantOrderId,
                  ), // Replace with your widget
                ),
              );

            }
          }

          else {
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



  Future<void> fetchAdvertisements() async {
    try {
      var response = await http.get(Uri.parse('https://manish-jewellers.com/api/v1/advertisements'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('$data');
        setState(() {
          advertisements = List<Map<String, dynamic>>.from(data['data']);
          isLoading = false;
        });
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }


  Widget _buildCarouselOffers() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (advertisements.isEmpty) {
      return Center(
        child: Image.asset(
          'assets/images/bh.jpg', // Default image when no ads are available
          fit: BoxFit.cover,
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 21 / 11,
        viewportFraction: 0.9,
        autoPlayInterval: Duration(seconds: 3),
        onPageChanged: (index, reason) => setState(() => _currentIndexoffer = index),
      ),
      items: advertisements.map((ad) => _buildCarouselItemOffer(ad)).toList(),
    );
  }

  Widget _buildCarouselItemOffer(Map<String, dynamic> ad) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              ad['image'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                );
              },
            ),
            Positioned(
              bottom: 10,
              left: 15,
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.black54,
                child: Text(
                  ad['title'],
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
  //  enteredAmount = double.tryParse(value)!;

    double enteredAmount = double.tryParse(value) ?? 0.0;

    if (enteredAmount != null) {
    //  double effectiveAmount;

      if (selectedPaymentMethod == 'Razorpay') {
        effectiveAmount = enteredAmount * 0.98; // Deduct 2% for online payments
      } else {
        effectiveAmount = enteredAmount; // No deduction for cash payments
      }

      _deductedAmountController.add(effectiveAmount);

      double goldPrice = double.tryParse(price22k.replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0;

    //  double goldPrice = (double.tryParse(price22k.replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0) / 10;

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

  Future<void> _startRazorpayPayment(BuildContext context) async {

    debugStreamValues();
    //
    // print("🔄 Updating gold calculations...");
    // _updateGoldCalculation(_onlineController.text);  // Ensure values are updated

    String currentInput = selectedPaymentMethod == 'Razorpay' ? _onlineController.text : _offlineController.text;
    _updateGoldCalculation(currentInput);

    await Future.delayed(Duration(milliseconds: 500)); // Give streams time to update


    String onlineAmountText = _onlineController.text.trim();
    double? amount = double.tryParse(onlineAmountText);

    _processRazorpayPayment(context,amount ?? 0.0,goldAcquired);

    //_processRazorpayPayment(context,enteredAmount,goldAcquired);
  }
  // void _updateGoldCalculation(String value) {
  //   double? enteredAmount = double.tryParse(value);
  //   if (enteredAmount != null) {
  //     double effectiveAmount;
  //     // If Razorpay, deduct 2%; if Cash (or any other method), use full amount.
  //     if (selectedPaymentMethod == 'Razorpay') {
  //       effectiveAmount = enteredAmount * 0.98;
  //       // Update the deducted amount stream so that the UI shows the new total.
  //       _deductedAmountController.add(effectiveAmount);
  //     } else {
  //       effectiveAmount = enteredAmount;
  //       // You can also clear the deducted amount stream if needed:
  //       _deductedAmountController.add(effectiveAmount);
  //     }
  //     // Clean the price string (remove any non-numeric characters) and parse it.
  //     double goldPrice = double.parse(price22k.replaceAll(RegExp('[^0-9.]'), ''));
  //     goldAcquired = effectiveAmount / goldPrice;
  //     // Update the gold weight stream so that the UI shows the new gold weight.
  //     _goldWeightController.add(goldAcquired);
  //
  //     print("Entered: $enteredAmount, Effective: $effectiveAmount, Gold Weight: $goldAcquired");
  //   }
  // }


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





  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Returns the token or null if not found
  }













  bool _isProcessingPayment = false; // Add this flag

  Future<void> _processRazorpayPayment(BuildContext context,double deductedAmount,double goldAcquiredtx) async {
    if (_isProcessingPayment) return; // Prevent multiple calls
    _isProcessingPayment = true;

    try {


      var selectedPlan = paymentPlans[_currentIndex];
      var planId = selectedPlan['id'];
      var totalBalance = selectedPlan['total_balance'];
      var start = selectedPlan['plan_start_date'];

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
        'plan_code': planCode.toString(),
        'plan_category': planName.toString(),
        'total_yearly_payment': '0',
        'total_gold_purchase': goldAcquiredtx.toString(),
        'start_date': getCurrentDate(),
        'installment_id': planId.toString(),
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
        print('$jsonResponse');

        requestorderId = jsonResponse['orderId'];
        requestToken = jsonResponse['token'];
        requestMerchantOrderId = jsonResponse['merchantOrderId'];
        print('Order ID: $requestorderId');
        print('Token: $requestToken');
        // String responseBody = await response.stream.bytesToString();
        // var jsonResponse = json.decode(responseBody);
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



  // Future<void> _processRazorpayPayment(BuildContext context) async {
  //
  //
  //   double deductedAmount = await _deductedAmountController.stream.first;
  //
  //   double goldAcquiredtx = await _goldWeightController.stream.first;
  //
  //   String? token = await getToken();
  //
  //
  //   var headers = {
  //     'Accept': 'application/json',
  //     'Authorization': 'Bearer $token'
  //   };
  //
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('https://manish-jewellers.com/api/online-payment'),
  //   );
  //
  //   String getCurrentDate() {
  //     return DateFormat('yyyy-MM-dd').format(DateTime.now());
  //   }
  //
  //   request.fields.addAll({
  //     'plan_amount': deductedAmount.toString(),
  //     'plan_code': planCode.toString(),
  //     'plan_category': planName.toString(),
  //     'total_yearly_payment': '0',
  //     'total_gold_purchase': goldAcquiredtx.toString(),
  //     'start_date': getCurrentDate().toString(),
  //     'installment_id': '0',
  //     'request_date': getCurrentDate().toString(),
  //     'remarks': '',
  //     'no_of_months': GlobalPlan().months.toString()
  //   });
  //
  //   print("API Request Fields: ${request.fields}");
  //
  //   request.headers.addAll(headers);
  //
  //   try {
  //     http.StreamedResponse response = await request.send();
  //     if (response.statusCode == 200) {
  //       print('${response}');
  //       String responseBody = await response.stream.bytesToString();
  //       var jsonResponse = json.decode(responseBody);
  //
  //       if (jsonResponse['success'] == true) {
  //         String paymentUrl = jsonResponse['payment_url'];
  //
  //         // Navigate to the new screen with payment URL
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => WebViewScreen(redirectUrl: paymentUrl),
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Failed to generate payment URL")),
  //         );
  //         print('${response} code ${response.statusCode}');
  //       }
  //     }
  //     else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error: ${response.reasonPhrase}")),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Network error. Please try again.")),
  //     );
  //   }
  // }




  Future<void> fetchPayments() async {
    String? token = await getToken();
    if (token == null) return;

    var headers = {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    var request = http.MultipartRequest(
      'GET',
      Uri.parse('https://manish-jewellers.com/api/installment-payment/v1/list'),
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
    return Scaffold(
      key: _scaffoldKey,
    //  drawer: CustomDrawer(),
      backgroundColor: AppColors.textDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // leading: IconButton(
        //   icon: Icon(Icons.menu,color: Colors.black,),
        //   onPressed: () => _scaffoldKey.currentState?.openDrawer(), // ✅ Open drawer using key
        // ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                _buildCarousel(),
                _buildIndicators(),
                _buildCarouselOffers(),
                _buildQuickAccessRow(),
                _buildSearchSection(),
                _buildTransactionHeader(),
                SizedBox(height: 10),
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
                    text: '\t\t ${uname.toUpperCase()}',
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


    planCode = plan['plan_code']; //INR
   planName = plan['plan_category'];


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
              const SizedBox(height: 20),
              _buildDetailRow(plan['plan_start_date'], '${plan['plan_code']} ${plan['id']} '),
              _buildDetailRow(plan['plan_end_date'], 'Monthly ₹${plan['monthly_average'].toStringAsFixed(0)}'),
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
        SingleChildScrollView(
          child: _rowContainer('Payment', 'assets/images/a.png', () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return _paymentConfirmationDialog(context);
              },
            );
          }),
        ),

        // Ledger Button: Navigate to Ledger Screen
        _rowContainer('Ledger', 'assets/images/b.png', () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LedgerHistoryScreen()),
          );
        }),

        // Loan Button: Navigate to Loan Screen (or implement loan action)
        _rowContainer('AuCred', 'assets/images/c.png', () {
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

          //add navigation ater 5 seconds
          //
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => LoanScreen(
          //     id: planId
          //   )), // Assume LoanScreen() is a valid screen.
          // );
        }),

        // Details Button: Navigate to Details Screen (or show information)
        _rowContainer('Details', 'assets/images/d.png', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InvestmentPaymentDetails()), // Assume DetailsScreen() is a valid screen.
          );
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
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  // Amount TextField with dynamic hintText
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
                  SizedBox(height: 16),
                  //  When Razorpay is selected, show the deducted total and new gold weight
                  if (selectedPaymentMethod == 'Razorpay') ...[
                    StreamBuilder<double>(
                      stream: _deductedAmountController.stream,
                      initialData: 0.0,
                      builder: (context, snapshot) {
                        return Text(
                          "Total: ${snapshot.data!.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    StreamBuilder<double>(
                      stream: _goldWeightController.stream,
                      initialData: 0.0,
                      builder: (context, snapshot) {
                        return Text(
                          "Gold Acquired: ${snapshot.data!.toStringAsFixed(4)} grams",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                       );
                     },
                   ),
                  ],
                  SizedBox(height: 16),
                  // Payment Options
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10, // Items के बीच gap
                    runSpacing: 10, // Lines के बीच gap
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Razorpay',
                            groupValue: selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedPaymentMethod = value!;
                                _updateGoldCalculation(_onlineController.text);
                              });
                            },
                          ),
                          Text("Online"),
                        ],
                      ),
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
                      //         _showQRDialog(context);
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
          onPressed: () async {
          print("method: $selectedPaymentMethod");

          if (selectedPaymentMethod == 'Cash') {
          String offlineAmount = _offlineController.text.trim();
          double? amount = double.tryParse(offlineAmount);

          if (amount == null || amount < 100) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Amount must be greater than 100 for cash payments.")),
          );
          return;
          } else {
          await payOffline(
          context,
          offlineAmount,
          planCode.toString(),
          planName.toString(),
          goldAcquired.toString(),
          );

          // await _showConfirmationDialog(context);
          }
          }

          else if (selectedPaymentMethod == 'Razorpay') {
          String onlineAmount = _onlineController.text.trim();

          if (onlineAmount.isNotEmpty) {
          await _startRazorpayPayment(context);

          await Future.delayed(Duration(seconds: 3)); // ⏳ Wait 3 seconds
          await _showConfirmationDialog(context);


          } else {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter a valid amount for online payment")),
          );
          }
          }
          }

                      // onPressed:  () {
                      //   if (selectedPaymentMethod == 'Cash') {
                      //     String offlineAmount = _offlineController.text.trim();
                      //     double? amount = double.tryParse(offlineAmount);
                      //     if (amount == null || amount < 100) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: Text("Amount must be greater than 100 for cash payments.")),
                      //       );
                      //       return;
                      //     } else {
                      //
                      //       payOffline(context, offlineAmount,planCode.toString(),planName.toString(), goldAcquired.toString()); // adjust as needed
                      //
                      //
                      //     }
                      //   }
                      //
                      //   else if (selectedPaymentMethod == 'Razorpay') {
                      //     String onlineAmount = _onlineController.text.trim();
                      //     if (onlineAmount.isNotEmpty) {
                      //      _startRazorpayPayment(context);
                      //       // _processRazorpayPayment(context);
                      //       // // ScaffoldMessenger.of(context).showSnackBar(
                      //       // //   SnackBar(content: Text("Please")),
                      //       // // );
                      //       // // Call the API function
                      //     } else {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: Text("Please enter a valid amount for online payment")),
                      //       );
                      //     }
                      //   }
                      //
                      //
                      // },
                      // Button is disabled if terms are not accepted
                      ,child: Text(
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


  Future<void> payOffline(BuildContext context, String amount, String pCode, String pName, String goldwt) async {
    try {
      String? token = await getToken();

      String getCurrentDate() {
        return DateFormat('yyyy-MM-dd').format(DateTime.now());
      }

      String formattedDate = getCurrentDate();

      if (formattedDate.isEmpty) {
        formattedDate = getCurrentDate();
      }

      String formatDate(String dateString) {
        try {
          // Remove suffixes like "st", "nd", "rd", "th" to prevent parsing errors
          String cleanDate = dateString.replaceAll(RegExp(r'\b(\d+)(st|nd|rd|th)\b'), '\$1');
          DateTime parsedDate = DateFormat("MMMM d, yyyy hh:mm a").parse(cleanDate);
          return DateFormat('yyyy-MM-dd').format(parsedDate);
        } catch (e) {
          print("Error parsing date: $e");
          return getCurrentDate(); // Use current date if parsing fails
        }
      }

      var selectedPlan = paymentPlans[_currentIndex];
      var planId = selectedPlan['id'];
      var totalBalance = selectedPlan['total_balance'];
      var start = selectedPlan['plan_start_date'];

      // Convert start date to required format
      String formattedStartDate = formatDate(start.toString());

      // Debugging: Print values before sending request
      print('Token: $token');
      print('Plan ID: $planId');
      print('Date before conversion: $start');
      print('Formatted Start Date: $formattedStartDate');

      if (token != null) {
        var headers = {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };

        var request = http.MultipartRequest('POST', Uri.parse('https://manish-jewellers.com/api/v1/payments'));

        request.fields.addAll({
          'plan_amount': amount,
          'plan_code': pCode,
          'plan_category': pName,
          'total_yearly_payment': '0',
          'total_gold_purchase': goldwt,
          'start_date': formattedStartDate,
          'installment_id': planId.toString(),
          'request_date': getCurrentDate(),
          'remarks': '',
          'no_of_months': ''
        });

        request.headers.addAll(headers);

        // Debugging: Print request fields
        print('Request Fields: ${jsonEncode(request.fields)}');

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 201) {
          String responseBody = await response.stream.bytesToString();
          print('Payment Successful: $responseBody');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Payment Successful!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentHistoryList()),
          );
        } else {
          String errorResponse = await response.stream.bytesToString();
          print('Error ${response.statusCode}: $errorResponse');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Payment failed! Error: ${response.statusCode}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Error: Token not found. User might need to log in again.');
      }
    } catch (e) {
      print('Exception: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
      padding: EdgeInsets.only(left: 25,bottom: 10,top: 5,right: 15),
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

            leading: CircleAvatar(
              radius: 37,
              backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/umbrella.png'),
              // Local asset image
                 ),
              title: Text(
                '${payment['payment_date']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(payment['payment_time']),
              trailing: Text(
                '₹${payment['payment_amount']}',
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 13),
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

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 11,height: 1)),
            Text(value, style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12,height: 1)),
          ],
        ),
      ),
    );
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

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Confirmation"),
          content: Text("Are you sure?"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                startTransaction();
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

}

