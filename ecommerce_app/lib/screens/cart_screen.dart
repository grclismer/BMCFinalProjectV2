import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the cart. This time, we *want* to listen (default)
    //    so this screen rebuilds when we remove an item.
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          // 2. The list of items
          Expanded(
            // 3. If cart is empty, show a message
            child: cart.items.isEmpty
                ? const Center(child: Text('Your cart is empty.'))
                : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                // 4. A ListTile to show item details
                return ListTile(
                  leading: CircleAvatar(child: Text(item.name[0])),
                  // Show a mini-image (or first letter)
                  title: Text(item.name),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 5. Total for this item
                      Text('₱${(item.price * item.quantity).toStringAsFixed(2)}'),
                      // 6. Remove button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => cart.removeItem(item.id),
                        // 7. Call the removeItem function
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // 8. The Total Price Summary
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('₱${cart.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          // We'll add a "Checkout" button here in a future module
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
