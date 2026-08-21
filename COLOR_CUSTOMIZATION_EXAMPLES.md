# Color Customization Examples

This guide shows you how to customize colors in your app using the Laroona Flutter Library.

## Basic Setup

### Setting Your Brand Color

Set your brand color in `main.dart` before running the app:

```dart
import 'package:laroona_flutter_lib/laroona_flutter_lib.dart';

void main() {
  // Set your brand color (hex format with #)
  setThemeColor('#1890ff');  // Blue

  runApp(MyApp());
}
```

**Popular Brand Colors:**

```dart
setThemeColor('#1890ff');  // Blue (Ant Design)
setThemeColor('#e91e63');  // Pink (Material Design)
setThemeColor('#9c27b0');  // Purple
setThemeColor('#ff5722');  // Deep Orange
setThemeColor('#4caf50');  // Green
setThemeColor('#ff9800');  // Orange
setThemeColor('#00bcd4');  // Cyan
```

### Reset to Default

```dart
setThemeColor(null);   // Resets to default green (#52c41a)
// or
setThemeColor('');
```

### Setting Background Colors

Customize background colors for both light and dark modes:

```dart
import 'package:laroona_flutter_lib/laroona_flutter_lib.dart';

void main() {
  // Brand color
  setThemeColor('#1890ff');

  // Light mode backgrounds
  setPrimaryBgColor('#e6f7ff');    // Light blue tint (default: #f6ffed)
  setBgLayoutColor('#f0f2f5');     // Light gray layout (default: #f5f5f4)

  // Dark mode backgrounds
  setDarkPrimaryBgColor('#0d1117'); // GitHub-style dark (default: #0f1419)
  setDarkBgLayoutColor('#161b22');  // Darker layout (default: #1a1f26)

  runApp(MyApp());
}
```

**Popular Background Color Schemes:**

```dart
// Minimal White/Black
setPrimaryBgColor('#ffffff');
setBgLayoutColor('#fafafa');
setDarkPrimaryBgColor('#000000');
setDarkBgLayoutColor('#0a0a0a');

// Warm Gray
setPrimaryBgColor('#faf9f7');
setBgLayoutColor('#f5f3f0');
setDarkPrimaryBgColor('#1c1917');
setDarkBgLayoutColor('#292524');

// Cool Blue (like Twitter)
setPrimaryBgColor('#f7f9f9');
setBgLayoutColor('#eff3f4');
setDarkPrimaryBgColor('#15202b');
setDarkBgLayoutColor('#192734');

// Soft Green
setPrimaryBgColor('#f0fdf4');
setBgLayoutColor('#f7fee7');
setDarkPrimaryBgColor('#052e16');
setDarkBgLayoutColor('#14532d');

// Reset all to defaults
setPrimaryBgColor(null);
setBgLayoutColor(null);
setDarkPrimaryBgColor(null);
setDarkBgLayoutColor(null);
```

---

## Using Colors in Your App

### Theme-Aware Colors (Recommended)

These automatically adapt to light/dark mode:

```dart
import 'package:laroona_flutter_lib/laroona_flutter_lib.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Background adapts to light/dark theme
      color: ThemeColors.getBgColor(context),

      child: Card(
        // Card color adapts (white in light, dark gray in dark mode)
        color: ThemeColors.getCardColor(context),

        child: Column(
          children: [
            Text(
              'Title',
              style: TextStyle(
                color: ThemeColors.getTextColor(context),  // Primary text
                fontSize: 18,
              ),
            ),
            Text(
              'Subtitle',
              style: TextStyle(
                color: ThemeColors.getGrayTextColor(context),  // Secondary text
                fontSize: 14,
              ),
            ),
            Divider(
              color: ThemeColors.getDividerColor(context),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Using Your Brand Color

```dart
// Primary button with brand color
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryColor,  // Your brand color
  ),
  child: Text('Submit'),
  onPressed: () {},
)

// Or use ThemeColors.getPrimaryColor (adapts to theme)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: ThemeColors.getPrimaryColor(context),
  ),
  child: Text('Submit'),
  onPressed: () {},
)
```

### Direct Color Usage

You can also use colors directly (but they won't adapt to theme):

```dart
import 'package:laroona_flutter_lib/laroona_flutter_lib.dart';

