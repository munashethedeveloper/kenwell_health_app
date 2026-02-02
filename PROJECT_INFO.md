# Firebase Project Information

## Your Firebase Project Details

### Project ID
```
kenwellmobileapp
```

### Project Number
```
195093019449
```

### Storage Bucket
```
kenwellmobileapp.firebasestorage.app
```

### Firebase Console URL
```
https://console.firebase.google.com/project/kenwellmobileapp
```

---

## Where to Find This Information

### 1. In This Repository

**Android Configuration:**
- File: `android/app/google-services.json`
- Contains: Project ID, Project Number, API Keys, etc.

**Firebase CLI Configuration:**
- File: `.firebaserc`
- Contains: Project ID and aliases

### 2. In Firebase Console

Visit: https://console.firebase.google.com/project/kenwellmobileapp

**Project Settings:**
1. Click the gear icon (⚙️) next to "Project Overview"
2. Click "Project settings"
3. See all project details in the "General" tab

---

## Using the Project ID

### For Firebase CLI Commands

```bash
# The .firebaserc file already contains your project ID
firebase use default

# Or specify directly
firebase use kenwellmobileapp

# Deploy functions
firebase deploy --only functions --project kenwellmobileapp
```

### For Firebase Setup

When running `firebase use --add`, you'll see:
```
? Which project do you want to add?
❯ kenwellmobileapp (Kenwell Mobile App)
```

Select this project and it will update `.firebaserc` automatically.

---

## Project Configuration Files

### Android: google-services.json
**Location:** `android/app/google-services.json`

**Contains:**
- Project ID: `kenwellmobileapp`
- Project Number: `195093019449`
- API Keys for Android
- OAuth Client IDs
- Firebase service configurations

**DO NOT commit changes** to this file unless updating Firebase project settings.

### iOS: GoogleService-Info.plist
**Location:** `ios/Runner/GoogleService-Info.plist` (if exists)

**Contains:**
- PROJECT_ID
- BUNDLE_ID
- API_KEY
- Other iOS-specific configurations

### Firebase CLI: .firebaserc
**Location:** `.firebaserc`

**Contains:**
- Project aliases
- Default project

**This file** is safe to commit and helps team members use the correct project.

---

## Quick Reference

| Item | Value |
|------|-------|
| **Project ID** | `kenwellmobileapp` |
| **Project Number** | `195093019449` |
| **Storage Bucket** | `kenwellmobileapp.firebasestorage.app` |
| **Console URL** | https://console.firebase.google.com/project/kenwellmobileapp |

---

## Firebase Services in Use

Based on the configuration files, this project uses:

✅ **Authentication** - User management  
✅ **Firestore** - Database  
✅ **Cloud Functions** - Server-side logic  
✅ **Storage** - File storage  
✅ **Analytics** - App analytics  

---

## For Team Members

When setting up the project:

1. **Clone the repository**
2. **Run `firebase login`** to authenticate
3. **Run `firebase use default`** - This will use `kenwellmobileapp` (already configured in `.firebaserc`)
4. **Continue with setup** as per `CLOUD_FUNCTIONS_SETUP.md`

The project ID is already configured, so you don't need to run `firebase use --add` unless you want to add an alias.

---

## Troubleshooting

**Q: "How do I verify I'm using the correct project?"**

A: Run:
```bash
firebase use
```

Expected output:
```
Active Project: kenwellmobileapp (kenwellmobileapp)
```

**Q: "I see a different project ID in Firebase Console"**

A: Check that you're looking at the correct project. The project ID is permanent and cannot be changed after project creation.

**Q: "Can I change the project ID?"**

A: No, the project ID is permanent. If you need a different ID, you must create a new Firebase project.

---

**Last Updated:** 2026-02-02  
**Project Created:** (Check Firebase Console for creation date)  
**Primary Use:** Kenwell Health Mobile Application
