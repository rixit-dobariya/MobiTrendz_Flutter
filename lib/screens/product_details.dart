import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobitrendz/screens/cart_screen.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../constants/app_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double totalPrice = 0.0;
  double _rating = 0.0;
  String? userId;
  List<dynamic> _reviews = [];
  final CartController cartController = Get.put(CartController());
  final WishlistController wishlistController = Get.put(WishlistController());
  bool hasUserReviewed = true;
  bool hasPurchased = false;
  @override
  void initState() {
    super.initState();
    _rating =
        double.tryParse(widget.product['averageRating'].toString()) ?? 0.0;
    double salePrice =
        double.tryParse(widget.product['salePrice'].toString()) ?? 0.0;
    double discount =
        double.tryParse(widget.product['discount'].toString()) ?? 0.0;

    if (discount > 0) {
      totalPrice = salePrice - (salePrice * discount / 100);
    } else {
      totalPrice = salePrice;
    }

    checkReviewEligibility(); // check purchase + review status
    fetchReviews();
  }

  Future<void> checkReviewEligibility() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getString("userId");

    if (userId == null) return;

    try {
      // Check if user has purchased the product
      final purchaseRes = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/orders/has-purchased/$userId/${widget.product["_id"]}'),
      );

      if (purchaseRes.statusCode == 200) {
        final data = json.decode(purchaseRes.body);
        hasPurchased = data['purchased'] ?? false;
      }
      final baseUrl = '${AppConstants.baseUrl}/reviews';
      final productId = widget.product["_id"];
      final userReviewRes = await http.get(
        Uri.parse('$baseUrl?productId=$productId&userId=$userId'),
      );

      if (userReviewRes.statusCode == 200) {
        final userReviews = json.decode(userReviewRes.body);
        hasUserReviewed = userReviews.isNotEmpty;
      }
      print(hasUserReviewed);
      print(hasPurchased);
      setState(() {});
    } catch (e) {
      debugPrint("Error checking review eligibility: $e");
    }
  }

  Future<void> fetchReviews() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/reviews?productId=${widget.product["_id"]}'),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _reviews = json.decode(response.body);
        });
      } else {
        // Handle failure
        throw Exception("Failed to load reviews");
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    }
  }

  Future<void> submitReview(double rating, String message) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      userId = sp.getString("userId");

      if (userId == null) {
        Get.snackbar("Error", "User ID not found in SharedPreferences.");
        return;
      }

      final url = Uri.parse('${AppConstants.baseUrl}/reviews');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "productId": widget.product["_id"],
          "rating": rating,
          "review": message,
          "userId": userId
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review submitted successfully!")),
        );
        fetchReviews(); // Refresh review list
        setState(() {
          hasUserReviewed = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit review.")),
        );
      }
    } catch (e) {
      debugPrint("Error submitting review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting review.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final TextEditingController reviewController = TextEditingController();
    double userRating = 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  product['productImage'],
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['productName'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${totalPrice.toString()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const Text(
              "Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              product['description'] ?? "No description available",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Reviews (${_reviews.length})",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                RatingBarIndicator(
                  rating: _rating,
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Color(0xffF3603F)),
                  itemCount: 5,
                  itemSize: 20.0,
                  direction: Axis.horizontal,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _reviews.isEmpty
                ? const Text("No reviews yet.")
                : Column(
                    children: _reviews.map<Widget>((review) {
                      final user = review["userId"];
                      final profileImage = user?["profilePicture"];
                      final fullName =
                          "${user?['firstName'] ?? ''} ${user?['lastName'] ?? ''}"
                              .trim();
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              profileImage != null && profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : const AssetImage(
                                          "assets/images/default_profile.png")
                                      as ImageProvider,
                        ),
                        title: Text(
                          fullName.isNotEmpty ? fullName : "Anonymous",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(review['review'] ?? ''),
                        trailing: RatingBarIndicator(
                          rating:
                              double.tryParse(review['rating'].toString()) ?? 0,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 15.0,
                          direction: Axis.horizontal,
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 12),
            if (hasPurchased && !hasUserReviewed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Submit Your Review",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      userRating = rating;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Write your review...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (reviewController.text.trim().isEmpty ||
                          userRating == 0.0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please enter rating and review")),
                        );
                        return;
                      }
                      submitReview(userRating, reviewController.text.trim());
                      reviewController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Submit Review",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Obx(() {
              final isLoading =
                  cartController.loadingProductIds.contains(product["_id"]);

              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          cartController.addToCart(product["_id"], quantity: 1);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Add to Cart",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
