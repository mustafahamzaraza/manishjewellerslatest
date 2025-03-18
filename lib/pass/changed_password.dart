import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../utill/colornew.dart';



class ChangedPasswordScreen extends StatefulWidget {
  const ChangedPasswordScreen({super.key});

  @override
  State<ChangedPasswordScreen> createState() => _ChangedPasswordScreenState();
}

class _ChangedPasswordScreenState extends State<ChangedPasswordScreen> {
  final TextEditingController changePasswordController = TextEditingController();
  final TextEditingController CchangePasswordController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();


  bool _isPasswordVisiblea = false;
  bool _isPasswordVisibleb = false;
  bool _isPasswordVisiblec = false;

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Returns the token or null if not found
  }

  Future<void> savePassword() async {
    String? token = await getToken();

    if (token != null) {
      final String url = 'http://manish-jewellers.com/api/changepassword';
      final Map<String, String> headers = {
        'Content-Type': 'application/json', // Standard JSON header
        'Authorization': 'Bearer $token',
      };

      // Prepare the request body
      final Map<String, String> body = {
        'current_password': currentPasswordController.text, // You can replace this with a variable
        'new_password': changePasswordController.text,
        'new_password_confirmation': CchangePasswordController.text,
      };

      try {
        // Create a multipart request
        var request = http.MultipartRequest('POST', Uri.parse(url))
          ..headers.addAll(headers)
          ..fields.addAll(body);

        // Send the request
        http.StreamedResponse response = await request.send();

        // Handle the response
        response.stream.transform(utf8.decoder).listen((value) {
          final responseData = json.decode(value);
          if (response.statusCode == 200) {
            if (responseData['message'] == 'Password changed successfully.') {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password changed successfully!')),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashBoardScreen(),
                ),
              );

            } else {
              // Handle unexpected response
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to change password.')),
              );
            }
          } else {
            // Handle error response
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to change password. Please try again.')),
            );
          }
        });
      } catch (error) {
        // Handle network or other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } else {
      // Token is not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found. Please log in again.')),
      );
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
          height: MediaQuery.of(context).size.height,
          color: AppColors.glowingGold, // Replace with your actual color
          child: Column(
            children: [
              // Top curved container
              Container(
                height: screenHeight * 0.4, // 40% of the screen height
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
                    // Logo section
                    Align(
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.1,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20, left: 10),
                                child: Image.asset(
                                  'assets/images/password.jpg',
                                  width: screenWidth * 0.6,
                                  height: screenWidth * 0.75,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 5, bottom: 130, top: 0, right: 45),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 2, color: Colors.black),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child:  Center(
                                    child: InkWell(
                                        onTap: (){
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => LoginScreen()),
                                          );
                                        },
                                        child: Icon(Icons.arrow_back)),
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
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.18, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: 35, // Font size relative to screen width
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Adjust with your color
                          height: 1
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Text(
                        "Your New Password Must Be Different from Previously Used Password",
                        style: TextStyle(
                          fontSize: screenWidth * 0.027,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                   //

                    Text(
                      "Current password",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      width: screenWidth * 0.8,
                      height: 35,
                      child: TextFormField(
                        controller: currentPasswordController,
                        obscureText: !_isPasswordVisiblea,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisiblea
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisiblea = !_isPasswordVisiblea;
                              });
                            },
                          ),
                          hintText: "*********",
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

                    SizedBox(height: 15),
                    // New password field




                    Text(
                      "New password",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      width: screenWidth * 0.8,
                      height: 35,
                      child: TextFormField(
                        controller: changePasswordController,
                        obscureText: !_isPasswordVisibleb,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisibleb
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisibleb = !_isPasswordVisibleb;
                              });
                            },
                          ),
                          hintText: "*********",
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
                    SizedBox(height: 15),
                    // Confirm password field
                    Text(
                      "Confirm password",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      width: screenWidth * 0.8,
                      height: 35,
                      child: TextFormField(
                        controller: CchangePasswordController,
                        obscureText: !_isPasswordVisiblec,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisiblec
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisiblec = !_isPasswordVisiblec;
                              });
                            },
                          ),
                          hintText: "*********",
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
                        onPressed: savePassword, // Call savePassword() on button press
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Save",
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
                                // Add navigation or other functionality if needed
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                "Change Password",
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



// import 'package:flutter/material.dart';
// import 'package:manishjeweleers/utils/color.dart';
//
// class ChangedPasswordScreen extends StatefulWidget {
//   const ChangedPasswordScreen({super.key});
//
//   @override
//   State<ChangedPasswordScreen> createState() => _ChangedPasswordScreenState();
// }
//
// class _ChangedPasswordScreenState extends State<ChangedPasswordScreen> {
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
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               SizedBox(
//                                 width: screenWidth * 0.1,
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.only(top: 20, left: 10),
//                                 child: Image.asset(
//                                   'assets/images/password.png',
//                                   width: screenWidth * 0.6,
//                                   height: screenWidth * 0.75,
//                                 ),
//                               ),
//                               Padding(
//                                   padding: EdgeInsets.only(
//                                       left: 5, bottom: 130, top: 0, right: 45),
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
//                         "Change Password",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.10, // Font size relative to screen width
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.textLight,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     SizedBox(height: 5),
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
//                     SizedBox(height: 20),
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
//                     SizedBox(height: 15),
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
//                     SizedBox(height: 5),
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
