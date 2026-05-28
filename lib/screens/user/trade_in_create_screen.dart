import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class TradeInCreateScreen extends StatefulWidget {
  const TradeInCreateScreen({super.key});

  @override
  State<TradeInCreateScreen> createState() => _TradeInCreateScreenState();
}

class _TradeInCreateScreenState extends State<TradeInCreateScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  List<String> _categories = [];
  String? _category;
  String _condition = 'Good';
  final List<String> _images = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await context.read<AuthProvider>().api.getTradeInCategories();
      if (_categories.isNotEmpty) _category = _categories.first;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files != null) {
      setState(() => _images.addAll(files.map((f) => f.path)));
    }
  }

  Future<void> _submit() async {
    if (_name.text.isEmpty || _desc.text.isEmpty || _category == null || _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields and add at least one image')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().api.createTradeIn(
            productName: _name.text.trim(),
            category: _category!,
            condition: _condition,
            description: _desc.text.trim(),
            expectedPrice: double.parse(_price.text),
            imagePaths: _images,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trade-in submitted')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell / Trade-in')),
      body: PageWrapper(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Product name')),
          DropdownButtonFormField<String>(
            value: _category,
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          DropdownButtonFormField<String>(
            value: _condition,
            items: ['New', 'Like New', 'Good', 'Fair']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _condition = v!),
            decoration: const InputDecoration(labelText: 'Condition'),
          ),
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Expected price (UGX)'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.photo),
            label: Text('Photos (${_images.length})'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit'),
          ),
        ],
      ),
        ),
    );
  }
}
