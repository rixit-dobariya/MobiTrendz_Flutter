import 'package:flutter/material.dart';
import 'package:mobitrendz/screens/checkout_screen.dart';

void main() {
  runApp(MaterialApp(home: CartScreen()));
}

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [
    {
      "name": "iPhone 15 Pro",
      "price": 130990,
      "quantity": 1,
      "image": "assets/iphone.jpg"
    },
    {
      "name": "Redmi Note 13",
      "price": 22990,
      "quantity": 1,
      "image": "assets/redmi.png"
    },
    {
      "name": "iPhone 15 Pro",
      "price": 130990,
      "quantity": 1,
      "image": "assets/iphone.jpg"
    },
    {
      "name": "iPhone 15 Pro",
      "price": 130990,
      "quantity": 1,
      "image": "assets/iphone.jpg"
    },
  ];

  int getTotalPrice() {
    return cartItems.fold<int>(
        0,
        (sum, item) =>
            sum + ((item["price"] as int) * (item["quantity"] as int)));
  }

  void updateQuantity(int index, int change) {
    setState(() {
      cartItems[index]["quantity"] += change;
      if (cartItems[index]["quantity"] < 1) cartItems[index]["quantity"] = 1;
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return CartItem(
                  item: cartItems[index],
                  onQuantityChanged: (change) => updateQuantity(index, change),
                );
              },
            ),
          ),
          BottomCheckoutBar(totalPrice: getTotalPrice()),
        ],
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(int) onQuantityChanged;

  CartItem({required this.item, required this.onQuantityChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Image.asset(item["image"], width: 80, height: 80),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "₹ ${item["price"]}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () => onQuantityChanged(-1),
              ),
              Text("${item["quantity"]}", style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () => onQuantityChanged(1),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class BottomCheckoutBar extends StatelessWidget {
  final int totalPrice;

  BottomCheckoutBar({required this.totalPrice});

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Price",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("₹ ${totalPrice}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
            child: const Text(
              "Checkout",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
