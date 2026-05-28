import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/user_sale.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminTradeInScreen extends StatefulWidget {
  const AdminTradeInScreen({super.key});

  @override
  State<AdminTradeInScreen> createState() => _AdminTradeInScreenState();
}

class _AdminTradeInScreenState extends State<AdminTradeInScreen> {
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
      _sales = await context.read<AuthProvider>().api.adminTradeIns();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trade-in requests')),
      body: PageWrapper(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                itemCount: _sales.length,
                itemBuilder: (context, i) {
                  final s = _sales[i];
                  return ListTile(
                    title: Text(s.productName),
                    subtitle: Text('${s.userName} · ${s.status}'),
                    onTap: () => context.push('/admin/trade-in/${s.id}').then((_) => _load()),
                  );
                },
              ),
            ),
        ),
    );
  }
}
