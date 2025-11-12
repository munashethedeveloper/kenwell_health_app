import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/date_picker_field.dart';
import '../view_model/personal_details_view_model.dart';

class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PersonalDetailsViewModel>(context);

    return Scaffold(
      appBar: const KenwellAppBar(title: 'Personal Details', automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // other fields...
            DatePickerField(
              controller: vm.dateController,
              label: 'Date',
              displayFormat: DateFormat('dd/MM/yyyy'),
            ),

            // rest of form continues...
          ],
        ),
      ),
    );
  }
}