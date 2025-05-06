import 'package:flutter/material.dart';
import 'package:mobitrendz/screens/product_details.dart';
import 'package:mobitrendz/screens/category_screen.dart';
import 'package:mobitrendz/screens/cart_screen.dart';
import 'package:mobitrendz/screens/orders_screen.dart';
import 'package:mobitrendz/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12, // Soft shadow
              blurRadius: 10, // A little more blur for the bottom bar
              offset: Offset(0, -4), // Light offset to create floating effect
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          elevation: 0, // Remove default elevation
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

class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: AssetImage("assets/profiles.png"),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Jay Gorfad",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for products...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Special Offers
            const Text("Special Offers",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.purple.shade100, blurRadius: 8)
                ],
              ),
              child: const Center(
                child: Text(
                  "Flat 10% OFF!",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Category Section
            const Text("Browse by Brand",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBrandIcon("assets/apple.png", "Apple", context),
                _buildBrandIcon("assets/samsung.png", "Samsung", context),
                _buildBrandIcon("assets/asus.png", "Asus", context),
                _buildBrandIcon("assets/oppo.png", "Oppo", context),
              ],
            ),
            const SizedBox(height: 18),

            // Most Popular
            const Text("Most Popular",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.75,
              children: [
                _buildProductCard(
                    "assets/iphone.jpg", "iPhone 15 Pro", "₹1,30,990", context),
                _buildProductCard(
                    "assets/redmi.png", "Redmi Note 13", "₹22,990", context),
                _buildProductCard(
                    "assets/iphone.jpg", "iPhone 15 Pro", "₹1,30,990", context),
                _buildProductCard(
                    "assets/redmi.png", "Redmi Note 13", "₹22,990", context),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandIcon(
      String imagePath, String brandName, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => CategoryScreen()));
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26, // Lighter, more subtle shadow color
                  blurRadius: 8, // Softer, less pronounced shadow
                  offset: Offset(
                      0, 4), // Slightly shifted shadow for a natural look
                ),
              ],
            ),
            padding: EdgeInsets.all(14),
            child: Image.asset(imagePath, width: 40, height: 40),
          ),
          const SizedBox(height: 6),
          Text(
            brandName,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      String imagePath, String name, String price, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                  imagePath: imagePath, name: name, price: price),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(imagePath,
                    width: 90, height: 90, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
