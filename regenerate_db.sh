#!/bin/bash
set -e

# This script regenerates the Drift database code after schema changes
# Run this script after modifying the app_database.dart file

echo "Regenerating Drift database code..."
echo ""

# Clean previous builds
echo "1. Cleaning previous builds..."
flutter clean

# Get dependencies
echo "2. Getting dependencies..."
flutter pub get

# Run build runner to generate database code
echo "3. Running build_runner to generate database code..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Database code generation complete!"
echo ""
echo "Note: If you see any errors, make sure:"
echo "  - Flutter SDK is properly installed"
echo "  - All dependencies in pubspec.yaml are up to date"
echo "  - The app_database.dart file has no syntax errors"