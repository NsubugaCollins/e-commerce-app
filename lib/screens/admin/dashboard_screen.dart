import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _data = await context.read<AuthProvider>().api.adminDashboard();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => context.push('/admin/$v'),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'analytics', child: Text('Analytics')),
              PopupMenuItem(value: 'earnings', child: Text('Earnings')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'profile', child: Text('Profile')),
            ],
          ),
        ],
      ),
      body: PageWrapper(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_data != null) ...[
                    _statCard('Total sales', currency.format(_data!['stats']['total_sales'])),
                    _statCard('Users', '${_data!['stats']['active_users']}'),
                    _statCard('Orders', '${_data!['stats']['total_orders']}'),
                    _statCard('Products', '${_data!['stats']['total_products']}'),
                    const SizedBox(height: 16),
                    Text('Recent orders', style: Theme.of(context).textTheme.titleMedium),
                    ...(_data!['recent_orders'] as List).map((o) => ListTile(
                          title: Text('Order #${o['id']}'),
                          subtitle: Text('${o['user_name']} · ${o['status']}'),
                          trailing: Text(currency.format(o['total_amount'])),
                          onTap: () => context.push('/admin/orders/${o['id']}'),
                        )),
                  ],
                ],
              ),
            ),
          ),
        );
  }

  Widget _statCard(String label, String value) {
    return Card(
      child: ListTile(title: Text(label), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}
