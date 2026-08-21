# Laroona Flutter Library - AI Developer Guide

**Version:** 0.1.0  
**Purpose:** Reusable Flutter library for rapid app development with standardized widgets, state management, and API integration patterns.

---

## 🎯 Quick Context

This is a **library package** (not an app) designed to be imported into Flutter projects. It provides a complete suite of widgets, providers, and utilities that follow specific architectural patterns for consistency and productivity.

### Core Philosophy

- **State Management:** Provider-based architecture
- **API Management:** Centralized through `RequestProvider`
- **Form Handling:** Automatic data binding via `DataInput`
- **Theme Support:** Full light/dark mode with `ThemeProvider`
- **Offline-First:** Automatic caching and connectivity handling

---

## 📦 Library Structure

```
lib/
├── laroona_flutter_lib.dart          # Main export file (import this)
├── providers/                         # State management
│   ├── auth_provider.dart            # Authentication & user roles
│   ├── request_provider.dart         # HTTP requests & caching
│   └── theme_provider.dart           # Theme mode management
├── widgets/                           # Reusable UI components
│   ├── data_input.dart               # Smart form input (key widget)
│   ├── data_list_view.dart           # Paginated list with pull-to-refresh
│   ├── data_modal.dart               # Modal with form handling
│   ├── app_scaffold.dart             # Standard page wrapper
│   ├── loading_button.dart           # Button with loading state
│   ├── dropdown.dart                 # Dropdown with options
│   ├── app_card.dart                 # Card container
│   ├── details_card.dart             # Details display
│   └── [other widgets...]
├── modals/
│   └── app_modal.dart                # Modal dialog wrapper
├── resources/
│   ├── colors.dart                   # Color constants (light/dark)
│   └── dimensions.dart               # Spacing/size constants
└── utils/
    ├── date_helper.dart              # Date formatting utilities
    └── theme_helper.dart             # Theme-aware color getters

```

---

## 🔧 Installation & Setup

### In Consumer Project

**pubspec.yaml:**

```yaml
dependencies:
  laroona_flutter_lib:
    path: ../path/to/laroona-flutter-lib
```

**main.dart setup:**

```dart
import 'package:laroona_flutter_lib/laroona_flutter_lib.dart';

void main() {
  // OPTIONAL: Customize colors for your app
  // These should be set before the app runs, typically in main()

  // Primary brand color (defaults to green #52c41a)
  setThemeColor('#1890ff');  // Example: Blue theme

  // Light mode background colors
  setPrimaryBgColor('#e6f7ff');    // Light blue tint (defaults to #f6ffed)
  setBgLayoutColor('#f0f2f5');     // Layout background (defaults to #f5f5f4)

  // Dark mode background colors
  setDarkPrimaryBgColor('#0d1117'); // Dark background (defaults to #0f1419)
  setDarkBgLayoutColor('#161b22');  // Dark layout (defaults to #1a1f26)

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RequestProvider(
            apiBaseUrl: 'https://your-api.com/api/',  // Required parameter
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

---

## 🏗️ Architecture Patterns

### 1. Request Pattern (API Calls)

**All HTTP requests go through `RequestProvider`.**

#### Fetching Data (GET)

**Single Endpoint:**

```dart
final requestProvider = Provider.of<RequestProvider>(context, listen: false);

await requestProvider.fetchRequest(
  context,
  key: 'users_list',              // Unique cache key
  path: '/users',                 // API endpoint
  pageSize: 20,                   // Items per page
  appendNewData: false,           // False = replace, True = append
  forceFetch: true,               // Bypass cache
  restartPage: true,              // Reset pagination
);

// Access data
final request = requestProvider.getRequest('users_list');
final users = request.data;       // List of items
final isLoading = request.isLoading;
final total = request.total;
```

**Multiple Endpoints:**

```dart
await requestProvider.fetchRequests(
  context,
  [
    Request(
      key: 'users_list',
      path: '/users',
      onSuccess: (responseData) {
        // Sequential call using responseData
      },
    ),
    Request(
      key: 'clubs_list',
      path: '/clubs',
    ),
  ],
  true,  // forceFetch
);
```

**Request Object Properties:**

- `request.data` - List of items (for lists)
- `request.singleData` - Map (for single object)
- `request.isLoading` - Loading state
- `request.isDone` - Completed state
- `request.isPaginated` - Auto-detected from response
- `request.currentPage` / `request.lastPage` - Pagination info
- `request.total` - Total count
- `request.errors` - Validation errors

#### Submitting Data (POST)

**Pattern:**

```dart
// 1. Set up post request with initial data
final requestProvider = Provider.of<RequestProvider>(context, listen: false);
requestProvider.setPostRequest(
  Request(
    key: 'user_form',
    path: '/users',
    postData: {'id': userId, 'name': 'Initial'},  // id: 0 = create, >0 = edit
  ),
);

