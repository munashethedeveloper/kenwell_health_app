# Firestore Index Setup Guide

This document explains how to set up and manage Firestore indexes for the Kenwell Health App.

## What are Firestore Indexes?

Firestore indexes are database structures that allow queries with multiple `where` clauses to run efficiently. When you create a query that filters on multiple fields (like `userId` AND `eventDate`), Firestore requires a composite index.

## Required Indexes for This App

### User Events Index

**Collection:** `user_events`  
**Fields:**
- `userId` (Ascending)
- `eventDate` (Ascending)

**Why it's needed:** The app queries user events filtered by both user ID and date range to show events for the current and next week.

## How to Create the Index

### Method 1: Automatic (Recommended)

1. Run the app and navigate to the "My Events" screen
2. You'll see an error like:
   ```
   FirebaseException ([cloud_firestore/failed-precondition] The query requires an index.
   You can create it here: https://console.firebase.google.com/...
   ```
3. **Click the link** in the error message
4. Firebase Console will open with the index configuration pre-filled
5. Click **"Create Index"**
6. Wait 1-2 minutes for the index to build (status shown in Firebase Console)
7. Once status shows "Enabled", retry the query - it will work automatically!

### Method 2: Manual

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`kenwellmobileapp`)
3. Click **Firestore Database** in the left menu
4. Click the **Indexes** tab
5. Click **"Create Index"**
6. Configure:
   - Collection ID: `user_events`
   - Add Field: `userId` (Ascending)
   - Add Field: `eventDate` (Ascending)
7. Click **"Create"**
8. Wait for the index to finish building

### Method 3: Deploy from firestore.indexes.json (For Developers)

If you have Firebase CLI installed:

```bash
firebase deploy --only firestore:indexes
```

This will deploy all indexes defined in `firestore.indexes.json`.

## How to Check Index Status

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **Firestore Database** → **Indexes** tab
4. Look for the `user_events` index
5. Status should be **"Enabled"** (not "Building")

## Important Notes

### Indexes are Automatically Used

Once you create an index in Firebase Console, **you don't need to change any code**. Firestore automatically uses the appropriate index when you run a matching query.

### Index Building Time

- Small collections: ~1 minute
- Large collections: Can take several minutes or longer
- You can monitor progress in Firebase Console

### Common Issues

**Issue:** Error persists after creating the index  
**Solution:** Wait a few more minutes. The index might still be building.

**Issue:** "Index already exists" error  
**Solution:** This means the index is created. Check if it's still in "Building" status.

**Issue:** Can't access Firebase Console link  
**Solution:** Make sure you have the right permissions on the Firebase project.

## Firestore Index Configuration File

The `firestore.indexes.json` file in the root directory contains the index definitions. This file:
- Documents all required indexes
- Can be deployed using Firebase CLI
- Helps with version control and team collaboration

## Need More Help?

- [Firestore Index Documentation](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Firebase Console](https://console.firebase.google.com/)
- Check with your team's Firebase admin if you don't have access
