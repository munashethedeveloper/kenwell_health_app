# Risk Assessment Screen - Male/Female Question Logic Fix

## Problem
The male and female specific questions on the risk assessment screen were not showing correctly because:

1. **View model not initialized**: The screen received `isFemale` and `age` parameters but never passed them to the view model
2. **Incorrect male question logic**: All male questions were hidden unless the user was both male AND over 40 years old

## Root Cause
The `PersonalRiskAssessmentViewModel` has a `setPersonalDetails()` method to set gender and age, but it was never being called. This meant:
- `vm.gender` was always `null`
- `vm.age` was always `null`
- `vm.showFemaleQuestions` always returned `false` (even for females)
- `vm.showMaleQuestions` always returned `false` (even for males)

## Solution

### 1. Initialize View Model with Gender and Age
Added initialization in `PersonalRiskAssessmentScreen.build()`:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  viewModel.setPersonalDetails(
    gender: isFemale ? 'Female' : 'Male',
    age: age,
  );
});
```

This ensures the view model knows the user's gender and age.

### 2. Fixed Male Question Logic
Updated `PersonalRiskAssessmentViewModel`:

**Before:**
```dart
bool get showMaleQuestions => isMale && (age ?? 0) >= 40;
```

**After:**
```dart
bool get showMaleQuestions => isMale;
bool get showProstateCheckQuestion => isMale && (age ?? 0) >= 40;
```

### 3. Conditional Display of Question 8
Updated `PersonalRiskAssessmentScreen` to conditionally show the prostate check question:

**Before:**
```dart
if (vm.showMaleQuestions)
  KenwellFormCard(
    child: Column(
      children: [
        // Question 8: Always shown if showMaleQuestions is true
        KenwellYesNoQuestion(...),
        // Question 9
        KenwellYesNoQuestion(...),
      ],
    ),
  )
```

**After:**
```dart
if (vm.showMaleQuestions)
  KenwellFormCard(
    child: Column(
      children: [
        // Question 8: Only shown if age >= 40
        if (vm.showProstateCheckQuestion)
          KenwellYesNoQuestion(...),
        // Question 9: Always shown for males
        KenwellYesNoQuestion(...),
      ],
    ),
  )
```

## Current Behavior (Fixed)

### Female Users
- **All females**: See questions 5 and 6 (pap smear, breast exam)
- **Females 40+**: Also see question 7 (mammogram)

### Male Users
- **Males under 40**: See question 9 only (prostate cancer test)
- **Males 40+**: See both questions 8 and 9 (prostate check and prostate cancer test)

## Question Breakdown

| Question | Display Logic |
|----------|---------------|
| Q5: Pap smear | Female only |
| Q6: Breast exam | Female only |
| Q7: Mammogram | Female AND age >= 40 |
| Q8: Prostate check | Male AND age >= 40 |
| Q9: Prostate cancer test | Male only (any age) |

## Testing

To verify the fix works correctly:

1. **Test Female < 40**:
   - Should see: Q5, Q6
   - Should NOT see: Q7, Q8, Q9

2. **Test Female >= 40**:
   - Should see: Q5, Q6, Q7
   - Should NOT see: Q8, Q9

3. **Test Male < 40**:
   - Should see: Q9
   - Should NOT see: Q5, Q6, Q7, Q8

4. **Test Male >= 40**:
   - Should see: Q8, Q9
   - Should NOT see: Q5, Q6, Q7

## Files Modified

1. `lib/ui/features/risk_assessment/view_model/personal_risk_assessment_view_model.dart`
   - Changed `showMaleQuestions` logic from `isMale && age >= 40` to just `isMale`
   - Added `showProstateCheckQuestion` getter for age-conditional question

2. `lib/ui/features/risk_assessment/widgets/personal_risk_assessment_screen.dart`
   - Added view model initialization in `build()` method
   - Wrapped Question 8 with `if (vm.showProstateCheckQuestion)` condition

## Impact

This fix ensures:
- ✅ Female users see appropriate questions based on their age
- ✅ Male users see appropriate questions based on their age
- ✅ Question 8 only appears for males 40+
- ✅ Question 9 appears for all males
- ✅ View model correctly receives gender and age data
- ✅ No breaking changes to other functionality
