import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/pass/verify_your_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utill/colornew.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();


  Future<void> sendForgotPasswordRequest(BuildContext context) async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://manish-jewellers.com/api/forgot-password'),
    );

    final email = emailController.text.trim();

    // Validate email
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter your email address",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    // Add email to request fields
    request.fields.addAll({'email': email});

    // Add headers
    request.headers.addAll(headers);

    try {
      // Send the request
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonResponse['message'].toString(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerifyYourScreen(email: email,)),
        );


      } else {
        // Parse error response
        String errorResponse = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(errorResponse);

        print('Error Fields: ${request.fields}');
        print('Status Code: ${response.statusCode}');
        print('Reason Phrase: ${response.reasonPhrase}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonResponse["message"] ?? "Failed to send verification code",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "An error occurred: $e",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          color: AppColors.glowingGold,
          child: Column(
            children: [
              // Top curved container
              Container(
                height: screenHeight * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(65),
                    bottomRight: Radius.circular(65),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: screenWidth * 0.1),
                              Padding(
                                padding: EdgeInsets.only(top: 20, left: 50),
                                child: Image.asset(
                                  'assets/images/lock.jpg',
                                  width: screenWidth * 0.5,
                                  height: screenWidth * 0.65,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 5, bottom: 130, top: 0, right: 45),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 2, color: Colors.black),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.arrow_back),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom login form
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.18, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: screenWidth * 0.10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                          height: 1
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Text(
                        "Please Enter Your Email Address To Receive Verification Code",
                        style: TextStyle(
                          fontSize: screenWidth * 0.028,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Label for Email
                    Text(
                      "EMAIL ADDRESS",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: 5),
                    // Email input field
                    Container(
                      width: screenWidth * 0.8,
                      height: 45,
                      child: TextFormField(
                        controller: emailController,
                        onFieldSubmitted: (_) {
                          // Optionally handle the "Enter" key press
                        },
                        decoration: InputDecoration(
                          hintText: "  enter email",
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      width: screenWidth * 0.8,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => sendForgotPasswordRequest(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Send",
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 15),
                          Container(
                            height: 20,
                            child: TextButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => SignupScreen()),
                                // );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                "Signup !",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



