
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class CheckoutRepository implements CheckoutRepositoryInterface{
  final DioClient? dioClient;
  CheckoutRepository({required this.dioClient});


  @override
  Future<ApiResponse> cashOnDeliveryPlaceOrder(String? addressID, String? couponCode,String? couponDiscountAmount, String? billingAddressId, String? orderNote, bool? isCheckCreateAccount, String? password) async {
    int isCheckAccount = isCheckCreateAccount! ? 1: 0;
    try {
      final response = await dioClient!.get('${AppConstants.orderPlaceUri}?address_id=$addressID&coupon_code=$couponCode&coupon_discount=$couponDiscountAmount&billing_address_id=$billingAddressId&order_note=$orderNote&guest_id=${Provider.of<AuthController>(Get.context!, listen: false).getGuestToken()}&is_guest=${Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()? 0 :1 }&is_check_create_account=$isCheckAccount&password=$password');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  // void initPhonePeSdk(String environmentValue, String merchantId, String flowId, bool enableLogs) {
  //   PhonePePaymentSdk.init(environmentValue, merchantId, flowId, enableLogs)
  //       .then((isInitialized) {
  //     print("PhonePe SDK Initialized: $isInitialized");
  //     // You can update UI or state here
  //   }).catchError((error) {
  //     print("Error in initializing PhonePe SDK: $error");
  //     // Handle the error accordingly
  //   });
  // }

  @override
  Future<ApiResponse> offlinePaymentPlaceOrder(String? addressID, String? couponCode, String? couponDiscountAmount, String? billingAddressId, String? orderNote, List <String?> typeKey, List<String> typeValue, int? id, String name, String? paymentNote, bool? isCheckCreateAccount, String? password) async {
    try {
      Map<String?, String> fields = {};
      Map<String?, String> info = {};
      for(var i = 0; i < typeKey.length; i++){
        info.addAll(<String?, String>{
          typeKey[i] : typeValue[i]
        });
      }

      int isCheckAccount = isCheckCreateAccount! ? 1: 0;
      fields.addAll(<String, String>{
        "method_informations" : base64.encode(utf8.encode(jsonEncode(info))),
        'method_name': name,
        'method_id': id.toString(),
        'payment_note' : paymentNote??'',
        'address_id': addressID??'',
        'coupon_code' : couponCode??"",
        'coupon_discount' : couponDiscountAmount??'',
        'billing_address_id' : billingAddressId??'',
        'order_note' : orderNote??'',
        'guest_id': Provider.of<AuthController>(Get.context!, listen: false).getGuestToken()??'',
        'is_guest' : Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()? '0':'1',
        'is_check_create_account' : isCheckAccount.toString(),
        'password' : password ?? '',
      });

      // 👇 Debug log for the outgoing request
      print("🔼 Sending offline payment request to: ${AppConstants.offlinePayment}");
      print("🧾 Payload:");
      fields.forEach((key, value) {
        print("  $key: $value");
      });

      Response response = await dioClient!.post(AppConstants.offlinePayment, data: fields);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> walletPaymentPlaceOrder(
      String? addressID, String? couponCode,String? couponDiscountAmount, String? billingAddressId, String? orderNote, bool? isCheckCreateAccount, String? password) async {
    int isCheckAccount = isCheckCreateAccount! ? 1: 0;
    try {

      final response = await dioClient!.get(
        '${AppConstants.walletPayment}'
            '?address_id=$addressID'
            '&coupon_code=$couponCode'
            '&coupon_discount=$couponDiscountAmount'
            '&billing_address_id=$billingAddressId'
            '&order_note=$orderNote'
            '&guest_id=${Provider.of<AuthController>(Get.context!, listen: false).getGuestToken()}'
            '&is_guest=${Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()? 0 :1}'
            '&is_check_create_account='
            '$isCheckAccount&password=$password',);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> offlinePaymentList() async {
    try {
      final response = await dioClient!.get('${AppConstants.offlinePaymentList}?guest_id=${Provider.of<AuthController>(Get.context!, listen: false).getGuestToken()}&is_guest=${!Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> digitalPaymentPlaceOrder(
      String? orderNote,
      String? customerId,
      String? addressId,
      String? billingAddressId,
      String? couponCode,
      String? couponDiscount,
      String? paymentMethod,
      bool? isCheckCreateAccount,
      String? password
      ) async {

    try {
      int isCheckAccount = isCheckCreateAccount! ? 1: 0;
      Map<dynamic, dynamic> data = {
        "order_note": orderNote,
        "customer_id":  customerId,
        "address_id": addressId,
        "billing_address_id": billingAddressId,
        "coupon_code": couponCode,
        "coupon_discount": couponDiscount,
        "payment_platform" : "app",
        "payment_method" : paymentMethod,
        "callback" : null,
        "payment_request_from" : "app",
        'guest_id' : Provider.of<AuthController>(Get.context!, listen: false).getGuestToken(),
        'is_guest': !Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn(),
        'is_check_create_account' : isCheckAccount.toString(),
        'password' : password,
      };



      print("Request Payload Online: $data");

      final response = await dioClient!.post(
          AppConstants.digitalPayment, data: {
        "order_note": orderNote,
        "customer_id":  customerId,
        "address_id": addressId,
        "billing_address_id": billingAddressId,
        "coupon_code": couponCode,
        "coupon_discount": couponDiscount,
        "payment_platform" : "app",
        "payment_method" : paymentMethod,
        "callback" : null,
        "payment_request_from" : "app",
        'guest_id' : Provider.of<AuthController>(Get.context!, listen: false).getGuestToken(),
        'is_guest': !Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn(),
        'is_check_create_account' : isCheckAccount.toString(),
        'password' : password,
      });

      print("Payment Response Digital : ${response.data}");
      //
      // String merchantOrderId = response.data['merchantOrderId'];
      // String orderId = response.data['order_id'];
      // String token = response.data['token'];
      //
      //
      // print("Merchant ID: $merchantOrderId");
      // print("Order ID: $orderId");
      // print("Token: $token");

      // Now start the PhonePe transaction using the extracted IDs
      // startPhonePeTransaction(orderId, merchantOrderId, token);



      return ApiResponse.withSuccess(response);

    }
    catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));

    }
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }


  // Function to start PhonePe payment transaction
  // void startPhonePeTransaction(String orderId, String merchantOrderId, String token) {
  //   try {
  //     Map<String, dynamic> payload = {
  //       "orderId": orderId,
  //       "merchantId": merchantOrderId,
  //       "token": token,
  //       "paymentMode": {"type": "PAY_PAGE"}
  //     };
  //
  //     String request = jsonEncode(payload);
  //     print("Payment Request: $request");
  //
  //     PhonePePaymentSdk.startTransaction(request, "appSchema") // replace with actual schema
  //         .then((response) {
  //       if (response != null) {
  //         String status = response['status'].toString();
  //         String error = response['error'].toString();
  //         if (status == 'SUCCESS') {
  //           print("Flow Completed - Status: Success!");
  //           // Navigate to payment status page or handle success
  //         } else {
  //           print("Flow Completed - Status: $status and Error: $error");
  //           // Navigate to payment status page or handle error
  //         }
  //       } else {
  //         print("Flow Incomplete");
  //         // Handle incomplete flow
  //       }
  //     }).catchError((error) {
  //       print("Error in transaction: $error");
  //       // Handle error
  //     });
  //   } catch (error) {
  //     print("Error: $error");
  //     // Handle error
  //   }
  // }





}
