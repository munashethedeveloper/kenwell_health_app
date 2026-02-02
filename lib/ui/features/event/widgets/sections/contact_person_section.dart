import 'package:flutter/material.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../view_model/event_view_model.dart';

/// Contact person information form section
class ContactPersonSection extends StatelessWidget {
  final EventViewModel viewModel;
  final String title;
  final bool isOnsite;
  final String? Function(String?, String?) requiredField;

  // Constructor
  const ContactPersonSection({
    super.key,
    required this.viewModel,
    required this.title,
    required this.isOnsite,
    required this.requiredField,
  });

  // Build method
  @override
  Widget build(BuildContext context) {
    final firstNameController = isOnsite
        ? viewModel.onsiteContactFirstNameController
        : viewModel.aeContactFirstNameController;
    final lastNameController = isOnsite
        ? viewModel.onsiteContactLastNameController
        : viewModel.aeContactLastNameController;
    final numberController = isOnsite
        ? viewModel.onsiteNumberController
        : viewModel.aeNumberController;
    final emailController = isOnsite
        ? viewModel.onsiteEmailController
        : viewModel.aeEmailController;

    // Build the form card
    return KenwellFormCard(
      title: title,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Contact Person First Name field
          KenwellTextField(
            label: 'Contact Person First Name',
            controller: firstNameController,
            padding: EdgeInsets.zero,
            inputFormatters:
                AppTextInputFormatters.lettersOnly(allowHyphen: true),
            validator: (value) =>
                requiredField('Contact Person First Name', value),
          ),
          const SizedBox(height: 24),
          // Contact Person Last Name field
          KenwellTextField(
            label: 'Contact Person Last Name',
            controller: lastNameController,
            padding: EdgeInsets.zero,
            inputFormatters:
                AppTextInputFormatters.lettersOnly(allowHyphen: true),
            validator: (value) =>
                requiredField('Contact Person Last Name', value),
          ),
          const SizedBox(height: 24),
          // Contact Number field
          KenwellTextField(
            label: 'Contact Number',
            controller: numberController,
            padding: EdgeInsets.zero,
            keyboardType: TextInputType.phone,
            inputFormatters: [AppTextInputFormatters.saPhoneNumberFormatter()],
            validator: Validators.validateSouthAfricanPhoneNumber,
          ),
          const SizedBox(height: 24),
          // Contact Email field
          KenwellTextField(
            label: 'Email',
            controller: emailController,
            padding: EdgeInsets.zero,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
        ],
      ),
    );
  }
}
