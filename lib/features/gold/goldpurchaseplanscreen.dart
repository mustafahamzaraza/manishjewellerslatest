import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import 'paymentdetailsscreen.dart'; // Assuming this exists

class GoldPurchasePlansScreen extends StatefulWidget {
  const GoldPurchasePlansScreen({Key? key}) : super(key: key);

  @override
  State<GoldPurchasePlansScreen> createState() => _GoldPurchasePlansScreenState();
}

class _GoldPurchasePlansScreenState extends State<GoldPurchasePlansScreen> {
  String? selectedPlan; // Stores the selected plan
  String? selectedCategory; // Stores the selected category
  int? planAmount; // Amount of the selected plan
  double? goldAmount; // Gold weight in grams
  bool hasAcceptedTerms = false;

  // Live gold prices
  double price18k = 0.0;
  double price22k = 0.0;
  double price24k = 0.0;

  // Function to fetch live gold prices from the API
  Future<void> fetchGoldPrices() async {
    const String apiUrl = "https://altaibagold.com/api/v1/goldPriceService";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          price18k = double.parse(data['data']['price_gram']['18k_gst_included'].toString());
          price22k = double.parse(data['data']['price_gram']['22k_gst_included'].toString());
          price24k = double.parse(data['data']['price_gram']['24k_gst_included'].toString());
        });
      } else {
        setState(() {
          price18k = price22k = price24k = 0.0; // Set to 0 on error
        });
      }
    } catch (e) {
      setState(() {
        price18k = price22k = price24k = 0.0; // Handle API failure
      });
    }
  }

  // Function to calculate gold weight based on the selected plan and category
  void _calculateGoldAmount() {
    if (selectedCategory != null && planAmount != null) {
      double selectedPricePerGram;

      // Determine the price per gram based on the selected category
      if (selectedCategory == '18 Carat Jewellery') {
        selectedPricePerGram = price18k;
      } else if (selectedCategory == '22 Carat Jewellery') {
        selectedPricePerGram = price22k;
      } else if (selectedCategory == '24 Carat Coin') {
        selectedPricePerGram = price24k;
      } else {
        selectedPricePerGram = 0.0;
      }

      // Calculate gold weight (grams)
      if (selectedPricePerGram > 0) {
        goldAmount = planAmount! / selectedPricePerGram;
        goldAmount = double.parse(goldAmount!.toStringAsFixed(5)); // Round to 2 decimal places
      } else {
        goldAmount = 0.0; // Price unavailable
      }
    }
  }







  // Function to open the Terms and Conditions URL
  Future<void> _openTermsAndConditions() async {
    const url = 'https://altaibagold.com/terms-and-condition';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGoldPrices(); // Fetch gold prices when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  "Premium Gold Purchase Plans",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Serif",
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select a Plan:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPlanOption(
                  'Plan Code: GP5000',
                  5000,
                  'Pay Rs 5000, 11 times a year (Total Rs 55,000/year)',
                ),
                const SizedBox(height: 12),
                _buildPlanOption(
                  'Plan Code: GP10000',
                  10000,
                  'Pay Rs 10,000, 11 times a year (Total Rs 1,10,000/year)',
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select a Category:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryOption('24 Carat Coin'),
                _buildCategoryOption('22 Carat Jewellery'),
                _buildCategoryOption('18 Carat Jewellery'),
                if (goldAmount != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Purchased Gold Weight:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${goldAmount?.toStringAsFixed(5)} grams',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: hasAcceptedTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          hasAcceptedTerms = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFFD4AF37),
                    ),
                    const Text('I accept the'),
                    GestureDetector(
                      onTap: _openTermsAndConditions,
                      child: const Text(
                        ' Terms & Conditions',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: selectedPlan != null &&
                      selectedCategory != null &&
                      hasAcceptedTerms
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentDetailsScreen(
                          id: 0,
                          selectedPlan: selectedPlan!,
                          selectedCategory: selectedCategory!,
                          planAmount: planAmount!,
                          goldAmount: goldAmount!,
                          paymentDone: '0',
                          paymentRemaining: '0',

                        ),
                      ),
                    );
                  }
                      : null, // Disable if terms not accepted
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Plan Option Widget
  Widget _buildPlanOption(String planCode, int amount, String description) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = planCode;
          planAmount = amount;
          _calculateGoldAmount(); // Recalculate gold on plan selection
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selectedPlan == planCode ? Colors.amber[100] : Colors.white,
          border: Border.all(
            color: selectedPlan == planCode ? const Color(0xFFD4AF37) : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planCode,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8E1F2F)),
            ),
            const SizedBox(height: 4),
            Text(
              'Rs $amount (11 payments/year)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Category Option Widget
  Widget _buildCategoryOption(String category) {
    return RadioListTile<String>(
      title: Text(
        category,
        style: const TextStyle(color: Color(0xFF8E1F2F)),
      ),
      value: category,
      groupValue: selectedCategory,
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
          _calculateGoldAmount(); // Recalculate gold on category selection
        });
      },
      activeColor: const Color(0xFFD4AF37),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // Add for launching URL
