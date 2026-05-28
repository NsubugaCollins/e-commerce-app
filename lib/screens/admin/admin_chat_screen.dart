import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/message.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/page_wrapper.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key, required this.userId});
  final int userId;

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  String _userName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<AuthProvider>().api.adminChatWith(widget.userId);
      _messages = data.messages;
      _userName = data.user.name;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) return;
    await context.read<AuthProvider>().api.adminSendMessage(widget.userId, message: _controller.text.trim());
    _controller.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.watch<AuthProvider>().user?.id;

    return Scaffold(
      appBar: AppBar(title: Text(_userName)),
      body: PageWrapper(
        child: Column(
          children: [
            Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final m = _messages[i];
                      final mine = m.senderId == myId;
                      return Align(
                        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mine
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(m.message.isEmpty ? '[media]' : m.message),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Reply...'))),
                IconButton(onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
        ),
    );
  }
}
