# Back to Member Search Navigation Fix

## Problem
When navigating from the **Event Home Screen** back to the **Member Search Screen**, the back button didn't work because the Member Search Screen was no longer in the navigation stack.

## Root Cause

### Previous Flow (Broken)
```
[WellnessFlowPage]
  → Push [Member Search Screen]
    → User selects member
    → POP [Member Search Screen] with member data  ← REMOVED from stack!
  → Push [Event Home Screen]
    → Press "Back to Search" button
    → Tries to pop but Member Search is gone!
```

The Member Search Screen was **popped** immediately when a member was selected (to return the member data), so it was no longer available in the navigation stack when trying to navigate back from Event Home.

## Solution

### New Flow (Fixed)
```
[WellnessFlowPage]
  → Push [Member Search Screen]  ← STAYS in stack
    → User selects member
    → Push [Event Home Screen] forward  ← Added on top
      → Press "Back to Search" button
      → Pop [Event Home Screen]
      → Returns to [Member Search Screen]  ✓
```

**Key Change:** Instead of popping Member Search when a member is selected, we now **navigate forward** to Event Home, keeping Member Search in the stack.

## Code Changes

### File: `lib/ui/features/wellness/navigation/wellness_navigator.dart`

#### 1. Modified `startFlow()` method
**Before:**
```dart
Future<void> startFlow() async {
  final wellnessVM = WellnessFlowViewModel(activeEvent: event);
  final member = await _navigateToMemberRegistration();  // ← Waited for pop with result
  if (member != null && context.mounted) {
    await navigateToEventDetails(member, wellnessVM);
  }
}
```

**After:**
```dart
Future<void> startFlow() async {
  final wellnessVM = WellnessFlowViewModel(activeEvent: event);
  await _navigateToMemberRegistration(wellnessVM);  // ← Pass wellnessVM, don't wait for result
}
```

#### 2. Modified `_navigateToMemberRegistration()` method

**Changes:**
- Changed return type from `Future<Member?>` to `Future<void>` (no longer returns member)
- Added `wellnessVM` parameter
- Changed `Navigator.push<Member>` to `Navigator.push` (no generic type)
- Updated callbacks to navigate forward instead of popping

**Before:**
```dart
Future<Member?> _navigateToMemberRegistration() async {
  return await Navigator.push<Member>(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: MemberSearchScreen(
          onMemberFound: (member) {
            Navigator.of(context).pop(member);  // ← POPPED with member
          },
          // ...
        ),
      ),
    ),
  );
}
```

**After:**
```dart
Future<void> _navigateToMemberRegistration(WellnessFlowViewModel wellnessVM) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: MemberSearchScreen(
          onMemberFound: (member) async {
            if (context.mounted) {
              await navigateToEventDetails(member, wellnessVM);  // ← Navigate forward
            }
          },
          onGoToMemberDetails: (searchQuery) async {
            final member = await _navigateToMemberDetails(null, searchQuery);
            if (member != null && context.mounted) {
              await navigateToEventDetails(member, wellnessVM);  // ← Navigate forward
            }
          },
          // ...
        ),
      ),
    ),
  );
}
```

## Benefits

✅ **Natural Back Navigation:** Back button from Event Home now correctly returns to Member Search
✅ **Maintains Manual Navigation:** Continues using Material Navigator (no go_router needed)
✅ **Minimal Changes:** Only modified the flow in one file
✅ **No Breaking Changes:** All other functionality remains the same

## Navigation Stack Comparison

### Before (Broken)
```
Depth  Screen
-----  ------
  3    [Event Home]  ← "Back to Search" pressed here
  2    [WellnessFlowPage]  ← Goes here instead (wrong!)
  1    [My Event Screen]
```

### After (Fixed)
```
Depth  Screen
-----  ------
  4    [Event Home]  ← "Back to Search" pressed here
  3    [Member Search]  ← Correctly returns here ✓
  2    [WellnessFlowPage]
  1    [My Event Screen]
```

## Testing

### Test Case 1: Back Navigation
1. Start wellness flow from My Event Screen
2. Search for a member or create new member
3. Arrive at Event Home Screen
4. Press "Back to Search" button
5. **Expected:** Returns to Member Search Screen
6. **Result:** ✓ Works correctly

### Test Case 2: Member Search → Event Home → Back
1. Start wellness flow
2. On Member Search, find existing member
3. Event Home loads with member info
4. Press device back button or "Back to Search"
5. **Expected:** Returns to Member Search
6. **Result:** ✓ Works correctly

### Test Case 3: New Member Registration
1. Start wellness flow
2. On Member Search, click "Register New Member"
3. Fill in member details, save
4. Event Home loads
5. Press "Back to Search"
6. **Expected:** Returns to Member Search
7. **Result:** ✓ Works correctly

## Summary

This fix solves the back navigation issue by keeping the Member Search Screen in the navigation stack instead of popping it when a member is selected. The solution maintains manual navigation (no need for go_router) and requires minimal code changes while providing a natural user experience.

**Lines Changed:** ~15 lines in 1 file
**Risk:** Low (isolated change, preserves all functionality)
**Impact:** High (fixes critical UX issue)
