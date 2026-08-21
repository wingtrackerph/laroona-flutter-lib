# Laroona Flutter Library

A reusable Flutter library with common widgets, providers, and utilities for rapid app development.

## Features

- **Request Provider**: HTTP request management with caching, error handling, and connectivity checks
- **Auth Provider**: Authentication state management
- **Theme Provider**: Theme and styling management with light/dark mode
- **Customizable Colors**: Set your brand color and access all theme colors
- **Reusable Widgets**: Pre-built UI components including cards, modals, inputs, buttons, and more
- **Utilities**: Date helpers, theme helpers, and common resources

## Installation

### Option 1: Local Path (During Development)

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  laroona_flutter_lib:
    path: ../path/to/laroona-flutter-lib
```

### Option 2: Git Repository

```yaml
dependencies:
  laroona_flutter_lib:
    git:
      url: https://github.com/yourusername/laroona-flutter-lib.git
      ref: main
```

### Option 3: Publish to pub.dev (Future)

```yaml
dependencies:
  laroona_flutter_lib: ^0.1.0
```

## Usage

### Import the library

```dart
import 'package:laroona_flutter_lib/laroona_flutter_lib.dart';
```

### Setup RequestProvider

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laroona_flutter_lib/laroona_flutter_lib.dart';

void main() {
  // Optional: Customize your app's colors
  setThemeColor('#1890ff');           // Brand color (hex with #)
  setPrimaryBgColor('#e6f7ff');       // Light mode backgrounds
  setBgLayoutColor('#f0f2f5');
  setDarkPrimaryBgColor('#0d1117');   // Dark mode backgrounds
  setDarkBgLayoutColor('#161b22');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RequestProvider(
            apiBaseUrl: 'https://your-api.com/api/',
          ),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

### Using Widgets

```dart
// Use the pre-built widgets
LoadingButton(
  label: 'Submit',
  onPressed: () {
    // Handle submit
  },
  isLoading: false,
)

// Or use AppScaffold for consistent layout
AppScaffold(
  title: 'My Screen',
  body: YourContent(),
)
```

## Available Components

### Providers

- `RequestProvider` - HTTP request management with caching
- `AuthProvider` - Authentication state management
- `ThemeProvider` - Theme management

### Widgets

- `AppCard`, `AppChip`, `AppScaffold`
- `DataInput`, `DataListView`, `DataModal`
- `DetailsCard`, `DetailsItem`
- `Dropdown`, `IconCard`
- `LoadingButton`, `LoadingSpinner`
- `PasswordTextField`, `SectionHeader`

### Modals

- `AppModal` - Reusable modal component

### Resources

- `colors.dart` - Color constants
- `dimensions.dart` - Dimension constants

### Utils

- `date_helper.dart` - Date utilities
- `theme_helper.dart` - Theme utilities

## Configuration

The library requires the consuming app to provide:

- API base URL when initializing `RequestProvider`
- Proper provider setup using the `provider` package

### Optional Customization

**Primary Brand Color:**

```dart
// Set your brand color (defaults to green #52c41a)
setThemeColor('#1890ff');  // Blue theme
```

**Background Colors:**

```dart
// Light mode (customize backgrounds)
setPrimaryBgColor('#e6f7ff');    // Primary background (default: #f6ffed)
setBgLayoutColor('#f0f2f5');     // Layout background (default: #f5f5f4)

// Dark mode
setDarkPrimaryBgColor('#0d1117'); // Dark background (default: #0f1419)
setDarkBgLayoutColor('#161b22');  // Dark layout (default: #1a1f26)

// Reset to defaults
setPrimaryBgColor(null);
```

**Theme Colors:**

Use `ThemeColors` helper for theme-aware colors:

```dart
Container(
  color: ThemeColors.getCardColor(context),  // Adapts to light/dark mode
  child: Text(
    'Hello',
    style: TextStyle(color: ThemeColors.getTextColor(context)),
  ),
)
```

All color constants are exported and available for customization. See:

- [laroona-flutter-lib-readme.md](laroona-flutter-lib-readme.md) - Complete API documentation
- [COLOR_CUSTOMIZATION_EXAMPLES.md](COLOR_CUSTOMIZATION_EXAMPLES.md) - Practical examples

## Dependencies

This library depends on:

- `provider` - State management
- `dio` - HTTP client
- `connectivity_plus` - Network connectivity
- `shared_preferences` - Local storage
- `toastification` - Toast notifications
- And more (see pubspec.yaml)

## License

Add your license here

## Contributing

Add contribution guidelines here
