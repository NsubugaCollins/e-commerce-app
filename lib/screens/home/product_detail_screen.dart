import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/page_wrapper.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await context.read<AuthProvider>().api.getProduct(widget.productId);
      if (mounted) {
        setState(() {
          _product = p;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addToCart() async {
    final auth = context.read<AuthProvider>();
    if (auth.status != AuthStatus.authenticated) {
      context.push('/login');
      return;
    }
    final ok = await context.read<CartProvider>().addProduct(
          widget.productId,
          quantity: _qty,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Added to cart' : 'Could not add to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Product not found')),
      );
    }

    final p = _product!;

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: PageWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: p.imageUrl,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(label: Text(p.category)),
                const SizedBox(height: 8),
                Text(
                  currency.format(p.price),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (p.description != null && p.description!.isNotEmpty)
                  Text(p.description!),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('Quantity:'),
                    IconButton(
                      onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_qty', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: () => setState(() => _qty++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _addToCart,
            child: const Text('Add to cart'),
          ),
        ),
      ),
    );
  }
}
