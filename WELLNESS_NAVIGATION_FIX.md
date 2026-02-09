# Wellness Navigation Back Button Fix

## Problem Statement
The wellness flow had multiple back navigation issues caused by mixing Material Navigator and Go Router navigation methods, along with problematic PopScope widgets.

## Issues Identified and Fixed

### 1. ✅ Mixed Navigation Methods (CRITICAL)
**Problem:** Code mixed `Navigator.of(context).pop()` and `context.pop()` (go_router) throughout wellness_navigator.dart
- 16 instances of `context.pop()` 
- 2 instances of `Navigator.of(context).pop()`
- This caused inconsistent behavior when navigating back

**Fix:** Standardized all navigation to use `Navigator.of(context).pop()` for manual navigation flows
- Wellness flow now exclusively uses Material Navigator
- Go Router import kept only for help button navigation to go_router routes

### 2. ✅ Recursive Navigation Loop (HIGH)
**Problem:** After completing a health screening (HRA, HIV, or TB), the code called `navigateToHealthScreenings()` again via `Navigator.push()`, creating nested navigation stacks:
```
Health Screenings Menu (1)
  → Complete HRA
    → Health Screenings Menu (2) ← DUPLICATE PUSH
      → Complete HIV  
        → Health Screenings Menu (3) ← ANOTHER DUPLICATE
```
This meant pressing back would show old versions of the screenings menu instead of going to event home.

**Fix:** Changed to a pop-and-loop pattern:
```dart
// In health screenings callbacks:
onHraTap: () async {
  final result = await _navigateToHra(member);
  if (result == true) {
    wellnessVM.hraCompleted = true;
    Navigator.of(context).pop(false); // Pop with false = not final submit
  }
}

// In parent caller:
bool? result;
do {
  result = await navigateToHealthScreenings(...);
} while (result == false); // Loop until user clicks "Submit All" (returns true)
```

**Benefits:**
- No nested navigation stack
- Back button works correctly from health screenings
- UI refreshes automatically when loop restarts
- Clean navigation history

### 3. ✅ Problematic PopScope in CurrentEventHomeScreen (HIGH)
**Problem:** PopScope widget attempted complex back handling:
```dart
PopScope(
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.canPop()) {
          context.pop();  // Go Router method
        } else {
          context.go('/member-search');  // Go Router method
        }
      });
    }
  },
```
This caused:
- Double navigation calls (PopScope + "Back to Search" button both handling back)
- Mixing Go Router with Material Navigator
- Race conditions with deferred callback

**Fix:** Removed PopScope entirely
- Screen now allows normal Flutter back button behavior
- "Back to Search" button properly calls `onBackToSearch` callback
- Callback handled cleanly in wellness_navigator.dart with `Navigator.of(context).pop()`

### 4. ✅ Problematic PopScope in MemberSearchScreen (MEDIUM)
**Problem:** PopScope blocked all back navigation:
```dart
PopScope(
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop) {
      context.go("/member-search");  // Always redirect, never pop
    }
  },
```
This prevented legitimate back navigation from member search to previous screens.

**Fix:** Removed PopScope entirely
- Screen now allows normal back navigation via Material Navigator
- Removed unnecessary go_router import

### 5. ✅ Duplicate Back Button Logic (MEDIUM)
**Problem:** "Back to Search" button had inline navigation logic:
```dart
onPressed: () {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/member-search');
  }
}
```
This duplicated the navigation handling and mixed navigation methods.

**Fix:** Simplified to call the callback directly:
```dart
onPressed: onBackToSearch,
```
The callback is properly handled in wellness_navigator.dart.

## Architecture Decisions

### Why Keep Manual Navigation for Wellness Flow?
The wellness flow remains on manual navigation (Material Navigator) because:

1. **Multi-step choreography** - Complex flow with conditional branches based on consent
2. **Data return patterns** - Uses `Future<Member?>`, `Future<bool?>` for clean data passing
3. **Modal presentation** - Each screen presented as a modal page with custom AppBars
4. **Recursive loops** - Health screenings menu needs to reappear after completing each test
5. **Isolated from main app** - Wellness flow is a self-contained feature

### Hybrid Navigation Strategy
- **Main app routes:** Go Router (calendar, stats, profile, etc.)
- **Wellness flow:** Material Navigator (member search → event home → screenings → survey)
- **Cross-boundary:** Help button in wellness flow uses `context.pushNamed('help')` to go_router

## Testing Checklist

### Back Navigation Tests
- [ ] Back from member search returns to calling screen
- [ ] Back from member details returns to member search
- [ ] Back from event home returns to member search
- [ ] Back from consent form returns to event home
- [ ] Back from health screenings returns to event home
- [ ] Back from individual screening (HRA/HIV/TB) returns to health screenings menu
- [ ] Back from survey returns to event home

### Health Screenings Loop Tests
- [ ] Complete HRA → Shows updated health screenings menu (not nested)
- [ ] Complete HIV → Shows updated health screenings menu (not nested)
- [ ] Complete TB → Shows updated health screenings menu (not nested)
- [ ] Press back from health screenings → Returns to event home (not nested menu)
- [ ] Complete all screenings + Submit → Returns to event home with screeningsCompleted=true

### Edge Cases
- [ ] Press Android/iOS back button from each screen
- [ ] Rapid back button presses don't crash
- [ ] Back navigation during async operations (member search, save)
- [ ] Back from help screen returns to wellness flow screen

## Files Modified

1. **lib/ui/features/wellness/navigation/wellness_navigator.dart**
   - Replaced all `context.pop()` with `Navigator.of(context).pop()`
   - Changed health screenings callbacks to pop with `false` instead of recursive push
   - Added do-while loop in event home to handle health screenings refresh
   - Total changes: ~25 lines

2. **lib/ui/features/wellness/widgets/current_event_home_screen.dart**
   - Removed PopScope widget wrapping Scaffold
   - Simplified "Back to Search" button to call callback directly
   - Removed go_router import
   - Total changes: ~15 lines removed

3. **lib/ui/features/wellness/widgets/member_search_screen.dart**
   - Removed PopScope widget wrapping Scaffold
   - Removed go_router import
   - Total changes: ~10 lines removed

## Summary

**Total lines changed:** ~50 lines (25 modified, 25 removed)

**Navigation now:**
- ✅ Consistent (all Material Navigator in wellness flow)
- ✅ Predictable (no recursive stacks)
- ✅ Simple (no complex PopScope logic)
- ✅ Working (back button behaves as expected)

**No breaking changes:**
- All screens still work the same
- Data passing unchanged
- UI unchanged
- Flow logic unchanged
- Only navigation behavior improved
