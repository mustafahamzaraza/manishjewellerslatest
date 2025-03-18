import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';



class GoldPriceScreenT extends StatefulWidget {
  @override
  _GoldPriceScreenTState createState() => _GoldPriceScreenTState();
}

class _GoldPriceScreenTState extends State<GoldPriceScreenT> {
  String price18k = "Loading...";
  String price22k = "Loading...";
  String price24k = "Loading...";
  String currentDateTime = "";

  TextEditingController cityController = TextEditingController();

  Future<void> fetchGoldPrices() async {
    const String apiUrl = "https://manish-jewellers.com/api/goldPriceService";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("$data");

        String dateTime = DateFormat("dd/MM/yyyy, hh:mm a").format(DateTime.now());

        setState(() {
          price18k = "₹${data['data']['price_gram']['18k_gst_included']}";
          price22k = "₹${data['data']['price_gram']['22k_gst_included']}";
          price24k = "₹${data['data']['price_gram']['24k_gst_included']}";
          currentDateTime = dateTime;
        });
      } else {
        setState(() {
          price18k = price22k = price24k = "Error fetching price";
          currentDateTime = "Error fetching time";
        });
      }
    } catch (e) {
      setState(() {
        price18k = price22k = price24k = "Error: ${e.toString()}";
        currentDateTime = "Error fetching time";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGoldPrices();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    double screenHeight = MediaQuery.of(context).size.height; // Get screen height

    return Scaffold(
      body: Container(
        // Gradient Background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFD700), // Gold
              Color(0xFFF5DEB3), // Wheat
              Color(0xFFEEE8AA), // Pale Goldenrod
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 0,
                    ),
                    Text(
                      "Manish Jewellers",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Serif",
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.only(right: screenWidth * 0.02),
                        child: Container(
                          height: screenWidth * 0.16,
                          width: screenWidth * 0.16,
                          decoration: BoxDecoration(
                             // border: Border.all(width: 0, color: Colors.white),
                              borderRadius: BorderRadius.circular(screenWidth * 0.06)),
                          child: Center(child:  Image(
                            image: AssetImage('assets/images/bg.png'),
                            height: 60,
                            width: 60,
                          ),),
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(height: 16),

                // Current Gold Rate
                Text(
                  "Current Gold Rate",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E1F2F),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Rate is for our store in Ahmedabad, Gujarat, India",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                SizedBox(height: 16),

                // Gold Price Containers
                goldPriceContainer("24KT", price24k),
                SizedBox(height: 12),
                goldPriceContainer("22KT", price22k),
                SizedBox(height: 12),
                goldPriceContainer("18KT", price18k),

                // Current Date-Time
                SizedBox(height: 16),
                Text(
                  currentDateTime,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),

                // Buttons for Alert and Advance
                SizedBox(height: 24),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // Gold Price Container Widget
  Widget goldPriceContainer(String title, String price) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Color(0xFFD4AF37), // Gold Border
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8E1F2F)),
          ),
          SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // Action Button Widget
  Widget actionButton(String text, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        if (text == "Make Advance") {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const GoldPurchasePlansScreen(),
          //   ),
          // );
        } else if (text == "Set Alert") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$text action triggered!")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFD4AF37),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


