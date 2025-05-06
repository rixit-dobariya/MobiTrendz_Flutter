import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: OrdersScreen(),
  ));
}

class OrdersScreen extends StatelessWidget {
  final List<OrderItem> orders = [
    OrderItem(
        name: "iPhone 15 Pro",
        price: "₹ 1,30,990",
        imageUrl: "assets/iphone.jpg",
        status: "Pending"),
    OrderItem(
        name: "Redmi Note 13",
        price: "₹ 22,990",
        imageUrl: "assets/redmi.png",
        status: "Shipped"),
    OrderItem(
        name: "iPhone 15 Pro",
        price: "₹ 1,30,990",
        imageUrl: "assets/iphone.jpg",
        status: "Pending"),
    OrderItem(
        name: "Redmi Note 13",
        price: "₹ 22,990",
        imageUrl: "assets/redmi.png",
        status: "Shipped"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        title: Text("Orders", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white, // White background for app bar
        elevation: 0, // Remove shadow for a clean look
        iconTheme: IconThemeData(color: Colors.black), // Black back icon
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderCard(order: orders[index]);
          },
        ),
      ),
    );
  }
}

class OrderItem {
  final String name;
  final String price;
  final String imageUrl;
  final String status;

  OrderItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.status,
  });
}

class OrderCard extends StatelessWidget {
  final OrderItem order;

  const OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Ensure card background is also white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3, // Slight shadow for depth
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Image.asset(order.imageUrl,
                width: 65, height: 65, fit: BoxFit.cover),
            SizedBox(width: 25),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(order.price,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.status == "Pending"
                          ? Colors.orange[100]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: order.status == "Pending"
                            ? Colors.orange[800]
                            : Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