// 2. Submit (usually triggered by DataInput changes + button press)
requestProvider.submitPostRequest(
  context: context,
  key: 'user_form',
  path: userId == 0 ? '/users' : '/users/$userId',
  showToast: true,                      // Show success toast
  showErrorToast: true,                 // Show error toast
  showErrorToastForAllError: false,     // Show all validation errors (use true if not using DataInput)
  extraParameters: {'extra_field': 'value'},  // Additional params not from DataInput
  onSuccess: (responseData) {
    // Handle success
  },
  onError: (error, requestError) {
    // Handle error
  },
);
```

**Request Errors Enum:**

```dart
enum RequestError {
  noInternetConnection,
  serverDown,
  sessionExpired,
  unhandledServerException,
  unstableInternetConnection,
  invalidParameters,
}
```

**Validation:**

- Automatic via `DataInput` widgets (see below)
- Manual: `requestProvider.isValid(context, 'form_key')`
- Access errors: `requestProvider.getPostRequestErrorProperty('form_key', 'field_name')`

#### DELETE Requests

```dart
await requestProvider.submitDeleteRequest(
  context: context,
  key: 'delete_user',
  id: userId,
  path: '/users/$userId',
  showToast: true,
  onSuccess: (responseData) {
    // Handle success
  },
);
```

#### Offline Behavior

- **GET requests:** Automatically cache to `SharedPreferences`
- **No internet:** Load from cache
- **Server down:** Use cached data, no error toast
- **Unstable connection:** Show toast, use cache if available

---

### 2. Data Input Pattern (Forms)

**`DataInput` is the core form widget** - it automatically binds to `RequestProvider` for validation and submission.

#### Basic Usage

```dart
DataInput(
  requestKey: 'user_form',              // Must match submitPostRequest key
  type: DataInputType.input,            // Input type
  title: 'Full Name',                   // Label
  dataKey: 'name',                      // Maps to postData['name']
  placeholder: 'Enter name',
  isRequired: true,                     // Adds validation automatically
  autoFocus: true,
)
```

#### Data Input Types

```dart
enum DataInputType {
  input,          // Text field
  password,       // Password with visibility toggle
  date,           // Date picker (format: mm/dd/yyyy or yyyy-mm-dd)
  time,           // Time picker (format: hh:mm:ss)
  number,         // Numeric input
  textArea,       // Multiline text
  select,         // Single select dropdown
  multiSelect,    // Multiple select
}
```

#### Complete DataInput Properties

```dart
DataInput(
  // Required
  requestKey: 'form_key',
  type: DataInputType.input,
  title: 'Field Label',
  dataKey: 'field_name',           // Key in postData Map

  // Optional
  errorKey: 'custom_error_key',    // Custom error field (default: dataKey)
  placeholder: 'Hint text',
  disabled: false,                 // Make field read-only
  hidden: false,                   // Hide field
  icon: Icon(Icons.person),        // Prefix icon
  prefixText: '\$',                // Prefix text

  // Formatting
  allCaps: false,                  // UPPERCASE input
  capitalize: false,               // Capitalize Each Word
  capitalizeFirst: false,          // Capitalize first letter
  maxLength: 50,                   // Character limit
  wholeNumbersOnly: false,         // For number type

  // Validation (auto-registers with RequestProvider)
  isRequired: true,                // Required field validation
  requiredLength: 6,               // Exact length validation

  // Select/Dropdown specific
  options: [                       // List of options
    {'id': 1, 'name': 'Option 1'},
    {'id': 2, 'name': 'Option 2'},
  ],
  optionsKey: 'name',             // Display key from option map
  disabledValues: [1, 3],         // Disable specific options
  isInitialValueDisabled: false,  // Disable placeholder option

  // Callbacks
  onSetValue: (value) {           // Called when value changes
    print('Value changed: $value');
  },

  // UI
  isLast: false,                  // Remove bottom padding
  autoFocus: false,
)
```

#### Automatic Validation

DataInput automatically registers validation rules with RequestProvider:

- `isRequired: true` → Validates non-empty
- `requiredLength: n` → Validates exact length
- `type: DataInputType.date` → Validates date format (mm/dd/yyyy or yyyy-mm-dd)
- `type: DataInputType.time` → Validates time format (hh:mm:ss)

Validation runs on `submitPostRequest` and prevents submission if invalid.

---

### 3. Data Modal Pattern

**Standard modal for forms with automatic save handling.**

```dart
// Show modal
showDialog(
  context: context,
  builder: (context) => AppModal(
    child: DataModal(
      requestKey: 'user_form',
      requestPath: userId == 0 ? '/users' : '/users/$userId',
      title: 'User Details',        // Optional: auto-generates from label
      label: 'User',                 // Used for auto-title: "Add User" / "Edit User"
      data: existingUser,            // For edit: {'id': 5, 'name': 'John'}
      closeAfterSave: true,          // Close modal on success
      showToast: true,
      showErrorToastForAllError: false,
      body: Column(
        children: [
          DataInput(requestKey: 'user_form', ...),
          DataInput(requestKey: 'user_form', ...),
        ],
      ),
      onPreSave: () {
        // Called before save
      },
      onDataSaved: (responseData, savedData) {
        // Called after successful save
        // Refresh list or update UI
      },
    ),
  ),
);
```

**DataModal automatically:**

- Creates save button in AppBar
- Shows loading spinner while saving
- Handles save button press
- Validates via DataInput widgets
- Closes modal on success (if closeAfterSave: true)

---

### 4. Data List View Pattern

**Standardized list with pagination, pull-to-refresh, and infinite scroll.**

```dart
DataListView(
  requestKey: 'users_list',
  requestPath: '/users',
  pageSize: 20,
  isInfiniteScroll: true,          // Load more on scroll
  horizontalPadding: 8,
  isItemInCard: true,              // Wrap items in AppCard
  emptyListMessage: 'No users found',

  // Build each item
  onItemBuild: (item, index) {
    return ListTile(
      title: Text(item['name']),
      subtitle: Text(item['email']),
    );
  },

  // Item tap
  onItemPressed: (item) {
    // Navigate or show details
  },

  // Lifecycle callbacks
  onInitialLoad: () {
    // Called before first load
  },
  onRefresh: () async {
    // Called on pull-to-refresh
    // Return Future if you need to do additional work
  },
  onLoaded: () {
    // Called after data loaded
  },

  // Custom empty state
  noResultWidget: Center(
    child: Text('Custom empty state'),
  ),

  // Optional controller for programmatic control
  controller: DataListViewController(),
);
```

**DataListViewController:**

```dart
final controller = DataListViewController();

