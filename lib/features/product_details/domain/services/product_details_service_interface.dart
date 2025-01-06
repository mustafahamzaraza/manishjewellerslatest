import 'dart:io';

abstract class ProductDetailsServiceInterface{
  Future<dynamic> get(String productID); // Original method
  Future<dynamic> getWithCarat(String productID, String carat);//new



  Future<dynamic> getCount(String productID);
  Future<dynamic> getSharableLink(String productID);
  Future<HttpClientResponse> previewDownload(String url);
}