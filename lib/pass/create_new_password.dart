import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utill/colornew.dart';
import 'changed_password.dart';


class CreateNewPassword extends StatefulWidget {
  final String email;
  final String verificationCode;

  const CreateNewPassword({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  State<CreateNewPassword> createState() => _CreateNewPasswordState();
}

class _CreateNewPasswordState extends State<CreateNewPassword> {
  final TextEditingController changePasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> _changePassword() async {
    final String apiUrl = "http://manish-jewellers.com/api/resetPassword";

    if (changePasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    try {
      var request = http.Request("POST", Uri.parse(apiUrl));
      request.headers.addAll({"Content-Type": "application/json"});
      request.body = jsonEncode({
        "email": widget.email,
        "verification_code": widget.verificationCode,
        "password": changePasswordController.text.trim(),
        "password_confirmation": confirmPasswordController.text.trim(),
      });

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'] ?? "Password reset successfully.")),
        );

        // Navigate to the login screen or any other screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChangedPasswordScreen()),
        );
      } else {
        String errorResponse = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(errorResponse);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'] ?? "Password reset failed.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      // Hide loading indicator
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: screenHeight,
          color: AppColors.glowingGold,
          child: Column(
            children: [
              // Top curved container
              Container(
                height: screenHeight * 0.4,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(65),
                    bottomRight: Radius.circular(65),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo section
                    Align(
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(width: screenWidth * 0.1),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Image.asset('assets/images/lockpassword.jpg',
                                  width: screenWidth * 0.5,
                                  height: screenWidth * 0.65,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 130),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 2, color: Colors.black),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () => Navigator.pop(context),
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
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.18, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15,),
                    Center(
                      child: Text(
                        "Create New\nPassword",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Text(
                        "Your New Password M"
                            "ust Be Different from Previously Used Password",
                        style: TextStyle(
                          fontSize: screenWidth * 0.027,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 25),
                    // New password
                    const Text("New password"),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: changePasswordController,
                      decoration: InputDecoration(
                        hintText: "*********",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Confirm password
                    const Text("Confirm password"),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        hintText: "*********",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Save button
                    SizedBox(
                      width: screenWidth * 0.8,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
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
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:manishjeweleers/utils/color.dart';
//
// class CreateNewPassword extends StatefulWidget {
//   const CreateNewPassword({super.key});
//
//   @override
//   State<CreateNewPassword> createState() => _CreateNewPasswordState();
// }
//
// class _CreateNewPasswordState extends State<CreateNewPassword> {
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     final TextEditingController changePasswordController = TextEditingController();
//     final TextEditingController CchangePasswordController = TextEditingController();
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           width: double.infinity,
//           height: MediaQuery.of(context).size.height,
//           color: AppColors.glowingGold, // Background color of the app
//           child: Column(
//             children: [
//               // Top curved container
//               Container(
//                 height: screenHeight * 0.4, // 40% of the screen height
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(65),
//                     bottomRight: Radius.circular(65),
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Logo section
//                     Align(
//                       child: Stack(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               SizedBox(
//                                 width: screenWidth * 0.1,
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.only(top: 20, left: 0,right: 0),
//                                 child: Image.asset(
//                                   'assets/images/lockpassword.png',
//                                 //  width: screenWidth * 0.5,
//                                  // width: 100,
//                                  // height: screenWidth * 0.75,
//                                 ),
//                               ),
//                               Padding(
//                                   padding: EdgeInsets.only(
//                                       left: 0, bottom: 130, top: 0, right: 0),
//                                   // child: Image.asset(
//                                   //   'assets/images/circular.jpg', // MJ icon asset path
//                                   //   width: screenWidth * 0.13, // Adjust width based on screen width
//                                   //   height: screenWidth * 0.25, // Adjust height based on screen width
//                                   // ),
//                                   child:Container(
//                                     height: 40,
//                                     width: 40,
//                                     decoration: BoxDecoration(
//                                         border: Border.all(width: 2,color: Colors.black),
//                                         borderRadius: BorderRadius.circular(20)
//                                     ),
//                                     child: const Center(
//                                       child: Icon(Icons.arrow_back),
//                                     ),
//                                   )
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Bottom login form
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.18, vertical: 10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: Text(
//                         "Create New\n Password",
//                         style: TextStyle(
//                           fontSize: 25, // Font size relative to screen width
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.textLight,
//                           height: 1
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     SizedBox(height: 7),
//                     Center(
//                       child: Text(
//                         "Your New Password Must Be Different from Previously Used Password",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.027,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black.withOpacity(0.9),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     SizedBox(height: 15),
//                     // Label for Name
//                     Text(
//                       "New password",
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.035, // Font size relative to screen width
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black.withOpacity(0.5),
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     // Name input field
//                     Container(
//                       width: screenWidth * 0.8, // 80% of the screen width
//                       height: 45,
//                       child: TextFormField(
//                         controller: changePasswordController,
//                         decoration: InputDecoration(
//                           hintText: "*********",
//                           hintStyle: TextStyle(color: Colors.grey),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       "confirm password",
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.035, // Font size relative to screen width
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black.withOpacity(0.5),
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     // Name input field
//                     Container(
//                       width: screenWidth * 0.8, // 80% of the screen width
//                       height: 45,
//                       child: TextFormField(
//                         controller: CchangePasswordController,
//                         decoration: InputDecoration(
//                           hintText: "*********",
//                           hintStyle: TextStyle(color: Colors.grey),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 25),
//                     Container(
//                       width: screenWidth * 0.8, // 80% of the screen width
//                       height: 40,
//                       child: ElevatedButton(
//                         onPressed: () {},
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             "Save",
//                             style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 1),
//                     Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(height: 15),
//                           Container(
//                             height: 20,
//                             child: TextButton(
//                               onPressed: () {
//                                 // Navigator.push(
//                                 //   context,
//                                 //   MaterialPageRoute(builder: (context) => SignupScreen()),
//                                 // );
//                               },
//                               style: TextButton.styleFrom(
//                                 padding: EdgeInsets.zero,
//                               ),
//                               child: Text(
//                                 "Change Password",
//                                 style: TextStyle(
//                                   color: Colors.black.withOpacity(0.5),
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
