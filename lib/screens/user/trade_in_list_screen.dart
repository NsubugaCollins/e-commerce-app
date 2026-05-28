import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/user_sale.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class TradeInListScreen extends StatefulWidget {
  const TradeInListScreen({super.key});

  @override
  State<TradeInListScreen> createState() => _TradeInListScreenState();
}

class _TradeInListScreenState extends State<TradeInListScreen> {
  List<UserSaleModel> _sales = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _sales = await context.read<AuthProvider>().api.getMyTradeIns();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My trade-ins'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/sell/create');
              _load();
            },
          ),
        ],
      ),
      body: PageWrapper(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _sales.isEmpty
                ? const Center(child: Text('No trade-in requests yet'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                    itemCount: _sales.length,
                    itemBuilder: (context, i) {
                      final s = _sales[i];
                      return ListTile(
                        title: Text(s.productName),
                        subtitle: Text('${s.status} · UGX ${s.expectedPrice.toStringAsFixed(0)}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/sell/${s.id}').then((_) => _load()),
                      );
                    },
                  ),
                ),
        ),
    );
  }
}
