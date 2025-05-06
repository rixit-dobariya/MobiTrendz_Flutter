import 'package:get/get.dart';

class FilterController extends GetxController {
  var selectedCategories = <String>[].obs;
  var minPrice = 0.0.obs;
  var maxPrice = 1000.0.obs;

  var filteredProducts = [].obs;
  var allProducts = [].obs;

  var searchQuery = ''.obs;

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }

  void updatePriceRange(double min, double max) {
    minPrice.value = min;
    maxPrice.value = max;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void applyFilters(List products) {
    List filtered = products.where((product) {
      double salePrice =
          double.tryParse(product['salePrice'].toString()) ?? 0.0;
      double discount = double.tryParse(product['discount'].toString()) ?? 0.0;
      double finalPrice = salePrice - (salePrice * discount / 100);

      bool priceMatch =
          finalPrice >= minPrice.value && finalPrice <= maxPrice.value;

      bool categoryMatch = selectedCategories.isEmpty ||
          selectedCategories.contains(product['categoryId']["_id"]);

      bool keywordMatch = true;
      if (searchQuery.value.isNotEmpty) {
        keywordMatch = (product['productName']?.toString().toLowerCase() ?? "")
            .contains(searchQuery.value.toLowerCase());
      }

      return priceMatch && categoryMatch && keywordMatch;
    }).toList();

    filteredProducts.value = filtered;
  }

  void clearFilters() {
    selectedCategories.clear();
    minPrice.value = 0.0;
    maxPrice.value = 1000.0;
    searchQuery.value = '';
  }
}
