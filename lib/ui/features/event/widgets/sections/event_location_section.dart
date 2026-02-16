import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../shared/ui/form/custom_dropdown_field.dart';
import '../../../../shared/ui/form/custom_text_field.dart';
import '../../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../shared/ui/form/kenwell_form_styles.dart';
import '../../../../domain/constants/provinces.dart';
import '../../view_model/event_view_model.dart';

/// Model for address suggestions
class AddressSuggestion {
  final String fullAddress;
  final String? city;
  final String? province;

  AddressSuggestion({
    required this.fullAddress,
    this.city,
    this.province,
  });
}

/// Event location information form section with address autocomplete
class EventLocationSection extends StatefulWidget {
  final EventViewModel viewModel;
  final String? Function(String?, String?) requiredField;

  // Constructor
  const EventLocationSection({
    super.key,
    required this.viewModel,
    required this.requiredField,
  });

  @override
  State<EventLocationSection> createState() => _EventLocationSectionState();
}

class _EventLocationSectionState extends State<EventLocationSection> {
  final FocusNode _addressFocusNode = FocusNode();
  bool _isGeocoding = false;
  
  // Common South African addresses for autocomplete
  // This can be expanded or loaded from a database
  final List<AddressSuggestion> _commonAddresses = [
    AddressSuggestion(
      fullAddress: '45 Long Street, Cape Town, Western Cape',
      city: 'Cape Town',
      province: 'Western Cape',
    ),
    AddressSuggestion(
      fullAddress: '123 Sandton Drive, Sandton, Gauteng',
      city: 'Sandton',
      province: 'Gauteng',
    ),
    AddressSuggestion(
      fullAddress: '100 Florida Road, Durban, KwaZulu-Natal',
      city: 'Durban',
      province: 'KwaZulu-Natal',
    ),
    AddressSuggestion(
      fullAddress: '200 Church Street, Pretoria, Gauteng',
      city: 'Pretoria',
      province: 'Gauteng',
    ),
    AddressSuggestion(
      fullAddress: '1 Adderley Street, Cape Town, Western Cape',
      city: 'Cape Town',
      province: 'Western Cape',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Listen for focus changes on address field
    _addressFocusNode.addListener(_onAddressFocusChange);
  }

  @override
  void dispose() {
    _addressFocusNode.removeListener(_onAddressFocusChange);
    _addressFocusNode.dispose();
    super.dispose();
  }

  /// Handle address field focus change
  void _onAddressFocusChange() {
    if (!_addressFocusNode.hasFocus) {
      _geocodeAddress();
    }
  }

  /// Geocode the address and auto-fill fields
  Future<void> _geocodeAddress() async {
    final address = widget.viewModel.addressController.text.trim();
    if (address.isEmpty || _isGeocoding) return;

    setState(() {
      _isGeocoding = true;
    });

    try {
      await widget.viewModel.geocodeAddress(address);
    } finally {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  /// Search for address suggestions
  Future<List<AddressSuggestion>> _searchAddresses(String pattern) async {
    if (pattern.isEmpty) return [];

    // First, search in common addresses
    final commonResults = _commonAddresses.where((suggestion) {
      return suggestion.fullAddress.toLowerCase().contains(pattern.toLowerCase());
    }).toList();

    // If we have common address matches, return them
    if (commonResults.isNotEmpty) {
      return commonResults.take(5).toList();
    }

    // Otherwise, try to use geocoding to find suggestions
    // Note: geocoding package doesn't provide autocomplete, so this is a fallback
    // that tries to geocode the partial address
    try {
      final locations = await locationFromAddress(pattern);
      if (locations.isNotEmpty) {
        final placemarks = await placemarkFromCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final street = placemark.street ?? '';
          final locality = placemark.locality ?? placemark.subAdministrativeArea ?? '';
          final adminArea = placemark.administrativeArea ?? '';
          
          if (street.isNotEmpty && locality.isNotEmpty) {
            return [
              AddressSuggestion(
                fullAddress: '$street, $locality, $adminArea',
                city: locality,
                province: adminArea,
              )
            ];
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching addresses: $e');
    }

    return [];
  }

  /// Handle address suggestion selection
  Future<void> _onAddressSelected(AddressSuggestion suggestion) async {
    // Set the full address
    widget.viewModel.addressController.text = suggestion.fullAddress;
    
    setState(() {
      _isGeocoding = true;
    });

    try {
      // Auto-fill town/city if available
      if (suggestion.city != null && suggestion.city!.isNotEmpty) {
        widget.viewModel.townCityController.text = suggestion.city!;
      }

      // Auto-fill province if available
      if (suggestion.province != null && suggestion.province!.isNotEmpty) {
        final matchedProvince = SouthAfricanProvinces.match(suggestion.province!);
        if (matchedProvince != null) {
          widget.viewModel.updateProvince(matchedProvince);
          debugPrint('Address selected: City=${suggestion.city}, Province=$matchedProvince');
        }
      } else {
        // If province not in suggestion, try geocoding
        await _geocodeAddress();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return KenwellFormCard(
      title: 'Event Location',
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Venue field
          KenwellTextField(
            label: 'Venue',
            controller: widget.viewModel.venueController,
            padding: EdgeInsets.zero,
            validator: (value) => widget.requiredField('Venue', value),
          ),
          const SizedBox(height: 24),
          // Address field with autocomplete
          TypeAheadField<AddressSuggestion>(
            builder: (context, controller, focusNode) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: KenwellFormStyles.decoration(
                  label: 'Address',
                  hint: 'Start typing address...',
                  suffixIcon: _isGeocoding
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.location_on, color: Color(0xFF201C58)),
                ).copyWith(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => widget.requiredField('Address', value),
              );
            },
            controller: widget.viewModel.addressController,
            focusNode: _addressFocusNode,
            suggestionsCallback: _searchAddresses,
            itemBuilder: (context, AddressSuggestion suggestion) {
              return ListTile(
                leading: const Icon(Icons.location_on, color: Color(0xFF201C58), size: 20),
                title: Text(
                  suggestion.fullAddress,
                  style: const TextStyle(fontSize: 14),
                ),
                dense: true,
              );
            },
            onSelected: _onAddressSelected,
            emptyBuilder: (context) {
              return const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'No suggestions found. Continue typing or press Tab to use geocoding.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
            hideOnEmpty: true,
            hideOnLoading: false,
            debounceDuration: const Duration(milliseconds: 400),
          ),
          const SizedBox(height: 24),
          // Town/City field
          KenwellTextField(
            label: 'Town/City',
            controller: widget.viewModel.townCityController,
            padding: EdgeInsets.zero,
            validator: (value) => widget.requiredField('Town/City', value),
          ),
          const SizedBox(height: 24),
          // Province dropdown field - wrapped in ListenableBuilder to update when ViewModel changes
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, child) {
              return KenwellDropdownField<String>(
                label: 'Province',
                value: widget.viewModel.province,
                items: SouthAfricanProvinces.all,
                onChanged: (val) {
                  if (val != null) widget.viewModel.updateProvince(val);
                },
                decoration: KenwellFormStyles.decoration(
                  label: 'Province',
                  hint: 'Select Province',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
