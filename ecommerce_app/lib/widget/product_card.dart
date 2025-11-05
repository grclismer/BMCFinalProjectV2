import 'package:flutter/material.dart';

// 1. This is a simple StatelessWidget
class ProductCard extends StatelessWidget {

  // 2. We'll require the data we need to display
  final String productName;
  final double price;
  final String imageUrl;
  final VoidCallback onTap; // NEW

  // 3. The constructor takes this data
  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.onTap, // NEW
  });

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the Card in an InkWell widget
    return InkWell(
      onTap: onTap, // 2. Call the function we passed in
      child: Card(
        elevation: 3,
        child: Column(
          // 3. The rest of your Column code is UNCHANGED
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image, size: 50));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('₱${price.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}