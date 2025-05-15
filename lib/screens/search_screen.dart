import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobitrendz/screens/filter_view.dart';
import 'package:mobitrendz/screens/product_details.dart';
import 'package:mobitrendz/widgets/ProductCard.dart';
import 'dart:convert';
import '../controllers/cart_controller.dart';
import '../../controllers/filter_controller.dart';
import '../constants/app_constants.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController txtSearch = TextEditingController();
  final CartController cartController = Get.put(CartController());
  final FilterController filterController = Get.put(FilterController());

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      var url = Uri.parse('${AppConstants.baseUrl}/products');
      var response = await http.get(url);
      print(response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        filterController.allProducts.value = data;
        filterController.applyFilters(data);
      } else {
        Get.snackbar(
          'Error',
          'Failed to load products: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onSearchChanged(String query) {
    filterController.updateSearchQuery(query);
    filterController.applyFilters(filterController.allProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded,
              size: 30, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FilterView()),
            ),
            icon: const Icon(Icons.filter_alt_rounded,
                size: 27, color: Colors.black),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffF2F3F2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: txtSearch,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 15),
              prefixIcon: Icon(Icons.search_rounded, size: 20),
              suffixIcon: Icon(Icons.close_rounded, size: 20),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Obx(() {
              if (filterController.filteredProducts.isEmpty) {
                return const Center(
                  child: Text(
                    'No records found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              } else {
                return GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: filterController.filteredProducts.length,
                  itemBuilder: (context, index) {
                    var product = filterController.filteredProducts[index]
                        as Map<String, dynamic>;
                    double sellPrice =
                        double.tryParse(product["salePrice"].toString()) ?? 0.0;
                    double discount =
                        double.tryParse(product["discount"].toString()) ?? 0.0;

                    double discountedPrice =
                        sellPrice - (sellPrice * discount / 100);

                    return Obx(() => ProductCard(
                          imageUrl: product["productImage"],
                          title: product["productName"],
                          price: discountedPrice.toStringAsFixed(2),
                          onPressed: () {
                            Get.to(() => ProductDetailScreen(product: product));
                          },
                          onCart: () {
                            cartController.addToCart(product["_id"]);
                          },
                          isLoading: cartController.loadingProductIds
                              .contains(product["_id"]),
                        ));
                  },
                );
              }
            }),
    );
  }
}
