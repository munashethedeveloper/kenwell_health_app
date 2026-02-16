import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kenwell_health_app/utils/input_formatters.dart';
import 'package:kenwell_health_app/utils/validators.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/international_phone_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../view_model/profile_view_model.dart';

/// Profile form section with all input fields
class ProfileFormSection extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final String? selectedRole;
  final ValueChanged<String?> onRoleChanged;

  const ProfileFormSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  State<ProfileFormSection> createState() => _ProfileFormSectionState();
}

class _ProfileFormSectionState extends State<ProfileFormSection> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return KenwellFormCard(
          title: 'Personal Information',
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              KenwellTextField(
                label: "First Name",
                controller: widget.firstNameController,
                inputFormatters:
                    AppTextInputFormatters.lettersOnly(allowHyphen: true),
                padding: EdgeInsets.zero,
                validator: Validators.validateFirstName,
              ),
              const SizedBox(height: 24),
              KenwellTextField(
                label: "Last Name",
                controller: widget.lastNameController,
                inputFormatters:
                    AppTextInputFormatters.lettersOnly(allowHyphen: true),
                padding: EdgeInsets.zero,
                validator: Validators.validateLastName,
              ),
              const SizedBox(height: 24),
              KenwellDropdownField<String>(
                label: "Role",
                value: widget.selectedRole,
                items: viewModel.availableRoles,
                enabled: false,
                padding: EdgeInsets.zero,
                validator: (v) => Validators.validateRequired(v, 'Role'),
                onChanged: widget.onRoleChanged,
              ),
              const SizedBox(height: 24),
              InternationalPhoneField(
                label: "Phone Number",
                controller: widget.phoneController,
                padding: EdgeInsets.zero,
                validator: Validators.validateInternationalPhoneNumber,
              ),
              const SizedBox(height: 24),
              KenwellTextField(
                label: "Email",
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                padding: EdgeInsets.zero,
                validator: Validators.validateEmail,
              ),
            ],
          ),
        );
      },
    );
  }
}
