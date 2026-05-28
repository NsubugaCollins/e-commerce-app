import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});
  final int orderId;

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  Map<String, dynamic>? _order;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _order = await context.read<AuthProvider>().api.adminOrder(widget.orderId);
      _status = _order!['status'] as String;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final o = _order!;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${o['id']}')),
      body: PageWrapper(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
          Text('Customer: ${o['user']?['name']} (${o['user']?['email']})'),
          Text('Total: UGX ${o['total_amount']}'),
          Text('Payment: ${o['payment_method']} / ${o['payment_status']}'),
          Text('Address: ${o['shipping_address']}'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _status,
            items: ['pending', 'processing', 'completed', 'cancelled']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _status = v!),
            decoration: const InputDecoration(labelText: 'Status'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().api.adminUpdateOrderStatus(widget.orderId, _status);
              _load();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated')));
              }
            },
            child: const Text('Update status'),
          ),
          const Divider(),
          ...(o['items'] as List).map((item) => ListTile(
                title: Text(item['product']?['name'] ?? 'Item'),
                trailing: Text('x${item['quantity']}'),
              )),
        ],
      ),
        ),
    );
  }
}
