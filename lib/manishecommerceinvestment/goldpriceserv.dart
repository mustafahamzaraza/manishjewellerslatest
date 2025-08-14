// lib/services/gold_price_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GoldPriceService {
  static const String _apiUrl = "https://manish-jewellers.com/api/v1/goldPriceService";



  static Future<double?> fetch22kPrice() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // double original24k = double.tryParse(data['data']['price_gram']['24k_gst_included'].toString()) ?? 0;
        // double discounted24k = original24k - 2500;
        // double price22k = discounted24k * (91.6 / 99.9);


        double price24KOriginal = double.parse(data['data']['price_gram']['24k_gst_included'].toString());

        double discountAmount = 0.0;
        // Apply discount to 24K price
        double discounted24K = price24KOriginal - discountAmount;

        // Calculate 22K and 18K prices based on discounted 24K
        double price22K = discounted24K * 0.916;
        double price18K = discounted24K * 0.75;
        print("$price22K $price18K");

        return price22K;



      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching gold price: $e");
      return null;
    }
  }


  static Future<double?> fetch18kPrice() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // double original24k = double.tryParse(data['data']['price_gram']['24k_gst_included'].toString()) ?? 0;
        // double discounted24k = original24k - 2500;
        // double price22k = discounted24k * (91.6 / 99.9);


        double price24KOriginal = double.parse(data['data']['price_gram']['24k_gst_included'].toString());

        double discountAmount = 0.0;
        // Apply discount to 24K price
        double discounted24K = price24KOriginal - discountAmount;

        // Calculate 22K and 18K prices based on discounted 24K
        double price22K = discounted24K * 0.916;
        double price18K = discounted24K * 0.75;
        print("$price22K $price18K");

        return price18K;

      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching gold price: $e");
      return null;
    }
  }


  static Future<double?> fetch24kPrice() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // double original24k = double.tryParse(data['data']['price_gram']['24k_gst_included'].toString()) ?? 0;
        // double discounted24k = original24k - 2500;
        // double price22k = discounted24k * (91.6 / 99.9);


        double price24KOriginal = double.parse(data['data']['price_gram']['24k_gst_included'].toString());

        double discountAmount = 0.0;
        // Apply discount to 24K price
        double discounted24K = price24KOriginal - discountAmount;

        // Calculate 22K and 18K prices based on discounted 24K
        double price22K = discounted24K * 0.916;
        double price18K = discounted24K * 0.75;
        print("$price22K $price18K");

        return discounted24K;

      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching gold price: $e");
      return null;
    }
  }

}
