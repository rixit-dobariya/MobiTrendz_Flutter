import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signin_screen.dart';
import '../../controllers/address_controller.dart';
import '../../models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAddressView extends StatefulWidget {
  final String? initialName;
  final String? initialPhone;
  final String? initialAddress;
  final String? initialCity;
  final String? initialState;
  final String? initialPostalCode;
  final String initialType;
  final bool isEdit;

  const AddAddressView({
    super.key,
    this.initialName,
    this.initialPhone,
    this.initialAddress,
    this.initialCity,
    this.initialState,
    this.initialPostalCode,
    this.initialType = "Home",
    this.isEdit = false,
  });

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController txtName;
  late TextEditingController txtPhone;
  late TextEditingController txtAddress;
  late TextEditingController txtCity;
  late TextEditingController txtState;
  late TextEditingController txtPostalCode;
  late String txtType;

  final AddressController addressController = Get.put(AddressController());

  @override
  void initState() {
    super.initState();
    txtName = TextEditingController(text: widget.initialName);
    txtPhone = TextEditingController(text: widget.initialPhone);
    txtAddress = TextEditingController(text: widget.initialAddress);
    txtCity = TextEditingController(text: widget.initialCity);
    txtState = TextEditingController(text: widget.initialState);
    txtPostalCode = TextEditingController(text: widget.initialPostalCode);
    txtType = widget.initialType;
  }

  @override
  void dispose() {
    txtName.dispose();
    txtPhone.dispose();
    txtAddress.dispose();
    txtCity.dispose();
    txtState.dispose();
    txtPostalCode.dispose();
    super.dispose();
  }

  void saveAddress() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        Get.to(() => SignInScreen());
        Get.snackbar("Error", "You need to login first!");
        return;
      }

      final newAddress = Address(
        userId: userId,
        fullName: txtName.text.trim(),
        phone: txtPhone.text.trim(),
        address: txtAddress.text.trim(),
        city: txtCity.text.trim(),
        state: txtState.text.trim(),
        pincode: int.tryParse(txtPostalCode.text.trim()) ?? 0,
      );

      await addressController.addAddress(newAddress);

      if (addressController.isLoading.isFalse) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              ),
              title: Text(
                widget.isEdit ? "Edit Address" : "Add Address",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      _buildTextFormField(
                        title: "Name",
                        placeholder: "Enter your name",
                        controller: txtName,
                        validator: (value) =>
                            value!.isEmpty ? 'Name cannot be empty' : null,
                      ),
                      const SizedBox(height: 15),
                      _buildTextFormField(
                        title: "Mobile",
                        placeholder: "Enter your mobile number",
                        keyboardType: TextInputType.phone,
                        controller: txtPhone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone cannot be empty';
                          } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Phone must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildTextFormField(
                        title: "Address Line",
                        placeholder: "Enter your address",
                        controller: txtAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'Address cannot be empty' : null,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              title: "City",
                              placeholder: "Enter City",
                              controller: txtCity,
                              validator: (value) => value!.isEmpty
                                  ? 'City cannot be empty'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextFormField(
                              title: "State",
                              placeholder: "Enter State",
                              controller: txtState,
                              validator: (value) => value!.isEmpty
                                  ? 'State cannot be empty'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildTextFormField(
                        title: "Postal Code",
                        placeholder: "Enter your Postal Code",
                        controller: txtPostalCode,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Postal Code cannot be empty';
                          } else if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                            return 'Postal Code must be 6 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black38,
                        ),
                        child: Text(
                          widget.isEdit ? "Update Address" : "Add Address",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (addressController.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    });
  }

  Widget _buildTextFormField({
    required String title,
    required String placeholder,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            )),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Colors.blueAccent, width: 1.2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