// Programmatic refresh
controller.refresh(preserveScrollOffset: true);

// Search
controller.search('query text');
```

**DataListView automatically:**

- Fetches data on mount
- Shows loading spinner
- Handles pagination
- Pull-to-refresh
- Infinite scroll
- Empty state
- Error handling

---

### 5. App Scaffold Pattern

**Standard page wrapper with consistent layout.**

```dart
AppScaffold(
  title: 'Page Title',
  titleIcon: 'icon_url',           // Optional icon next to title

  // Action buttons in AppBar
  icons: [Icons.add, Icons.filter],
  actionWidgets: [                  // Alternative to icons
    IconButton(icon: Icon(Icons.add), onPressed: () {}),
  ],
  onActionPressed: (index) {
    // Handle icon tap by index
  },

  // Search
  onSearched: (text) {
    // Handle search input
  },

  // Tabs
  tabs: ['Tab 1', 'Tab 2'],
  onTabChanged: (index) {
    // Handle tab change
  },

  // Middle section (below AppBar)
  middle: Container(
    child: Text('Middle section'),
  ),
  middleBottomSize: 20,             // Spacing below middle
  middlePinned: false,              // Pin middle section on scroll

  // Body
  body: YourPageContent(),

  // Bottom nav bar
  hasBottomNavBar: true,
  isBottomNavBarVisible: true,
  bottomNavBarHeight: 60,
)
```

---

### 6. Authentication Pattern

**AuthProvider manages user state.**

```dart
final authProvider = Provider.of<AuthProvider>(context);

