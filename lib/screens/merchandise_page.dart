import 'package:flutter/material.dart';
import '../widgets/animated_blocks_background.dart';

class MerchandisePage extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      'name': 'GenMon Cap',
      'price': 100,
      'image': Icons.emoji_objects,
    },
    {
      'name': 'GenMon Hoodie',
      'price': 300,
      'image': Icons.checkroom,
    },
    {
      'name': 'GenMon T-Shirt',
      'price': 200,
      'image': Icons.emoji_people,
    },
    {
      'name': 'GenMon Jacket',
      'price': 400,
      'image': Icons.hiking,
    },
    {
      'name': 'GenMon Bag',
      'price': 250,
      'image': Icons.backpack,
    },
  ];

  String userId = "HIuqKfSyt734wPozzG3W";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AnimatedBlocksBackground(neonColor: Color(0xFF00FF99)),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Merchandise', style: TextStyle(color: Colors.white)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(product['image'], size: 60, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        product['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${product['price']} GenMon Coins',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Purchased ${product['name']}!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: const Text('Buy'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
} 