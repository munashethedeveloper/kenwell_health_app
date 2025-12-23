# Build Instructions After Database Schema Changes

After making changes to the database schema in `lib/data/local/app_database.dart`, you need to regenerate the database code.

## Steps to Regenerate Database Code

1. Make sure you have all dependencies installed:
   ```bash
   flutter pub get
   ```

2. Run the build_runner to regenerate the database code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

   Or for continuous watching during development:
   ```bash
   flutter pub run build_runner watch --delete-conflicting-outputs
   ```

## Recent Changes

### Schema Version 13
- Added `screenedCount` column to the Events table to track the number of screened participants
- Added migration logic to handle the new column for existing databases
- Updated EventRepository mappings to include `screenedCount` in both entity-to-domain and domain-to-companion conversions

### Event Filtering Fix
- Fixed week filtering logic in ConductEventScreen to properly include events on boundary dates
- Changed from `!(ev.isBefore(selectedStart) || ev.isAfter(selectedEnd))` to explicit boundary checks using `isAfter`, `isBefore`, and `isAtSameMomentAs`

## Testing After Changes

1. Run the build_runner command above
2. Clean and rebuild the app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. Test the following scenarios:
   - Create a new event and verify it appears in the ConductEventScreen
   - Switch between "This Week" and "Next Week" tabs to verify filtering works correctly
   - Start an event and verify the screened count increments properly
   - Restart the app and verify events persist correctly with screened count
