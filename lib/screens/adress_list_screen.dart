import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_address_screen.dart';
import '../../controllers/address_controller.dart';

class AddressListView extends StatefulWidget {
  const AddressListView({super.key});

  @override
  State<AddressListView> createState() => _AddressListViewState();
}

class _AddressListViewState extends State<AddressListView> {
  final AddressController addressController = Get.put(AddressController());

  @override
  void initState() {
    super.initState();
    addressController.fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Delivery Address",
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
          separatorBuilder: (_, __) =>
              const SizedBox(height: 15), // <-- Spacing added here
          itemBuilder: (context, index) {
            var address = addressController.addresses[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
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
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
