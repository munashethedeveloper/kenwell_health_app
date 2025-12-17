# Wellness Flow Refactoring Documentation

## Overview
This document describes the refactoring of the wellness flow to support dynamic screen navigation based on user consent checkbox selections.

## Problem Statement
Previously, the wellness flow was hardcoded with 11 fixed steps (0-10), requiring users to complete all screens regardless of their consent selections. The consent screen had 4 checkboxes (HRA, VCT, TB, HIV) that were all required to be checked before proceeding.

## Solution
The wellness flow has been refactored to:
1. **Allow flexible consent**: Users must select at least one checkbox (not all)
2. **Dynamic screen routing**: Only show screens relevant to selected checkboxes
3. **Always show survey**: Survey screen appears at the end regardless of selections

## Changes Made

### 1. Consent Screen View Model (`consent_screen_view_model.dart`)

#### Modified Validation
```dart
// OLD: All checkboxes required
bool get isFormValid => hra && vct && tb && hiv && ...

// NEW: At least one checkbox required
bool get isFormValid => (hra || vct || tb || hiv) && ...
```

#### New Helper Methods
- **`hasAtLeastOneScreening`**: Returns true if at least one checkbox is selected
- **`selectedScreenings`**: Returns a list of selected screening types (e.g., `['hra', 'tb']`)

### 2. Consent Screen Widget (`consent_screen.dart`)

#### Enhanced Validation
Added explicit check for checkbox selection with clear error message:
```dart
if (!vm.hasAtLeastOneScreening) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please select at least one screening option.'),
    ),
  );
  return;
}
```

### 3. Wellness Flow View Model (`wellness_flow_view_model.dart`)

#### Dynamic Flow System
Changed from numeric step indices to named step strings:

```dart
// NEW: Named steps for clarity and flexibility
List<String> _flowSteps = ['consent'];

String get currentStepName => _flowSteps[_currentStep];
```

#### Flow Initialization Method
```dart
void initializeFlow(List<String> selectedScreenings) {
  _flowSteps = ['consent'];
  
  // Add HRA screens if selected
  if (selectedScreenings.contains('hra')) {
    _flowSteps.addAll(['personal_details', 'risk_assessment', 'screening_results']);
  }
  
  // Add nurse intervention if any screening selected
  if (selectedScreenings.isNotEmpty) {
    _flowSteps.add('nurse_intervention');
  }
  
  // Add HIV/VCT screens if selected
  if (selectedScreenings.contains('hiv') || selectedScreenings.contains('vct')) {
    _flowSteps.addAll(['hiv_test', 'hiv_results', 'hiv_nurse_intervention']);
  }
  
  // Add TB screens if selected
  if (selectedScreenings.contains('tb')) {
    _flowSteps.addAll(['tb_test', 'tb_nurse_intervention']);
  }
  
  // Survey is ALWAYS included at the end
  _flowSteps.add('survey');
}
```

#### Updated Navigation Methods
```dart
void nextStep() {
  if (_currentStep < _flowSteps.length - 1) {
    _currentStep++;
    debugPrint('Moving to step $_currentStep: ${_flowSteps[_currentStep]}');
    notifyListeners();
  }
}

void previousStep() {
  if (_currentStep > 0) {
    _currentStep--;
    debugPrint('Moving back to step $_currentStep: ${_flowSteps[_currentStep]}');
    notifyListeners();
  }
}
```

### 4. Wellness Flow Screen (`wellness_flow_screen.dart`)

#### Dynamic Screen Builder
Replaced numeric switch statement with named step routing:

```dart
Widget _buildScreenForStep(BuildContext context, WellnessFlowViewModel flowVM) {
  final stepName = flowVM.currentStepName;
  
  switch (stepName) {
    case 'consent':
      return ConsentScreen(
        onNext: () {
          // Initialize flow based on selected checkboxes
          flowVM.initializeFlow(flowVM.consentVM.selectedScreenings);
          flowVM.nextStep();
        },
        ...
      );
    case 'personal_details':
      return PersonalDetailsScreen(...);
    // ... other cases
  }
}
```

## Checkbox to Screen Mapping

| Checkbox | Screens Shown |
|----------|---------------|
| **HRA** | Personal Details → Risk Assessment → Screening Results |
| **VCT or HIV** | HIV Test → HIV Results → HIV Nurse Intervention |
| **TB** | TB Test → TB Nurse Intervention |
| **Any Selection** | Nurse Intervention (general) |
| **Always** | Survey (at the end) |

## Flow Examples

### Example 1: Only HRA Selected
```
Consent → Personal Details → Risk Assessment → Screening Results 
       → Nurse Intervention → Survey
```

