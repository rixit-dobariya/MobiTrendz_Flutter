import 'package:flutter/material.dart';
import 'package:mobitrendz/screens/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String imagePath;
  final String name;
  final String price;

  const ProductDetailScreen({
    super.key,
    required this.imagePath,
    required this.name,
    required this.price,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  double totalPrice = 0.0;
  Color selectedColor = Colors.orange; // Default selected color

  @override
  void initState() {
    super.initState();
    totalPrice = double.parse(widget.price.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  void updateTotalPrice() {
    setState(() {
      totalPrice = quantity *
          double.parse(widget.price.replaceAll(RegExp(r'[^0-9]'), ''));
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Ensures it fits on one screen
            children: [
              // Product Image Container with Thicker Border
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20), // Increased padding
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey.shade400,
                        width: 3), // Increased border thickness
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(widget.imagePath,
                      height: 200, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 10),

              // Product Name
              Text(
                widget.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              // Line after product name
              const Divider(thickness: 1),

              // Description Title
              const Text(
                "Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),

              // Description Text
              const Text(
                "ADVANCED DISPLAY — The 6.1” Super Retina XDR display with ProMotion ramps up refresh rates to 120Hz",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              // Size and Color Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Size",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text("Color",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("128 GB", style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      _buildColorOption(Colors.orange),
                      _buildColorOption(Colors.grey),
                      _buildColorOption(Colors.green),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quantity Section
              const Text("Quantity",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Quantity Selector
              Row(
                children: [
                  _buildQuantityButton(Icons.remove, false),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      quantity.toString(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildQuantityButton(Icons.add, true),
                ],
              ),
              const SizedBox(height: 10),

              // Line after quantity
              const Divider(thickness: 1),

              // Total Price Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Price",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    "₹${totalPrice.toInt()}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add to Cart Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text("Add to Cart",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Color Selection Widget
  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color; // Update selected color
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selectedColor == color
              ? Border.all(
                  color: Colors.black,
                  width: 2) // Change this color to any you prefer
              : null,
        ),
      ),
    );
  }

  // Quantity Button Widget
  Widget _buildQuantityButton(IconData icon, bool isIncrement) {
    return InkWell(
      onTap: () {
        setState(() {
          if (isIncrement) {
            quantity++;
          } else if (quantity > 1) {
            quantity--;
          }
          updateTotalPrice();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
