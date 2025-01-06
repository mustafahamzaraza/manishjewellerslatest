import 'package:flutter/material.dart';

class GoldThemeDrawer extends StatelessWidget {
  const GoldThemeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // Gold gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE082), Color(0xFFFFD54F)], // Light gold gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/profile.jpg'), // Replace with your asset
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Gold User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'golduser@example.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home,
              text: 'Home',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.star,
              text: 'Favorites',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              text: 'Settings',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  static ListTile _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber[700]),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}
