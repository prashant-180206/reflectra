import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 56),
                SizedBox(height: 12),
                Text(
                  'Profile placeholder',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'This tab is ready for your account and preferences UI.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
