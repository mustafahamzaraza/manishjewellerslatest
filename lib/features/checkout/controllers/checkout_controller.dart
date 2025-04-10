import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/screens/digital_payment_order_place_screen.dart';
import 'package:path/path.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../manishecommerceinvestment/payment/payment_status.dart';



class CheckoutController with ChangeNotifier {
  final CheckoutServiceInterface checkoutServiceInterface;
  CheckoutController({required this.checkoutServiceInterface});

  String environmentValue = 'PRODUCTION';
  String merchantId = "M22J5SI2LQ62U";
  //String environmentValue = 'SANDBOX';
  //String merchantId = "MANISHJEWELUAT"; //testing


  String flowId = "7c9e6679-7425-40de-944b-e07fc1f90ae7";


  void initPhonePeSdk(String environmentValue, String merchantId, String flowId, bool enableLogs) {
    PhonePePaymentSdk.init(environmentValue, merchantId, flowId, enableLogs)
        .then((isInitialized) {
      print("PhonePe SDK Initialized: $isInitialized");
      // You can update UI or state here
    }).catchError((error) {
      print("Error in initializing PhonePe SDK: $error");
      // Handle the error accordingly
    });
  }

  int? _addressIndex;
  int? _billingAddressIndex;
  int? get billingAddressIndex => _billingAddressIndex;
  int? _shippingIndex;
  bool _isLoading = false;
  bool _isCheckCreateAccount = false;
  bool _newUser = false;

  int _paymentMethodIndex = -1;
  bool _onlyDigital = true;
  bool get onlyDigital => _onlyDigital;
  int? get addressIndex => _addressIndex;
  int? get shippingIndex => _shippingIndex;
  bool get isLoading => _isLoading;
  int get paymentMethodIndex => _paymentMethodIndex;
  bool get isCheckCreateAccount => _isCheckCreateAccount;



  String selectedPaymentName = '';
  void setSelectedPayment(String payment){
    selectedPaymentName = payment;
    notifyListeners();
  }


  final TextEditingController orderNoteController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  List<String> inputValueList = [];



  Future<void> placeOrder({required Function callback, String? addressID,
        String? couponCode, String? couponAmount,
        String? billingAddressId, String? orderNote, String? transactionId,
        String? paymentNote, int? id, String? name,bool isfOffline = false, bool wallet = false}) async {
    for(TextEditingController textEditingController in inputFieldControllerList) {
      inputValueList.add(textEditingController.text.trim());

    }

    _isLoading = true;
    _newUser = false;
    notifyListeners();
    ApiResponse apiResponse;
    isfOffline?
    apiResponse = await checkoutServiceInterface.offlinePaymentPlaceOrder(addressID, couponCode,couponAmount, billingAddressId, orderNote, keyList, inputValueList, offlineMethodSelectedId, offlineMethodSelectedName, paymentNote, _isCheckCreateAccount, passwordController.text.trim()):
    wallet?
    apiResponse = await checkoutServiceInterface.walletPaymentPlaceOrder(addressID, couponCode,couponAmount, billingAddressId, orderNote, _isCheckCreateAccount, passwordController.text.trim()):
    apiResponse = await checkoutServiceInterface.cashOnDeliveryPlaceOrder(addressID, couponCode,couponAmount, billingAddressId, orderNote, _isCheckCreateAccount, passwordController.text.trim());

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      _isCheckCreateAccount = false;
      _isLoading = false;
      _addressIndex = null;
      _billingAddressIndex = null;
      sameAsBilling = false;
      if(!Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()){
        _newUser = apiResponse.response!.data['new_user'];
      }

      String message = apiResponse.response!.data.toString();
      callback(true, message, '', _newUser);
    } else {
      _isLoading = false;
     ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  void setAddressIndex(int index) {
    _addressIndex = index;
    notifyListeners();
  }
  void setBillingAddressIndex(int index) {
    _billingAddressIndex = index;
    notifyListeners();
  }


  void resetPaymentMethod(){
    _paymentMethodIndex = -1;
    codChecked = false;
    walletChecked = false;
    offlineChecked = false;
  }


  void shippingAddressNull(){
    _addressIndex = null;
    notifyListeners();
  }

  void billingAddressNull(){
    _billingAddressIndex = null;
    notifyListeners();
  }

  void setSelectedShippingAddress(int index) {
    _shippingIndex = index;
    notifyListeners();
  }
  void setSelectedBillingAddress(int index) {
    _billingAddressIndex = index;
    notifyListeners();
  }


  bool offlineChecked = false;
  bool codChecked = false;
  bool walletChecked = false;

  void setOfflineChecked(String type){
    if(type == 'offline'){
      offlineChecked = !offlineChecked;
      codChecked = false;
      walletChecked = false;
      _paymentMethodIndex = -1;
      setOfflinePaymentMethodSelectedIndex(0);
    }else if(type == 'cod'){
      codChecked = !codChecked;
      offlineChecked = false;
      walletChecked = false;
      _paymentMethodIndex = -1;
    }else if(type == 'wallet'){
      walletChecked = !walletChecked;
      offlineChecked = false;
      codChecked = false;
      _paymentMethodIndex = -1;
    }

    notifyListeners();
  }



  String selectedDigitalPaymentMethodName = '';

  void setDigitalPaymentMethodName(int index, String name) {
    _paymentMethodIndex = index;
    selectedDigitalPaymentMethodName = name;
    codChecked = false;
    walletChecked = false;
    offlineChecked = false;
    notifyListeners();
  }


  void digitalOnly(bool value, {bool isUpdate = false}){
    _onlyDigital = value;
    if(isUpdate){
      notifyListeners();
    }

  }



  OfflinePaymentModel? offlinePaymentModel;
  Future<ApiResponse> getOfflinePaymentList() async {
    ApiResponse apiResponse = await checkoutServiceInterface.offlinePaymentList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      offlineMethodSelectedIndex = 0;
      offlinePaymentModel = OfflinePaymentModel.fromJson(apiResponse.response?.data);
    }
    else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  List<TextEditingController> inputFieldControllerList = [];
  List <String?> keyList = [];
  int offlineMethodSelectedIndex = -1;
  int offlineMethodSelectedId = 0;
  String offlineMethodSelectedName = '';

  void setOfflinePaymentMethodSelectedIndex(int index, {bool notify = true}){
    keyList = [];
    inputFieldControllerList = [];
    offlineMethodSelectedIndex = index;
    if(offlinePaymentModel != null && offlinePaymentModel!.offlineMethods!= null && offlinePaymentModel!.offlineMethods!.isNotEmpty){
      offlineMethodSelectedId = offlinePaymentModel!.offlineMethods![offlineMethodSelectedIndex].id!;
      offlineMethodSelectedName = offlinePaymentModel!.offlineMethods![offlineMethodSelectedIndex].methodName!;
    }

    if(offlinePaymentModel!.offlineMethods != null && offlinePaymentModel!.offlineMethods!.isNotEmpty && offlinePaymentModel!.offlineMethods![index].methodInformations!.isNotEmpty){
      for(int i= 0; i< offlinePaymentModel!.offlineMethods![index].methodInformations!.length; i++){
        inputFieldControllerList.add(TextEditingController());
        keyList.add(offlinePaymentModel!.offlineMethods![index].methodInformations![i].customerInput);
      }
    }
    if(notify){
      notifyListeners();
    }

  }

  Future<ApiResponse> digitalPaymentPlaceOrder({String? orderNote, String? customerId,
    String? addressId,
    String? billingAddressId,
    String? couponCode,
    String? couponDiscount,
    String? paymentMethod}) async {
    _isLoading =true;



    ApiResponse apiResponse = await checkoutServiceInterface.digitalPaymentPlaceOrder(orderNote, customerId, addressId, billingAddressId, couponCode, couponDiscount, paymentMethod, _isCheckCreateAccount, passwordController.text.trim());
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _addressIndex = null;
      _billingAddressIndex = null;
      sameAsBilling = false;
      _isLoading = false;





     String orderId = apiResponse.response?.data['orderId'];
     int merchantOrderId = apiResponse.response?.data['merchantOrderId'];
     String tokenvar = apiResponse.response?.data['token'];


      Future.delayed(Duration(seconds: 3), () {
        startPhonePeTransaction(Get.context!,orderId, merchantOrderId.toString(), tokenvar);
      });


      // Navigator.pushReplacement(Get.context!, MaterialPageRoute(builder: (_) =>
      //     DigitalPaymentScreen(
      //     url: apiResponse.response?.data['redirect_link']
      //     )));



    } else if(apiResponse.error == 'Already registered '){
      _isLoading = false;
      showCustomSnackBar('${getTranslated(apiResponse.error, Get.context!)}', Get.context!);
    } else {
      _isLoading = false;
      showCustomSnackBar('${getTranslated('payment_method_not_properly_configured', Get.context!)}', Get.context!);
    }
    notifyListeners();
    return apiResponse;
  }