// Login
await authProvider.login(context, {
  'token': 'jwt_token',
  'role_id': 1,                    // Your app's role ID
  'name': 'John Doe',
  // ... other user data (any structure your app needs)
});

// Logout
await authProvider.logout(context);

// Access user data
final user = authProvider.user;       // Full user object
final token = authProvider.token;     // JWT token
final isLoggedIn = authProvider.loggedIn;

// Example: Access user properties
final userName = authProvider.user['name'];
final userRole = authProvider.user['role_id'];
final userEmail = authProvider.user['email'];
```

**Define Your Own Roles:**

Each app should define its own user roles enum:

```dart
// In your app code (not in the library)
enum AppUserRole {
  guest(0),
  user(1),
  moderator(2),
  admin(3),
  superAdmin(4);

  const AppUserRole(this.value);
  final int value;
}

// Use it
if (authProvider.user['role_id'] == AppUserRole.admin.value) {
  // Show admin features
}
```

**AuthProvider automatically:**

- Persists user to SharedPreferences
- Clears requests on login/logout
- Preserves theme on logout
- Initializes with 1 second delay (check `isInitializing`)

---

### 7. Theme Pattern

**ThemeProvider manages light/dark mode.**

```dart
final themeProvider = Provider.of<ThemeProvider>(context);

// Check current mode
final isDark = themeProvider.isDarkMode;

// Toggle theme
await themeProvider.toggleTheme();

// Set explicitly
await themeProvider.setThemeMode(true);  // Dark mode

// Use theme-aware colors
import 'package:laroona_flutter_lib/utils/theme_helper.dart';

Container(
  color: ThemeColors.getBgColor(context),      // Background color
  child: Text(
    'Hello',
    style: TextStyle(
      color: ThemeColors.getTextColor(context), // Text color
    ),
  ),
)
```

**ThemeColors Helper Methods:**

```dart
ThemeColors.getBgColor(context)           // Primary background
ThemeColors.getLayoutBgColor(context)     // Layout background
ThemeColors.getCardColor(context)         // Card background
ThemeColors.getTextColor(context)         // Primary text
ThemeColors.getGrayTextColor(context)     // Secondary text
ThemeColors.getDisabledBorderColor(context)
ThemeColors.getDisabledTextColor(context)
ThemeColors.getHintTextColor(context)
ThemeColors.getStone300Color(context)
ThemeColors.getDividerColor(context)
ThemeColors.getPrimaryColor(context)      // Brand color
ThemeColors.isDark(context)               // Boolean check
```

---

## 🎨 Styling System

### Color Customization

The library provides a flexible color system with full light/dark theme support. All colors are exported and can be accessed by users of the library.

Import: `import 'package:laroona_flutter_lib/laroona_flutter_lib.dart';`

#### Customizing Primary Brand Color

Set your app's primary brand color using `setThemeColor()`:

```dart
// In main.dart before runApp()
void main() {
  setThemeColor('#1890ff');  // Your brand color (hex format with #)
  runApp(MyApp());
}

// Or dynamically (e.g., user selects theme color in settings)
void _updateBrandColor(String colorHex) {
  setThemeColor(colorHex);
  setState(() {});  // Rebuild to apply changes
}

// Reset to default green
setThemeColor(null);  // or setThemeColor('')

// Access the current primary color
Color myPrimaryColor = primaryColor;
```

**Default Primary Color:** `#52c41a` (green)

#### Customizing Background Colors

Customize the main background colors for light and dark themes:

