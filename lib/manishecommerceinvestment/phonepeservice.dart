import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment/payment_status.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment/upimer.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:uuid/uuid.dart';


class PhonePeService {
  String result = '';
  late String flowId;

  static final PhonePeService _instance = PhonePeService._internal();
  factory PhonePeService() => _instance;
  PhonePeService._internal();

  /// Generate a unique flow ID
  void getFlowId() {
    var uuid = Uuid();
    flowId = uuid.v4();
  }

  /// Initialize the PhonePe SDK
  Future<void> initPhonePeSdk({
    required BuildContext context,
    required String environmentValue,
    required String merchantId,
    required bool enableLogs,
    required Function(String result) onResult,
    required Function(dynamic error) onError,
  }) async {
    getFlowId();
    try {
      bool isInitialized = await PhonePePaymentSdk.init(
        environmentValue,
        merchantId,
        flowId,
        enableLogs,
      );
      result = 'PhonePe SDK Initialized - $isInitialized';
      onResult(result);
    } catch (error) {
      handleError(error, onError);
    }
  }

  /// Start the PhonePe transaction
  Future<void> startTransaction({
    required BuildContext context,
    required String requestOrderId,
    required String requestToken,
    required String merchantId,
    required String merchantOrderId,
    required String appSchema,
    required Function(String result) onResult,
    required Function(dynamic error) onError,
  }) async {
    try {
      Map<String, dynamic> payload = {
        "orderId": requestOrderId,
        "merchantId": merchantId,
        "token": requestToken,
        "paymentMode": {"type": "PAY_PAGE"}
      };

      String request = jsonEncode(payload);
      print("Payment Request: $request");

      var response = await PhonePePaymentSdk.startTransaction(request, appSchema);

      if (response != null) {
        String status = response['status'].toString();
        String error = response['error'].toString();
        if (status == 'SUCCESS') {
          result = "Flow Completed - Status: Success!";
        } else {
          result = "Flow Completed - Status: $status and Error: $error";
        }

        onResult(result);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentStatusPage(id: merchantOrderId),
          ),
        );
      } else {
        result = "Flow Incomplete";
        onResult(result);
      }
    } catch (error) {
      handleError(error, onError);
    }
  }

  /// Get installed UPI apps on Android
  Future<void> getInstalledApps({
    required Function(String result) onResult,
    required Function(dynamic error) onError,
  }) async {
    if (Platform.isAndroid) {
      await getInstalledUpiAppsForAndroid(onResult: onResult, onError: onError);
    } else {
      onResult("Develop Code");
    }
  }

  /// Get installed UPI apps for Android
  Future<void> getInstalledUpiAppsForAndroid({
    required Function(String result) onResult,
    required Function(dynamic error) onError,
  }) async {
    try {
      String? apps = await PhonePePaymentSdk.getUpiAppsForAndroid();
      if (apps != null) {
        Iterable l = json.decode(apps);
        List<UPIApp> upiApps = List<UPIApp>.from(l.map((model) => UPIApp.fromJson(model)));

        String appString = '';
        for (var element in upiApps) {
          appString += "${element.applicationName} ${element.version} ${element.packageName}\n";
        }
        result = 'Installed Upi Apps:\n$appString';
      } else {
        result = 'Installed Upi Apps - 0';
      }
      onResult(result);
    } catch (error) {
      handleError(error, onError);
    }
  }

  /// Handle errors
  void handleError(dynamic error, Function(dynamic error) onError) {
    if (error is Exception) {
      onError(error.toString());
    } else {
      onError(error);
    }
  }
}
