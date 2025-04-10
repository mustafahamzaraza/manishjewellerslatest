import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/plandetails.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class RemainingPlansScreen extends StatefulWidget {
  const RemainingPlansScreen({Key? key}) : super(key: key);

  @override
  State<RemainingPlansScreen> createState() => _RemainingPlansScreenState();
}

class _RemainingPlansScreenState extends State<RemainingPlansScreen> {
  List<String> purchasedPlanCodes = []; // Store purchased plans

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Returns the token or null if not found
  }

  Future<void> fetchUserPlans() async {
    String? token = await getToken();
    final String url = 'http://manish-jewellers.com/api/v1/user-plans';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          List<dynamic> plans = responseData['data']['plans'];
          print('plans $plans');

          if (plans.isNotEmpty) {
            setState(() {
              purchasedPlanCodes =
                  plans.map((plan) => plan['plan_code'].toString()).toList();
            });
          }
        }
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserPlans();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    double screenHeight = MediaQuery.of(context).size.height; //

    return Scaffold(
      body: Column(
        children: [

          SizedBox(height: 50,),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Investment\nPlans",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DashBoardScreen()),
                      );
                    },
                    child: Center(
                        child:
                          Padding(
                            padding: EdgeInsets.only(right: screenWidth * 0.02),
                            child: Container(
                              height: screenWidth * 0.16,
                              width: screenWidth * 0.16,
                              decoration: BoxDecoration(
                                  border: Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(screenWidth * 0.06)),
                              child: Center(child:  Image(
                                image: AssetImage('assets/images/bg.png'),
                                height: 60,
                                width: 60,
                              ),),
                            ),
                          ),

                    )
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              children: [
                if (!purchasedPlanCodes.contains("INR"))
                  _buildPlanCard(
                    context,
                    "First Plan",
                    "13 Months (12+1)",
                    "Invest for 12 months, & we pay your 13th installment!",
                    Colors.yellow.shade300,
                    1,
                  ),
                const SizedBox(height: 33),
                if (!purchasedPlanCodes.contains("SNR"))
                  _buildPlanCard(
                    context,
                    "Second Plan",
                    "20 Months (18+2)",
                    "Invest for 18 months, & we pay your 19–20th installment!",
                    Colors.yellow.shade300,
                    2,
                  ),
                const SizedBox(height: 33),
                if (!purchasedPlanCodes.contains("TNR"))
                  _buildPlanCard(
                    context,
                    "Third Plan",
                    "28 Months (24+4)",
                    "Invest for 24 months, & we pay your 25–28th installment!",
                    Colors.yellow.shade300,
                    3,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
      BuildContext context,
      String title,
      String duration,
      String description,
      Color color,
      int planId,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlanDetailScreen(planId: planId),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 5.3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset(
                      'assets/images/check.png',
                      fit: BoxFit.cover,
                      width: 60,
                      height: 30,
                    )
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  duration,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -15,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.black,
                child: const Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