Container(
  color: primaryBgColor,        // Light green background
  // or
  color: darkPrimaryBgColor,    // Dark background
)
```

---

## Complete Color Reference

### ThemeColors Helper Methods

| Method                                        | Light Mode Returns | Dark Mode Returns |
| --------------------------------------------- | ------------------ | ----------------- |
| `ThemeColors.getBgColor(context)`             | Light green tint   | Dark background   |
| `ThemeColors.getLayoutBgColor(context)`       | Light gray         | Darker gray       |
| `ThemeColors.getCardColor(context)`           | White              | Dark card         |
| `ThemeColors.getTextColor(context)`           | Dark blue          | Light text        |
| `ThemeColors.getGrayTextColor(context)`       | Gray               | Light gray        |
| `ThemeColors.getHintTextColor(context)`       | Hint gray          | Dark hint         |
| `ThemeColors.getPrimaryColor(context)`        | Brand color        | White             |
| `ThemeColors.getDividerColor(context)`        | Light divider      | Dark divider      |
| `ThemeColors.getDisabledBorderColor(context)` | Light border       | Dark border       |
| `ThemeColors.getDisabledTextColor(context)`   | Disabled gray      | Disabled light    |
| `ThemeColors.getStone300Color(context)`       | Stone gray         | Dark stone        |
| `ThemeColors.isDark(context)`                 | `false`            | `true`            |

---

## Advanced Examples

### Dynamic Color Selection

Allow users to select their preferred color:

```dart
class ColorSettings extends StatefulWidget {
  @override
  State<ColorSettings> createState() => _ColorSettingsState();
}

class _ColorSettingsState extends State<ColorSettings> {
  final List<String> brandColors = [
    '#52c41a',  // Default Green
    '#1890ff',  // Blue
    '#e91e63',  // Pink
    '#9c27b0',  // Purple
    '#ff5722',  // Orange
    '#00bcd4',  // Cyan
  ];

  String selectedColor = '#52c41a';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Choose Brand Color'),
        Wrap(
          spacing: 8,
          children: brandColors.map((colorHex) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = colorHex;
                  setThemeColor(colorHex);
                });

                // Save to preferences
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString('brand_color', colorHex);
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == colorHex ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
```

### Complete Theme Customization

Allow users to customize the entire color scheme (brand color + backgrounds):

```dart
class ThemeCustomizationSettings extends StatefulWidget {
  @override
  State<ThemeCustomizationSettings> createState() => _ThemeCustomizationSettingsState();
}

class _ThemeCustomizationSettingsState extends State<ThemeCustomizationSettings> {
  // Predefined color schemes
  final List<Map<String, String>> colorSchemes = [
    {
      'name': 'Default Green',
      'primary': '#52c41a',
      'lightBg': '#f6ffed',
      'lightLayout': '#f5f5f4',
      'darkBg': '#0f1419',
      'darkLayout': '#1a1f26',
    },
    {
      'name': 'Ocean Blue',
      'primary': '#1890ff',
      'lightBg': '#e6f7ff',
      'lightLayout': '#f0f5ff',
      'darkBg': '#0a1929',
      'darkLayout': '#132f4c',
    },
    {
      'name': 'Sunset Orange',
      'primary': '#ff5722',
      'lightBg': '#fff3e0',
      'lightLayout': '#ffe0b2',
      'darkBg': '#1a1310',
      'darkLayout': '#2d1f1a',
    },
    {
      'name': 'Royal Purple',
      'primary': '#9c27b0',
      'lightBg': '#f3e5f5',
      'lightLayout': '#e1bee7',
      'darkBg': '#1a0f1e',
      'darkLayout': '#2d1b35',
    },
  ];

  String selectedScheme = 'Default Green';

  void applyColorScheme(Map<String, String> scheme) {
    setThemeColor(scheme['primary']);
    setPrimaryBgColor(scheme['lightBg']);
    setBgLayoutColor(scheme['lightLayout']);
    setDarkPrimaryBgColor(scheme['darkBg']);
    setDarkBgLayoutColor(scheme['darkLayout']);

    // Save to preferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('primary_color', scheme['primary']!);
      prefs.setString('light_bg', scheme['lightBg']!);
      prefs.setString('light_layout', scheme['lightLayout']!);
      prefs.setString('dark_bg', scheme['darkBg']!);
      prefs.setString('dark_layout', scheme['darkLayout']!);
    });

