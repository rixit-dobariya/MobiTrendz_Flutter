import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Orders Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              child: Row(
                children: [
                  Image.asset(
                    'assets/iphone15.png', // Add this asset
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Id  #25304',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('iPhone 15 Pro'),
                        Text('Quantity  1'),
                        Text('₹ 1,30,990',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Address',
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jay Gorfad'),
                  Text('Kothariya Main Road'),
                  Text('Rajkot - 360002'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Payment Details:',
              child: Row(
                children: [
                  Image.asset(
                    'assets/googlepay.jpg', // Add Google Pay icon here
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jay Gorfad'),
                      Text('jaygorfad@okaxis'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Summary',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSummaryRow('Subtotal:', '₹1,30,990'),
        _buildSummaryRow('Delivery:', 'Free', isFree: true),
        const Divider(),
        _buildSummaryRow('Grand Total:', '₹1,30,990', isBold: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isFree ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }
}
