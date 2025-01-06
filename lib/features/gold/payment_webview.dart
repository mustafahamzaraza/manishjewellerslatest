import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_sixvalley_ecommerce/features/gold/planslistscreen.dart';
import 'package:flutter_sixvalley_ecommerce/features/gold/purchasedplansscreen.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/screens/home_screens.dart';
import '../../globalclass.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async'; // For StreamSubscription
import 'dart:convert';


 // To handle deep links


class WebViewScreen extends StatefulWidget {
  final String redirectUrl;
  final String plan;
  final String category;
  final int planAmount;
  final double goldAmount;
  final int totalpaymentyearly;
  final String startdate;
  final int paymentDone;
  final int paymentRemaining;
  final int id;

  WebViewScreen({
    required this.redirectUrl,
    required this.plan,
    required this.category,
    required this.planAmount,
    required this.goldAmount,
    required this.totalpaymentyearly,
    required this.startdate, // Accept goldAmount as a parameter
    required this.paymentDone,
    required this.paymentRemaining,
    required this.id,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
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
        // onConsoleMessage: (controller, consoleMessage) {
        //   print('Console Message: ${consoleMessage.message}');
        //   if (consoleMessage.toString().contains("Payment succeeded")) {
        //     myBool = true;
        //     Navigator.pop(context); // Close the WebViewScreen
        //     Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => PurchasedPlansList(),
        //       ),
        //     );
        //   }
        //   if (consoleMessage.toString().contains("payment-success")) {
        //     myBool = true;
        //     Navigator.pop(context); // Close the WebViewScreen
        //     Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => PurchasedPlansList(),
        //       ),
        //     );
        //   }
        // },

        onTitleChanged: (controller, url) async {
          // Handle redirection after payment
          if (url.toString().contains("https://altaibagold.com/payment-success")) {
            myBool = true;
            print("Payment Success URL reached!");

            Navigator.pop(context); // Close the WebViewScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PurchasedPlansList(), // Success Screen
              ),
            );
          }
          if (url.toString().contains("https://altaibagold.com/payment-success")) {
            Navigator.pop(context); // Close the WebViewScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(), // Failed Screen
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

        onLoadStop: (controller, url) async {
          // Check if the current URL is the success URL
          if (url.toString().contains("payment-success")) {
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
                if (parsedResponse['message'] == 'Payment succeeded') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PurchasedPlansList()),
                  );
                }
              }
            } catch (e) {
              print("Error parsing response: $e");
            }
          } else if (url.toString().contains("payment-failed")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },

      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_sixvalley_ecommerce/features/gold/planslistscreen.dart';
// import 'package:flutter_sixvalley_ecommerce/features/gold/purchasedplansscreen.dart';
// import 'package:flutter_sixvalley_ecommerce/features/home/screens/home_screens.dart';
// import '../../globalclass.dart';
//
//
// class WebViewScreen extends StatefulWidget {
//   final String redirectUrl;
//   final String plan;
//   final String category;
//   final int planAmount;
//   final double goldAmount;
//   final int totalpaymentyearly;
//   final String startdate;
//   final int paymentDone;
//   final int paymentRemaining;
//   final int id;
//
//   WebViewScreen(
//       {
//         required this.redirectUrl,
//         required this.plan,
//         required this.category,
//         required this.planAmount,
//         required this.goldAmount,
//         required this.totalpaymentyearly,
//         required this.startdate, // Accept goldAmount as a parameter
//         required this.paymentDone,
//         required this.paymentRemaining,
//         required this.id
//       });
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   //
//
//
//
//   late InAppWebViewController _webViewController;
//
//   late InAppWebView _webView;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//      appBar: AppBar(
//         title: Text('Transaction Gateway'),
//       ),
//       body: InAppWebView(
//         initialUrlRequest: URLRequest(
//           url: WebUri(widget.redirectUrl),
//          //   headers: {'x-rtb-fingerprint-id': 'your-fingerprint-id'}
//         ),
//
//         onWebViewCreated: (InAppWebViewController controller) {
//           _webViewController = controller;
//         },
//         onConsoleMessage: (controller, consoleMessage) {
//           // Handle console messages from JavaScript (printed in the console)
//           if(consoleMessage.toString().contains("Payment succeeded")){
//             myBool = true;
//             Navigator.pop(context); // Close the WebViewScreen
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PurchasedPlansList(), // Replace with your success screen
//               ),
//             );
//           }
//
//           print(consoleMessage.message);  // Here, you can print the JavaScript console logs
//         },
//
//         onTitleChanged: (controller, url) async{
//
//           if (url.toString().contains("https://altaibagold.com/payment-success?token")) { // Adjust based on your payment gateway's success URL
//
//             myBool = true;
//
//             print("success abd bool is $myBool");
//
//             Navigator.pop(context); // Close the WebViewScreen
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PurchasedPlansList(), // Replace with your success screen
//               ),
//             );
//           }
//           if(url.toString().contains('Payment succeeded')){
//             Navigator.pop(context); // Close the WebViewScreen
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PurchasedPlansList(), // Replace with your success screen
//               ),
//             );
//           }
//           if (url.toString().contains("https://altaibagold.com/payment-failed")) { // Adjust based on your payment gateway's success URL
//             Navigator.pop(context); // Close the WebViewScreen
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HomePage(), // Replace with your success screen
//               ),
//             );
//           }
//         },
//
//         onProgressChanged: (controller, progress) {
//           // You can show a progress bar if needed
//           // progress value ranges from 0 to 100
//         },
//         onLoadError: (controller, url, code, message) {
//           print('Error loading page: $message');
//         },
//
//       ),
//     );
//   }
// }
//
//
