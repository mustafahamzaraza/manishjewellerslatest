import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utill/colornew.dart';
import 'create_new_password.dart';


class VerifyYourScreen extends StatefulWidget {
  final String email;

  const VerifyYourScreen({super.key, required this.email});

  @override
  State<VerifyYourScreen> createState() => _VerifyYourScreenState();
}

class _VerifyYourScreenState extends State<VerifyYourScreen> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyOTP() async {
    var headers = {
      'Content-Type': 'application/json',
    };

    var request = http.MultipartRequest('POST', Uri.parse('http://manish-jewellers.com/api/verify-code'));

    // Add the fields for email and verification code
    request.fields.addAll({
      'email': widget.email, // Get the email from the widget
      'verification_code': codeController.text.trim(), // Get the verification code from the TextField
    });

    // Add headers
    request.headers.addAll(headers);

    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      // Send the request
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody');
        var jsonResponse = jsonDecode(responseBody);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? "Verification successful."),
            backgroundColor: Colors.black,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to the next screen (if any)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreateNewPassword(
            email: widget.email,
            verificationCode: codeController.text.trim(),
          )),
        );
      } else {
        String errorResponse = await response.stream.bytesToString();
        print('Error Response: $errorResponse');
        var jsonResponse = jsonDecode(errorResponse);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? "Verification failed."),
            backgroundColor: Colors.black,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please try again."),
          backgroundColor: Colors.black,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
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
                child: Center(
                  child: Image.asset(
                    'assets/images/email.jpg',
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.65,
                  ),
                ),
              ),
              // Bottom login form
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Verify Your Email",
                        style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Text(
                        "Please Enter The Code Sent to ${widget.email}",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.7),
                          height: 1
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Verification Code",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: codeController,
                      decoration: InputDecoration(
                        hintText: "Enter verification code",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Verify",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Center(
                    //   child: TextButton(
                    //     onPressed: () {
                    //       // Resend code logic
                    //     },
                    //     child: Text(
                    //       "Resend Code",
                    //       style: TextStyle(
                    //         color: Colors.black.withOpacity(0.7),
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
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


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:manishjeweleers/utils/color.dart';
//
// class VerifyYourScreen extends StatefulWidget {
//   final String email;
//
//   const VerifyYourScreen({super.key, required this.email});
//
//   @override
//   State<VerifyYourScreen> createState() => _VerifyYourScreenState();
// }
//
// class _VerifyYourScreenState extends State<VerifyYourScreen> {
//   final TextEditingController codeController = TextEditingController();
//   bool isLoading = false;
//
//   Future<void> verifyOTP() async {
//     final String apiUrl = "http://manish-jewellers.com/api/verify-code";
//
//     // Show loading indicator
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "email": widget.email,
//           "verification_code": codeController.text.trim(),
//         }),
//       );
//
//       final responseData = jsonDecode(response.body);
//
//       if (response.statusCode == 200) {
//         // If verification is successful, show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(responseData['message'] ?? "Verification successful.")),
//         );
//
//         // Navigate to the next screen (if any)
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => NextScreen()),
//         // );
//       } else {
//         // Show error message if verification fails
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(responseData['message'] ?? "Verification failed.")),
//         );
//       }
//     } catch (error) {
//       // Handle network errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("An error occurred. Please try again.")),
//       );
//     } finally {
//       // Hide loading indicator
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           width: double.infinity,
//           height: screenHeight,
//           color: AppColors.glowingGold,
//           child: Column(
//             children: [
//               // Top curved container
//               Container(
//                 height: screenHeight * 0.4,
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(65),
//                     bottomRight: Radius.circular(65),
//                   ),
//                 ),
//                 child: Center(
//                   child: Image.asset(
//                     'assets/images/email.png',
//                     width: screenWidth * 0.5,
//                     height: screenWidth * 0.65,
//                   ),
//                 ),
//               ),
//               // Bottom login form
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: Text(
//                         "Verify Your Email",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.08,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.textLight,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Center(
//                       child: Text(
//                         "Please Enter The 4 Digit Code Sent to ${widget.email}",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.035,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black.withOpacity(0.7),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     Text(
//                       "Verification Code",
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.04,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black.withOpacity(0.6),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     TextFormField(
//                       controller: codeController,
//                       decoration: InputDecoration(
//                         hintText: "Enter verification code",
//                         hintStyle: const TextStyle(color: Colors.grey),
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     SizedBox(
//                       width: screenWidth * 0.8,
//                       child: ElevatedButton(
//                         onPressed: isLoading ? null : verifyOTP,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: isLoading
//                             ? const CircularProgressIndicator(
//                           color: Colors.white,
//                         )
//                             : const Text(
//                           "Verify",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Center(
//                       child: TextButton(
//                         onPressed: () {
//                           // Resend code logic
//                         },
//                         child: Text(
//                           "Resend Code",
//                           style: TextStyle(
//                             color: Colors.black.withOpacity(0.7),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
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
//
//
// // import 'package:flutter/material.dart';
// // import 'package:manishjeweleers/utils/color.dart';
// //
// // class VerifyYourScreen extends StatefulWidget {
// //   const VerifyYourScreen({super.key});
// //
// //   @override
// //   State<VerifyYourScreen> createState() => _VerifyYourScreenState();
// // }
// //
// // class _VerifyYourScreenState extends State<VerifyYourScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     double screenWidth = MediaQuery.of(context).size.width;
// //     double screenHeight = MediaQuery.of(context).size.height;
// //     final TextEditingController emailController = TextEditingController();
// //     return Scaffold(
// //       body: SingleChildScrollView(
// //         child: Container(
// //           width: double.infinity,
// //           height: MediaQuery.of(context).size.height,
// //           color: AppColors.glowingGold, // Background color of the app
// //           child: Column(
// //             children: [
// //               // Top curved container
// //               Container(
// //                 height: screenHeight * 0.4, // 40% of the screen height
// //                 width: double.infinity,
// //                 decoration: const BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.only(
// //                     bottomLeft: Radius.circular(65),
// //                     bottomRight: Radius.circular(65),
// //                   ),
// //                 ),
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     // Logo section
// //                     Align(
// //                       child: Stack(
// //                         children: [
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               SizedBox(
// //                                 width: screenWidth * 0.1,
// //                               ),
// //                               Padding(
// //                                 padding: const EdgeInsets.only(top: 20, left: 50),
// //                                 child: Image.asset(
// //                                   'assets/images/email.png', // MJ icon asset path
// //                                   width: screenWidth * 0.5, // Adjust width based on screen width
// //                                   height: screenWidth * 0.65, // Adjust height based on screen width
// //                                 ),
// //                               ),
// //                               Padding(
// //                                   padding: const EdgeInsets.only(
// //                                       left: 5, bottom: 130, top: 0, right: 45),
// //                                   // child: Image.asset(
// //                                   //   'assets/images/circular.jpg', // MJ icon asset path
// //                                   //   width: screenWidth * 0.13, // Adjust width based on screen width
// //                                   //   height: screenWidth * 0.25, // Adjust height based on screen width
// //                                   // ),
// //                                   child:InkWell(
// //                                     onTap: () {
// //                                       print("object");
// //                                     },
// //                                     child: Container(
// //                                       height: 40,
// //                                       width: 40,
// //                                       decoration: BoxDecoration(
// //                                           border: Border.all(width: 2,color: Colors.black),
// //                                           borderRadius: BorderRadius.circular(20)
// //                                       ),
// //                                       child: const Center(
// //                                         child: Icon(Icons.arrow_back),
// //                                       ),
// //                                     ),
// //                                   )
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               // Bottom login form
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.18, vertical: 20),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Center(
// //                       child: Text(
// //                         "Verify Your Email",
// //                         style: TextStyle(
// //                           fontSize: screenWidth * 0.10, // Font size relative to screen width
// //                           fontWeight: FontWeight.bold,
// //                           color: AppColors.textLight,
// //                          // fontStyle: FontStyle.normal
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 5),
// //                     Center(
// //                       child: Text(
// //                         "Please Enter The 4 Digit Code Send to your@email.com",
// //                         style: TextStyle(
// //                           fontSize: screenWidth * 0.029,
// //                           fontWeight: FontWeight.w500,
// //                           color: Colors.black.withOpacity(0.9),
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 25),
// //                     // Label for Name
// //                     Text(
// //                       "verification code",
// //                       style: TextStyle(
// //                         fontSize: screenWidth * 0.035, // Font size relative to screen width
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.black.withOpacity(0.5),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 5),
// //                     // Name input field
// //                     Container(
// //                       width: screenWidth * 0.8, // 80% of the screen width
// //                       height: 45,
// //                       child: TextFormField(
// //                         controller: emailController,
// //                         decoration: InputDecoration(
// //                           hintText: "  enter email",
// //                           hintStyle: const TextStyle(color: Colors.grey),
// //                           filled: true,
// //                           fillColor: Colors.white,
// //                           border: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                             borderSide: BorderSide.none,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 25),
// //                     Container(
// //                       width: screenWidth * 0.8, // 80% of the screen width
// //                       height: 40,
// //                       child: ElevatedButton(
// //                         onPressed: () {},
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.black,
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                         ),
// //                         child: const Center(
// //                           child: Text(
// //                             "Verify",
// //                             style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 5),
// //                     Center(
// //                       child: Column(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           const SizedBox(height: 15),
// //                           Container(
// //                             height: 20,
// //                             child: TextButton(
// //                               onPressed: () {
// //                                 // Navigator.push(
// //                                 //   context,
// //                                 //   MaterialPageRoute(builder: (context) => SignupScreen()),
// //                                 // );
// //                               },
// //                               style: TextButton.styleFrom(
// //                                 padding: EdgeInsets.zero,
// //                               ),
// //                               child: Text(
// //                                 "Resend Code",
// //                                 style: TextStyle(
// //                                   color: Colors.black.withOpacity(0.5),
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
