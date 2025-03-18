import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utill/colornew.dart';


class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, String>> notifications = [];
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }


  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchNotifications() async {
    String? token = await getToken();
    if (token == null || token.isEmpty) {
      print("Error: Token is null or empty");
      setState(() => isLoading = false);
      return;
    }

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var url = Uri.parse('https://manish-jewellers.com/api/notifications');

    try {
      var response = await http.get(url, headers: headers);
      print("Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");

      // Log full response to inspect for extra content
      String responseBody = response.body;
      print("Full Response: $responseBody");

      // Remove BOM if present and trim whitespace
      if (responseBody.isNotEmpty && responseBody.codeUnitAt(0) == 0xFEFF) {
        responseBody = responseBody.substring(1);
      }
      responseBody = responseBody.trim();

      // Verify content type
      if (!(response.headers['content-type']?.contains('application/json') ?? false)) {
        print("Unexpected content-type: ${response.headers['content-type']}");
        setState(() => isLoading = false);
        return;
      }

      dynamic jsonResponse;
      try {
        jsonResponse = json.decode(responseBody);
      } catch (e) {
        print("Error decoding message: $e");
        print("Cleaned Response body: $responseBody");
        setState(() => isLoading = false);
        return;
      }

      if (response.statusCode == 200) {
        if (jsonResponse['data'] == null) {
          print('Error: Data field is null');
          setState(() => isLoading = false);
          return;
        }

        List<Map<String, String>> fetchedNotifications = [];
        for (var item in jsonResponse['data']) {
          var message = item['message'];
          fetchedNotifications.add({
            'id': item['id']?.toString() ?? '',
            'message': message?['message'] ?? '',
            'payment_date': message?['payment_date'] ?? '',
            'payment_time': message?['payment_time'] ?? '',
            'payment_type': message?['payment_type'] ?? '',
            'money_paid': message?['money_paid'] ?? '',
            'installment_id': message?['installment_id']?.toString() ?? '',
            'no_of_months': message?['no_of_months']?.toString() ?? '',
            'total_payment': message?['total_payment'] ?? '',
            'total_gold': message?['total_gold'] ?? '',
            'createdAt': item['created_at'] ?? '',
          });
        }

        setState(() {
          notifications = fetchedNotifications;
          isLoading = false;
        });
      } else {
        print("Error: ${response.reasonPhrase} (${response.statusCode})");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      setState(() => isLoading = false);
    }
  }










  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    double screenHeight = MediaQuery.of(context).size.height; // Get screen height

    return Scaffold(
      backgroundColor: AppColors.appBar6,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.03),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.03),
                    child: const Text("Notifications",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
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
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: screenHeight * 0.07,
                    width: screenWidth * 0.7,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xffcdcdcd),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search here',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(8.0), // Adjust padding if needed
                          child: Image.asset('assets/images/searchbar.png', width: 12, height: 12),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 10, left: 20, bottom: 5),
                      ),
                    ),
                  ),
                  SizedBox(width: 5,),
                  Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffcdcdcd), borderRadius: BorderRadius.circular(10)),
                    height: screenWidth * 0.14,
                    width: screenWidth * 0.14,
                    child: const Image(
                      image: AssetImage('assets/images/e.png'),
                      height: 65,
                      width: 50,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Transaction",
                        style: TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      RichText(
                        text: const TextSpan(
                          text: 'Sort by',
                          style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w400, fontSize: 13),
                          children: [
                            TextSpan(
                              text: '\tLatest',
                              style: TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),




              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (notifications.isEmpty)
                const Center(child: Text("No notifications available", style: TextStyle(color: AppColors.textLight)))
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchNotifications,
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {

                        final notification = notifications[index];

                        final dynamic message = notification['message'];

                        Map<String, dynamic> details = {};

                        if (message is Map<String, dynamic>) {
                          details = message; // If it's already a Map, use it directly
                        } else if (message is String) {
                          try {
                            details = jsonDecode(message) as Map<String, dynamic>;
                          } catch (e) {
                            print("Error decoding message: $e");
                          }
                        }

                        print(details); // Debugging output




                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.005),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  height: screenWidth * 0.1,
                                  width: screenWidth * 0.1,
                                  decoration: BoxDecoration(
                                    color: AppColors.glowingGold,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Image(
                                    image: AssetImage('assets/images/umbrella.png'),
                                    height: 50,
                                  ),
                                ),
                                // title: Text(
                                //   details['message']?.toString() ?? "No message",
                                //   style: const TextStyle(
                                //     fontSize: 14,
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.black,
                                //     height: 1,
                                //   ),
                                // ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${details['payment_type'] ?? 'Cash'}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          "${details['money_paid']?.toString() ?? '2220.00'}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${details['payment_date'] ?? 'Feb 4th,'} ${details['payment_time'] ?? '2025'}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),

                                        Text(
                                          "${notification['created_at']?.toString() ?? '12:30 PM'}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    )



                                  ],
                                ),
                              ),
                              const Divider(
                                color: AppColors.textLight,
                                indent: 1,
                                thickness: 1,
                                endIndent: 1,
                              ),

                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}



