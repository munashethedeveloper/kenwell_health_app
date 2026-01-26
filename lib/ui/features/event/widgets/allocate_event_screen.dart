import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/app_provider.dart';
import '../view_model/allocate_event_view_model.dart';
import 'package:kenwell_health_app/models/user.dart';

class AllocateEventScreen extends StatelessWidget {
  final void Function(List<String> assignedUserIds) onAllocate;

  const AllocateEventScreen({
    super.key,
    required this.onAllocate,
  });

  @override
  Widget build(BuildContext context) {
    // Get users from UserService via Provider
    final userService =
        Provider.of<AppProvider>(context, listen: false).userService;
    final List<User> allUsers = userService.users;

    return ChangeNotifierProvider(
      create: (_) => AllocateEventViewModel(allUsers: allUsers),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Allocate Event'),
        ),
        body: Consumer<AllocateEventViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: vm.allUsers.map((user) {
                      return CheckboxListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        value: vm.selectedUserIds.contains(user.id),
                        onChanged: (_) => vm.toggleUser(user.id),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      vm.assignUsersToEvent(onAllocate);
                      Navigator.pop(context);
                    },
                    child: const Text('Assign Selected Users'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
