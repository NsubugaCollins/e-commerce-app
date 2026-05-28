import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  Map<String, dynamic> _settings = {};
  final _controllers = <String, TextEditingController>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _settings = await context.read<AuthProvider>().api.adminSettings();
      for (final e in _settings.entries) {
        _controllers[e.key] = TextEditingController(text: e.value?.toString() ?? '');
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final data = <String, dynamic>{};
    for (final e in _controllers.entries) {
      data[e.key] = e.value.text;
    }
    await context.read<AuthProvider>().api.adminUpdateSettings(data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Site settings')),
      body: PageWrapper(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(0),
              children: [
                ..._controllers.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: e.value,
                        decoration: InputDecoration(labelText: e.key),
                      ),
                    )),
                ElevatedButton(onPressed: _save, child: const Text('Save settings')),
              ],
            ),
        ),
    );
  }
}
