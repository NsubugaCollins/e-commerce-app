import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _orders = await context.read<AuthProvider>().api.adminOrders();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: PageWrapper(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, i) {
                  final o = _orders[i];
                  return ListTile(
                    title: Text('Order #${o['id']}'),
                    subtitle: Text('${o['user']?['name']} · ${o['status']}'),
                    trailing: Text('UGX ${o['total_amount']}'),
                    onTap: () => context.push('/admin/orders/${o['id']}').then((_) => _load()),
                  );
                },
              ),
            ),
        ),
    );
  }
}
