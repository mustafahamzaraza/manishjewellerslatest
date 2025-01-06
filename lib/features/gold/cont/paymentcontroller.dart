import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../globalclass.dart';
import '../payment_webview.dart';


class PaymentDetailsController extends ChangeNotifier {

  double paymentDone = 0.0; // Default value
  // Update paymentDone
  void updatePaymentDone(double newPaymentDone) {
    paymentDone = newPaymentDone;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  //ye
  String? token;
  int? id;
  String? planCode;
  String? planCategory;
  int? totalYearlyPayment;
  double? totalGoldPurchase;
  String? startDates;

  String? newtoken;

  //int? paymentDone;
  int? paymentRemaining;


  String? newToken; // To store the token locally


  double? price18k, price22k, price24k;
  double purchasedGoldWeight = 0.0;
  int? goldPriceForRequest;



  // Retrieve user token from SharedPreferences
  Future<String?> getUserToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('user_token');
      newToken = token;
      if (token != null) {
        print("Token found: $token");

        return token;
      } else {
        print("No token found.");
        return null;
      }
    } catch (e) {
      print("Error fetching token: $e");
      return null;
    }
  }




  final StreamController<double> _goldWeightController = StreamController<double>.broadcast();

  Stream<double> get purchasedGoldWeightStream => _goldWeightController.stream;

  // Fetch and calculate gold weight
  Future<void> fetchAndCalculateGoldWeight(int planAmount, String selectedCategory) async {
    // Fetch the latest gold prices
    await fetchGoldPrices();

    // Calculate the gold weight based on the fetched prices
    calculateGoldWeight(planAmount, selectedCategory);

    print("Payment Done $paymentDone");
  }

  Future<void> fetchGoldPrices() async {
    try {
      final response = await http.get(Uri.parse('https://altaibagold.com/api/v1/goldPriceService'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        price18k = data['data']['price_gram']['18k_gst_included']?.toDouble();
        price22k = data['data']['price_gram']['22k_gst_included']?.toDouble();
        price24k = data['data']['price_gram']['24k_gst_included']?.toDouble();
        print("response data $data");
        notifyListeners();
      } else {
        print('Failed to fetch gold prices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching gold prices: $e');
    }
  }

  void calculateGoldWeight(int planAmount, String selectedCategory) {

     double selectedPricePerGram = 0.0;

    if (selectedCategory == '18 Carat Jewellery') {
      selectedPricePerGram = price18k ?? 0.0;
    } else if (selectedCategory == '22 Carat Jewellery') {
      selectedPricePerGram = price22k ?? 0.0;
    } else if (selectedCategory == '24 Carat Coin') {
      selectedPricePerGram = price24k ?? 0.0;
    }

    print("Selected Price Per Gram: $selectedPricePerGram plan amount $planAmount selected cat: $selectedCategory");

    // purchasedGoldWeight = selectedPricePerGram > 0 ? planAmount / selectedPricePerGram : 0.0;
     purchasedGoldWeight = selectedPricePerGram > 0 ? planAmount / selectedPricePerGram : 0.0;
    // Emit the new gold weight through the stream
    _goldWeightController.sink.add(purchasedGoldWeight);
    notifyListeners();

     print("Gold weight:$purchasedGoldWeight");

  }

  // Don't forget to close the StreamController when done
  void dispose() {
    _goldWeightController.close();
    super.dispose();
  }





  Future<void> submitPayment({
    required BuildContext context,
    required int iD,
    required String planCode,
    required String planCategory,
    required int planAmount,
    required double goldAmount, // Pass isFirstPayment as a parameter
  }) async {
    if (token == null) {
      await getUserToken(); // Ensure token is loaded
    }


    var totalGoldPurchasenow = purchasedGoldWeight;

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $newToken',
    };

    var body = json.encode({
      "payment_request_from": "app",
      "payment_method": "razor_pay",
      "id": iD,
      "plan_code": planCode,
      "plan_amount": planAmount,
      "plan_category": planCategory,
      "total_yearly_payment": planAmount * 11,
      "total_gold_purchase": goldAmount,
      "start_date": DateTime.now().toIso8601String(),
      "details": [
        {
          "monthly_payment": planAmount,
          "purchase_gold_weight": totalGoldPurchasenow.toStringAsFixed(5),
        }
      ],
    });




    try {
      var response = await http.post(
        Uri.parse('https://altaibagold.com/api/v1/installment-payment/add'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {

        var responseData = json.decode(response.body);
        debugPrint('Payment Response: $responseData');
        debugPrint('Body: $body \n\n Gold Purchased Now: ${totalGoldPurchasenow.toStringAsFixed(10)}');

        notifyListeners();

        // Check if redirect_link is present in the response
        if (responseData['redirect_link'] != null) {
          String redirectLink = responseData['redirect_link'];
          debugPrint('Redirecting to WebView: $redirectLink');

          // Navigate to WebViewScreen with redirect link

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewScreen(
                redirectUrl: redirectLink,
                id: id ?? 0,
                plan: planCode ?? '',
                category: planCategory ?? '',
                planAmount: int.tryParse(planAmount.toString()) ?? 0, // Ensure int
                goldAmount: totalGoldPurchasenow?.toDouble() ?? 0.0, // Ensure double
                totalpaymentyearly: planAmount * 11, // Ensure int
                startdate: DateTime.now().toIso8601String(), // Ensure String
                paymentDone: paymentDone.toInt() ?? 0, // Set accordingly
                paymentRemaining: paymentRemaining ?? 0,
              ),
            ),
          ).then((_){
            (context as Element).reassemble();
            }
          );

        } else {
         // ScaffoldMessenger.of(context).showSnackBar(
          //  SnackBar(content: Text('No redirect link found in response!')),
          //);
        }
      }
      else if(response.reasonPhrase.toString().contains('Unauthorized')){
        debugPrint('Failed to save payment details: ${response.reasonPhrase}');
        debugPrint('Headers: $headers');
        debugPrint('Body: $body');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please Login')),
        );
        print('token $token  newToken $newToken');
      }
      else{

      }
    } catch (e) {
      debugPrint('Error during payment submission: $e');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');
    }
  }



  // Future<void> submitPayment({
  //   required BuildContext context,
  //   required int iD,
  //   required String planCode,
  //   required String planCategory,
  //   required int planAmount,
  //   required double goldAmount,
  // }) async {
  //   if (token == null) {
  //     await getUserToken(); // Ensure token is loaded
  //   }
  //
  //   // var totalGoldPurchase = isFirstPayment ? goldAmount : purchasedGoldWeight;
  //
  //   var totalGoldPurchasenow;
  //
  //   var totalgoldreq;
  //
  //   if(paymentDone == 0 || paymentDone == null){
  //     totalGoldPurchasenow = goldAmount;
  //     totalgoldreq = goldAmount;
  //   }
  //   else{
  //     totalGoldPurchasenow = purchasedGoldWeight;
  //     totalgoldreq = (goldAmount + totalGoldPurchasenow).toStringAsFixed(5);
  //   }
  //
  //   var headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $newToken',
  //   };
  //
  //   var body = json.encode({
  //     "payment_request_from": "app",
  //     "payment_method": "razor_pay",
  //     "id": iD,
  //     "plan_code": planCode,
  //     "plan_amount": 1/*planAmount*/,
  //     "plan_category": planCategory,
  //     "total_yearly_payment": planAmount * 11,
  //     "total_gold_purchase": totalgoldreq,
  //     "start_date": DateTime.now().toIso8601String(),
  //     "details": [
  //       {
  //         "monthly_payment": planAmount,
  //         // "purchase_gold_weight": goldAmount,
  //         "purchase_gold_weight": totalGoldPurchasenow.toStringAsFixed(5),
  //
  //       }
  //     ],
  //   });
  //
  //   try {
  //     var response = await http.post(
  //       Uri.parse('https://altaibagold.com/api/v1/installment-payment/add'),
  //       headers: headers,
  //       body: body,
  //     );
  //
  //     if (response.statusCode == 200) {
  //
  //       var responseData = json.decode(response.body);
  //
  // //      isFirstPayment = false;
  //       notifyListeners();
  //
  //       debugPrint("payment done: $paymentDone total gold purchase = ${totalgoldreq}");
  //       debugPrint('Payment Response: $responseData');
  //       debugPrint('Body: $body \n\n Gold Purchased Now: ${totalGoldPurchasenow.toStringAsFixed(10)}');
  //
  //       // Check if redirect_link is present in the response
  //       if (responseData['redirect_link'] != null) {
  //         String redirectLink = responseData['redirect_link'];
  //         debugPrint('Redirecting to WebView: $redirectLink');
  //
  //         // Navigate to WebViewScreen with redirect link
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => WebViewScreen(
  //                 redirectUrl: redirectLink,
  //                 id: id ?? 0,
  //                 plan: planCode ?? '',
  //                 category: planCategory ?? '',
  //                 planAmount: int.tryParse(planAmount.toString()) ?? 0, // Ensure int
  //                 goldAmount: totalGoldPurchase?.toDouble() ?? 0.0, // Ensure double
  //                 totalpaymentyearly: totalYearlyPayment ?? 0, // Ensure int
  //                 startdate: startDates ?? '', // Ensure String
  //                 paymentDone: paymentDone ?? 0,
  //                 paymentRemaining: paymentRemaining ?? 0,
  //             ),
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('No redirect link found in response!')),
  //         );
  //       }
  //     }
  //     else {
  //       debugPrint('Failed to save payment details: ${response.reasonPhrase}');
  //       debugPrint('Headers: $headers');
  //       debugPrint('Body: $body');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('PLease Login')),
  //       );
  //       print('token $token  newToken $newToken');
  //     }
  //   } catch (e) {
  //     debugPrint('Error during payment submission: $e');
  //     debugPrint('Headers: $headers');
  //     debugPrint('Body: $body');
  //   }
  // }
}



