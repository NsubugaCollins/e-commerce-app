import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await context.read<AuthProvider>().api.getOrders();
      if (mounted) {
        setState(() {
          _orders = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currency = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: PageWrapper(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
                  ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('No orders yet')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _orders.length,
                    itemBuilder: (context, i) {
                      final o = _orders[i];
                      return Card(
                        child: ExpansionTile(
                          title: Text('Order #${o.id}'),
                          subtitle: Text(
                            '${currency.format(o.totalAmount)} · ${o.status}',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payment: ${o.paymentMethod}'),
                                  Text('Delivery Address: ${o.shippingAddress}'),
                                  const Divider(),
                                  ...o.items.map(
                                    (item) => ListTile(
                                      dense: true,
                                      leading: item.product?.imageUrl != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: CachedNetworkImage(
                                                imageUrl: item.product!.imageUrl,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                errorWidget: (c, u, e) => const Icon(Icons.image, size: 24),
                                                placeholder: (c, u) => const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              ),
                                            )
                                          : const Icon(Icons.image, size: 40),
                                      title: Text(item.product?.name ?? 'Item'),
                                      subtitle: Text(currency.format(item.price)),
                                      trailing: Text('x${item.quantity}'),
                                    ),
                                  ),
                                  if (o.paymentMethod == 'paypal' &&
                                      o.paymentStatus != 'paid')
                                    TextButton(
                                      onPressed: () async {
                                        final url = await context
                                            .read<AuthProvider>()
                                            .api
                                            .getPayPalApprovalUrl(o.id);
                                        await launchUrl(
                                          Uri.parse(url),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      },
                                      child: const Text('Pay with PayPal'),
                                    ),
                                  if (o.status == 'completed' || o.status == 'processing')
                                    TextButton(
                                      onPressed: () => _rateOrder(context, o.id),
                                      child: const Text('Rate order'),
                                    ),
                                  if (o.status == 'pending')
                                    TextButton.icon(
                                      onPressed: () => _cancelOrder(context, o.id),
                                      icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                      label: const Text('Cancel order', style: TextStyle(color: Colors.red)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }

  Future<void> _rateOrder(BuildContext context, int orderId) async {
    int stars = 5;
    final comment = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rate your order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(
              builder: (ctx, setS) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(i < stars ? Icons.star : Icons.star_border),
                    onPressed: () => setS(() => stars = i + 1),
                  );
                }),
              ),
            ),
            TextField(controller: comment, decoration: const InputDecoration(hintText: 'Comment (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().api.submitRating(
            rating: stars,
            comment: comment.text.isEmpty ? null : comment.text,
            orderId: orderId,
          );
      _load();
    }
  }

  Future<void> _cancelOrder(BuildContext context, int orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      setState(() => _loading = true);
      try {
        await context.read<AuthProvider>().api.cancelOrder(orderId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel order: $e')),
          );
        }
      } finally {
        _load();
      }
    }
  }
}