### Example 2: Only HIV Selected
```
Consent → Nurse Intervention → HIV Test → HIV Results 
       → HIV Nurse Intervention → Survey
```

### Example 3: HRA + TB Selected
```
Consent → Personal Details → Risk Assessment → Screening Results 
       → Nurse Intervention → TB Test → TB Nurse Intervention → Survey
```

### Example 4: All Checkboxes Selected
```
Consent → Personal Details → Risk Assessment → Screening Results 
       → Nurse Intervention → HIV Test → HIV Results 
       → HIV Nurse Intervention → TB Test → TB Nurse Intervention → Survey
```

## Testing Scenarios

### Scenario 1: No Checkboxes Selected
1. Open consent form
2. Fill all required fields
3. Sign the form
4. Click "Next" without selecting any checkbox
5. **Expected**: Error message "Please select at least one screening option."

### Scenario 2: Only HRA Selected
1. Open consent form
2. Select only HRA checkbox
3. Complete form and proceed
4. **Expected**: Navigate through Personal Details → Risk Assessment → Screening Results → Nurse Intervention → Survey

### Scenario 3: Only TB Selected
1. Open consent form
2. Select only TB checkbox
3. Complete form and proceed
4. **Expected**: Navigate through Nurse Intervention → TB Test → TB Nurse Intervention → Survey

### Scenario 4: HIV and VCT Selected
1. Open consent form
2. Select both HIV and VCT checkboxes
3. Complete form and proceed
4. **Expected**: Navigate through Nurse Intervention → HIV Test → HIV Results → HIV Nurse Intervention → Survey
5. **Note**: HIV and VCT map to the same screens

### Scenario 5: All Checkboxes Selected
1. Open consent form
2. Select all checkboxes (HRA, VCT, TB, HIV)
3. Complete form and proceed
4. **Expected**: Navigate through all screens in order, ending with Survey

### Scenario 6: Survey Always Appears
1. Select any combination of checkboxes
2. Navigate through the flow
3. **Expected**: Survey screen always appears as the final step

## Key Benefits

1. **Flexible User Experience**: Users only see relevant screens based on their selections
2. **Reduced Flow Time**: Skip unnecessary screens, improving efficiency
3. **Maintainable Code**: Named steps are easier to understand than numeric indices
4. **Extensible Architecture**: Easy to add new screening types and screens
5. **Preserved Requirements**: Survey always shown, at least one selection required

## Technical Notes

### Debug Logging
The refactored code includes debug prints for flow navigation:
- `debugPrint('Initialized flow with steps: $_flowSteps')`
- `debugPrint('Moving to step $_currentStep: ${_flowSteps[_currentStep]}')`

These help track flow progression during development and debugging.

### Animation
Screen transitions use `AnimatedSwitcher` with a 300ms duration and are keyed by step name:
```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: KeyedSubtree(
    key: ValueKey<String>(flowVM.currentStepName),
    child: currentScreen,
  ),
)
```

### Navigation Safety
The `nextStep()` and `previousStep()` methods include bounds checking to prevent index out of range errors:
```dart
if (_currentStep < _flowSteps.length - 1) { ... }
if (_currentStep > 0) { ... }
```

## Future Enhancements

Potential improvements for future iterations:

1. **Conditional Nurse Intervention**: Make nurse intervention screens conditional based on specific checkboxes rather than appearing for any selection
2. **Screen Dependencies**: Add logic for screens that depend on data from previous screens
3. **Flow Persistence**: Save flow state to allow users to resume if they exit mid-flow
4. **Progress Indicator**: Add a progress bar showing completion percentage based on remaining steps
5. **Flow Validation**: Add validation at each step to ensure required data is collected

## Migration Notes

This is a **non-breaking change** for existing functionality:
- All existing screens remain functional
- Survey submission and data collection unchanged
- Event tracking and increment logic preserved
- No database schema changes required

Users who previously selected all checkboxes will experience the same flow as before.

## Files Modified

1. `lib/ui/features/consent_form/view_model/consent_screen_view_model.dart`
2. `lib/ui/features/consent_form/widgets/consent_screen.dart`
3. `lib/ui/features/wellness/view_model/wellness_flow_view_model.dart`
4. `lib/ui/features/wellness/widgets/wellness_flow_screen.dart`

## Conclusion

The wellness flow refactoring successfully implements dynamic screen routing based on user consent selections while maintaining all business requirements (survey always shown, at least one selection required). The new architecture is more maintainable, extensible, and provides a better user experience by showing only relevant screens.
