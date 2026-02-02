# Quick Fix: "firebase use must be run from a Firebase project directory"

## The Error You're Seeing

```
PS C:\src\flutter_projects\ProductionReadyKenwellApp\kenwell_health_app> firebase use --add

Error: firebase use must be run from a Firebase project directory.
```

## What This Means

Firebase CLI is looking for configuration files (`.firebaserc` and `firebase.json`) but can't find them.

## Quick Solution

### Step 1: Verify You're in the Correct Directory

```powershell
# Make sure you're in the kenwell_health_app folder
cd C:\src\flutter_projects\ProductionReadyKenwellApp\kenwell_health_app

# Check if firebase.json exists
dir firebase.json
```

**Expected:** You should see `firebase.json` listed.

### Step 2: Check for .firebaserc

```powershell
# Check if .firebaserc exists
dir .firebaserc
```

**If you see the file:** ✅ Great! Try `firebase use --add` again.

**If you DON'T see the file:** ⚠️ Continue to Step 3.

### Step 3: Pull the Latest Changes

The `.firebaserc` file was recently added to the repository. Pull the latest changes:

```powershell
git pull origin copilot/fix-navigation-logic
```

### Step 4: Verify .firebaserc Exists Now

```powershell
dir .firebaserc
```

**Expected:** You should now see the file.

### Step 5: Try Again

```powershell
firebase use --add
```

**Expected Output:**
```
? Which project do you want to add? (Use arrow keys)
❯ kenwell-health-app (Kenwell Health App)
  other-project
```

## If Still Not Working

### Manual Fix - Create .firebaserc

If the file is still missing after pulling, create it manually:

```powershell
@"
{
  "projects": {
    "default": "YOUR-PROJECT-ID-HERE"
  }
}
"@ | Out-File -FilePath .firebaserc -Encoding utf8
```

Then run:
```powershell
firebase use --add
```

## What .firebaserc Does

This file tells Firebase CLI:
- Which Firebase project to use
- Project aliases (like "production", "staging")
- Your project ID

Example:
```json
{
  "projects": {
    "default": "kenwell-health-app",
    "production": "kenwell-health-app"
  }
}
```

## Summary

**The fix:**
1. ✅ Make sure you're in the `kenwell_health_app` directory
2. ✅ Pull the latest changes to get `.firebaserc`
3. ✅ Run `firebase use --add` again

**If manual creation needed:**
- Use the PowerShell command above to create `.firebaserc`
- Then run `firebase use --add`

---

**After this is fixed, continue with Step 3 of the setup guide!**

See `CLOUD_FUNCTIONS_SETUP.md` for the complete setup process.
