import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/screens/more_screen_view.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/pp.dart';
import '../features/notification/screens/notification_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../utill/colornew.dart';
import 'buygoldend.dart';
import 'endsubscription.dart';
import 'goldratescreen.dart';
import 'investmentPlans.dart';


class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.glowingGold, // Background color
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Icon
            Center(
              child: Image.asset('assets/images/1.png', height: MediaQuery.of(context).size.height * (200 / 812),),
            ),
            const SizedBox(height: 20),

            // Menu Items
            Expanded(
              child: ListView(
                children: [
                  _divider(),
                  _drawerItem(context, 'Home', DashBoardScreen()),
                  _divider(),
                  _drawerItem(context, 'Gold Rates', GoldPriceScreenT()),
                  _divider(),
                  _drawerItem(context, 'Buy Gold', GoldCaratScreen()),
                  _divider(),
                  _drawerItem(context, 'Purchase New Plan', RemainingPlansScreen()),
                  _divider(),
                  _drawerItem(context, 'Cancel AutoPayment', AutoSubscriptionCancellationScreen()),
                  _divider(),
                  _drawerItem(context, 'Profile', MoreScreen()),
                  _divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Drawer Item Widget with Direct Navigation
  Widget _drawerItem(BuildContext context, String title, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // Divider Widget
  Widget _divider() {
    return Divider(
      color: Colors.black87,
      thickness: 1,
    );
  }
}

