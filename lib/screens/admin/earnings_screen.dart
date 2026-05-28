import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminEarningsScreen extends StatefulWidget {
  const AdminEarningsScreen({super.key});

  @override
  State<AdminEarningsScreen> createState() => _AdminEarningsScreenState();
}

class _AdminEarningsScreenState extends State<AdminEarningsScreen> {
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _data = await context.read<AuthProvider>().api.adminEarnings();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: PageWrapper(
        child: _data == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(0),
                children: [
                ListTile(
                  title: const Text('Total earned'),
                  trailing: Text('UGX ${_data!['summary']['total_earned']}'),
                ),
                ListTile(
                  title: const Text('Pending'),
                  trailing: Text('UGX ${_data!['summary']['pending_payout']}'),
                ),
                ListTile(
                  title: const Text('Paid orders'),
                  trailing: Text('${_data!['summary']['paid_orders_count']}'),
                ),
                const Divider(),
                ...(_data!['payment_method_data'] as List).map((d) => ListTile(
                      title: Text(d['payment_method'].toString()),
                      trailing: Text('UGX ${d['total']}'),
                    )),
              ],
            ),
        ),
    );
  }
}
