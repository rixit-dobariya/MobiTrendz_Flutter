import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobitrendz/constants/app_constants.dart';
import 'package:mobitrendz/screens/product_details.dart';
import 'category_screen.dart';
import '../controllers/category_controller.dart';
import '../models/category_model.dart';
import '../../controllers/cart_controller.dart';
import '../widgets/ProductCard.dart';

class HomePageContent extends StatefulWidget {
  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final CategoryController _categoryController = Get.put(CategoryController());
  final CartController cartController = Get.put(CartController());

  var isProductLoading = true.obs;
  var products = [].obs;
  var isPromoLoading = true.obs;
  var promoCodes = [].obs;
  var isBannerLoading = true.obs;
  var banners = [].obs;
  @override
  void initState() {
    super.initState();
    _categoryController.fetchCategories();
    fetchProducts();
    fetchPromoCodes();
    fetchBanners(); // 👈 Add this
  }

  void fetchBanners() async {
    try {
      isBannerLoading(true);
      final response = await http.get(Uri.parse(
          '${AppConstants.baseUrl}/banners?type=slider')); // Assuming 'slider' type
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        banners.value = data; // list of banner objects
      } else {
        print("Failed to load banners");
      }
    } catch (e) {
      print("Error fetching banners: $e");
    } finally {
      isBannerLoading(false);
    }
  }

  void fetchPromoCodes() async {
    try {
      isPromoLoading(true);
      final response =
          await http.get(Uri.parse('${AppConstants.baseUrl}/offers'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        promoCodes.value = data
            .map((item) => {
                  "id": item["_id"],
                  "name": item["offerCode"],
                  "discount": item["discount"],
                  "description": item["offerDescription"],
                  "activeStatus": item["activeStatus"],
                })
            .toList();
      } else {
        print("Failed to load promo codes");
      }
    } catch (e) {
      print("Error fetching promo codes: $e");
    } finally {
      isPromoLoading(false);
    }
  }

  void fetchProducts() async {
    try {
      isProductLoading(true);
      final response =
          await http.get(Uri.parse('${AppConstants.baseUrl}/products/latest'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        products.value = data;
      } else {
        print("Failed to load products");
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isProductLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontFamily: 'Montserrat', // or any stylish custom font
                ),
                children: [
                  TextSpan(
                    text: 'Mobi',
                    style: TextStyle(color: Colors.black87),
                  ),
                  TextSpan(
                    text: 'Trendz',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for products...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text("Trending Banners",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() {
              if (isBannerLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (banners.isEmpty) {
                return Center(child: Text("No Banners Found"));
              }
              return SizedBox(
                height: 160,
                child: PageView.builder(
                  itemCount: banners.length,
                  controller: PageController(viewportFraction: 0.9),
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          banner[
                              "bannerImage"], // Adjust field name to match your backend
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.error),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 20),

            // Categories
            const Text("Browse by Brand",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Obx(() {
              if (_categoryController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categoryController.categories
                      .map((category) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _buildBrandIcon(category),
                          ))
                      .toList(),
                ),
              );
            }),
            const SizedBox(height: 18),
            const SizedBox(height: 20),
            // const Text("Promo Codes",
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // const SizedBox(height: 12),
            // Obx(() {
            //   if (isPromoLoading.value) {
            //     return Center(child: CircularProgressIndicator());
            //   }
            //   if (promoCodes.isEmpty) {
            //     return Center(child: Text("No Promo Codes Available"));
            //   }
            //   return SizedBox(
            //     height: 110,
            //     child: ListView.builder(
            //       scrollDirection: Axis.horizontal,
            //       itemCount: promoCodes.length,
            //       itemBuilder: (context, index) {
            //         final promo = promoCodes[index];
            //         return Container(
            //           width: 220,
            //           margin: const EdgeInsets.only(right: 12),
            //           padding: const EdgeInsets.all(12),
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             borderRadius: BorderRadius.circular(12),
            //             border: Border.all(color: Colors.grey.shade300),
            //             boxShadow: [
            //               BoxShadow(
            //                 color: Colors.black12,
            //                 blurRadius: 4,
            //                 offset: Offset(0, 2),
            //               )
            //             ],
            //           ),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 promo["name"] ?? "",
            //                 style: TextStyle(
            //                     fontSize: 16,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.black87),
            //               ),
            //               const SizedBox(height: 4),
            //               Text(
            //                 promo["description"] ?? "",
            //                 maxLines: 2,
            //                 overflow: TextOverflow.ellipsis,
            //                 style: TextStyle(
            //                     fontSize: 13, color: Colors.grey[600]),
            //               ),
            //               const SizedBox(height: 4),
            //               if (promo["discount"] != null &&
            //                   promo["discount"] > 0)
            //                 Text(
            //                   "${promo["discount"]}% OFF",
            //                   style: TextStyle(
            //                     fontSize: 13,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.green,
            //                   ),
            //                 ),
            //             ],
            //           ),
            //         );
            //       },
            //     ),
            //   );
            // }),

            const SizedBox(height: 20),
            const Text("Latest Products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() {
              if (isProductLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (products.isEmpty) {
                return const Center(child: Text("No products found"));
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        Get.find<CartController>().addToCart(product["_id"]);
                      },
                      isLoading: Get.find<CartController>()
                          .loadingProductIds
                          .contains(product["_id"]),
                      margin: 0,
                      width: double.infinity,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandIcon(CategoryModel category) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CategoryScreen(
              category: category,
            ));
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(14),
            child: Image.network(
              category.image,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(var product) {
    double sellPrice = (product["salePrice"] as num).toDouble();
    double discount = (product["discount"] as num).toDouble();

    double finalPrice = sellPrice - (sellPrice * discount / 100);

    return GestureDetector(
      onTap: () {
        Get.to(ProductDetailScreen(product: product));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(product["productImage"],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.error)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product["productName"],
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              finalPrice.toString(),
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
