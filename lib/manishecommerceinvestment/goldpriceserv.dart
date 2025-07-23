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

        double original24k = double.tryParse(data['data']['price_gram']['24k_gst_included'].toString()) ?? 0;
        double discounted24k = original24k - 2500;
        double price22k = discounted24k * (91.6 / 99.9);

        return price22k;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching gold price: $e");
      return null;
    }
  }
}
