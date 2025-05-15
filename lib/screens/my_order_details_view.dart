import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobitrendz/constants/app_constants.dart';

class MyOrdersDetailView extends StatefulWidget {
  final String orderId;

  const MyOrdersDetailView({Key? key, required this.orderId}) : super(key: key);

  @override
  _MyOrdersDetailViewState createState() => _MyOrdersDetailViewState();
}

class _MyOrdersDetailViewState extends State<MyOrdersDetailView> {
  late Map<String, dynamic> order;
  late List<Map<String, dynamic>> orderItems;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    orderItems = [];
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    final String url = '${AppConstants.baseUrl}/orders/${widget.orderId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          order = responseData['order'];
          orderItems =
              List<Map<String, dynamic>>.from(responseData['orderItems']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load order details.';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset("assets/img/back.png", width: 20, height: 20),
        ),
        centerTitle: true,
        title: Text(
          "My Order Detail",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _showError(errorMessage)
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      _buildOrderInfoCard(),
                      const SizedBox(height: 15),
                      _buildAddressCard(),
                      const SizedBox(height: 15),
                      _buildOrderItemsList(),
                      const SizedBox(height: 15),
                      _buildAmountSummaryCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Order ID: #${order["_id"] ?? ''}",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                getPaymentStatus(order),
                style: TextStyle(
                  color: getPaymentStatusColor(order),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  "${order["orderDate"] ?? ''}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                getOrderStatus(order),
                style: TextStyle(
                  color: getOrderStatusColor(order),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow("Payment Type:", getPaymentType(order)),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Address",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          // Full Name
          Text(
            "${order["delAddressId"]?["fullName"] ?? "N/A"}",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          // Address
          Text(
            "${order["delAddressId"]?["address"] ?? "N/A"}",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${order["delAddressId"]?["city"] ?? "N/A"}, ${order["delAddressId"]?["state"] ?? "N/A"} - ${order["delAddressId"]?["pincode"] ?? "N/A"}",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
              "Phone:", "${order["delAddressId"]?["phone"] ?? "N/A"}"),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Items",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          ...orderItems.map((pObj) {
            // Parse price safely
            String priceStr = pObj['price']['\$numberDecimal'] ?? '0.0';
            double price = double.tryParse(priceStr) ?? 0.0;

            // Parse quantity safely
            int quantity = pObj["quantity"] is int
                ? pObj["quantity"]
                : int.tryParse(pObj["quantity"].toString()) ?? 0;

            double totalPrice = price * quantity;

            bool showReviewButton = (order["orderStatus"] == "Delivered" &&
                (pObj["rating"] == 0 || pObj["rating"] == 0.0));

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 1)
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: pObj["productId"]?["productImage"] != null &&
                                pObj["productId"]!["productImage"]
                                    .toString()
                                    .isNotEmpty
                            ? NetworkImage(pObj["productId"]["productImage"])
                            : const AssetImage("assets/img/placeholder.png")
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details + review button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pObj["productId"]?["productName"] ??
                              'Unknown product',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Quantity: $quantity",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Total: \₹${totalPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (showReviewButton)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: implement review functionality
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Write Review",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAmountSummaryCard() {
    double itemsTotal = 0;
    double totalDiscount = 0;

    for (var item in orderItems) {
      final price =
          double.tryParse(item['price']['\$numberDecimal'].toString()) ?? 0.0;
      final qty = double.tryParse(item['quantity'].toString()) ?? 0.0;
      final discount =
          double.tryParse(item['discount']['\$numberDecimal'].toString()) ??
              0.0;

      itemsTotal += price * qty;
      totalDiscount += discount * qty;
    }

    final double totalAmount = itemsTotal - totalDiscount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        children: [
          _buildAmountRow("Items Total", "\₹${itemsTotal.toStringAsFixed(2)}"),
          _buildAmountRow(
              "Total Discount", "- \₹${totalDiscount.toStringAsFixed(2)}"),
          const Divider(height: 30, thickness: 1),
          _buildAmountRow(
            "Total Amount",
            "\₹${totalAmount.toStringAsFixed(2)}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: [
          Text(
            "$label ",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showError(String error) {
    return Center(
      child: Text(
        error,
        style: TextStyle(color: Colors.red, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  String getPaymentStatus(Map<String, dynamic> order) {
    String status = order["paymentStatus"] ?? "";
    if (status.toLowerCase() == "paid") {
      return "Paid";
    } else if (status.toLowerCase() == "unpaid") {
      return "Unpaid";
    }
    return "Unknown";
  }

  Color getPaymentStatusColor(Map<String, dynamic> order) {
    String status = order["paymentStatus"] ?? "";
    if (status.toLowerCase() == "paid") {
      return Colors.green;
    } else if (status.toLowerCase() == "unpaid") {
      return Colors.red;
    }
    return Colors.grey;
  }

  String getOrderStatus(Map<String, dynamic> order) {
    String status = order["orderStatus"] ?? "";
    switch (status.toLowerCase()) {
      case "pending":
        return "Pending";
      case "shipped":
        return "Shipped";
      case "delivered":
        return "Delivered";
      case "cancelled":
        return "Cancelled";
      default:
        return "Unknown";
    }
  }

  Color getOrderStatusColor(Map<String, dynamic> order) {
    String status = order["orderStatus"] ?? "";
    switch (status.toLowerCase()) {
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

  String getPaymentType(Map<String, dynamic> order) {
    return order["paymentType"] ?? "N/A";
  }
}
