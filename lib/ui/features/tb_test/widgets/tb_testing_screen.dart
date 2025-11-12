import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/date_picker_field.dart';
import '../view_model/tb_testing_view_model.dart';

class TbTestingScreen extends StatelessWidget {
  const TbTestingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TbTestingViewModel>();

    return Scaffold(
      appBar: const KenwellAppBar(title: 'TB Testing'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... other fields above ...
            if (viewModel.treatedBefore == 'Yes')
              DatePickerField(
                controller: viewModel.treatedDateController,
                label: 'When were you treated?',
                displayFormat: DateFormat('dd/MM/yyyy'),
              ),

            // ... rest of the form ...
          ],
        ),
      ),
    );
  }
}