// import 'paymentdetailsscreen.dart'; // Assuming this exists for navigation to payment screen
//
// class GoldPurchasePlansScreen extends StatefulWidget {
//   const GoldPurchasePlansScreen({Key? key}) : super(key: key);
//
//   @override
//   State<GoldPurchasePlansScreen> createState() => _GoldPurchasePlansScreenState();
// }
//
// class _GoldPurchasePlansScreenState extends State<GoldPurchasePlansScreen> {
//   String? selectedPlan;
//   String? selectedCategory;
//   int? planAmount; // Stores the amount of the selected plan
//   double? goldAmount; // Stores the amount of gold in grams
//   bool hasAcceptedTerms = false; // Tracks if the user has accepted the terms
//
//   // Define the gold price per gram for each category
//   static const Map<String, double> goldPricePerGram = {
//     '24 Carat Coin': 000, // 24 Carat Gold = 9000 Rs per gram
//     '22 Carat Jewellery': 000, // 22 Carat Gold = 7000 Rs per gram
//     '18 Carat Jewellery': 000, // 18 Carat Gold = 6000 Rs per gram
//   };
//
//   // Function to calculate the gold amount
//   void _calculateGoldAmount() {
//     if (selectedCategory != null && planAmount != null) {
//       goldAmount = planAmount! / goldPricePerGram[selectedCategory]!;
//       // Round the gold amount to two decimal places
//       goldAmount = double.parse(goldAmount!.toStringAsFixed(2));
//     }
//   }
//
//
//
//   // Function to open the Terms and Conditions page
//   Future<void> _openTermsAndConditions() async {
//     const url = 'https://altaibagold.com/terms-and-condition';
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFFFFD700), // Gold
//               Color(0xFFF5DEB3), // Wheat
//               Color(0xFFEEE8AA), // Pale Goldenrod
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 48),
//                 Text(
//                   "Premium Gold Purchase Plans",
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: "Serif",
//                     color: Colors.black87,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Select a Plan:',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildPlanOption(
//                   'Plan Code: GP5000',
//                   5000,
//                   'Pay Rs 5000, 11 times a year (Total Rs 55,000/year)',
//                 ),
//                 const SizedBox(height: 12),
//                 _buildPlanOption(
//                   'Plan Code: GP10000',
//                   10000,
//                   'Pay Rs 10,000, 11 times a year (Total Rs 1,10,000/year)',
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Select Category Section
//                 const Text(
//                   'Select a Category:',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildCategoryOption('24 Carat Coin'),
//                 _buildCategoryOption('22 Carat Jewellery'),
//                 _buildCategoryOption('18 Carat Jewellery'),
//
//                 // Show Gold Amount if both plan and category are selected
//                 if (selectedPlan != null && selectedCategory != null && planAmount != null)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Purchased Gold Weight:',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         Text(
//                           '${goldAmount?.toStringAsFixed(2)} grams',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 // Terms and Conditions Section
//                 const SizedBox(height: 20),
//
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: hasAcceptedTerms,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           hasAcceptedTerms = value ?? false;
//                         });
//                       },
//                       activeColor: const Color(0xFFD4AF37),
//                     ),
//                     const Flexible(
//                       child: Text(
//                         'Terms & Conditions ',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: _openTermsAndConditions,
//                       child: Text(
//                         'View Terms and Conditions',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 // Proceed Button
//                 const SizedBox(height: 32),
//                 ElevatedButton(
//                   onPressed: selectedPlan != null &&
//                       selectedCategory != null &&
//                       hasAcceptedTerms // Ensure terms are accepted
//                       ? () {
//                     // Calculate the amount of gold (in grams) when the button is pressed
//                     _calculateGoldAmount();
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PaymentDetailsScreen(
//                           selectedPlan: selectedPlan ?? '',
//                           selectedCategory:selectedCategory ?? '',
//                           planAmount: planAmount ?? 0,
//                           goldAmount: goldAmount ?? 0.0,  // Pass the rounded gold amount
//                         ),
//                       ),
//                     );
//                   }
//                       : null, // Disable the button if terms are not accepted
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFD4AF37),
//                     minimumSize: const Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Proceed to Payment',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Plan Option Widget
//   Widget _buildPlanOption(String planCode, int amount, String description) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedPlan = planCode;
//           planAmount = amount;
//           _calculateGoldAmount(); // Recalculate gold when the plan is selected
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: selectedPlan == planCode ? Colors.amber[100] : Colors.white,
//           border: Border.all(
//             color: selectedPlan == planCode ? const Color(0xFFD4AF37) : Colors.grey[300]!,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               planCode,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8E1F2F)),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Rs $amount (11 payments/year)',
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               description,
//               style: const TextStyle(fontSize: 12, color: Colors.black54),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Category Option Widget
//   Widget _buildCategoryOption(String category) {
//     return RadioListTile<String>(
//       title: Text(
//         category,
//         style: const TextStyle(color: Color(0xFF8E1F2F)),
//       ),
//       value: category,
//       groupValue: selectedCategory,
//       onChanged: (value) {
//         setState(() {
//           selectedCategory = value;
//           _calculateGoldAmount(); // Recalculate gold when the category is selected
//         });
//       },
//       activeColor: const Color(0xFFD4AF37),
//     );
//   }
// }
//
//
//
//
