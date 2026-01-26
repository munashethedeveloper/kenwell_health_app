import 'package:flutter/material.dart';
import '../../../utils/seed_events.dart';

/// Admin tools screen for database operations
class AdminToolsScreen extends StatefulWidget {
  const AdminToolsScreen({super.key});

  @override
  State<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends State<AdminToolsScreen> {
  bool _isSeeding = false;
  bool _isClearing = false;
  String? _message;

  Future<void> _seedEvents() async {
    setState(() {
      _isSeeding = true;
      _message = null;
    });

    try {
      await EventSeeder().seedEvents();
      if (!mounted) return;
      setState(() {
        _message = '✅ Successfully created 5 sample events!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = '❌ Error seeding events: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isSeeding = false);
      }
    }
  }

  Future<void> _clearEvents() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Events?'),
        content: const Text(
          'This will permanently delete all events from the database. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isClearing = true;
      _message = null;
    });

    try {
      await EventSeeder().clearAllEvents();
      if (!mounted) return;
      setState(() {
        _message = '✅ Successfully cleared all events';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = '❌ Error clearing events: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Tools'),
        backgroundColor: const Color(0xFF201C58),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Database Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use these tools to manage your Firestore database',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Events Collection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isSeeding ? null : _seedEvents,
                      icon: _isSeeding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload),
                      label: Text(
                          _isSeeding ? 'Seeding...' : 'Seed Sample Events'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF201C58),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Creates 5 sample wellness events in Firestore',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _isClearing ? null : _clearEvents,
                      icon: _isClearing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.delete_forever),
                      label: Text(
                          _isClearing ? 'Clearing...' : 'Clear All Events'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Deletes all events from the database (cannot be undone)',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Card(
                color: _message!.startsWith('✅')
                    ? Colors.deepPurple.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.startsWith('✅')
                          ? Colors.deepPurple.shade900
                          : Colors.red.shade900,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
