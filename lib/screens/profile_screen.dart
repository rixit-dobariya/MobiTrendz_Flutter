import 'package:flutter/material.dart';
import 'package:mobitrendz/screens/adress_list_screen.dart';
import 'package:mobitrendz/screens/edit_address.dart';
import 'package:mobitrendz/screens/edit_profile_view.dart';
import 'package:mobitrendz/screens/signin_screen.dart';

void main() {
  runApp(MaterialApp(
    home: ProfileScreen(),
  ));
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
        title: Text("Profile",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage("assets/profiles.png"), // Profile Image
          ),
          SizedBox(height: 10),
          Text("Jay Gorfad",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("+91 7600242424",
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          SizedBox(height: 20),
          Divider(),
          ProfileOption(
            icon: Icons.person,
            title: "Edit Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileView()),
              );
            },
          ),
          ProfileOption(
            icon: Icons.location_on,
            title: "Address",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddressListView()),
              );
            },
          ),
          ProfileOption(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback? onTap; // Callback function for navigation

  const ProfileOption(
      {required this.icon, required this.title, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(title, style: TextStyle(color: color ?? Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap, // Handle navigation when tapped
    );
  }
}

// Edit Profile Screen (Add this screen)
