# Cloud Functions Setup Guide

This guide will help you set up Firebase Cloud Functions to automate the user deletion process.

## Prerequisites

1. **Firebase CLI installed:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Node.js installed:**
   - Version 18 or higher
   - Check with: `node --version`

3. **Firebase Project on Blaze Plan:**
   - Cloud Functions require the Blaze (pay-as-you-go) plan
   - Don't worry - first 2M function invocations/month are FREE
   - Typical cost: <$1/month for normal usage

## Setup Steps

### Step 1: Login to Firebase

```bash
firebase login
```

This will open a browser window for authentication.

### Step 2: Initialize Firebase in Your Project

Navigate to your project directory:
```bash
cd /path/to/kenwell_health_app
```

Link to your Firebase project:
```bash
firebase use --add
```

Select your project from the list and give it an alias (e.g., "production").

### Step 3: Install Function Dependencies

```bash
cd functions
npm install
```

This will install all required packages including:
- `firebase-admin` - For server-side Firebase operations
- `firebase-functions` - For creating Cloud Functions

### Step 4: Build the Functions

```bash
npm run build
```

This compiles TypeScript to JavaScript. You should see output in the `functions/lib` directory.

### Step 5: Deploy to Firebase

From the project root (not the functions folder):
```bash
cd ..
firebase deploy --only functions
```

You should see output like:
```
✔ functions: Finished running predeploy script.
i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...
✔ functions: required API cloudfunctions.googleapis.com is enabled
i  functions: preparing functions directory for uploading...
i  functions: packaged functions (XX KB) for uploading
✔ functions: functions folder uploaded successfully
i  functions: creating Node.js 18 function deleteUserCompletely...
✔ functions[deleteUserCompletely]: Successful create operation.
Function URL (deleteUserCompletely): https://us-central1-YOUR-PROJECT.cloudfunctions.net/deleteUserCompletely
```

### Step 6: Verify Deployment

Test the health check function:
```bash
firebase functions:log
```

Or visit the Firebase Console:
- Go to https://console.firebase.google.com
- Select your project
- Click "Functions" in the left menu
- You should see `deleteUserCompletely` and `healthCheck` listed

## Flutter App Integration

### Step 1: Add Cloud Functions Package

Add to `pubspec.yaml`:
```yaml
dependencies:
  cloud_functions: ^4.6.0  # Add this line
```

Then run:
```bash
flutter pub get
```

### Step 2: Update Code

The code has already been updated in:
- `lib/data/services/firebase_auth_service.dart`

The new `deleteUser()` method will:
1. Try to call the Cloud Function
2. If successful, delete both Firestore and Auth
3. If function fails, fallback to Firestore-only deletion

## Testing

### Test with a Dummy User

1. Create a test user through the app
2. Note the user's email
3. Delete the user through "View Users" tab
4. Check Firebase Console > Authentication
5. The user should be completely gone ✅
6. Try to re-register with the same email
7. Should work without issues ✅

### Monitor Function Logs

```bash
firebase functions:log --only deleteUserCompletely
```

Or in Firebase Console > Functions > Logs

## Troubleshooting

### Error: "billing-plan-not-configured"

**Cause:** Your Firebase project is on the Spark (free) plan.

**Solution:**
1. Go to Firebase Console
2. Click "Upgrade" in the bottom left
3. Select "Blaze - Pay as you go"
4. Add billing information
5. Set budget alerts (e.g., $5/month) to prevent surprises

**Note:** Functions usage under 2M invocations/month is FREE.

### Error: "Permission denied"

**Cause:** The calling user is not an admin.

**Solution:**
1. Verify the user has role "ADMIN" or "TOP MANAGEMENT" in Firestore
2. Check the `users` collection
3. Update the role field if needed

### Error: "Function not found"

**Cause:** Function not deployed or wrong region.

**Solution:**
1. Verify deployment: `firebase functions:list`
2. Re-deploy: `firebase deploy --only functions`
3. Check function name in Flutter code matches deployed name

### Functions Not Updating

**Cause:** Cached deployment or build issue.

**Solution:**
```bash
cd functions
npm run build
cd ..
firebase deploy --only functions --force
```

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
