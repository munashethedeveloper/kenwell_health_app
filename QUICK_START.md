# Quick Start Guide - Event Flow Refactor

## What Changed?

The event conducting flow now starts with **Member Registration** instead of going directly to the Event Details screen. This ensures all participants are registered before accessing event features.

## Before You Run the App

**⚠️ CRITICAL:** Generate the database code first:

```bash
./regenerate_db.sh
```

This creates the required database files for the new Members table.

## New User Flow

### 1. Start/Resume Event
From the Conduct Event screen, click "Start Event" or "Resume Event"

### 2. Member Registration (NEW!)
- Select ID type: **RSA ID Number** or **Passport Number**
- Enter the ID/Passport number
- Click **Search**

### 3. Two Possible Outcomes

#### A. Member Found ✓
- View member details card
- Click **"Continue to Event Details"**
- Proceed to event sections

#### B. Member Not Found
- See "Member Not Found" message
- Click **"Go to Member Details"**
- Fill out the registration form
- Member is saved to database
- Automatically navigate to Event Details

### 4. Event Details Screen (Enhanced)
Now shows completion indicators (green checkmarks) for:
- ✓ Consent
- ✓ Member Registration
- ✓ Health Screenings
- ✓ Survey

Click any card to complete that section.

## Key Features

### Smart Navigation
- Only shows "Register Member" button if member doesn't exist
- Only shows "Continue" button if member exists
- Prevents duplicate registrations

### Database Persistence
- All member data saved to local database
- Fast searches by ID or Passport number
- Data persists across app restarts

### Visual Feedback
- Green checkmarks show completed sections
- Clear status at a glance
- Helps track event progress

## Testing the Changes

1. **Test New Member Registration**
   - Search for non-existent ID (e.g., "1234567890123")
   - Register the member
   - Verify navigation to Event Details
   - Check that Member Registration has checkmark

2. **Test Existing Member**
   - Search for previously registered ID
   - Verify "Continue" button appears
   - Check member details are displayed
   - Proceed to Event Details

3. **Test ID vs Passport**
   - Switch between ID and Passport types
   - Verify field label changes
   - Test search with both types

4. **Test Completion Indicators**
   - Complete Consent form
   - Return to Event Details
   - Verify Consent has checkmark
   - Repeat for other sections

## Troubleshooting

### "The getter 'members' isn't defined"
**Solution:** Run `./regenerate_db.sh`

### "Undefined class 'MemberEntity'"
**Solution:** Run `./regenerate_db.sh`

### Database errors
**Solution:** 
1. Uninstall and reinstall the app (forces DB recreation)
2. Check logs for specific error
3. See `IMPLEMENTATION_NOTES.md` for details

### Search not working
- Verify database was regenerated
- Check that app has been reinstalled after database schema change
- Look for error messages in search results

## Need Help?

See detailed documentation:
- `IMPLEMENTATION_NOTES.md` - Full implementation details and testing checklist
- `REGENERATE_DATABASE.md` - Database regeneration instructions
- Code comments in modified files

## Questions?

Common scenarios:

**Q: Can I skip member registration?**
A: No, member registration is now required before accessing event features.

**Q: What if I search for a member that doesn't exist?**
A: You'll be prompted to register them via the Member Details form.

**Q: Can I update member information?**
A: Not yet - this is planned for a future enhancement.

**Q: Where is member data stored?**
A: In the local SQLite database via Drift ORM.

**Q: Will old events still work?**
A: Yes, existing events continue to work. The change only affects the flow when starting/resuming events.
