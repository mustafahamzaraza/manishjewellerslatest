import 'dart:convert';
import 'package:http/http.dart' as http;


// class GoldPriceService {
//   Future<double> getGoldPrice() async {
//     // Fetch the API response
//     final response = await http.get(Uri.parse('https://api.example.com/goldprice'));
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       double pricePerOunce = data['data']['price']; // Assume it's in USD/INR per ounce
//
//       // Convert to price per gram
//       double pricePerGram = pricePerOunce / 31.1035; // Ounce to gram conversion
//       return pricePerGram;
//     } else {
//       throw Exception('Failed to fetch gold price');
//     }
//   }
// }


//
class GoldPriceService {
  final String apiKey = 'goldapi-dvgksm3sjecks-io'; // Your provided API key

  // The GoldAPI endpoint for getting gold prices
  final String url = 'https://www.goldapi.io/api/XAU/INR';

  Future<double> getGoldPrice() async {
    try {
      // Send the GET request with the required headers
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-access-token': apiKey,  // Include the API key in the headers
        },
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the response contains the gold price key
        if (data.containsKey('price')) {
          return data['price'];  // Return the gold price
        } else {
          throw Exception('Price data not found in response');
        }
      } else {
        throw Exception('Failed to load gold price. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}