```dart
// In main.dart before runApp()
void main() {
  // Light mode backgrounds
  setPrimaryBgColor('#e6f7ff');    // Primary background (default: #f6ffed)
  setBgLayoutColor('#f0f2f5');     // Layout background (default: #f5f5f4)

  // Dark mode backgrounds
  setDarkPrimaryBgColor('#0d1117'); // Dark primary background (default: #0f1419)
  setDarkBgLayoutColor('#161b22');  // Dark layout background (default: #1a1f26)

  runApp(MyApp());
}

// Or dynamically
void _updateBackgroundColors() {
  setPrimaryBgColor('#e6f4ff');
  setBgLayoutColor('#f5f5f5');
  setDarkPrimaryBgColor('#0a0e14');
  setDarkBgLayoutColor('#151a1f');
  setState(() {});  // Rebuild to apply changes
}

// Reset to defaults
setPrimaryBgColor(null);           // or setPrimaryBgColor('')
setBgLayoutColor(null);
setDarkPrimaryBgColor(null);
setDarkBgLayoutColor(null);

// Access current colors
Color lightBg = primaryBgColor;
Color layoutBg = bgLayoutColor;
Color darkBg = darkPrimaryBgColor;
Color darkLayout = darkBgLayoutColor;
```

**Use Cases:**

- **Consistent brand theme:** Match backgrounds to your brand colors
- **User preferences:** Let users choose light/soft backgrounds
- **Organization branding:** Different backgrounds per tenant
- **Accessibility:** Adjust backgrounds for better contrast

#### Available Color Constants

**Light Theme Colors:**

```dart
// Backgrounds
primaryBgColor        // Color(0xfff6ffed) - Light green tint
bgLayoutColor         // Color(0xfff5f5f4) - Light gray
Colors.white          // Card backgrounds

// Text
darkTextColor         // Color(0xff30455e) - Primary dark text
grayTextColor         // Color(0xff898989) - Secondary gray text
hintTextColor         // Color(0xff919599) - Input hints

// Borders & Disabled States
disabledBorderColor   // Color(0xffe0dddd) - Disabled borders
disabledTextColor     // Color(0xffb6b5bc) - Disabled text
dividerColor          // Color(0xffd3d3d3) - Dividers/separators
stone300Color         // Color(0xffd6d3d1) - Subtle borders
```

**Dark Theme Colors:**

```dart
// Backgrounds
darkPrimaryBgColor    // Color(0xff0f1419) - Dark background
darkBgLayoutColor     // Color(0xff1a1f26) - Dark layout
darkCardColor         // Color(0xff1e2329) - Dark card background

// Text
darkDarkTextColor     // Color(0xffe3e8ef) - Primary light text
darkGrayTextColor     // Color(0xffd5dce3) - Secondary light text
darkHintTextColor     // Color(0xff8b95a1) - Dark mode hints

// Borders & Disabled States
darkDisabledBorderColor  // Color(0xff2d3339)
darkDisabledTextColor    // Color(0xff6b7280)
darkDividerColor         // Color(0xff2d3339)
darkStone300Color        // Color(0xff374151)
```

#### Using Colors in Your Code

**Direct Usage (not recommended):**

```dart
Container(
  color: primaryBgColor,  // Works, but won't adapt to theme
  child: Text('Hello', style: TextStyle(color: darkTextColor)),
)
```

**Theme-Aware Usage (recommended):**

```dart
import 'package:laroona_flutter_lib/laroona_flutter_lib.dart';

Container(
  color: ThemeColors.getBgColor(context),         // Adapts to light/dark
  child: Text(
    'Hello',
    style: TextStyle(
      color: ThemeColors.getTextColor(context),   // Adapts to light/dark
    ),
  ),
)
```

#### ThemeColors Helper Methods

All helper methods automatically return the correct color based on the current theme:

```dart
// Background Colors
ThemeColors.getBgColor(context)           // Primary background (light green or dark)
ThemeColors.getLayoutBgColor(context)     // Layout background
ThemeColors.getCardColor(context)         // Card background (white or dark card)

// Text Colors
ThemeColors.getTextColor(context)         // Primary text color
ThemeColors.getGrayTextColor(context)     // Secondary/muted text
ThemeColors.getHintTextColor(context)     // Placeholder/hint text

// UI Element Colors
ThemeColors.getPrimaryColor(context)      // Your brand color (or white in dark mode)
ThemeColors.getDividerColor(context)      // Divider lines
ThemeColors.getStone300Color(context)     // Subtle borders/backgrounds

// Disabled States
ThemeColors.getDisabledBorderColor(context)
ThemeColors.getDisabledTextColor(context)

// Theme Check
ThemeColors.isDark(context)               // Returns bool
```

#### Example: Customizing Colors

**Scenario 1: App with custom brand color**

```dart
void main() {
  setThemeColor('#e91e63');  // Pink brand color
  runApp(MyApp());
}
```

