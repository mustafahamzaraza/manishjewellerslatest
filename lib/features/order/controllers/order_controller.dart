import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_sixvalley_ecommerce/data/local/cache_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/models/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/services/order_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';



class OrderController with ChangeNotifier {
  final OrderServiceInterface orderServiceInterface;
  OrderController({required this.orderServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  OrderModel? orderModel;
  OrderModel? deliveredOrderModel;


  Future<void> getOrderList(int offset, String status, {String? type}) async {
    // Print initial parameters for debugging
    print('Fetching orders with offset: $offset, status: $status, type: $type');

    // Check and retrieve cached response
    var localData = await database.getCacheResponseById(AppConstants.orderUri);
    if (type == 'reorder') {
      if (localData != null) {
        print('Local cache data found for reorder.');
        deliveredOrderModel = OrderModel.fromJson(jsonDecode(localData.response));
        notifyListeners();
      } else {
        print('No local cache data found for reorder.');
      }
    }

    // Reset orderModel if offset is 1
    if (offset == 1) {
      print('Resetting orderModel for offset 1');
      orderModel = null;
    }

    // Make API call to fetch order list
    ApiResponse apiResponse = await orderServiceInterface.getOrderList(offset, status, type: type);
    print('API call completed.');

    // Handle API response
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      print('API response status: ${apiResponse.response!.statusCode}');
      print('Response data: ${jsonEncode(apiResponse.response?.data)}');

      // If offset is 1, initialize or update orderModel
      if (offset == 1) {
        orderModel = OrderModel.fromJson(apiResponse.response?.data);
        print('Initialized orderModel for offset 1.');

        if (type == 'reorder') {
          deliveredOrderModel = OrderModel.fromJson(apiResponse.response?.data);
          print('Updated deliveredOrderModel for reorder.');

          // Update or insert into cache
          if (localData != null) {
            print('Updating local cache for reorder.');
            await database.updateCacheResponse(
              AppConstants.orderUri,
              CacheResponseCompanion(
                endPoint: const Value(AppConstants.orderUri),
                header: Value(jsonEncode(apiResponse.response!.headers.map)),
                response: Value(jsonEncode(apiResponse.response!.data)),
              ),
            );
          } else {
            print('Inserting new data into local cache.');
            await database.insertCacheResponse(
              CacheResponseCompanion(
                endPoint: const Value(AppConstants.orderUri),
                header: Value(jsonEncode(apiResponse.response!.headers.map)),
                response: Value(jsonEncode(apiResponse.response!.data)),
              ),
            );
          }
        }
      } else {
        // Append additional orders for pagination
        print('Adding orders for pagination.');
        orderModel!.orders!.addAll(OrderModel.fromJson(apiResponse.response?.data).orders!);
        orderModel!.offset = OrderModel.fromJson(apiResponse.response?.data).offset;
        orderModel!.totalSize = OrderModel.fromJson(apiResponse.response?.data).totalSize;
      }
    } else {
      // Handle API error
      print('Error occurred: ${apiResponse.error}');
      ApiChecker.checkApi(apiResponse);
    }

    // Notify listeners after changes
    print('Notifying listeners.');
    notifyListeners();
  }


   //default
  // Future<void> getOrderList(int offset, String status, {String? type}) async {
  //
  //   print('Fetching orders with offset: $offset, status: $status, type: $type');
  //   var localData =  await database.getCacheResponseById(AppConstants.orderUri);
  //
  //
  //
  //   if(type == 'reorder'){
  //     if(localData != null) {
  //       deliveredOrderModel = OrderModel.fromJson(jsonDecode(localData.response));
  //       notifyListeners();
  //     }
  //   }
  //
  //   if(offset == 1){
  //     orderModel = null;
  //   }
  //   ApiResponse apiResponse = await orderServiceInterface.getOrderList(offset, status, type: type);
  //   if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
  //     if(offset == 1){
  //       orderModel = OrderModel.fromJson(apiResponse.response?.data);
  //       if(type == 'reorder'){
  //         deliveredOrderModel = OrderModel.fromJson(apiResponse.response?.data);
  //
  //         if(localData != null) {
  //           await database.updateCacheResponse(AppConstants.orderUri, CacheResponseCompanion(
  //             endPoint: const Value(AppConstants.orderUri),
  //             header: Value(jsonEncode(apiResponse.response!.headers.map)),
  //             response: Value(jsonEncode(apiResponse.response!.data)),
  //           ));
  //         } else {
  //           await database.insertCacheResponse(
  //             CacheResponseCompanion(
  //               endPoint: const Value(AppConstants.orderUri),
  //               header: Value(jsonEncode(apiResponse.response!.headers.map)),
  //               response: Value(jsonEncode(apiResponse.response!.data)),
  //             ),
  //           );
  //         }
  //
  //       }
  //     }else {
  //       orderModel!.orders!.addAll(OrderModel.fromJson(apiResponse.response?.data).orders!);
  //       orderModel!.offset = OrderModel.fromJson(apiResponse.response?.data).offset;
  //       orderModel!.totalSize = OrderModel.fromJson(apiResponse.response?.data).totalSize;
  //     }
  //   }else{
  //     ApiChecker.checkApi(apiResponse);
  //   }
  //   notifyListeners();
  // }

  int _orderTypeIndex = 0;
  int get orderTypeIndex => _orderTypeIndex;

  String selectedType = 'ongoing';
  void setIndex(int index, {bool notify = true}) {
    _orderTypeIndex = index;
    if(_orderTypeIndex == 0){
      selectedType = 'ongoing';
      getOrderList(1, 'ongoing');
    }else if(_orderTypeIndex == 1){
      selectedType = 'delivered';
      getOrderList(1, 'delivered');
    }else if(_orderTypeIndex == 2){
      selectedType = 'canceled';
      getOrderList(1, 'canceled');
    }
    if(notify) {
      notifyListeners();
    }
  }


  Orders? trackingModel;
  Future<void> initTrackingInfo(String orderID) async {
      ApiResponse apiResponse = await orderServiceInterface.getTrackingInfo(orderID);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        trackingModel = Orders.fromJson(apiResponse.response!.data);
      }
      notifyListeners();
  }


  Future<ApiResponse> cancelOrder(BuildContext context, int? orderId) async {
    _isLoading = true;
    ApiResponse apiResponse = await orderServiceInterface.cancelOrder(orderId);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _isLoading = false;

    } else {
      _isLoading = false;
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

}
