import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentStatusPage extends StatefulWidget {
  final String id; // <-- accept merchantOrderId

  const PaymentStatusPage({Key? key, required this.id}) : super(key: key);

  @override
  _PaymentStatusPageState createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  String _response = 'Fetching...';

  @override
  void initState() {
    super.initState();
    fetchPaymentStatus();
  }


  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Returns the token or null if not found
  }

  Future<void> fetchPaymentStatus() async {

    String? token = await getToken();
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var request = http.Request(
      'POST',
      Uri.parse('https://manish-jewellers.com/api/v1/online-payment-status'),
    );
    request.bodyFields = {
      'merchantOrderId': widget.id,
    };
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseData = await response.stream.bytesToString();
        setState(() {
          _response = responseData;
        });

        print('Data $responseData');

      } else {
        setState(() {
          _response = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Exception: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Status'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_response),
        ),
      ),
    );
  }
}