**Scenario 2: User selects brand color**

```dart
class SettingsPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ColorPicker(
          onColorSelected: (colorHex) {
            setThemeColor(colorHex);
            setState(() {});  // Rebuild to show changes
          },
        ),
      ],
    );
  }
}
```

**Scenario 3: Different colors per tenant/organization**

```dart
void main() async {
  final orgSettings = await fetchOrgSettings();
  setThemeColor(orgSettings['brand_color']);  // e.g., '#ff5722'
  runApp(MyApp());
}
```

### Dimensions

Import: `import 'package:laroona_flutter_lib/resources/dimensions.dart';`

**Font Sizes:**

- `inputFontSize` (16)
- `fontSizeLarge` (38)
- `appBarFontSize` (18)
- `listItemTitleFontSize` (18)
- `listItemSubtitleFontSize` (16)
- `tagFontSize` (12)
- `detailsTitleFontSize` (18)

**Padding:**

- `paddingSizeXXXXSmall` (2) → `paddingSizeXXXLarge` (80)
- `paddingSizeSmall` (16) - Common default
- `pagePaddingSize` (8) - Page padding

**Radius:**

- `radiusSizeSmall` (4)
- `radiusSize` (8)
- `cardRadiusSize` (8)

**Icons:**

- `iconSizeXSmall` (12) → `iconSizeXLarge` (48)
- `iconSize` (24) - Common default
- `iconContainerSize` (48)

**Web:**

- `webMaxWidth` (1200)
- `webMaxWidthLarge` (1400)
- `webMaxWidthSmall` (1000)

---

## 🛠️ Utility Functions

### Date Helper

Import: `import 'package:laroona_flutter_lib/utils/date_helper.dart';`

```dart
// Parse dates
DateTime? date = toDateTime('2024-01-15T10:30:00Z');
DateTime? utcDate = toUtcDateTime('2024-01-15 10:30:00');

// Format dates
String formatted = toFullDateTimeFormat('2024-01-15T10:30:00Z');
// → "Mon Jan 15 2024 10:30 AM"

String dateOnly = toFullDateFormatFromDate(DateTime.now());
// → "Mon Jan 15 2024"

String sqlFormat = toSqlDateTime(DateTime.now());
// → "2024-01-15 10:30:45"

String defaultFormat = toDefaultDateFormat('2024-01-15T10:30:00Z');
// → "2024-01-15"

// Format constants
const fullDateFormat = 'E MMM dd yyyy';
const fullDateTimeFormat = 'E MMM dd yyyy h:mm a';
const defaultDateFormat = 'yyyy-MM-dd';
const defaultTimeFormat = "h:mm:ss a";
const sqlDateTimeFormat = "yyyy-MM-dd HH:mm:ss";
```

---

## 🧩 Common Widget Reference

### LoadingButton

```dart
LoadingButton(
  text: 'Save',
  isLoading: isLoading,
  style: LoadingButtonStyle.primary,  // or .white
  compact: false,                      // Smaller version
  onPressed: () {
    // Handle press
  },
)
```

### AppCard

```dart
AppCard(
  padding: EdgeInsets.all(16),
  child: YourContent(),
)
```

### DetailsCard

```dart
DetailsCard(
  title: 'User Details',
  items: [
    {'label': 'Name', 'value': 'John Doe'},
    {'label': 'Email', 'value': 'john@example.com'},
  ],
)
```

### DetailsItem

```dart
DetailsItem(
  label: 'Email',
  value: 'john@example.com',
  icon: Icons.email,
)
```

### Dropdown

```dart
Dropdown(
  items: ['Option 1', 'Option 2', 'Option 3'],
  value: selectedValue,
  onChanged: (value) {
    setState(() => selectedValue = value);
  },
  hint: 'Select option',
)
```

### LoadingSpinner

```dart
LoadingSpinner()  // Centered circular progress indicator
```

### PasswordTextField

```dart
PasswordTextField(
  controller: passwordController,
  labelText: 'Password',
  onChanged: (value) {},
)
```

### SectionHeader

```dart
SectionHeader(
  title: 'Section Title',
  icon: Icons.info,
)
```

---

## 📋 Expected API Response Format

The library expects specific response formats from your backend:

### GET Requests (Paginated)

