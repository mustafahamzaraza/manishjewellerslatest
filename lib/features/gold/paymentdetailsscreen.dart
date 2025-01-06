import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/gold/planslistscreen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;
import 'cont/paymentcontroller.dart';


class PaymentDetailsScreen extends StatelessWidget {
  final String selectedPlan;
  final String selectedCategory;
  final int planAmount;
  final double goldAmount;
  final String paymentDone;
  final String paymentRemaining;
  final int id;

  const PaymentDetailsScreen({
    Key? key,
    required this.selectedPlan,
    required this.selectedCategory,
    required this.planAmount,
    required this.goldAmount,
    required this.paymentDone,
    required  this.paymentRemaining,
    required this.id
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String startDate = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());




    final controller = Provider.of<PaymentDetailsController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAndCalculateGoldWeight(planAmount, selectedCategory);
    });


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Details',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD4AF37), // Gold
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFF5DEB3)], // Gold to Wheat gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Consumer<PaymentDetailsController>(
          builder: (context, controller, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Plan: $selectedPlan\nCategory: $selectedCategory',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                        'Monthly Payment: Rs $planAmount\n'
                        'Total Yearly Payment: Rs ${planAmount * 11}',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Done: Rs $paymentDone',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Payment Remaining: Rs $paymentRemaining',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),


                  SizedBox(
                    height: 5,
                  ),



                  StreamBuilder<double>(
                    stream: controller.purchasedGoldWeightStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Loading indicator while fetching
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        return Text(
                          'Current Purchased Gold Weight: ${snapshot.data!.toStringAsFixed(5)} grams',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        );
                      } else {
                        return const Text(
                          'Current Purchased Gold Weight: 0.00 grams',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Total Gold Purchased: $goldAmount grams',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start Date: $startDate',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37), // Gold
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(

                      onPressed: () async {

                      bool? confirm = await _showConfirmationDialog(context);
                      if (confirm == true) {
                        await controller.submitPayment(
                          iD: id,
                          planCode: selectedPlan,
                          planCategory: selectedCategory,
                          planAmount: planAmount,
                          goldAmount: goldAmount,
                          context: context,
                        );

                        if (controller.id != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Payment Submitted!')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37), // Gold color
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.amber[50], // Light gold background for the dialog
          title: Text(
            'Confirm Payment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber[800], // Darker gold for the title
            ),
          ),
          content: Text(
            'Are you sure you want to proceed with the payment?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87, // Professional dark text
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // "No"
              },
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent, // Red for 'No' option
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // "Yes"
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.amber[700], // Golden color for 'Yes' option
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}











