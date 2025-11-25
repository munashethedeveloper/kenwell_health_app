import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/local/app_database.dart';

class UserDiagnosticsScreen extends StatefulWidget {
  const UserDiagnosticsScreen({super.key});

  @override
  State<UserDiagnosticsScreen> createState() => _UserDiagnosticsScreenState();
}

class _UserDiagnosticsScreenState extends State<UserDiagnosticsScreen> {
  Future<List<UserEntry>>? _usersFuture;

  @override
  void initState() {
    super.initState();
    _reloadUsers();
  }

  void _reloadUsers() {
    final db = context.read<AppDatabase>();
    setState(() {
      _usersFuture = db.listUsers();
    });
  }

  Future<void> _copyUsersJson() async {
    final db = context.read<AppDatabase>();
    final users = await db.listUsers();
    final payload = users.map(_entryToMap).toList();
    final pretty = const JsonEncoder.withIndent('  ').convert(payload);
    await Clipboard.setData(ClipboardData(text: pretty));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied ${users.length} user(s) to clipboard')),
      );
    }
  }

  Map<String, dynamic> _entryToMap(UserEntry entry) => {
        'id': entry.id,
        'email': entry.email,
        'role': entry.role,
        'username': entry.username,
        'firstName': entry.firstName,
        'lastName': entry.lastName,
        'phoneNumber': entry.phoneNumber,
        'isCurrent': entry.isCurrent,
      };

  Future<void> _setAsCurrent(UserEntry entry) async {
    final db = context.read<AppDatabase>();
    await db.setCurrentUser(entry.id);
    _reloadUsers();
    _showSnack('Marked ${entry.email} as current');
  }

  Future<void> _deleteUser(UserEntry entry) async {
    final db = context.read<AppDatabase>();
    await db.deleteUserById(entry.id);
    _reloadUsers();
    _showSnack('Deleted ${entry.email}');
  }

  void _showUserDetails(UserEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.email,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('User ID: ${entry.id}'),
            Text('Role: ${entry.role}'),
            Text('Username: ${entry.username}'),
            Text('First/Last: ${entry.firstName} ${entry.lastName}'),
            Text('Phone: ${entry.phoneNumber}'),
            Text('Current: ${entry.isCurrent ? "Yes" : "No"}'),
            const Divider(),
            Text(
              const JsonEncoder.withIndent('  ').convert(_entryToMap(entry)),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadUsers,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy JSON',
            onPressed: _copyUsersJson,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firebaseUser?.email ?? 'No Firebase user',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('UID: ${firebaseUser?.uid ?? '—'}'),
                    Text('Verified: ${firebaseUser?.emailVerified ?? false}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<UserEntry>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final users = snapshot.data ?? [];
                  if (users.isEmpty) {
                    return const Center(child: Text('No local users stored.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      _reloadUsers();
                      await _usersFuture;
                    },
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: Icon(
                            user.isCurrent
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: user.isCurrent
                                ? Colors.green
                                : Colors.grey.shade400,
                          ),
                          title: Text(user.email),
                          subtitle: Text(
                            '${user.firstName} ${user.lastName}\nRole: ${user.role}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'view':
                                  _showUserDetails(user);
                                  break;
                                case 'current':
                                  _setAsCurrent(user);
                                  break;
                                case 'delete':
                                  _deleteUser(user);
                                  break;
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'view',
                                child: ListTile(
                                  leading: Icon(Icons.visibility),
                                  title: Text('View details'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'current',
                                child: ListTile(
                                  leading: Icon(Icons.check_circle),
                                  title: Text('Set as current'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text('Delete local copy'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