```json
{
  "data": {
    "current_page": 1,
    "last_page": 5,
    "total": 100,
    "clocked": 50, // Optional
    "total_live": 75, // Optional
    "data": [
      { "id": 1, "name": "Item 1" },
      { "id": 2, "name": "Item 2" }
    ]
  }
}
```

### GET Requests (Non-paginated)

```json
{
  "data": {
    "total": 10,
    "data": [{ "id": 1, "name": "Item 1" }]
  }
}
```

### GET Single Object

```json
{
  "data": {
    "id": 1,
    "name": "Item 1",
    "details": "..."
  }
}
```

### POST Success

```json
{
  "data": {
    "id": 1,
    "name": "Created Item"
  },
  "success_message": "Item created successfully" // Optional (shown in toast)
}
```

### POST/DELETE Error (Validation)

```json
{
  "error": {
    "field_name": ["Error message 1", "Error message 2"],
    "another_field": "Single error message"
  }
}
```

### POST/DELETE Error (General)

```json
{
  "error": "Something went wrong message"
}
```

### Session Expired

```json
{
  "message": "Unauthenticated"
}
```

This triggers automatic logout.

---

## 🔐 Authentication Flow

### Login Flow

1. Call API to get user data and token
2. Call `authProvider.login(context, userData)`
3. User data validated (must not be null)
4. User data saved to SharedPreferences
5. RequestProvider cleared
6. Navigate to home

**Note:** The library doesn't enforce specific role validation. Implement your own role checks in your app based on your user structure.

### Logout Flow

1. Call `authProvider.logout(context)`
2. SharedPreferences cleared (except theme)
3. RequestProvider cleared
4. Navigate to login

### Request Authentication

- All requests automatically include `Authorization: Bearer {token}` header if logged in
- Token retrieved from `authProvider.token`

---

## 💡 Code Generation Tips for AI

### When Creating a New Page

1. **Wrap with AppScaffold:**

```dart
class MyPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Page Title',
      body: PageContent(),
    );
  }
}
```

2. **Use DataListView for lists:**

```dart
body: DataListView(
  requestKey: 'my_list',
  requestPath: '/endpoint',
  onItemBuild: (item, index) => YourListItem(item),
)
```

3. **Use DataModal for forms:**

```dart
// Show modal button
onPressed: () {
  showDialog(
    context: context,
    builder: (_) => AppModal(
      child: DataModal(
        requestKey: 'my_form',
        requestPath: '/endpoint',
        label: 'Item',
        body: Column(
          children: [
            DataInput(...),
            DataInput(...),
          ],
        ),
        onDataSaved: (_, __) {
          // Refresh list
        },
      ),
    ),
  );
}
```

4. **Always use DataInput in forms:**

```dart
DataInput(
  requestKey: 'form_key',
  type: DataInputType.input,
  title: 'Field Name',
  dataKey: 'api_field',
  isRequired: true,
)
```

5. **Use ThemeColors for colors:**

```dart
color: ThemeColors.getCardColor(context)
```

6. **Follow VIBE_RULES patterns:**

- Never manually call `submitPostRequest` - DataModal handles it
- DataInput automatically handles validation
- Use `request_provider` for all API state
- Success/error messages should come from API

### When User Asks for a Form

**Generate this pattern:**

```dart
// Modal trigger
IconButton(
  icon: Icon(Icons.add),
  onPressed: () {
    showDialog(
      context: context,
      builder: (_) => AppModal(
        child: DataModal(
          requestKey: 'form_key',
          requestPath: '/api/endpoint',
          label: 'Item',
          data: editMode ? existingItem : null,
          body: Column(
            children: [
              DataInput(
                requestKey: 'form_key',
                type: DataInputType.input,
                title: 'Name',
                dataKey: 'name',
                isRequired: true,
              ),
              DataInput(
                requestKey: 'form_key',
                type: DataInputType.select,
                title: 'Category',
                dataKey: 'category_id',
                options: categories,
                optionsKey: 'name',
                isRequired: true,
              ),
              DataInput(
                requestKey: 'form_key',
                type: DataInputType.date,
                title: 'Date',
                dataKey: 'date',
                isRequired: true,
              ),
            ],
          ),
          onDataSaved: (responseData, savedData) {
            // Refresh parent list or update UI
            listController.refresh();
          },
        ),
      ),
    );
  },
)
```

