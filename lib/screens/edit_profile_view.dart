import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobitrendz/constants/app_constants.dart';
import 'package:mobitrendz/screens/change_password.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();

  String? userId;
  String? profileImageUrl;
  File? pickedImage;

  bool isLoading = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");

    if (userId != null) {
      final res =
          await http.get(Uri.parse('${AppConstants.baseUrl}/users/$userId'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _emailController.text = data['email'] ?? '';
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _mobileController.text = data['mobile'] ?? '';
          profileImageUrl = data['profilePicture'];
        });
      } else {
        Get.snackbar("Error", "Failed to fetch profile",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() {
        pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/users/$userId');
      final request = http.MultipartRequest('PUT', uri);

      request.fields['firstName'] = _firstNameController.text.trim();
      request.fields['lastName'] = _lastNameController.text.trim();
      request.fields['mobile'] = _mobileController.text.trim();
      request.fields['status'] = 'Active';

      if (pickedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          pickedImage!.path,
          filename: path.basename(pickedImage!.path),
        ));
      } else if (profileImageUrl != null) {
        request.fields['profilePicture'] = profileImageUrl!;
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Profile updated successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        Navigator.pop(context);
      } else {
        debugPrint("Server error: $respStr");
        Get.snackbar("Error", "Failed to update profile",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = pickedImage != null
        ? FileImage(pickedImage!)
        : (profileImageUrl == null || profileImageUrl!.isEmpty)
            ? const AssetImage("assets/img/default_profile.png")
            : NetworkImage(profileImageUrl!) as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset("assets/img/back.png", width: 20, height: 20)),
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: displayImage,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Tap to change profile picture",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 30),
                      _buildTextField(
                        title: "Email",
                        placeholder: "Enter your email",
                        controller: _emailController,
                        enabled: false,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        title: "First Name",
                        placeholder: "Enter your first name",
                        controller: _firstNameController,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        title: "Last Name",
                        placeholder: "Enter your last name",
                        controller: _lastNameController,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        title: "Mobile Number",
                        placeholder: "Enter your mobile number",
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v.length < 10) return 'Invalid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      isSubmitting
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _submitForm,
                              child: const Text("Update",
                                  style: TextStyle(fontSize: 16)),
                            ),
                      const SizedBox(height: 25),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const ChangePasswordView());
                        },
                        child: const Text(
                          "Reset Password",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String title,
    required String placeholder,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
