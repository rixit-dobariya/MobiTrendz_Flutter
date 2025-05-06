import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/address_model.dart';
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressController extends GetxController {
  var isLoading = false.obs;
  var addresses = <Address>[].obs; // List to store addresses

  // Fetch the list of addresses
  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        _showError('No user found. Please log in.');
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/addresses/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        addresses.value =
            responseData.map((address) => Address.fromJson(address)).toList();
      } else {
        _showError('Failed to load addresses');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAddress(Address address) async {
    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/addresses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': address.userId,
          'fullName': address.fullName,
          'address': address.address,
          'city': address.city,
          'state': address.state,
          'pincode': address.pincode,
          'phone': address.phone,
        }),
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Address added successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        _showError(responseData['message'] ?? 'Failed to add address');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
