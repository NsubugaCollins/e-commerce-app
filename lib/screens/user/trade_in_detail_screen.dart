import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_sale.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class TradeInDetailScreen extends StatefulWidget {
  const TradeInDetailScreen({super.key, required this.saleId});
  final int saleId;

  @override
  State<TradeInDetailScreen> createState() => _TradeInDetailScreenState();
}

class _TradeInDetailScreenState extends State<TradeInDetailScreen> {
  UserSaleModel? _sale;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _sale = await context.read<AuthProvider>().api.getTradeIn(widget.saleId);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final s = _sale;
    if (s == null) {
      return const Scaffold(body: Center(child: Text('Not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.productName)),
      body: PageWrapper(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
          Text('Status: ${s.status}', style: Theme.of(context).textTheme.titleMedium),
          Text('Category: ${s.category} · ${s.condition}'),
          Text('Expected: UGX ${s.expectedPrice.toStringAsFixed(0)}'),
          if (s.offeredPrice != null)
            Text('Offer: UGX ${s.offeredPrice!.toStringAsFixed(0)}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          if (s.adminNotes != null) Text('Admin: ${s.adminNotes}'),
          const SizedBox(height: 8),
          Text(s.description),
          if (s.status == 'offer_made') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().api.acceptTradeInOffer(s.id);
                      _load();
                    },
                    child: const Text('Accept offer'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().api.rejectTradeInOffer(s.id);
                      _load();
                    },
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
        ),
    );
  }
}
