import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GoldCaratScreen extends StatefulWidget {
  @override
  _GoldCaratScreenState createState() => _GoldCaratScreenState();
}

class _GoldCaratScreenState extends State<GoldCaratScreen> {
  String _selectedCarat = "24 Carat";
  double price24k = 0.0;
  double price22k = 0.0;
  double price18k = 0.0;
  double goldAmount = 0.0;
  String currentDateTime = "";
  double totalMoney = 200000.0; // Fixed balance

  @override
  void initState() {
    super.initState();
    fetchGoldPrices();
  }

  // Fetch Gold Prices from API
  Future<void> fetchGoldPrices() async {
    const String apiUrl = "https://manish-jewellers.com/api/v1/goldPriceService";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double original24k = double.tryParse(data['data']['price_gram']['24k_gst_included'].toString()) ?? 0;


        print('data $data');

        double discounted24k = original24k - 2500; // Apply ₹2500 discount
        // Calculate 22k and 18k price based on new 24k price
        double new22k = discounted24k * (91.6 / 99.9);
        double new18k = discounted24k * (75 / 99.9);

        String dateTime = DateFormat("dd/MM/yyyy, hh:mm a").format(DateTime.now());

        setState(() {
          price24k = discounted24k;
          price22k = new22k;
          price18k = new18k;
          currentDateTime = dateTime;

          _calculateGoldAmount();
        });
      } else {
        setState(() {
          price18k = price22k = price24k = 0.0;
          currentDateTime = "Error fetching time";
        });
      }
    } catch (e) {
      setState(() {
        price18k = price22k = price24k = 0.0;
        currentDateTime = "Error: ${e.toString()}";
      });
    }
  }

  // Calculate Gold Amount including Making Charges
  void _calculateGoldAmount() {
    double pricePerGram;
    double makingCharge = 0;

    switch (_selectedCarat) {
      case "24 Carat":
        pricePerGram = price24k;
        makingCharge = 100;
        break;
      case "22 Carat":
        pricePerGram = price22k;
        makingCharge = 1000;
        break;
      case "18 Carat":
        pricePerGram = price18k;
        makingCharge = 1300;
        break;
      default:
        pricePerGram = 0;
    }

    setState(() {
      if (pricePerGram > 0) {
        double effectivePricePerGram = pricePerGram + makingCharge;
        goldAmount = totalMoney / effectivePricePerGram;
      } else {
        goldAmount = 0.0;
      }
    });
  }

  // Update Calculation when user selects a different carat
  void _onCaratSelected(String carat) {
    setState(() {
      _selectedCarat = carat;
      _calculateGoldAmount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Gold Rate',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: fetchGoldPrices,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Select Gold Carat"),
              _goldCaratOption("24 Carat"),
              _goldCaratOption("22 Carat"),
              _goldCaratOption("18 Carat"),
              SizedBox(height: 15),
              _infoBox("Selected Carat Price", "₹${_getSelectedPrice().toStringAsFixed(2)}"),
              _infoBox("Making Charge per gram", "₹${_getMakingCharge()}"),
              _infoBox("Your Total Balance", "₹2,00,000"),
              _infoBox("Total Gold Balance", "${goldAmount.toStringAsFixed(2)} gm"),
              SizedBox(height: 15),
              _lastUpdatedInfo(),
            ],
          ),
        ),
      ),
    );
  }

  // Gold Carat Selection Widget
  Widget _goldCaratOption(String title) {
    double price = (title == "24 Carat") ? price24k : (title == "22 Carat") ? price22k : price18k;

    return Column(
      children: [
        InkWell(
          onTap: () => _onCaratSelected(title),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: title,
                    groupValue: _selectedCarat,
                    onChanged: (String? newValue) => _onCaratSelected(newValue!),
                  ),
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                "₹${price.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        ),
        Divider(thickness: 1.5, color: Colors.grey.shade300),
      ],
    );
  }

  // Get selected carat price
  double _getSelectedPrice() {
    switch (_selectedCarat) {
      case "24 Carat":
        return price24k;
      case "22 Carat":
        return price22k;
      case "18 Carat":
        return price18k;
      default:
        return 0.0;
    }
  }

  // Get making charge for selected carat
  String _getMakingCharge() {
    switch (_selectedCarat) {
      case "24 Carat":
        return "100";
      case "22 Carat":
        return "1000";
      case "18 Carat":
        return "1300";
      default:
        return "0";
    }
  }

  // Section Title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Information Box
  Widget _infoBox(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  // Last Updated Info
  Widget _lastUpdatedInfo() {
    return Center(
      child: Text("Last Updated: $currentDateTime", style: TextStyle(color: Colors.grey)),
    );
  }
}




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
//
// class GoldCaratScreen extends StatefulWidget {
//   @override
//   _GoldCaratScreenState createState() => _GoldCaratScreenState();
// }
//
// class _GoldCaratScreenState extends State<GoldCaratScreen> {
//   String _selectedCarat = "24 Carat";
//   String price24k = "Loading...";
//   String price22k = "Loading...";
//   String price18k = "Loading...";
//   double goldAmount = 0.0;
//   String currentDateTime = "";
//   double totalMoney = 200000.0; // Fixed balance of 2 lakh rupees
//
//   @override
//   void initState() {
//     super.initState();
//     fetchGoldPrices();
//   }
//
//   // Fetch Gold Prices from API
//   Future<void> fetchGoldPrices() async {
//     const String apiUrl = "https://manish-jewellers.com/api/v1/goldPriceService";
//
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         String dateTime = DateFormat("dd/MM/yyyy, hh:mm a").format(DateTime.now());
//
//         setState(() {
//           price18k = data['data']['price_gram']['18k_gst_included'].toString();
//           price22k = data['data']['price_gram']['22k_gst_included'].toString();
//           price24k = data['data']['price_gram']['24k_gst_included'].toString();
//           currentDateTime = dateTime;
//
//           _calculateGoldAmount();
//         });
//       } else {
//         setState(() {
//           price18k = price22k = price24k = "Error fetching price";
//           currentDateTime = "Error fetching time";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         price18k = price22k = price24k = "Error: ${e.toString()}";
//         currentDateTime = "Error fetching time";
//       });
//     }
//   }
//
//   // Calculate Gold Amount including Making Charges
//   void _calculateGoldAmount() {
//     double pricePerGram;
//     double makingCharge = 0;
//
//     switch (_selectedCarat) {
//       case "24 Carat":
//         pricePerGram = double.tryParse(price24k) ?? 0;
//         makingCharge = 100;
//         break;
//       case "22 Carat":
//         pricePerGram = double.tryParse(price22k) ?? 0;
//         makingCharge = 1000;
//         break;
//       case "18 Carat":
//         pricePerGram = double.tryParse(price18k) ?? 0;
//         makingCharge = 1300;
//         break;
//       default:
//         pricePerGram = 0;
//     }
//
//     setState(() {
//       if (pricePerGram > 0) {
//         double effectivePricePerGram = pricePerGram + makingCharge;
//         goldAmount = totalMoney / effectivePricePerGram;
//       } else {
//         goldAmount = 0.0;
//       }
//     });
//   }
//
//   // Update Calculation when user selects a different carat
//   void _onCaratSelected(String carat) {
//     setState(() {
//       _selectedCarat = carat;
//       _calculateGoldAmount();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           'Gold Rate',
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         iconTheme: IconThemeData(color: Colors.black),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh, color: Colors.black),
//             onPressed: fetchGoldPrices,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _sectionTitle("Select Gold Carat"),
//               _goldCaratOption("24 Carat"),
//               _goldCaratOption("22 Carat"),
//               _goldCaratOption("18 Carat"),
//               SizedBox(height: 15),
//
//               _infoBox("Selected Carat Price", "₹${_getSelectedPrice()}"),
//               _infoBox("Making Charge per gram", "₹${_getMakingCharge()}"),
//               _infoBox("Your Total Balance", "₹2,00,000"),
//               _infoBox("Total Gold Balance", "${goldAmount.toStringAsFixed(2)} gm"),
//
//               SizedBox(height: 15),
//               _lastUpdatedInfo(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Gold Carat Selection Widget
//   Widget _goldCaratOption(String title) {
//     return Column(
//       children: [
//         InkWell(
//           onTap: () => _onCaratSelected(title),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Radio<String>(
//                     value: title,
//                     groupValue: _selectedCarat,
//                     onChanged: (String? newValue) => _onCaratSelected(newValue!),
//                   ),
//                   Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               Text(
//                 "₹${title == "24 Carat" ? price24k : title == "22 Carat" ? price22k : price18k}",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
//               ),
//             ],
//           ),
//         ),
//         Divider(thickness: 1.5, color: Colors.grey.shade300),
//       ],
//     );
//   }
//
//   // Get selected carat price
//   String _getSelectedPrice() {
//     switch (_selectedCarat) {
//       case "24 Carat":
//         return price24k;
//       case "22 Carat":
//         return price22k;
//       case "18 Carat":
//         return price18k;
//       default:
//         return "Error";
//     }
//   }
//
//   // Get making charge for selected carat
//   String _getMakingCharge() {
//     switch (_selectedCarat) {
//       case "24 Carat":
//         return "100";
//       case "22 Carat":
//         return "1000";
//       case "18 Carat":
//         return "1300";
//       default:
//         return "0";
//     }
//   }
//
//   // Section Title
//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Text(
//         title,
//         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   // Information Box
//   Widget _infoBox(String title, String value) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10),
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.grey.shade100,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: TextStyle(fontSize: 18)),
//           Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
//         ],
//       ),
//     );
//   }
//
//   // Last Updated Info
//   Widget _lastUpdatedInfo() {
//     return Center(
//       child: Text("Last Updated: $currentDateTime", style: TextStyle(color: Colors.grey)),
//     );
//   }
// }
