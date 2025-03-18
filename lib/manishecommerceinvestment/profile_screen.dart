import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../pass/changed_password.dart';
import '../utill/colornew.dart';


class ProfileScreenT extends StatefulWidget {
  const ProfileScreenT({super.key});

  @override
  State<ProfileScreenT> createState() => _ProfileScreenTState();
}

class _ProfileScreenTState extends State<ProfileScreenT> {
  String name = '';
  String email = '';
  String mobileNo = '';
  String address = '';
  TextEditingController addressController = TextEditingController();


  String newAddress = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData(newAddress: '');
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }


  Future<void> signOut() async {

    String? token = await getToken();


    try {
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://manish-jewellers.com/api/logout'),
      );

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print("Logout Success: $responseBody");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token'); // Removes the token completely


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );


      } else {
        print("Logout Failed: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Smooth rounded corners
          ),
          elevation: 8, // Subtle shadow for a premium feel
          backgroundColor: Colors.white,
          title: const Text(
            "Sign Out",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600, // Slightly bolder for emphasis
              color: Color(0xFFFFD700), // Gold accent
            ),
            textAlign: TextAlign.center, // Center align for better aesthetics
          ),
          content: const Text(
            "Are you sure you want to sign out?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500, // Balanced weight for readability
              color: Colors.black87, // Slightly softer black for comfort
            ),
           // Centered text for better layout
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly, // Space buttons evenly
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Black for neutral cancel
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Red for warning
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.pop(context);
                signOut();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }




  Future<void> fetchProfileData({required String newAddress}) async {
    String? token = await getToken();
    try {
      final response = await http.post(
        Uri.parse('http://manish-jewellers.com/api/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "name": name,
          "email": email,
          "mobile_no": mobileNo,
          "address": newAddress ?? address
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('profile details $data');

        if (data['status'] == true) {
          setState(() {
            name = data['data']['name'] ?? ''; // Default to empty string if null
            email = data['data']['email'] ?? '';
            mobileNo = data['data']['mobile_no']?.toString() ?? '';
            address = data['data']['address'] ?? 'Not Provided'; // Default value
          });
        } else {
          print("Profile fetch failed");
        }
      } else {
        print("API call failed");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _showAddressDialog() {
    TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // White background
          title: const Text(
            "Update Address",
            style: TextStyle(
              fontWeight: FontWeight.bold, // Bold title
              fontSize: 18,
              color: Color(0xFFB76E79), // Gold color
            ),
          ),
          content: TextField(
            controller: addressController,
            style: const TextStyle(
              fontWeight: FontWeight.bold, // Bold text
              color: Color(0xFFFFD700), // Gold color
            ),
            decoration: InputDecoration(
              hintText: "Enter your address",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFAE7B5)), // Gold border
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFAE7B5), width: 2), // Gold border on focus
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Black for cancel
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                String newAddress = addressController.text.trim();
                if (newAddress.isNotEmpty) {
                  fetchProfileData(newAddress: newAddress);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700), // Gold color
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    double screenHeight = MediaQuery.of(context).size.height; //
    return Scaffold(
      backgroundColor:AppColors.textDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Row(
                      children: [

                        CircleAvatar(
                          radius: 37,
                          backgroundColor: Colors.black,
                          backgroundImage: AssetImage('assets/images/profile.jpg'),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5, // Adjust width
                          child: Text(
                            name.isNotEmpty ? name.toUpperCase() : "Cludia Alves",
                            overflow: TextOverflow.ellipsis, // Avoid overflow issue
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DashBoardScreen()),
                      );
                    },
                    child: Center(
                        child:  Padding(
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

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 25),
                child: Text(
                  "About Me",
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              rowWidgetContainer(
                name.isNotEmpty ? name : "name",
                "user name",
                Icons.person,
                    () {},
              ),
              const Divider(color: AppColors.textLight, thickness: 1, endIndent: 20, indent: 20),
              const SizedBox(height: 5),
              rowWidgetContainer(
                email.isNotEmpty ? email : "hellow@gmail.com",
                "emailaddress",
                Icons.mail,
                    () {

                    },
              ),
              const Divider(color: AppColors.textLight, thickness: 1, endIndent: 20, indent: 20),
              const SizedBox(height: 5),
              rowWidgetContainer(
                mobileNo.isNotEmpty ? mobileNo : "+1234567890",
                "phone number",
                Icons.phone,
                    () {},
              ),
              const Divider(color: AppColors.textLight, thickness: 1, endIndent: 20, indent: 20),
              const SizedBox(height: 5),

              rowWidgetContainer(address.isNotEmpty ? address : "Address", "address", Icons.location_on,

                    () {
                      print("Clicked");
                _showAddressDialog();
              },),


              const Divider(color: AppColors.textLight, thickness: 1, endIndent: 20, indent: 20),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 25),
                child: Text("Settings",
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              rowWidgetContainer("Change Password", "*******", Icons.key, () {
                print("Change Password clicked");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangedPasswordScreen()),
                      (route) => false,
                );
              }),
              const Divider(color: AppColors.textLight, thickness: 1, endIndent: 20, indent: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Image(
                          image: AssetImage("assets/images/signout.png"),
                          height: 80,
                          width: 70,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 0),
                        InkWell(
                          onTap: () {
                            print("Sign Out clicked");
                            _showSignOutDialog();

                          },
                          child: const Text(
                            "Sign Out",
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "",
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget rowWidgetContainer(String value, String name, IconData icons, VoidCallback ontap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: ontap,
          child: Row(
            children: [
              Container(
                height: 30,
                margin: const EdgeInsets.only(left: 20),
                width: 30,
                decoration: BoxDecoration(
                  color: AppColors.professionalBrown4,
                  border: Border.all(width: 0, color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icons,
                    color: AppColors.textDark,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLight,
                    ),
                  ),
                  // IconButton(
                  //   onPressed: ontap,
                  //   icon: const Icon(
                  //     Icons.edit,
                  //     color: Colors.grey, // Edit icon color
                  //     size: 20, // Edit icon size
                  //   ),
                  // ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(''),
                  if (name == "address" || name == "*******")
                    IconButton(
                      onPressed: ontap,
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.grey, // Edit icon color
                        size: 20, // Edit icon size
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}






