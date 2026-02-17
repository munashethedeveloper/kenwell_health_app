# View Members Tab - Navigation Guide

## 📍 Where is the View Members Tab?

The **View Members** tab is located in the **Member Management** screen. Here's how to access it:

### Navigation Path:

```
App Home (Main Navigation)
    ↓
Users Tab (Bottom Navigation - People Icon)
    ↓
My User Management Screen
    ↓
Member Registration Menu Item (Tap)
    ↓
Member Management Screen
    ↓
View Members Tab ✅ (Second Tab)
```

### Step-by-Step Instructions:

1. **Open the App**
2. **Tap the "Users" icon** in the bottom navigation bar (icon looks like 👥)
3. **On "My User Management" screen**, you'll see two menu items:
   - User Registration (for staff)
   - Member Registration (for event participants) ← **Tap this**
4. **Member Management screen opens** with two tabs at the top:
   - "Create Members" (first tab)
   - **"View Members"** (second tab) ← **This is it!**

## 🎯 What Can You Do in View Members Tab?

### Features:
- **Search Members**: Search by name or email using the search bar
- **Filter Members**: Filter by gender (All, Male, Female) using filter chips
- **View Member Details**: Each card shows:
  - Full name
  - Email address
  - Phone number
  - ID or Passport number
  - Gender
- **Member Actions**: Tap any member card to:
  - **View Events** - See all events the member attended
  - **Delete Member** - Remove member (requires permission)

### Statistics:
- Shows total number of members
- Shows filtered results count when search/filter is active
- Pull-to-refresh to reload members

## 🔐 Permissions Required

To see the View Members tab, your user account must have the **`view_members`** permission assigned to your role.

If you don't see the tab:
1. Check with your administrator about your role permissions
2. Roles like ADMIN, PROJECT MANAGER typically have this permission

## 📱 Technical Details

### File Locations:
- **Main Screen**: `lib/ui/features/member/widgets/member_registration_screen_version_two.dart`
- **View Members Implementation**: `lib/ui/features/member/widgets/sections/view_members_section.dart`
- **Routing Config**: `lib/routing/go_router_config.dart`

### Route Information:
- **Route Name**: `memberRegistration`
- **Path**: `/member-registration`

## 🆘 Troubleshooting

### "I don't see the View Members tab"
- **Check**: Do you have the `view_members` permission?
- **Check**: Are you navigating to "Member Registration" (not "User Registration")?
- **Solution**: Contact your administrator to check your role permissions

### "The tab is empty"
- **Cause**: No members have been registered yet
- **Solution**: Use the "Create Members" tab to register your first member

### "I can't delete members"
- **Cause**: You need the `delete_member` permission
- **Solution**: Contact your administrator if you need this permission

## 🔄 Related Features

- **Create Members Tab**: Register new event participants
- **Member Events Screen**: View all events a specific member attended
- **User Management**: Separate section for managing staff users (not event participants)

---

**Last Updated**: February 2026
**Version**: 2.0 (Tabbed Interface)
