import 'package:flutter/material.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';

// 1. This is a new StatelessWidget
class ProductDetailScreen extends StatelessWidget {

  // 2. We will pass in the product's data (the map)
  final Map<String, dynamic> productData;
  // 3. We'll also pass the unique product ID (critical for 'Add to Cart' later)
  final String productId;

  // 4. The constructor takes both parameters
  const ProductDetailScreen({
    super.key,
    required this.productData,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ADD THIS LINE: Get the CartProvider
    // We set listen: false because we are not rebuilding, just calling a function
    final cart = Provider.of<CartProvider>(context, listen: false);

    // 1. Extract data from the map for easier use
    final String name = productData['name'] ?? 'No Name';
    final String description = productData['description'] ?? 'No Description';
    final double price = (productData['price'] ?? 0).toDouble();
    final String imageUrl = productData['imageUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(
        // 3. Show the product name in the top bar
        title: Text(name),
      ),
      // 4. This allows scrolling if the description is very long
      body: SingleChildScrollView(
        child: Column(
          // 5. Make children fill the width
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 100),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 9. Product Name (large font)
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 10. Price (large font, different color)
                  Text(
                    '₱${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(description),
                  const SizedBox(height: 30),
                  // 13. The "Add to Cart" button (UI ONLY)
                  ElevatedButton.icon(
                    onPressed: () {
                      // 4. THIS IS THE NEW LOGIC!
                      // Call the addItem function from our provider
                      cart.addItem(productId, name, price);

                      // 5. Show a confirmation pop-up
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
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