import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ProfileScreen(),
  ));
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
            backgroundImage: AssetImage("assets/profiles.png"),
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
                MaterialPageRoute(builder: (context) => EditAddressScreen()),
              );
            },
          ),
          ProfileOption(icon: Icons.location_on, title: "Address"),
          ProfileOption(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
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
  final VoidCallback? onTap;

  const ProfileOption(
      {required this.icon, required this.title, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(title, style: TextStyle(color: color ?? Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class EditAddressScreen extends StatefulWidget {
  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final TextEditingController nameController =
      TextEditingController(text: "Jay Gorfad");
  final TextEditingController phoneController =
      TextEditingController(text: "7600242424");
  final TextEditingController addressController =
      TextEditingController(text: "Kothariya Main Road");
  final TextEditingController pincodeController =
      TextEditingController(text: "360002");
  final TextEditingController cityController =
      TextEditingController(text: "Rajkot");
  final TextEditingController stateController =
      TextEditingController(text: "Gujarat");

  void _updateProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Address saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Edit Address"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            SizedBox(height: 5),
            _buildInputBox("Name", nameController),
            _buildInputBox("Mobile Number", phoneController),
            _buildInputBox("Address", addressController),
            _buildInputBox("Pincode", pincodeController),
            _buildInputBox("City", cityController),
            _buildInputBox("State", stateController),
            SizedBox(height: 8),
            Divider(),
            SizedBox(
              height: 15,
            ),
            Center(
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child:
                    Text("Save Address", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: controller,
                enabled: enabled,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
