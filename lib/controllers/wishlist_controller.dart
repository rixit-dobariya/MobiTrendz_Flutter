import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobitrendz/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistController extends GetxController {
  RxList<String> loadingWishlistProductIds = <String>[].obs;

  var wishlistProducts = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  Future<void> fetchWishlist() async {
    try {
      isLoading.value = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        _showError('User not logged in');
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/wishlist/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> products = data['wishlist']['productIds'];

        wishlistProducts.assignAll(products.cast<Map<String, dynamic>>());
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        _showError(error['message'] ?? 'Failed to fetch wishlist');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToWishlist(String productId) async {
    loadingWishlistProductIds.add(productId);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        _showError('User not logged in');
        return;
      }

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/wishlist/$userId/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"productId": productId}),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Product added to wishlist!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        // fetchWishlist();
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        _showError(responseData['message'] ?? 'Failed to add to wishlist');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      loadingWishlistProductIds.remove(productId);
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
