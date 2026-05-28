import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/message.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  List<MessageThread> _threads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _threads = await context.read<AuthProvider>().api.adminMessageThreads();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer messages')),
      body: PageWrapper(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                itemCount: _threads.length,
                itemBuilder: (context, i) {
                  final t = _threads[i];
                  return ListTile(
                    title: Text(t.name),
                    subtitle: Text(t.email),
                    trailing: t.unreadCount > 0
                        ? CircleAvatar(radius: 12, child: Text('${t.unreadCount}'))
                        : null,
                    onTap: () => context.push('/admin/messages/${t.id}').then((_) => _load()),
                  );
                },
              ),
                ),
        ),
    );
  }
}
