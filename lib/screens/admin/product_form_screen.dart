import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminProductFormScreen extends StatefulWidget {
  const AdminProductFormScreen({super.key, this.productId});
  final int? productId;

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _productId = TextEditingController();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _category = TextEditingController();
  final _price = TextEditingController();
  String? _imagePath;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) _load();
  }

  Future<void> _load() async {
    final p = await context.read<AuthProvider>().api.adminProduct(widget.productId!);
    _productId.text = p.productId;
    _name.text = p.name;
    _desc.text = p.description ?? '';
    _category.text = p.category;
    _price.text = p.price.toString();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _imagePath = file.path);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final form = FormData.fromMap({
        'product_id': _productId.text,
        'name': _name.text,
        'description': _desc.text,
        'category': _category.text,
        'price': _price.text,
        if (_imagePath != null)
          'image': await MultipartFile.fromFile(_imagePath!),
      });
      if (widget.productId == null) {
        await context.read<AuthProvider>().api.adminCreateProduct(form);
      } else {
        await context.read<AuthProvider>().api.adminUpdateProduct(widget.productId!, form);
      }
      if (mounted) context.pop();
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
      appBar: AppBar(title: Text(widget.productId == null ? 'New product' : 'Edit product')),
      body: PageWrapper(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
          TextField(controller: _productId, decoration: const InputDecoration(labelText: 'Product ID')),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category')),
          TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
          TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text('Main image')),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            child: _loading ? const CircularProgressIndicator() : const Text('Save'),
          ),
        ],
      ),
        ),
    );
  }
}