  bool sameAsBilling = false;
  void setSameAsBilling(){
    sameAsBilling = !sameAsBilling;
    notifyListeners();
  }

  void clearData(){
    orderNoteController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _isCheckCreateAccount = false;
  }


  void setIsCheckCreateAccount(bool isCheck, {bool update = true}) {
    _isCheckCreateAccount = isCheck;
    if(update) {
      notifyListeners();
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }


  Future<void> updatePaymentStatus(String merchantOrderId) async {
    final url = Uri.parse('https://manish-jewellers.com/api/v1/payment-status-update/$merchantOrderId');

    String? token = await getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // body: jsonEncode({
        //   // Optional: only include if the API expects a body
        //   'status': 'success',
        // }),
      );

      if (response.statusCode == 200) {
        print('✅ Payment orderrrr status updated successfully.');
        print('token h yhn $token');
        print('Final order payment Response: ${response.body}');
      }
      else {
        print('❌ Failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('⚠️ Error: $e');
    }
  }




  void startPhonePeTransaction(BuildContext context,String orderId, String merchantOrderId, String token) {
    try {
      Map<String, dynamic> payload = {
        "orderId": orderId,
        "merchantId": merchantOrderId,
        "token": token,
        "paymentMode": {"type": "PAY_PAGE"}
      };

      String request = jsonEncode(payload);
      print("Payment Request: $request");

      PhonePePaymentSdk.startTransaction(request, "appSchema") // replace with actual schema
          .then((response) {
        if (response != null) {
          String status = response['status'].toString();
          String error = response['error'].toString();
          if (status == 'SUCCESS') {
            print("Flow Completed - Status: Success!");
            // Navigate to payment status page or handle success


            print("Used order id: ${orderId} merchant order id: ${merchantOrderId}");

            updatePaymentStatus('$merchantOrderId');


            Future.delayed(Duration(seconds: 3), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentStatusPage(
                    id: merchantOrderId,
                  ), // Replace with your widget
                ),
              );
              print('Merchant order id :$merchantOrderId');
            });





          } else {
            print("Flow Completed - Status: $status and Error: $error");
            // Navigate to payment status page or handle error
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentStatusPage(
                  id: merchantOrderId,
                ), // Replace with your widget
              ),
            );
          }
        } else {
          print("Flow Incomplete");
          // Handle incomplete flow
        }
      }).catchError((error) {
        print("Error in transaction: $error");
        // Handle error
      });
    } catch (error) {
      print("Error: $error");
      // Handle error
    }
  }


}
