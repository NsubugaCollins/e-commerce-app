import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _products = await context.read<AuthProvider>().api.adminProducts();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/products/new').then((_) => _load()),
          ),
        ],
      ),
      body: PageWrapper(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, i) {
                  final p = _products[i];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('${p.category} · UGX ${p.price}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await context.read<AuthProvider>().api.adminDeleteProduct(p.id);
                        _load();
                      },
                    ),
                    onTap: () => context.push('/admin/products/${p.id}').then((_) => _load()),
                  );
                },
              ),
            ),
        ),
    );
  }
}
