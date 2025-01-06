import 'dart:io';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/repositories/product_details_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/services/product_details_service_interface.dart';

class ProductDetailsService implements ProductDetailsServiceInterface{
  ProductDetailsRepositoryInterface productDetailsRepositoryInterface;

  ProductDetailsService({required this.productDetailsRepositoryInterface});

  @override
  Future get(String productID) async{
    return await productDetailsRepositoryInterface.get(productID);
  }



  //new
  @override
  Future getWithCarat(String productID, String carat) async {
    // Call the repository method to get product details with the selected carat
    return await productDetailsRepositoryInterface.getWithCarat(productID, carat);
  }
  //


  @override
  Future getCount(String productID) async{
    return await productDetailsRepositoryInterface.getCount(productID);
  }

  @override
  Future getSharableLink(String productID) async{
    return await productDetailsRepositoryInterface.getSharableLink(productID);
  }

  @override
  Future<HttpClientResponse> previewDownload(String url) async{
    return await productDetailsRepositoryInterface.previewDownload(url);
  }




}