### When User Asks for a List Page

**Generate this pattern:**

```dart
class MyListPage extends StatefulWidget {
  @override
  State<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  final _listController = DataListViewController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'My List',
      icons: [Icons.add],
      onActionPressed: (index) {
        if (index == 0) {
          // Show add modal (see form pattern above)
        }
      },
      body: DataListView(
        requestKey: 'my_list',
        requestPath: '/api/items',
        pageSize: 20,
        controller: _listController,
        onItemBuild: (item, index) {
          return AppCard(
            child: ListTile(
              title: Text(item['name']),
              subtitle: Text(item['description']),
              trailing: Icon(Icons.chevron_right),
            ),
          );
        },
        onItemPressed: (item) {
          // Navigate to details or show edit modal
        },
      ),
    );
  }
}
```

---

## 🚨 Common Pitfalls

1. **Don't forget required requestKey:** All DataInput, DataModal, DataListView need it
2. **Match requestKey across components:** Form modal and submit must use same key
3. **postData['id']:** `id: 0` = create, `id > 0` = update (convention)
4. **ThemeColors in all color references:** Don't hardcode colors
5. **Provider.of with listen: false** when calling methods (avoid rebuilds)
6. **Check context.mounted** before async operations that use context
7. **DataInput types:** Use correct type for automatic validation (date, time)
8. **API response format:** Backend must return expected JSON structure
9. **Define your own roles:** Create your own UserRole enum in your app, not in the library

---

## 📚 Dependencies (Auto-included)

- `provider` - State management
- `dio` - HTTP client
- `connectivity_plus` - Network status
- `shared_preferences` - Local storage
- `toastification` - Toast notifications
- `go_router_plus` - Routing
- `intl` - Date formatting
- `pull_to_refresh` - Pull to refresh
- `dropdown_button2` - Dropdown widgets
- `persistent_bottom_nav_bar` - Bottom navigation
- `mobile_scanner` - QR/barcode scanning

---

## 🎓 Learning Path for New AI Agent

1. Read this document thoroughly
2. Understand RequestProvider pattern (section 1)
3. Understand DataInput auto-binding (section 2)
4. Study complete patterns: List Page + Form Modal
5. Reference VIBE_RULES.md for original project context
6. Check widget source for advanced props

---

## 📝 Quick Reference Card

```dart
// Import library
import 'package:laroona_flutter_lib/laroona_flutter_lib.dart';

// Setup providers (main.dart)
RequestProvider(apiBaseUrl: 'https://api.com/api/')
AuthProvider()
ThemeProvider()

// Customize colors (optional, in main() before runApp)
setThemeColor('#1890ff')           // Brand color
setPrimaryBgColor('#e6f7ff')       // Light mode primary background
setBgLayoutColor('#f0f2f5')        // Light mode layout background
setDarkPrimaryBgColor('#0d1117')   // Dark mode primary background
setDarkBgLayoutColor('#161b22')    // Dark mode layout background

// Access current colors
primaryColor              // Get current primary color
primaryBgColor           // Get light primary background
bgLayoutColor            // Get light layout background
darkPrimaryBgColor       // Get dark primary background
darkBgLayoutColor        // Get dark layout background

// Standard page
AppScaffold(title: '...', body: ...)

// List
DataListView(requestKey: '...', requestPath: '...', onItemBuild: ...)

// Form
AppModal(child: DataModal(requestKey: '...', body: Column(children: [DataInput(...)])))

// Input
DataInput(requestKey: '...', type: ..., title: '...', dataKey: '...', isRequired: true)

// Fetch data
requestProvider.fetchRequest(context, key: '...', path: '...', ...)

// Submit data
requestProvider.submitPostRequest(context: context, key: '...', path: '...', ...)

// Theme-aware colors (auto light/dark)
ThemeColors.getBgColor(context)
ThemeColors.getCardColor(context)
ThemeColors.getTextColor(context)
ThemeColors.getPrimaryColor(context)

// Date format
toFullDateTimeFormat(dateString)

// Auth
authProvider.login(context, userData)
authProvider.logout(context)
authProvider.loggedIn
```

---

**This document should give you everything needed to use this library without reading source code. For edge cases or advanced usage, refer to the actual widget implementations.**
