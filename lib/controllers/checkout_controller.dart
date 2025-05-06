import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobitrendz/screens/order_successful.dart';
import '../constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutController extends GetxController {
  var selectedAddress = {}.obs;
  var promoCode = {}.obs;
  var cartItems = [].obs;
  var totalPrice = 0.0.obs;
  var shippingCharge = 0.0.obs;
  var discountAmount = 0.0.obs;
  var subtotal = 0.0.obs;

  void calculateTotal() {
    try {
      double rawSubtotal = 0;
      for (var item in cartItems) {
        final product = item['productId'];
        if (product == null) continue;

        double salePrice = product['salePrice']?.toDouble() ?? 0;
        double discount = product['discount']?.toDouble() ?? 0;
        int quantity = item['quantity'] ?? 1;
        double finalPrice = salePrice - (salePrice * discount / 100);
        rawSubtotal += finalPrice * quantity;
      }

      // Promo logic...
      double promoDiscount = 0;
      if (promoCode.isNotEmpty) {
        double discountPercent = promoCode['discount']?.toDouble() ?? 0;
        double maxDiscount = promoCode['maxDiscount']?.toDouble() ?? 0;
        promoDiscount =
            (rawSubtotal * discountPercent / 100).clamp(0, maxDiscount);
      }
      subtotal.value = rawSubtotal;
      discountAmount.value = promoDiscount;
      shippingCharge.value = cartItems.isNotEmpty ? 50.0 : 0.0;
      totalPrice.value = rawSubtotal - promoDiscount + shippingCharge.value;
    } catch (e) {
      Get.snackbar("message", '${e}');
    }
  }

  var isLoading = false.obs;

  // Method to create Razorpay order
  Future<void> createRazorpayOrder() async {
    final url = Uri.parse('${AppConstants.baseUrl}/payment/create-order');
    isLoading.value = true;

    try {
      final response = await http.post(
        url,
        body: json.encode({'amount': totalPrice.value}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          final razorpayOrderId = responseData['order']['id'];
          initiatePayment(razorpayOrderId);
        } else {
          Get.snackbar('Error', 'Failed to create Razorpay order');
        }
      } else {
        Get.snackbar('Error', 'Failed to create Razorpay order');
      }
    } catch (error) {
      Get.snackbar('Error', 'An error occurred while creating Razorpay order');
    } finally {
      isLoading.value = false;
    }
  }

  final Razorpay _razorpay = Razorpay();

  @override
  void onInit() {
    super.onInit();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Method to initiate payment via Razorpay SDK
  void initiatePayment(String razorpayOrderId) {
    var options = {
      'key': AppConstants.razorPayKey, // Replace with your actual Razorpay key
      'amount': (totalPrice.value * 100).toInt(), // Amount in paise
      'currency': 'INR',
      'order_id': razorpayOrderId,
      'name': 'Purebite grocery shop',
      'description': 'Order Payment',
      'prefill': {
        'name':
            '${selectedAddress["firstName"] ?? ""} ${selectedAddress["lastName"] ?? ""}',
        'contact': selectedAddress["phone"] ?? "",
      },
      'theme': "#53B175",
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar('Error', 'Failed to initiate payment');
    }
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    confirmPayment(response.paymentId ?? "", response.orderId ?? "");
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar('Error', 'Payment failed: ${response.message}');
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet payment
  }

  // Confirm payment with backend
  Future<void> confirmPayment(
      String razorpayPaymentId, String razorpayOrderId) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/orders/checkout'); // Replace with your actual endpoint

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId'); // or your actual key
      final response = await http.post(
        url,
        body: json.encode({
          'userId': userId,
          'addressId': selectedAddress['_id'] ?? selectedAddress['id'],
          'promoCodeId': promoCode['id'],
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true ||
            responseData['message'] == 'Checkout completed successfully.') {
          resetCheckout();
          Get.snackbar(
            'Success',
            responseData['message'] ?? 'Order placed successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.offAll(() => OrderSuccessScreen());
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to complete the order',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        final responseData = json.decode(response.body);
        Get.snackbar(
          'Error',
          responseData['message'] ?? 'Failed to confirm payment',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      Get.snackbar('Error', 'An error occurred while confirming payment');
    }
  }

  // Clear everything after successful order
  void resetCheckout() {
    selectedAddress.clear();
    promoCode.clear();
    cartItems.clear();
    totalPrice.value = 0;
    discountAmount.value = 0;
  }
}
