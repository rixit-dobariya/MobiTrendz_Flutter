import 'package:flutter/material.dart';
import 'package:mobitrendz/screens/home_page_content.dart';

import 'package:mobitrendz/screens/cart_screen.dart';
import 'package:mobitrendz/screens/orders_screen.dart';
import 'package:mobitrendz/screens/profile_screen.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomePageContent(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Map<String, String>> categories = [
    {"name": "Apple", "image": "assets/apple.png"},
    {"name": "Samsung", "image": "assets/samsung.png"},
    {"name": "Asus", "image": "assets/asus.png"},
    {"name": "Oppo", "image": "assets/oppo.png"},
  ];

  final List<Map<String, String>> products = [
    {
      "name": "iPhone 15 Pro",
      "price": "₹1,30,990",
      "image": "assets/iphone.jpg"
    },
    {"name": "Redmi Note 13", "price": "₹22,990", "image": "assets/redmi.png"},
    {
      "name": "iPhone 15 Pro",
      "price": "₹1,30,990",
      "image": "assets/iphone.jpg"
    },
    {"name": "Redmi Note 13", "price": "₹22,990", "image": "assets/redmi.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Category",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: categories.map((category) {
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      padding: EdgeInsets.all(14),
                      child: Image.asset(category["image"]!, width: 40),
                    ),
                    SizedBox(height: 6),
                    Text(category["name"]!,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(products[index]["image"]!, width: 100),
                        SizedBox(height: 10),
                        Text(products[index]["name"]!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center),
                        SizedBox(height: 6),
                        Text(products[index]["price"]!,
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "Cart"),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt), label: "Orders"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
