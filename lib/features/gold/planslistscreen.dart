import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/gold/purchasedplansscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/screens/home_screens.dart';
import 'package:intl/intl.dart'; // For formatting dates

class PlansListScreen extends StatefulWidget {
  final String plan;
  final String category;
  final int planAmount;
  final double goldAmount;
  final int totalpaymentyearly;
  final String startdate;
  final int paymentDone;
  final int paymentRemaining;
  final int id;

  const PlansListScreen({
    Key? key,
    required this.plan,
    required this.category,
    required this.planAmount,
    required this.goldAmount,
    required this.totalpaymentyearly,
    required this.startdate, // Accept goldAmount as a parameter
    required this.paymentDone,
    required this.paymentRemaining,
    required this.id
  }) : super(key: key);

  @override
  State<PlansListScreen> createState() => _PlansListScreenState();
}

class _PlansListScreenState extends State<PlansListScreen> {








  @override
  Widget build(BuildContext context) {
    // Determine the payment status based on the payments remaining
    // String paymentStatus = paymentsRemaining == 0 ? 'Fully Paid' : 'Pending';
    // Color statusColor = paymentsRemaining == 0 ? Colors.green : Colors.red;

    // Get the current date in a readable format
    String currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Payment Plan',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.amber[500], // Golden color
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the Current Date

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Plan ID: ${widget.id.toString()}',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Date: $currentDate',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Plan Details:',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Plan: ${widget.plan}\nCategory: ${widget.category}\nCurrently Paid: Rs ${widget.planAmount}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),


                // Display the Gold Amount in grams
                Text(
                  'Gold Amount: ${widget.goldAmount.toStringAsFixed(2)} grams',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[500], // Golden color
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Summary Section
                Text(
                  "Plan's Total Payment : Rs ${widget.planAmount * 11}",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),

                Text(
                  "Plan Started From : ${widget.startdate.toString()}",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),


                SizedBox(height: 15,),

                Text(
                  "Total Payment Done: Rs ${widget.paymentDone}",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600, // Semi-bold for a professional touch
                    color: Colors.amber[900], // Rich gold color for a refined look
                    backgroundColor: Colors.amber[50], // Soft gold background for contrast
                    shadows: [
                      Shadow(
                        offset: Offset(1.5, 1.5), // Shadow for depth
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.2), // Soft black shadow for subtle depth
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12), // Add spacing between the text items

                Text(
                  "Total Payment Remaining: Rs ${widget.paymentRemaining}",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600, // Semi-bold for consistency
                    color: Colors.amber[700], // A slightly lighter gold for contrast
                    backgroundColor: Colors.amber[50], // Soft background to keep focus on text
                    shadows: [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.2), // Soft black shadow for subtle depth
                      ),
                    ],
                  ),
                ),




                const Spacer(),


                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PurchasedPlansList(

                          ), // Navigate to PurchasedPlansScreen
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Pay the Remaining Installments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // Add spacing between buttons
                //],

                // Button to navigate back to Home
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[400], // Golden color
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
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
}



