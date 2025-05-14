import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../widgets/ProductCard.dart';
import '../../controllers/cart_controller.dart';
import '../../models/category_model.dart';
import '../screens/product_details.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> products = [];
  final CartController cartController = Get.put(CartController());
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProductsByCategory();
  }

  Future<void> fetchProductsByCategory() async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/products/category/${widget.category.id}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          products = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        Get.snackbar("Error", "Failed to load products: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      Get.snackbar("Error", "Error fetching products: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.name,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text("No products found"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Obx(
                        () => ProductCard(
                          imageUrl: product['productImage'] ?? '',
                          title: product['productName'] ?? '',
                          price: (((product['salePrice'] ?? 0) *
                                  (1 - ((product['discount'] ?? 0) / 100))))
                              .toString(),
                          discount: product['discount']?.toString(),
                          onPressed: () {
                            Get.to(() => ProductDetailScreen(product: product));
                          },
                          onCart: () {
                            cartController.addToCart(product["_id"]);
                          },
                          isLoading: cartController.loadingProductIds
                              .contains(product["_id"]),
                          margin: 0,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
