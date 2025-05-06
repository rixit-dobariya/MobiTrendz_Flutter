// lib/controllers/category_controller.dart
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../models/category_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryController extends GetxController {
  var categories = <CategoryModel>[].obs;
  var isLoading = false.obs;

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      var url = Uri.parse('${AppConstants.baseUrl}/categories');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        categories.value = List<CategoryModel>.from(
          data.map((item) => CategoryModel.fromJson(item)),
        );
      } else {
        showError("Failed to load categories");
      }
    } catch (e) {
      showError("Error fetching categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
      colorText: Get.theme.colorScheme.onError,
      snackPosition: SnackPosition.TOP,
    );
  }
}
