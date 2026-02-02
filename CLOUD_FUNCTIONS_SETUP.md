# Cloud Functions Setup Guide

> **⚡ Quick Help:** Already logged in and wondering what's next?  
> → Jump to [Step 2: Link to Your Firebase Project](#step-2-link-to-your-firebase-project)

This guide will help you set up Firebase Cloud Functions to automate the user deletion process.

## Quick Checklist

Follow these steps in order:
- [ ] **Step 1:** Login to Firebase (`firebase login`)
- [ ] **Step 2:** Link to your Firebase project (`firebase use --add`)
- [ ] **Step 3:** Install dependencies (`cd functions && npm install`)
- [ ] **Step 4:** Build functions (`npm run build`)
- [ ] **Step 5:** Deploy to Firebase (`cd .. && firebase deploy --only functions`)
- [ ] **Step 6:** Test with a dummy user

**Total Time:** ~10 minutes  
**Prerequisites:** Node.js 18+, Firebase CLI, Blaze plan

---

## Prerequisites

Before starting, ensure you have:

1. **Firebase CLI installed:**
   ```bash
   npm install -g firebase-tools
   ```
   Verify with: `firebase --version`

2. **Node.js installed:**
   - Version 18 or higher
   - Check with: `node --version`

3. **Firebase Project on Blaze Plan:**
   - Cloud Functions require the Blaze (pay-as-you-go) plan
   - Don't worry - first 2M function invocations/month are FREE
   - Typical cost: <$1/month for normal usage
   - Upgrade at: https://console.firebase.google.com → Project Settings → Usage and billing

---

## Setup Steps

### Step 1: Login to Firebase ✅

**Command:**
```bash
firebase login
```

**Expected Outcomes:**

**If you see:** `"Already logged in as [your-email]"`
- ✅ **SUCCESS!** You're already authenticated.
- ⏭️ **Skip to Step 2** - You don't need to do anything else here.

**If you see:** `"Waiting for authentication..."`
- A browser window will open
- Sign in with your Google account
- Return to terminal after successful login
- You should see: `✔ Success! Logged in as [your-email]`

**Troubleshooting:**
- If browser doesn't open: `firebase login --no-localhost`
- If you need to switch accounts: `firebase logout` then `firebase login`

**➡️ NEXT: Proceed to Step 2**

---

### Step 2: Link to Your Firebase Project

**Navigate to your project:**
```bash
cd C:\src\flutter_projects\ProductionReadyKenwellApp\kenwell_health_app
```

**Link to Firebase project:**
```bash
firebase use --add
```

**What happens:**
1. You'll see a list of your Firebase projects
2. Use arrow keys to select your Kenwell Health project
3. Enter an alias (suggestion: `production`)
4. Press Enter

**Expected Output:**
```
? Which project do you want to add? (Use arrow keys)
❯ kenwell-health-app (Kenwell Health App)
  other-project-1
  other-project-2

? What alias do you want to use for this project? production
✔ Created alias production for kenwell-health-app.
Now using alias production (kenwell-health-app)
```

**Troubleshooting:**
- **No projects listed?** Check you're logged into the correct Google account
- **Wrong project selected?** Run `firebase use --add` again to change
- **Check current project:** `firebase use`

**➡️ NEXT: Proceed to Step 3**

---

### Step 3: Install Function Dependencies

**Navigate to functions folder:**
```bash
cd functions
```

**Install packages:**
```bash
npm install
```

**What happens:**
- Downloads `firebase-admin` (server-side Firebase operations)
- Downloads `firebase-functions` (Cloud Functions framework)
- Creates `node_modules` folder
- Creates `package-lock.json`

**Expected Output:**
```
npm install
added 234 packages in 15s
```

**Troubleshooting:**
- **Error: ENOENT: no such file or directory** → Make sure you're in the correct project directory
- **npm not found?** Install Node.js from https://nodejs.org/
- **Permission errors?** Run as administrator (Windows) or use `sudo` (Mac/Linux)

**Time:** ~30 seconds (depending on internet speed)

**➡️ NEXT: Proceed to Step 4**

---

### Step 4: Build the Functions

**Build TypeScript to JavaScript:**
```bash
npm run build
```

**What happens:**
- Compiles TypeScript (`src/index.ts`) to JavaScript (`lib/index.js`)
- Type-checks your code
- Creates the `lib` directory

**Expected Output:**
```
> build
> tsc

[no output means success!]
```

**Troubleshooting:**
- **Compilation errors?** Check `functions/src/index.ts` for syntax errors
- **tsc not found?** Run `npm install` again
- **Want to watch for changes?** Use `npm run build:watch`

**Time:** ~5 seconds

**➡️ NEXT: Proceed to Step 5**

---

### Step 5: Deploy to Firebase 🚀

**Navigate back to project root:**
```bash
cd ..
```

**Deploy functions:**
```bash
firebase deploy --only functions
```

**What happens:**
- Uploads your functions to Firebase
- Enables Cloud Functions API (if not already enabled)
- Creates the `deleteUserCompletely` function
- Creates the `healthCheck` function

**Expected Output:**
```
=== Deploying to 'kenwell-health-app'...

i  deploying functions
i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...
✔  functions: required API cloudfunctions.googleapis.com is enabled
i  functions: preparing codebase functions for deployment
i  functions: preparing functions directory for uploading...
✔  functions: functions folder uploaded successfully
i  functions: creating Node.js 18 function deleteUserCompletely(us-central1)...
i  functions: creating Node.js 18 function healthCheck(us-central1)...
✔  functions[deleteUserCompletely(us-central1)]: Successful create operation.
✔  functions[healthCheck(us-central1)]: Successful create operation.

✔  Deploy complete!

Functions URLs:
  deleteUserCompletely: https://us-central1-YOUR-PROJECT.cloudfunctions.net/deleteUserCompletely
  healthCheck: https://us-central1-YOUR-PROJECT.cloudfunctions.net/healthCheck
```

**Troubleshooting:**
- **Error: "billing-plan-not-configured"** → Upgrade to Blaze plan (see Prerequisites)
- **Error: "Permission denied"** → Check you selected the correct project in Step 2
- **Deployment hangs?** Check your internet connection
- **Want to force re-deploy?** Add `--force` flag

**Time:** ~2-3 minutes (first deployment is slower)

**➡️ NEXT: Proceed to Step 6**

---

### Step 6: Verify Deployment

**Check deployed functions:**
```bash
firebase functions:list
```

**Expected Output:**
```
┌──────────────────────┬────────────┬─────────────┐
│ Name                 │ State      │ Region      │
├──────────────────────┼────────────┼─────────────┤
│ deleteUserCompletely │ ACTIVE     │ us-central1 │
│ healthCheck          │ ACTIVE     │ us-central1 │
└──────────────────────┴────────────┴─────────────┘
```

**Alternative verification:**
1. Go to https://console.firebase.google.com
2. Select your project
3. Click "Functions" in the left menu
4. You should see both functions listed as "Active"

**➡️ NEXT: Test with a dummy user!**

---

## Testing & Verification

### Test with a Dummy User

**Important:** The Flutter app already has the Cloud Functions integration! The code was updated in the previous commit.

**To verify everything works:**

1. **Open your app** (if not already running)
2. **Create a test user:**
   - Email: `test.user@example.com`
   - Any password, role, etc.
3. **Delete the test user:**
   - Go to "View Users" tab
   - Find the test user
   - Click delete
   - Confirm deletion
4. **Check the console logs** (Debug output):
   - ✅ Look for: `"Cloud Function successfully deleted user"`
   - ⚠️ If you see: `"Falling back to Firestore-only deletion"` → Function not called (check deployment)
5. **Verify in Firebase Console:**
   - Go to https://console.firebase.google.com
   - Click "Authentication" → "Users"
   - The test user should be GONE (not just from Firestore, but from Auth too!)
6. **Try to re-register:**
   - Register a new user with `test.user@example.com`
   - ✅ Should work immediately (if Cloud Function succeeded)
   - ❌ If it fails with "email in use" → Auth account wasn't deleted (check function logs)

### Monitor Function Logs

**View real-time logs:**
```bash
firebase functions:log --only deleteUserCompletely
```

**Or in Firebase Console:**
1. Go to https://console.firebase.google.com
2. Click "Functions"
3. Click on `deleteUserCompletely`
4. Click "Logs" tab
5. You'll see each deletion with details

**What to look for:**
- `Starting deletion for user [userId]`
- `Successfully deleted user [userId] (X documents + Auth account)`
- Any errors if something went wrong

---

## Flutter App Integration (Already Done!)

The Flutter app code has already been updated with Cloud Functions support.  
**You don't need to make any code changes!**

**What was updated:**
- `pubspec.yaml` - Added `cloud_functions: ^4.6.0`
- `firebase_auth_service.dart` - Smart deletion with automatic fallback
- `user_management_view_model.dart` - Updated success messages

**How it works:**
```
Delete Button → Try Cloud Function → Success? → Both deleted ✅
                                  ↓
                                Fail? → Firestore only ⚠️ (shows manual instructions)
```

---

## Common Issues & Solutions

### "Already logged in as..." - What do I do?

**This is a SUCCESS message!** ✅

**What it means:**
- You're authenticated with Firebase
- Step 1 is complete
- You don't need to do anything else

**Next step:**
→ Go to [Step 2: Link to Your Firebase Project](#step-2-link-to-your-firebase-project)

---

### Error: "billing-plan-not-configured"

**Cause:** Your Firebase project is on the Spark (free) plan.

**Solution:**
1. Go to https://console.firebase.google.com
2. Select your project
3. Click "Upgrade" in the bottom left
4. Select "Blaze - Pay as you go"
5. Add billing information
6. Set budget alerts (e.g., $5/month) to prevent surprises

**Note:** Functions usage under 2M invocations/month is FREE.

---

### Error: "Permission denied" during deployment

**Cause:** You don't have permission to deploy to the selected project.

**Solution:**
1. Check you selected the correct project: `firebase use`
2. Verify you're logged into the correct account: `firebase logout` then `firebase login`
3. Check project permissions in Firebase Console

---

### Error: "Function not found" in app

**Cause:** Function not deployed or wrong region.

**Solution:**
1. Verify deployment: `firebase functions:list`
2. Re-deploy: `firebase deploy --only functions`
3. Check function name matches: `deleteUserCompletely`

---

### Functions Not Updating After Changes

**Cause:** Cached deployment or build issue.

**Solution:**
```bash
cd functions
npm run build
cd ..
firebase deploy --only functions --force
```

---

### "Falling back to Firestore-only deletion" in logs

**Cause:** Cloud Function not being called successfully.

**Possible reasons:**
1. Function not deployed yet
2. Wrong region configured
3. Network/connectivity issue
4. Permissions issue

**Solution:**
1. Check function is deployed: `firebase functions:list`
2. Check function logs: `firebase functions:log`
3. Try re-deploying: `firebase deploy --only functions --force`

---

### Can't find my Firebase project in the list

**Cause:** Logged into wrong Google account or no projects exist.

**Solution:**
1. Check current account: `firebase login:list`
2. Switch accounts if needed: `firebase logout` then `firebase login`
3. Verify you have access to the project in Firebase Console

---

## Cost Estimation

### Free Tier Includes:
- 2M invocations/month
- 400,000 GB-seconds compute time
- 200,000 CPU-seconds
- 5GB network egress

### Typical Usage (User Deletion):
- ~1 invocation per deletion
- ~100ms execution time
- ~128MB memory

### Estimated Costs:
- 10 deletions/day = ~300/month → **FREE**
- 100 deletions/day = ~3,000/month → **FREE**
- 1,000 deletions/day = ~30,000/month → **~$0.50/month**

**Most apps will stay in the FREE tier!**

## Security

The Cloud Function includes several security checks:

1. ✅ **Authentication Required** - Only logged-in users can call it
2. ✅ **Role-Based Access** - Only ADMIN and TOP MANAGEMENT roles allowed
3. ✅ **Self-Deletion Prevention** - Users cannot delete their own account
4. ✅ **Input Validation** - userId parameter is required and validated
5. ✅ **Error Handling** - Detailed error messages for debugging

## Monitoring

### View Function Metrics

Firebase Console > Functions > Dashboard shows:
- Number of invocations
- Execution time
- Error rate
- Memory usage

### Set Up Alerts

1. Go to Firebase Console > Functions
2. Click on a function
3. Click "Metrics" tab
4. Click "Create Alert"
5. Set thresholds (e.g., error rate > 5%)

## Rollback

If you need to rollback:

```bash
firebase functions:delete deleteUserCompletely
```

The app will automatically fallback to the old Firestore-only deletion method.

## Next Steps

1. ✅ Deploy the functions
2. ✅ Test with a dummy user
3. ✅ Monitor logs for the first few deletions
4. ✅ Set up billing alerts
5. ✅ Update team documentation

## Support

For issues or questions:
1. Check function logs: `firebase functions:log`
2. Review Firebase Console > Functions > Logs
3. Check Flutter app debug output
4. Contact the development team

---

**Last Updated:** 2026-02-02
**Firebase CLI Version:** 13.0.0+
**Node.js Version:** 18+
**Functions Runtime:** Node.js 18
