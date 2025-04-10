import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Subscription {
  final String planName;
  final String mandateId;

  Subscription({required this.planName, required this.mandateId});
}

class AutoSubscriptionCancellationScreen extends StatefulWidget {
  @override
  _AutoSubscriptionCancellationScreenState createState() =>
      _AutoSubscriptionCancellationScreenState();
}

class _AutoSubscriptionCancellationScreenState
    extends State<AutoSubscriptionCancellationScreen> {
  List<Subscription> subscriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserActivePlans();
  }

  Future<void> fetchUserActivePlans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final headers = {
      'Authorization': 'Bearer $token',
    };

    final url = Uri.parse(
        'https://manish-jewellers.com/api/v1/installment-payment/check-user-active-plan');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("installment-payment/check-user-active-plan data $data");

        if (data['status'] == true && data['plan'] is List) {
          List<Subscription> fetchedPlans = (data['plan'] as List)
              .map((plan) => Subscription(
            planName: plan['plan_category'] ?? 'Unnamed Plan',
            mandateId: plan['mandate_id'] ?? '',
          ))
              .toList();

          setState(() {
            subscriptions = fetchedPlans;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load active plans');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> cancelSubscription(String mandateId) async {
    final url = Uri.parse(
        'https://manish-jewellers.com/api/v1/phonepe/subscription/cancel/$mandateId');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        print('response ${response.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription $mandateId cancelled successfully')),
        );

        setState(() {
          subscriptions.removeWhere((sub) => sub.mandateId == mandateId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel subscription')),
        );

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Subscription Cancellation'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : subscriptions.isEmpty
          ? Center(child: Text('No active subscriptions found.'))
          : ListView.builder(
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final subscription = subscriptions[index];
          return Card(
            margin:
            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(subscription.planName,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
              Text('Mandate ID: ${subscription.mandateId}'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                onPressed: () =>
                    cancelSubscription(subscription.mandateId),
                child: Text('Cancel'),
              ),
            ),
          );
        },
      ),
    );
  }
}
