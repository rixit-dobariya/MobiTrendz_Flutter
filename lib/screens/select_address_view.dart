import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobitrendz/screens/checkout_screen.dart';
import 'add_address_screen.dart';
import '../../controllers/address_controller.dart';
import '../../controllers/checkout_controller.dart';

class SelectAddressView extends StatefulWidget {
  const SelectAddressView({super.key});

  @override
  State<SelectAddressView> createState() => _SelectAddressViewState();
}

class _SelectAddressViewState extends State<SelectAddressView> {
  final AddressController addressController = Get.put(AddressController());
  final CheckoutController checkoutController = Get.find<CheckoutController>();

  @override
  void initState() {
    super.initState();
    addressController.fetchAddresses();
  }

  void selectAddress(Map<String, dynamic> addressJson) {
    checkoutController.selectedAddress.value = addressJson;
    Get.to(() => CheckoutScreen()); // Return to previous screen after selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Select Delivery Address",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Get.to(() => AddAddressView(isEdit: false));
              addressController.fetchAddresses();
            },
            icon: const Icon(
              Icons.add,
              size: 24,
              color: Colors.black,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (addressController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (addressController.addresses.isEmpty) {
          return const Center(child: Text('No addresses found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          itemCount: addressController.addresses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final address = addressController.addresses[index];
            final selectedId = checkoutController.selectedAddress['_id'] ?? '';
            final isSelected = selectedId == address.id;

            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Phone: ${address.phone}"),
                  Text("Address: ${address.address}, ${address.city}"),
                  Text("State: ${address.state} - ${address.pincode}"),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.blue : Colors.grey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => selectAddress(address.toJson()),
                      child: Text(
                        isSelected ? "Selected" : "Select",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
