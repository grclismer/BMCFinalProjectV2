import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_app/screens/admin_panel_screen.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';
import 'package:ecommerce_app/widget/product_card.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:provider/provider.dart';

// 3. Change StatelessWidget to StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // 4. Create the State class
  State<HomeScreen> createState() => _HomeScreenState();
}

// 5. Rename the main class to _HomeScreenState and extend State
class _HomeScreenState extends State<HomeScreen> {
  // 1. A state variable to hold the user's role. Default to 'user'.
  String _userRole = 'user';
  // 2. Get the current user from Firebase Auth
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoadingRole = true;

  // 3. This function runs ONCE when the screen is first created
  @override
  void initState() {
    super.initState();
    // 4. Call our function to get the role as soon as the screen loads
    _fetchUserRole();
  }

  // 5. This is our new function to get data from Firestore
  Future<void> _fetchUserRole() async {
    // 6. If no one is logged in, do nothing
    if (_currentUser == null) {
      setState(() => _isLoadingRole = false);
      return;
    }

    try {
      // 7. Go to the 'users' collection, find the document
      //    matching the current user's ID
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      // 8. If the document exists...
      if (doc.exists && doc.data() != null) {
        // 9. ...call setState() to save the role to our variable
        setState(() {
          _userRole = doc.data()!['role'] ?? 'user';
          _isLoadingRole = false;
        });
      } else {
        setState(() {
          _userRole = 'user';
          _isLoadingRole = false;
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
      setState(() => _isLoadingRole = false);
    }
  }

  void _logout() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // 1. Use the _currentUser variable we defined
        title: Text(_currentUser != null ? 'Welcome, ${_currentUser!.email}' : 'Home'),
        actions: [
          // 1. --- ADD THIS NEW WIDGET ---
          // This is a special, efficient way to use Provider
          Consumer<CartProvider>(
            // 2. The "builder" function rebuilds *only* the icon
            builder: (context, cart, child) {
              // 3. The "Badge" widget adds a small label
              return Badge(
                // 4. Get the count from the provider
                label: Text(cart.itemCount.toString()),
                // 5. Only show the badge if the count is > 0
                isLabelVisible: cart.itemCount > 0,
                // 6. This is the child (our icon button)
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    // 7. Navigate to the CartScreen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // 2. --- THIS IS THE MAGIC ---
          //    This is a "collection-if". The IconButton will only
          //    be built IF _userRole is equal to 'admin'.
          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                // 3. This is why we imported admin_panel_screen.dart
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),

          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 2. This is our query to Firestore
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true) // 3. Show newest first
            .snapshots(),

        // 4. The builder runs every time new data arrives from the stream
        builder: (context, snapshot) {

          // 5. STATE 1: While data is loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 6. STATE 2: If an error occurs
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 7. STATE 3: If there's no data (or no products)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products found. Add some in the Admin Panel!'),
            );
          }

          // 8. STATE 4: We have data!
          // Get the list of product documents from the snapshot
          final products = snapshot.data!.docs;

          // 9. Use GridView.builder for a 2-column grid
          return GridView.builder(
            padding: const EdgeInsets.all(10.0),

            // 10. This configures the grid
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 10, // Horizontal space between cards
              mainAxisSpacing: 10, // Vertical space between cards
              childAspectRatio: 3 / 4, // Makes cards taller than wide
            ),

            itemCount: products.length,
            itemBuilder: (context, index) {
              // 11. Get the data for one product
              final productDoc = products[index];
              final productData = productDoc.data() as Map<String, dynamic>;

              // 12. Return our custom ProductCard widget!
              return ProductCard(
                productName: productData['name'] ?? 'No Name',
                price: (productData['price'] ?? 0).toDouble(),
                imageUrl: productData['imageUrl'] ?? '',
                onTap: () {
                  // 5. Navigate to the new screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        // 6. Pass the data to the new screen
                        productData: productData,
                        productId: productDoc.id, // 7. Pass the unique ID!
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}