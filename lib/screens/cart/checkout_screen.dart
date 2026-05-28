import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/page_wrapper.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _address = TextEditingController();
  int _pointsToUse = 0;
  String _payment = 'cash';
  bool _submitting = false;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter delivery address')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final order = await context.read<AuthProvider>().api.placeOrder(
            shippingAddress: _address.text.trim(),
            paymentMethod: _payment,
            pointsToUse: _pointsToUse,
          );
      if (!mounted) return;
      context.read<CartProvider>().clear();
      await context.read<AuthProvider>().refreshUser();
      if (!mounted) return;

      if (_payment == 'paypal') {
        final url = await context.read<AuthProvider>().api.getPayPalApprovalUrl(order.id);
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete payment in PayPal, then check Orders')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      }
      context.go('/orders');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final currency = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);
    final total = cart.cart?.total ?? 0;
    final maxPoints = auth.user?.points ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: PageWrapper(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          Text(
            'Order total: ${currency.format(total)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _address,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Delivery address',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          Text('Reward points available: $maxPoints'),
          Slider(
            value: _pointsToUse.toDouble(),
            min: 0,
            max: maxPoints.toDouble(),
            divisions: maxPoints > 0 ? maxPoints : 1,
            label: '$_pointsToUse pts',
            onChanged: maxPoints > 0
                ? (v) => setState(() => _pointsToUse = v.round())
                : null,
          ),
          Text('Discount: ${currency.format(_pointsToUse * 10)}'),
          const SizedBox(height: 16),
          const Text('Payment method'),
          RadioListTile<String>(
            title: const Text('Cash on delivery'),
            value: 'cash',
            groupValue: _payment,
            onChanged: (v) => setState(() => _payment = v!),
          ),
          RadioListTile<String>(
            title: const Text('PayPal (complete on website)'),
            value: 'paypal',
            groupValue: _payment,
            onChanged: (v) => setState(() => _payment = v!),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitting ? null : _placeOrder,
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Place order'),
          ),
        ],
      ),
        ),
    );
  }
}
