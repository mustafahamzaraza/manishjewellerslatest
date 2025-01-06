import 'dart:io';
import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class ProductDetailsRepositoryInterface implements RepositoryInterface {
  // Updated get method with carat


  @override
 // Future<dynamic> get(String productID, String carat);
  Future<dynamic> getWithCarat(String productID, String carat);//new


  Future<dynamic> getCount(String productID);
  Future<dynamic> getSharableLink(String productID);
  Future<HttpClientResponse> previewDownload(String url);
}



// import 'dart:io';
// import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';
//
//
// abstract class ProductDetailsRepositoryInterface implements RepositoryInterface{
//   Future<dynamic> getCount(String productID);
//   Future<dynamic> getSharableLink(String productID);
//   Future<HttpClientResponse> previewDownload(String url);
//
// }