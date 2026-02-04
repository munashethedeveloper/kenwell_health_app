# Windows Build Notes

## Known Build Warnings

### CMake Deprecation Warning from Firebase SDK

When building the application on Windows, you may see a deprecation warning:

```
CMake Deprecation Warning at build/windows/x64/extracted/firebase_cpp_sdk_windows/CMakeLists.txt:17 
(cmake_minimum_required):
  Compatibility with CMake < 3.10 will be removed from a future version of CMake.
  Update the VERSION argument <min> value or use a ...<max> suffix to tell
  CMake that the project does not need compatibility with older versions.
```

**This warning is expected and does not affect the build.**

#### Explanation

- The warning originates from the Firebase C++ SDK, which is an external dependency
- Firebase C++ SDK for Windows uses an older CMake version (< 3.10) in its configuration
- This is a known limitation of the current Firebase C++ SDK
- The build process completes successfully despite this warning

#### Impact

- **No functional impact**: The application builds and runs correctly
- **Informational only**: The warning is purely informational
- **External dependency**: This is managed by the Firebase team, not this project

#### What We've Done

- Updated the main project's CMake minimum version to 3.21 (modern and stable)
- Documented this known warning for developer reference
- The project's own CMake configuration follows best practices

#### Future Resolution

The Firebase team is aware of this warning and it will be addressed in future SDK releases. Until then, this warning can be safely ignored as it doesn't affect the build or runtime behavior of the application.

## Build Requirements

- CMake 3.21 or higher
- Visual Studio 2019 or later
- Flutter SDK (latest stable)
- Firebase plugins as specified in pubspec.yaml

## Building for Windows

```bash
flutter build windows
```

Or run in debug mode:

```bash
flutter run -d windows
```
