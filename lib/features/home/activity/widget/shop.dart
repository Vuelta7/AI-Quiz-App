import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/provider/user_provider.dart';
import 'package:learn_n/core/widgets/loading.dart';
import 'package:lottie/lottie.dart';

class Shop extends ConsumerWidget {
  const Shop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);
    final textIconColor = ref.watch(textIconColorProvider);
    final userColor = ref.watch(userColorProvider);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Loading());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User data not found.'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final currencyPoints = userData['currencypoints'] ?? 0;

        final List<Product> products = [
          Product(
            name: 'Buy Hint',
            price: 50,
            icon: Icons.lightbulb,
            bgColor: Colors.blue,
            onTap: currencyPoints >= 50
                ? () async {
                    print('Buy Hint tapped');
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .update({
                      'currencypoints': currencyPoints - 50,
                      'hints': (userData['hints'] ?? 0) + 1,
                    });
                  }
                : null,
          ),
          Product(
            name: 'Change Pet Name',
            price: 1000,
            icon: Icons.pets,
            bgColor: Colors.green,
            onTap: currencyPoints >= 1000
                ? () async {
                    print('Change Pet Name tapped');
                    String newName = await _showInputDialog(
                        context, 'Change Pet Name', userColor, textIconColor);
                    if (newName.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                        'currencypoints': currencyPoints - 1000,
                        'petName': newName,
                      });
                    }
                  }
                : null,
          ),
          Product(
            name: 'Change Username',
            price: 1000,
            icon: Icons.person,
            bgColor: Colors.red,
            onTap: currencyPoints >= 1000
                ? () async {
                    print('Change Username tapped');
                    String newUsername = await _showInputDialog(
                        context, 'Change Username', userColor, textIconColor);
                    if (newUsername.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                        'currencypoints': currencyPoints - 1000,
                        'username': newUsername,
                      });
                    }
                  }
                : null,
          ),
        ];

        return SizedBox(
          height: 800,
          child: Column(
            children: [
              Lottie.asset('assets/hints.json', height: 300),
              Text(
                'Points: $currencyPoints',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textIconColor,
                  fontFamily: 'PressStart2P',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12.0),
                  children: products
                      .map((product) => ProductCard(
                            product: product,
                            textIconColor: textIconColor,
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final Color textIconColor;

  const ProductCard({
    super.key,
    required this.product,
    required this.textIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = product.onTap == null;

    return GestureDetector(
      onTap: isDisabled ? null : product.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey : product.bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(34, 0, 0, 0),
              offset: Offset(0, 8),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  product.icon,
                  size: 48,
                  color: isDisabled ? Colors.black38 : textIconColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: TextStyle(
                color: isDisabled ? Colors.black38 : textIconColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.price} Points',
              style: TextStyle(
                color: isDisabled ? Colors.black38 : textIconColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final int price;
  final IconData icon;
  final Color bgColor;
  final VoidCallback? onTap;

  Product({
    required this.name,
    required this.price,
    required this.icon,
    required this.bgColor,
    this.onTap,
  });
}

Future<String> _showInputDialog(BuildContext context, String title,
    Color userColor, Color textIconColor) async {
  String inputText = '';
  await showDialog(
    context: context,
    builder: (context) {
      final TextEditingController controller = TextEditingController();
      return AlertDialog(
        backgroundColor: userColor,
        title: Text(title, style: TextStyle(color: textIconColor)),
        content: TextField(
            controller: controller,
            style: TextStyle(color: textIconColor),
            maxLength: 8,
            decoration: InputDecoration(
                hintText: title, hintStyle: TextStyle(color: textIconColor))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: textIconColor)),
          ),
          TextButton(
            onPressed: () {
              inputText = controller.text;
              Navigator.of(context).pop();
            },
            child: Text(
              'Confirm',
              style: TextStyle(color: textIconColor),
            ),
          ),
        ],
      );
    },
  );
  return inputText;
}
