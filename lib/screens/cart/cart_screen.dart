import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/page_wrapper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = context.read<CartProvider>();
      cartProvider.load(backgroundRefresh: cartProvider.cart != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currency = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);
    final showLoadingOverlay = cart.loading && cart.cart == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: showLoadingOverlay
          ? const Center(child: CircularProgressIndicator())
          : PageWrapper(
              child: cart.cart == null || cart.cart!.items.isEmpty
                  ? Center(
                      child: cart.refreshing
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Refreshing cart...'),
                          ],
                        )
                      : const Text('Your cart is empty'),
                )
              : Column(
                  children: [
                    if (cart.refreshing)
                      const LinearProgressIndicator(minHeight: 3),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cart.cart!.items.length,
                        itemBuilder: (context, i) {
                          final item = cart.cart!.items[i];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: ProductCard(
                                      product: item.product,
                                      compact: true,
                                      onTap: () =>
                                          context.push('/product/${item.product.id}'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.product.name, maxLines: 2),
                                        Text(currency.format(item.lineTotal)),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: item.quantity > 1
                                                  ? () => cart.updateQuantity(
                                                        item.id,
                                                        item.quantity - 1,
                                                      )
                                                  : null,
                                            ),
                                            Text('${item.quantity}'),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () => cart.updateQuantity(
                                                    item.id,
                                                    item.quantity + 1,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline),
                                              onPressed: () =>
                                                  cart.removeItem(item.id),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Total: ${currency.format(cart.cart!.total)}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.push('/checkout'),
                            child: const Text('Checkout'),
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
