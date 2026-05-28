import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_sale.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminTradeInDetailScreen extends StatefulWidget {
  const AdminTradeInDetailScreen({super.key, required this.saleId});
  final int saleId;

  @override
  State<AdminTradeInDetailScreen> createState() => _AdminTradeInDetailScreenState();
}

class _AdminTradeInDetailScreenState extends State<AdminTradeInDetailScreen> {
  UserSaleModel? _sale;
  final _offer = TextEditingController();
  final _notes = TextEditingController();
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _sale = await context.read<AuthProvider>().api.adminTradeIn(widget.saleId);
      _status = _sale!.status;
      if (_sale!.offeredPrice != null) _offer.text = _sale!.offeredPrice.toString();
      if (_sale!.adminNotes != null) _notes.text = _sale!.adminNotes!;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = _sale;
    if (s == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.productName)),
      body: PageWrapper(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
          Text('From: ${s.userName}'),
          Text(s.description),
          Text('Expected: UGX ${s.expectedPrice}'),
          TextField(controller: _offer, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Offer price')),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Admin notes')),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().api.adminMakeOffer(
                    widget.saleId,
                    double.parse(_offer.text),
                    notes: _notes.text,
                  );
              _load();
            },
            child: const Text('Send offer'),
          ),
          DropdownButtonFormField<String>(
            value: _status,
            items: ['pending', 'under_review', 'offer_made', 'accepted', 'rejected', 'completed']
                .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                .toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().api.adminUpdateTradeInStatus(
                    widget.saleId,
                    _status,
                    notes: _notes.text,
                  );
              _load();
            },
            child: const Text('Update status'),
          ),
        ],
      ),
        ),
    );
  }
}
