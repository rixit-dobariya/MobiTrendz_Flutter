import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobitrendz/constants/app_constants.dart';
import 'package:mobitrendz/screens/checkout_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobitrendz/controllers/checkout_controller.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final checkoutController = Get.put(CheckoutController(), permanent: true);

  bool isLoading = true;
  bool hasError = false;
  Map<String, bool> updatingMap = {};
  Map<String, bool> deletingMap = {};

  @override
  void initState() {
    super.initState();
    fetchCartData();
  }

  Future<void> fetchCartData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");

    if (userId == null) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
      Get.snackbar('Error', 'User not logged in.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    final cartUrl = '${AppConstants.baseUrl}/cart/$userId';

    try {
      final response = await http.get(Uri.parse(cartUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];

        checkoutController.cartItems.assignAll(items);
        checkoutController.calculateTotal();

        setState(() {
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        Get.snackbar('Error', 'Failed to load cart data.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
      Get.snackbar('Error', 'Check your internet connection.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (newQuantity < 1) return;

    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    final url = '${AppConstants.baseUrl}/cart/$userId';

    if (!mounted) return;
    setState(() {
      updatingMap[productId] = true;
    });

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productId': productId, 'quantity': newQuantity}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await fetchCartData();
        if (mounted) {
          Get.snackbar('Success', 'Quantity updated',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP);
        }
      } else {
        Get.snackbar('Error', 'Failed to update quantity',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', 'Error updating quantity',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }

    if (!mounted) return;
    setState(() {
      updatingMap[productId] = false;
    });
  }

  Future<void> removeCartItem(String productId) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");
    final url = '${AppConstants.baseUrl}/cart/$userId';

    if (!mounted) return;
    setState(() {
      deletingMap[productId] = true;
    });

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productId': productId}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await fetchCartData();
        if (mounted) {
          Get.snackbar('Success', 'Item removed',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP);
        }
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Error', data['message'] ?? 'Failed to remove item',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', 'Error removing item',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }

    if (!mounted) return;
    setState(() {
      deletingMap[productId] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Cart", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (hasError)
            Center(child: Text('Failed to load cart data'))
          else if (checkoutController.cartItems.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 100, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text(
                    "Your cart is empty",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: checkoutController.cartItems.length,
              itemBuilder: (context, index) {
                var pObj = checkoutController.cartItems[index] as Map? ?? {};
                final productId = pObj['productId']['_id'];
                final isUpdating = updatingMap[productId] == true;
                final isDeleting = deletingMap[productId] == true;

                return CartItem(
                  item: pObj,
                  isUpdating: isUpdating,
                  isDeleting: isDeleting,
                  onRemove: () => removeCartItem(productId),
                  onQuantityChanged: (change) => updateQuantity(
                    productId,
                    pObj['quantity'] + change,
                  ),
                );
              },
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(
              () => BottomCheckoutBar(
                totalPrice: checkoutController.totalPrice.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final Map<dynamic, dynamic> item;
  final bool isUpdating;
  final bool isDeleting;
  final Function() onRemove;
  final Function(int) onQuantityChanged;

  const CartItem({
    super.key,
    required this.item,
    this.isUpdating = false,
    this.isDeleting = false,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final productData = item['productId'] as Map<dynamic, dynamic>;
    final int quantity = item['quantity'] ?? 1;
    final int salePrice = productData['salePrice'] ?? 0;
    final int discount = productData['discount'] ?? 0;

    final priceAfterDiscount = salePrice - salePrice * discount / 100;
    final totalPrice = priceAfterDiscount * quantity;

    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                productData['productImage'] ?? 'https://placeholder.com/80',
                height: 80,
                width: 65,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 65),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            productData['productName'] ?? 'Unknown Product',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        isDeleting
                            ? const SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                onPressed: onRemove,
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (isUpdating)
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          _quantityButton(
                            icon: Icons.remove,
                            onPressed: quantity > 1
                                ? () => onQuantityChanged(-1)
                                : null,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "$quantity",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 20),
                          _quantityButton(
                            icon: Icons.add,
                            onPressed: () => onQuantityChanged(1),
                            color: Colors.black,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹$priceAfterDiscount",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "x $quantity",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "₹$totalPrice",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        onPressed: onPressed,
        icon: Icon(icon, color: color),
      ),
    );
  }
}

class BottomCheckoutBar extends StatelessWidget {
  final double totalPrice;

  const BottomCheckoutBar({
    super.key,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Price",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "₹${totalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          MaterialButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
            height: 55,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minWidth: double.infinity,
            color: Colors.black,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Checkout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text(
                    "₹${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
