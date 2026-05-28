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
  bool _categoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await context.read<AuthProvider>().api.getTradeInCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          if (_categories.isNotEmpty) _category = _categories.first;
          _categoriesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _categoriesLoading = false);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isNotEmpty) {
      setState(() => _images.addAll(files.map((f) => f.path)));
    }
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _desc.text.trim().isEmpty ||
        _category == null ||
        _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields and add at least one image')),
      );
      return;
    }
    final priceVal = double.tryParse(_price.text.trim());
    if (priceVal == null || priceVal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid expected price')),
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
            expectedPrice: priceVal,
            imagePaths: _images,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trade-in submitted successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Product name ──
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Product name',
                  hintText: 'e.g. Samsung Galaxy S22',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // ── Category ──
              _categoriesLoading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    ))
                  : _categories.isEmpty
                      ? const Text(
                          'Could not load categories. Please check your connection.',
                          style: TextStyle(color: Colors.red),
                        )
                      : DropdownButtonFormField<String>(
                          value: _category,
                          isExpanded: true,
                          items: _categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _category = v),
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                        ),
              const SizedBox(height: 16),

              // ── Condition ──
              DropdownButtonFormField<String>(
                value: _condition,
                isExpanded: true,
                items: ['New', 'Like New', 'Good', 'Fair']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _condition = v!),
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  prefixIcon: Icon(Icons.star_outline),
                ),
              ),
              const SizedBox(height: 16),

              // ── Description ──
              TextFormField(
                controller: _desc,
                maxLines: 4,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the product condition, any accessories included, etc.',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Expected price ──
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Expected price (UGX)',
                  hintText: 'e.g. 500000',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 20),

              // ── Image picker ──
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  _images.isEmpty
                      ? 'Add photos'
                      : '${_images.length} photo${_images.length == 1 ? '' : 's'} selected',
                ),
              ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            _images[i],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.image, size: 32),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: InkWell(
                            onTap: () => setState(() => _images.removeAt(i)),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Cycle will only have access to the photos you select.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 28),

              // ── Submit ──
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Trade-in'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