    setState(() {
      selectedScheme = scheme['name']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Color Scheme',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ...colorSchemes.map((scheme) {
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse(scheme['primary']!.substring(1), radix: 16) + 0xFF000000),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Text(scheme['name']!),
              subtitle: Text('Primary: ${scheme['primary']}'),
              trailing: selectedScheme == scheme['name']
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () => applyColorScheme(scheme),
            ),
          );
        }).toList(),
      ],
    );
  }
}
```

### Loading Colors from Storage

```dart
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved colors
  final prefs = await SharedPreferences.getInstance();

  // Load and apply all saved colors
  final savedPrimaryColor = prefs.getString('primary_color');
  final savedLightBg = prefs.getString('light_bg');
  final savedLightLayout = prefs.getString('light_layout');
  final savedDarkBg = prefs.getString('dark_bg');
  final savedDarkLayout = prefs.getString('dark_layout');

  if (savedPrimaryColor != null) setThemeColor(savedPrimaryColor);
  if (savedLightBg != null) setPrimaryBgColor(savedLightBg);
  if (savedLightLayout != null) setBgLayoutColor(savedLightLayout);
  if (savedDarkBg != null) setDarkPrimaryBgColor(savedDarkBg);
  if (savedDarkLayout != null) setDarkBgLayoutColor(savedDarkLayout);

  runApp(MyApp());
}
```

### Organization-Specific Branding

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fetch organization settings from API
  final orgSettings = await fetchOrganizationSettings();

  // Apply organization's complete color scheme
  setThemeColor(orgSettings['brand_color']);
  setPrimaryBgColor(orgSettings['light_bg']);
  setBgLayoutColor(orgSettings['light_layout']);
  setDarkPrimaryBgColor(orgSettings['dark_bg']);
  setDarkBgLayoutColor(orgSettings['dark_layout']);

  runApp(MyApp());
}
```

### Custom Color Scheme

If you want to completely customize the color scheme:

```dart
// Create your own colors in your app
class MyColors {
  static const primary = Color(0xff1890ff);
  static const secondary = Color(0xfff5222d);
  static const success = Color(0xff52c41a);
  static const warning = Color(0xfffaad14);
  static const error = Color(0xfff5222d);
}

// Use them with ThemeColors for theme awareness
Container(
  color: ThemeColors.getCardColor(context),  // Use library's card color
  child: Row(
    children: [
      Icon(Icons.check, color: MyColors.success),  // Your custom color
      Text(
        'Success',
        style: TextStyle(color: ThemeColors.getTextColor(context)),  // Library text color
      ),
    ],
  ),
)
```

---

## Best Practices

1. **Use ThemeColors helpers** for most UI elements - they automatically adapt to light/dark mode
2. **Set brand color once** in `main()` before `runApp()`
3. **Save user preferences** to SharedPreferences for persistence
4. **Test both themes** - Always check light and dark mode when customizing
5. **Avoid hardcoding colors** - Use the provided constants or ThemeColors helpers
6. **Brand color for accents** - Use `primaryColor` for buttons, highlights, and brand elements
7. **Theme-aware for backgrounds/text** - Use ThemeColors helpers for backgrounds and text

---

## Troubleshooting

**Q: My color isn't updating after `setThemeColor()`**

A: Call `setState(() {})` in the widget that needs to rebuild, or restart the app if set in `main()`.

**Q: Colors look different in light vs dark mode**

A: Use `ThemeColors` helpers instead of direct color constants. They automatically return the correct color for the current theme.

**Q: Can I use gradients?**

A: Yes! Create gradients using `primaryColor` and other colors:

```dart
decoration: BoxDecoration(
  gradient: LinearGradient(
    colors: [primaryColor, primaryColor.withOpacity(0.7)],
  ),
)
```

**Q: How do I know current theme mode?**

A: Use `ThemeColors.isDark(context)` or check `Theme.of(context).brightness == Brightness.dark`

---

For more details, see the [main documentation](laroona-flutter-lib-readme.md).
