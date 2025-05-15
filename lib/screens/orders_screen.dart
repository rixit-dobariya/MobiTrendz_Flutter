import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobitrendz/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userId = sp.getString("userId");

    if (userId == null || userId.isEmpty) {
      Get.snackbar("Error", "User ID not found");
      return;
    }

    final Uri url = Uri.parse("${AppConstants.baseUrl}/orders/user/$userId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          orders = jsonData['orders'] ?? [];
          isLoading = false;
        });
      } else {
        Get.snackbar("Error", "Failed to load orders");
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Color getOrderStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "shipped":
        return Colors.blue;
      case "delivered":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "completed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "failed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return "";
    final dateTime = DateTime.tryParse(isoDate);
    if (dateTime == null) return "";
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
  }

  Widget buildOrderItem(Map<String, dynamic> order) {
    final address = order['delAddressId'];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Row(
            children: [
              Expanded(
                child: Text(
                  "Order No: #${order['_id']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getOrderStatusColor(order['orderStatus']),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['orderStatus'] ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formatDate(order['createdAt']),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Order details
          buildOrderRow(
              "Total:", "₹${order['total']?['\$numberDecimal'] ?? '0'}"),
          buildOrderRow("Shipping:",
              "₹${order['shippingCharge']?['\$numberDecimal'] ?? '0'}"),
          buildOrderRow("Payment Mode:", order['paymentMode'] ?? ""),
          buildOrderRow(
            "Payment Status:",
            order['paymentStatus'] ?? "",
            statusColor: getPaymentStatusColor(order['paymentStatus']),
          ),
          if (address != null)
            buildOrderRow(
              "Delivery Address:",
              "${address['fullName']}, ${address['address']}, ${address['city']}, ${address['state']} - ${address['pincode']} | Ph: ${address['phone']}",
            ),
        ],
      ),
    );
  }

  Widget buildOrderRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: statusColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : orders.isEmpty
            ? const Center(
                child: Text(
                  "No orders found.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 60),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return buildOrderItem(orders[index]);
                },
              );
  }
}
