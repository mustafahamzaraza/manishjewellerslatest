import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/screens/dashboard_screen.dart';

import 'dart:convert';

import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/pp.dart';


// To handle deep links


class WebViewScreenTwo extends StatefulWidget {
  final String redirectUrl;

  WebViewScreenTwo({
    required this.redirectUrl,

  });

  @override
  State<WebViewScreenTwo> createState() => _WebViewScreenTwoState();
}

class _WebViewScreenTwoState extends State<WebViewScreenTwo> {
  late InAppWebViewController _webViewController;
  late InAppWebView _webView;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Gateway'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(widget.redirectUrl),
          // If needed, add headers like 'x-rtb-fingerprint-id' here
          // headers: {'x-rtb-fingerprint-id': 'your-fingerprint-id'}
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
        },

        onTitleChanged: (controller, url) async {
          // Handle redirection after payment
          if (url.toString().contains("https://manish-jewellers.com/callback")) {

            print("Payment Success URL reached!");

            Navigator.pop(context); // Close the WebViewScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentHistoryList(), // Success Screen
              ),
            );
          }
          if (url.toString().contains("https://manish-jewellers.com/callback")) {
            Navigator.pop(context); // Close the WebViewScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentHistoryList(), // Failed Screen
              ),
            );
          }
        },
        onProgressChanged: (controller, progress) {
          // You can show a progress bar if needed
          // progress value ranges from 0 to 100
        },
        onLoadError: (controller, url, code, message) {
          print('Error loading page: $message');
        },


        //https://manish-jewellers.com/razorpay/callback
        onLoadStop: (controller, url) async {
          // Check if the current URL is the success URL
          if (url.toString().contains("https://manish-jewellers.com/callback")) {
            try {
              // Inject JavaScript to get the full page content (HTML body or JSON response)
              String? response = await controller.evaluateJavascript(
                source: "document.body.innerText",
              );

              print("Response: $response"); // Debug the content fetched from the page

              // If the response is in JSON format, parse it
              if (response != null && response.isNotEmpty) {
                final parsedResponse = jsonDecode(response);

                // Check if the message in the response is "Payment succeeded"
                if (parsedResponse['message'] == 'https://manish-jewellers.com/callback') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentHistoryList()),
                  );
                }
              }
            } catch (e) {
              print("Error parsing response: $e");
            }
          }


          // if (url.toString().contains("payment-success")) {
          //   try {
          //     // Inject JavaScript to get the full page content (HTML body or JSON response)
          //     String? response = await controller.evaluateJavascript(
          //       source: "document.body.innerText",
          //     );
          //
          //     print("Response: $response"); // Debug the content fetched from the page
          //
          //     // If the response is in JSON format, parse it
          //     if (response != null && response.isNotEmpty) {
          //       final parsedResponse = jsonDecode(response);
          //
          //       // Check if the message in the response is "Payment succeeded"
          //       if (parsedResponse['message'] == 'Payment succeeded') {
          //         Navigator.pushReplacement(
          //           context,
          //           MaterialPageRoute(builder: (context) => PaymentHistoryList()),
          //         );
          //       }
          //     }
          //   } catch (e) {
          //     print("Error parsing response: $e");
          //   }
          // }



          else if (url.toString().contains("payment-failed")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashBoardScreen()),
            );
          }
        },

      ),
    );
  }
}


