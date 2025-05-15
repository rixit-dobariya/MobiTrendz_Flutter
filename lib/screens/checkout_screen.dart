import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobitrendz/controllers/checkout_controller.dart';
import 'package:mobitrendz/screens/select_address_view.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

  final checkoutController = Get.find<CheckoutController>();

  @override
  Widget build(BuildContext context) {
    final selectedAddress = checkoutController.selectedAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: selectedAddress == null
          ? const Center(child: Text('No address selected.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Obx(() {
                // Observing cartItems and other reactive values here
                final cartItems = checkoutController.cartItems;
                final subtotal = checkoutController.subtotal.value;
                final shippingCharge = checkoutController.shippingCharge.value;
                final total = checkoutController.totalPrice.value;
                final isLoading = checkoutController.isLoading.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Shipping Address',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(selectedAddress['fullName'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          Text(selectedAddress['address'] ?? ''),
                          Text(
                              '${selectedAddress['city'] ?? ''}, ${selectedAddress['state'] ?? ''}'),
                          Text('Pincode: ${selectedAddress['pincode'] ?? ''}'),
                          const SizedBox(height: 4),
                          Text('Phone: ${selectedAddress['phone'] ?? ''}'),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Get.to(() => SelectAddressView());
                              },
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Colors.blueAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Change Address',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cart Items List - DYNAMIC
                    if (cartItems.isEmpty)
                      const Center(child: Text('Cart is empty.'))
                    else
                      Column(
                        children: cartItems.map<Widget>((item) {
                          final product = item['productId'] ?? {};
                          final name = product['productName'] ?? 'Product';
                          final qty = item['quantity'] ?? 1;
                          final salePrice =
                              (product['salePrice'] ?? 0).toDouble();
                          final discount =
                              (product['discount'] ?? 0).toDouble();
                          final priceAfterDiscount =
                              salePrice - (salePrice * discount / 100);
                          final imageUrl = product['productImage'] ?? '';

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 60,
                                          width: 60,
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                              Icons.image_not_supported),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text('Qty: $qty'),
                                    ],
                                  ),
                                ),
                                Text(
                                    '₹${(priceAfterDiscount * qty).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 16),

                    // Summary Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SummaryRow(
                              label: 'Subtotal',
                              value: '₹${subtotal.toStringAsFixed(2)}'),
                          SummaryRow(
                              label: 'Shipping Charge',
                              value: '₹${shippingCharge.toStringAsFixed(2)}'),
                          const Divider(),
                          SummaryRow(
                              label: 'Total',
                              value: '₹${total.toStringAsFixed(2)}',
                              isBold: true),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (checkoutController
                                        .selectedAddress.isEmpty) {
                                      Get.snackbar("Error",
                                          "Please select a delivery address");
                                      return;
                                    }

                                    if (checkoutController.cartItems.isEmpty) {
                                      Get.snackbar("Error", "Cart is empty");
                                      return;
                                    }

                                    checkoutController
                                        .calculateTotal(); // Ensure pricing is up-to-date
                                    await checkoutController
                                        .createRazorpayOrder(); // Starts the payment process
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Proceed to pay"),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}
