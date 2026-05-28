import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _data = await context.read<AuthProvider>().api.adminAnalytics();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: PageWrapper(
        child: _data == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(0),
                children: [
                Text('Sales (7 days)', style: Theme.of(context).textTheme.titleMedium),
                ...(_data!['sales_data'] as List).map((d) => ListTile(
                      title: Text(d['date'].toString()),
                      trailing: Text('UGX ${d['total']}'),
                    )),
                const Divider(),
                Text('Orders by status', style: Theme.of(context).textTheme.titleMedium),
                ...(_data!['order_status_data'] as List).map((d) => ListTile(
                      title: Text(d['status'].toString()),
                      trailing: Text('${d['count']}'),
                    )),
                const Divider(),
                Text('Top products', style: Theme.of(context).textTheme.titleMedium),
                ...(_data!['top_products'] as List).map((d) => ListTile(
                      title: Text(d['product_name']?.toString() ?? 'Product'),
                      trailing: Text('${d['total_qty']} sold'),
                    )),
              ],
            ),
        ),
    );
  }
}
