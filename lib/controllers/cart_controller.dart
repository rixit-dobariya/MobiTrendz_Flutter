import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartController extends GetxController {
  RxList<String> loadingProductIds = <String>[].obs;

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    loadingProductIds.add(productId);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final Map<String, dynamic> data = {
        "userId": userId,
        "productId": productId,
        "quantity": quantity,
      };

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/cart'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Product added to cart!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _showError('Failed to add product');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      loadingProductIds.remove(productId);
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
