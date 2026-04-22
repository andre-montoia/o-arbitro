# O Árbitro — Scaffold & Design System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap the Flutter project with a fully working navigable app shell, all design tokens, and every reusable UI component defined in the design system spec.

**Architecture:** A single Flutter codebase (iOS + Android) using a centralised `AppTheme` class for all tokens. Components live in `lib/ui/components/`. Screens are thin shells that use components — no business logic yet. Firebase is configured but not used until Plan 5.

**Tech Stack:** Flutter 3.x, Dart, Firebase (config only), Rive, phosphor_flutter, Google Fonts (Syne + Space Grotesk bundled as assets)

---

## File Map

```
o-arbitro/
├── pubspec.yaml                          # dependencies + font assets
├── assets/
│   └── fonts/
│       ├── Syne-Bold.ttf
│       ├── Syne-ExtraBold.ttf
│       ├── SpaceGrotesk-Regular.ttf
│       ├── SpaceGrotesk-Medium.ttf
│       └── SpaceGrotesk-Bold.ttf
├── lib/
│   ├── main.dart                         # app entry point, theme wiring
│   ├── ui/
│   │   ├── theme/
│   │   │   ├── app_colors.dart           # all colour tokens as constants
│   │   │   ├── app_text_styles.dart      # all text style definitions
│   │   │   ├── app_spacing.dart          # spacing tokens
│   │   │   └── app_theme.dart            # ThemeData factory
│   │   ├── components/
│   │   │   ├── arbitro_button.dart       # Primary / Secondary / Ghost / Destructive
│   │   │   ├── glass_card.dart           # Default / Highlighted / Gold / Danger variants
│   │   │   ├── arbitro_badge.dart        # Tag/badge with colour variants
│   │   │   ├── arbitro_input.dart        # Text input with focus state
│   │   │   └── bottom_sheet_handle.dart  # Reusable modal handle
│   │   └── screens/
│   │       ├── lobby_screen.dart         # Grid Destacado layout
│   │       ├── slots_screen.dart         # Placeholder shell
│   │       ├── roulette_screen.dart      # Placeholder shell
│   │       └── ledger_screen.dart        # Placeholder shell
│   └── navigation/
│       └── app_router.dart               # Bottom nav + route definitions
├── test/
│   ├── ui/
│   │   ├── components/
│   │   │   ├── arbitro_button_test.dart
│   │   │   ├── glass_card_test.dart
│   │   │   └── arbitro_badge_test.dart
│   │   └── screens/
│   │       └── lobby_screen_test.dart
```

---

### Task 1: Flutter Project Init + pubspec

**Files:**
- Create: `pubspec.yaml`
- Create: `assets/fonts/` (download fonts)

- [ ] **Step 1: Create Flutter project**

```bash
cd /root/o-arbitro
flutter create . --org pt.oarbitro --project-name o_arbitro --platforms android,ios
```

Expected output: `All done! Your project is now ready.`

- [ ] **Step 2: Download fonts**

```bash
mkdir -p assets/fonts
cd assets/fonts
# Syne
curl -L "https://fonts.google.com/download?family=Syne" -o syne.zip && unzip -j syne.zip "*.ttf" && rm syne.zip
# Space Grotesk
curl -L "https://fonts.google.com/download?family=Space+Grotesk" -o sg.zip && unzip -j sg.zip "*.ttf" && rm sg.zip
ls *.ttf
```

Expected: `Syne-Bold.ttf  Syne-ExtraBold.ttf  SpaceGrotesk-Regular.ttf  SpaceGrotesk-Medium.ttf  SpaceGrotesk-Bold.ttf` (plus other weights — that's fine)

- [ ] **Step 3: Replace pubspec.yaml**

```yaml
name: o_arbitro
description: O Árbitro — O destino decide.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  phosphor_flutter: ^2.1.0
  rive: ^0.12.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/fonts/

  fonts:
    - family: Syne
      fonts:
        - asset: assets/fonts/Syne-Bold.ttf
          weight: 700
        - asset: assets/fonts/Syne-ExtraBold.ttf
          weight: 800
    - family: SpaceGrotesk
      fonts:
        - asset: assets/fonts/SpaceGrotesk-Regular.ttf
          weight: 400
        - asset: assets/fonts/SpaceGrotesk-Medium.ttf
          weight: 500
        - asset: assets/fonts/SpaceGrotesk-Bold.ttf
          weight: 700
```

- [ ] **Step 4: Fetch dependencies**

```bash
flutter pub get
```

Expected: `Got dependencies!`

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock assets/
git commit -m "feat: init Flutter project with fonts and dependencies"
```

---

### Task 2: Colour Tokens

**Files:**
- Create: `lib/ui/theme/app_colors.dart`
- Test: `test/ui/theme/app_colors_test.dart`

- [ ] **Step 1: Write the failing test**

```bash
mkdir -p test/ui/theme
cat > test/ui/theme/app_colors_test.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';

void main() {
  test('bg primary is midnight navy', () {
    expect(AppColors.bgPrimary, const Color(0xFF0D0D1A));
  });

  test('purple brand colour', () {
    expect(AppColors.purple, const Color(0xFF7C3AED));
  });

  test('gradient primary has two stops', () {
    expect(AppColors.gradientPrimary.colors.length, 2);
    expect(AppColors.gradientPrimary.colors.first, const Color(0xFF7C3AED));
    expect(AppColors.gradientPrimary.colors.last, const Color(0xFFEC4899));
  });
}
EOF
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/ui/theme/app_colors_test.dart
```

Expected: FAIL — `app_colors.dart` not found

- [ ] **Step 3: Implement AppColors**

```bash
mkdir -p lib/ui/theme
cat > lib/ui/theme/app_colors.dart << 'EOF'
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Base
  static const Color bgPrimary   = Color(0xFF0D0D1A);
  static const Color surface     = Color(0xFF13132A);
  static const Color surface2    = Color(0xFF1E1E3A);
  static const Color border      = Color(0x33A855F7); // rgba(168,85,247,0.2)

  // Brand
  static const Color purple      = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFA855F7);
  static const Color pink        = Color(0xFFEC4899);

  // Semantic
  static const Color gold        = Color(0xFFF59E0B);
  static const Color success     = Color(0xFF10B981);
  static const Color danger      = Color(0xFFEF4444);

  // Text
  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textMuted    = Color(0xFFA0A0C0);
  static const Color textDisabled = Color(0xFF555577);

  // Gradients
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, pink],
  );

  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, Color(0xFFFBBF24)],
  );

  // Glass fills (semi-transparent)
  static const Color glassFill   = Color(0x147C3AED); // rgba(124,58,237,0.08)
  static const Color glassBorder = Color(0x33A855F7); // rgba(168,85,247,0.2)
}
EOF
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/ui/theme/app_colors_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/ui/theme/app_colors.dart test/ui/theme/app_colors_test.dart
git commit -m "feat: add AppColors design tokens"
```

---

### Task 3: Spacing Tokens

**Files:**
- Create: `lib/ui/theme/app_spacing.dart`

- [ ] **Step 1: Create spacing tokens**

```bash
cat > lib/ui/theme/app_spacing.dart << 'EOF'
abstract final class AppSpacing {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 24;
  static const double xxl  = 32;

  static const double screenPadding = lg;
  static const double cardPadding   = lg;
  static const double sectionGap    = xl;
  static const double cardRadius    = 12;
  static const double buttonRadius  = 100;
  static const double inputRadius   = 10;
  static const double modalRadius   = 20;
}
EOF
```

- [ ] **Step 2: Commit**

```bash
git add lib/ui/theme/app_spacing.dart
git commit -m "feat: add AppSpacing tokens"
```

---

### Task 4: Text Styles

**Files:**
- Create: `lib/ui/theme/app_text_styles.dart`
- Test: `test/ui/theme/app_text_styles_test.dart`

- [ ] **Step 1: Write the failing test**

```bash
cat > test/ui/theme/app_text_styles_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/theme/app_text_styles.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';

void main() {
  test('display uses Syne weight 800', () {
    expect(AppTextStyles.display.fontFamily, 'Syne');
    expect(AppTextStyles.display.fontWeight!.index, 700); // FontWeight.w800 index
    expect(AppTextStyles.display.color, AppColors.textPrimary);
  });

  test('body uses SpaceGrotesk weight 500', () {
    expect(AppTextStyles.body.fontFamily, 'SpaceGrotesk');
  });

  test('label is uppercase tracked', () {
    expect(AppTextStyles.label.letterSpacing, 1.5);
  });
}
EOF
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/ui/theme/app_text_styles_test.dart
```

Expected: FAIL — `app_text_styles.dart` not found

- [ ] **Step 3: Implement AppTextStyles**

```bash
cat > lib/ui/theme/app_text_styles.dart << 'EOF'
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w800,
    fontSize: 32,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 10,
    color: AppColors.purpleLight,
    letterSpacing: 1.5,
    height: 1.0,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
}
EOF
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/ui/theme/app_text_styles_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/ui/theme/app_text_styles.dart test/ui/theme/app_text_styles_test.dart
git commit -m "feat: add AppTextStyles type scale"
```

---

### Task 5: ThemeData Factory

**Files:**
- Create: `lib/ui/theme/app_theme.dart`

- [ ] **Step 1: Implement AppTheme**

```bash
cat > lib/ui/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgPrimary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purple,
      secondary: AppColors.pink,
      surface: AppColors.surface,
      onPrimary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.display,
      headlineMedium: AppTextStyles.heading,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,
      labelSmall: AppTextStyles.label,
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.purpleLight, width: 1.5),
      ),
      labelStyle: AppTextStyles.body,
      hintStyle: AppTextStyles.caption,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.purpleLight,
      unselectedItemColor: AppColors.textDisabled,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
EOF
```

- [ ] **Step 2: Commit**

```bash
git add lib/ui/theme/app_theme.dart
git commit -m "feat: add AppTheme ThemeData factory"
```

---

### Task 6: ArbitroButton Component

**Files:**
- Create: `lib/ui/components/arbitro_button.dart`
- Test: `test/ui/components/arbitro_button_test.dart`

- [ ] **Step 1: Write the failing test**

```bash
mkdir -p test/ui/components
cat > test/ui/components/arbitro_button_test.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/components/arbitro_button.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('primary button renders label', (tester) async {
    await tester.pumpWidget(_wrap(
      ArbitroButton(label: 'GIRAR', onPressed: () {}),
    ));
    expect(find.text('GIRAR'), findsOneWidget);
  });

  testWidgets('disabled button has reduced opacity', (tester) async {
    await tester.pumpWidget(_wrap(
      const ArbitroButton(label: 'GIRAR', onPressed: null),
    ));
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('GIRAR'), matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('ghost variant renders', (tester) async {
    await tester.pumpWidget(_wrap(
      ArbitroButton(
        label: 'CANCELAR',
        variant: ArbitroButtonVariant.ghost,
        onPressed: () {},
      ),
    ));
    expect(find.text('CANCELAR'), findsOneWidget);
  });
}
EOF
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/ui/components/arbitro_button_test.dart
```

Expected: FAIL — `arbitro_button.dart` not found

- [ ] **Step 3: Implement ArbitroButton**

```bash
mkdir -p lib/ui/components
cat > lib/ui/components/arbitro_button.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

enum ArbitroButtonVariant { primary, secondary, ghost, destructive }

class ArbitroButton extends StatelessWidget {
  const ArbitroButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ArbitroButtonVariant.primary,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ArbitroButtonVariant variant;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    Widget child = GestureDetector(
      onTap: onPressed,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 100),
        child: _buildInner(),
      ),
    );

    if (isDisabled) {
      child = Opacity(opacity: 0.5, child: child);
    }

    if (fullWidth) {
      child = SizedBox(width: double.infinity, child: child);
    }

    return child;
  }

  Widget _buildInner() {
    return switch (variant) {
      ArbitroButtonVariant.primary     => _GradientButton(label: label),
      ArbitroButtonVariant.secondary   => _SecondaryButton(label: label),
      ArbitroButtonVariant.ghost       => _GhostButton(label: label),
      ArbitroButtonVariant.destructive => _DestructiveButton(label: label),
    };
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      gradient: AppColors.gradientPrimary,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    ),
    child: Text(label, style: AppTextStyles.button, textAlign: TextAlign.center),
  );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0x267C3AED),
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      border: Border.all(color: const Color(0x4DA855F7)),
    ),
    child: Text(
      label,
      style: AppTextStyles.button.copyWith(color: AppColors.purpleLight),
      textAlign: TextAlign.center,
    ),
  );
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surface2,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    ),
    child: Text(
      label,
      style: AppTextStyles.button.copyWith(color: AppColors.textMuted),
      textAlign: TextAlign.center,
    ),
  );
}

class _DestructiveButton extends StatelessWidget {
  const _DestructiveButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0x26EF4444),
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      border: Border.all(color: const Color(0x4DEF4444)),
    ),
    child: Text(
      label,
      style: AppTextStyles.button.copyWith(color: AppColors.danger),
      textAlign: TextAlign.center,
    ),
  );
}
EOF
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/ui/components/arbitro_button_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/ui/components/arbitro_button.dart test/ui/components/arbitro_button_test.dart
git commit -m "feat: add ArbitroButton component with 4 variants"
```

---

### Task 7: GlassCard Component

**Files:**
- Create: `lib/ui/components/glass_card.dart`
- Test: `test/ui/components/glass_card_test.dart`

- [ ] **Step 1: Write the failing test**

```bash
cat > test/ui/components/glass_card_test.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/components/glass_card.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('renders child content', (tester) async {
    await tester.pumpWidget(_wrap(
      const GlassCard(child: Text('test content')),
    ));
    expect(find.text('test content'), findsOneWidget);
  });

  testWidgets('gold variant renders without error', (tester) async {
    await tester.pumpWidget(_wrap(
      const GlassCard(
        variant: GlassCardVariant.gold,
        child: Text('rare'),
      ),
    ));
    expect(find.text('rare'), findsOneWidget);
  });
}
EOF
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/ui/components/glass_card_test.dart
```

Expected: FAIL — `glass_card.dart` not found

- [ ] **Step 3: Implement GlassCard**

```bash
cat > lib/ui/components/glass_card.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum GlassCardVariant { defaultCard, highlighted, gold, danger }

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.variant = GlassCardVariant.defaultCard,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final GlassCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (fillColor, borderColor, shadow) = switch (variant) {
      GlassCardVariant.defaultCard => (
        AppColors.glassFill,
        AppColors.glassBorder,
        <BoxShadow>[],
      ),
      GlassCardVariant.highlighted => (
        AppColors.glassFill,
        const Color(0x80A855F7),
        [const BoxShadow(color: Color(0x337C3AED), blurRadius: 20)],
      ),
      GlassCardVariant.gold => (
        const Color(0x14F59E0B),
        const Color(0x66F59E0B),
        [const BoxShadow(color: Color(0x26F59E0B), blurRadius: 20)],
      ),
      GlassCardVariant.danger => (
        const Color(0x14EF4444),
        const Color(0x4DEF4444),
        <BoxShadow>[],
      ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: borderColor),
          boxShadow: shadow,
        ),
        child: child,
      ),
    );
  }
}
EOF
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/ui/components/glass_card_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/ui/components/glass_card.dart test/ui/components/glass_card_test.dart
git commit -m "feat: add GlassCard component with 4 variants"
```

---

### Task 8: ArbitroBadge Component

**Files:**
- Create: `lib/ui/components/arbitro_badge.dart`
- Test: `test/ui/components/arbitro_badge_test.dart`

- [ ] **Step 1: Write the failing test**

```bash
cat > test/ui/components/arbitro_badge_test.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/components/arbitro_badge.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('renders label text uppercased', (tester) async {
    await tester.pumpWidget(_wrap(const ArbitroBadge(label: 'popular')));
    expect(find.text('POPULAR'), findsOneWidget);
  });

  testWidgets('gold variant uses gold colour', (tester) async {
    await tester.pumpWidget(_wrap(
      const ArbitroBadge(label: 'raro', variant: BadgeVariant.gold),
    ));
    final text = tester.widget<Text>(find.text('RARO'));
    expect(text.style?.color, AppColors.gold);
  });
}
EOF
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/ui/components/arbitro_badge_test.dart
```

Expected: FAIL

- [ ] **Step 3: Implement ArbitroBadge**

```bash
cat > lib/ui/components/arbitro_badge.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum BadgeVariant { purple, pink, green, gold }

class ArbitroBadge extends StatelessWidget {
  const ArbitroBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.purple,
  });

  final String label;
  final BadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      BadgeVariant.purple => (const Color(0x33A855F7), AppColors.purpleLight),
      BadgeVariant.pink   => (const Color(0x33EC4899), AppColors.pink),
      BadgeVariant.green  => (const Color(0x3310B981), AppColors.success),
      BadgeVariant.gold   => (const Color(0x33F59E0B), AppColors.gold),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: fg),
      ),
    );
  }
}
EOF
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/ui/components/arbitro_badge_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/ui/components/arbitro_badge.dart test/ui/components/arbitro_badge_test.dart
git commit -m "feat: add ArbitroBadge component"
```

---

### Task 9: ArbitroInput & BottomSheetHandle Components

**Files:**
- Create: `lib/ui/components/arbitro_input.dart`
- Create: `lib/ui/components/bottom_sheet_handle.dart`

- [ ] **Step 1: Implement ArbitroInput**

```bash
cat > lib/ui/components/arbitro_input.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class ArbitroInput extends StatelessWidget {
  const ArbitroInput({
    super.key,
    this.hint,
    this.label,
    this.controller,
    this.onChanged,
    this.keyboardType,
  });

  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    keyboardType: keyboardType,
    style: AppTextStyles.bodyStrong,
    decoration: InputDecoration(
      hintText: hint,
      labelText: label,
    ),
  );
}
EOF
```

- [ ] **Step 2: Implement BottomSheetHandle**

```bash
cat > lib/ui/components/bottom_sheet_handle.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}
EOF
```

- [ ] **Step 3: Commit**

```bash
git add lib/ui/components/arbitro_input.dart lib/ui/components/bottom_sheet_handle.dart
git commit -m "feat: add ArbitroInput and BottomSheetHandle components"
```

---

### Task 10: Screen Shells + Navigation

**Files:**
- Create: `lib/ui/screens/slots_screen.dart`
- Create: `lib/ui/screens/roulette_screen.dart`
- Create: `lib/ui/screens/ledger_screen.dart`
- Create: `lib/navigation/app_router.dart`

- [ ] **Step 1: Create placeholder screens**

```bash
mkdir -p lib/ui/screens lib/navigation

cat > lib/ui/screens/slots_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class SlotsScreen extends StatelessWidget {
  const SlotsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text('Social Slots', style: AppTextStyles.display),
    ),
  );
}
EOF

cat > lib/ui/screens/roulette_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class RouletteScreen extends StatelessWidget {
  const RouletteScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text('Roleta do Destino', style: AppTextStyles.display),
    ),
  );
}
EOF

cat > lib/ui/screens/ledger_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text('Absurdity Ledger', style: AppTextStyles.display),
    ),
  );
}
EOF
```

- [ ] **Step 2: Create AppRouter with bottom nav**

```bash
cat > lib/navigation/app_router.dart << 'EOF'
import 'package:flutter/material.dart';
import '../ui/screens/lobby_screen.dart';
import '../ui/screens/slots_screen.dart';
import '../ui/screens/roulette_screen.dart';
import '../ui/screens/ledger_screen.dart';
import '../ui/theme/app_colors.dart';
import '../ui/theme/app_spacing.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _index = 0;

  static const _screens = [
    LobbyScreen(),
    SlotsScreen(),
    RouletteScreen(),
    LedgerScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _screens[_index],
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Lobby'),
          BottomNavigationBarItem(icon: Icon(Icons.casino_rounded), label: 'Slots'),
          BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked_rounded), label: 'Roleta'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Ledger'),
        ],
      ),
    ),
  );
}
EOF
```

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/ lib/navigation/
git commit -m "feat: add screen shells and bottom navigation router"
```

---

### Task 11: Lobby Screen

**Files:**
- Create: `lib/ui/screens/lobby_screen.dart`
- Test: `test/ui/screens/lobby_screen_test.dart`

- [ ] **Step 1: Write the failing test**

```bash
mkdir -p test/ui/screens
cat > test/ui/screens/lobby_screen_test.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_arbitro/ui/screens/lobby_screen.dart';
import 'package:o_arbitro/ui/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: child,
);

void main() {
  testWidgets('lobby shows app logo', (tester) async {
    await tester.pumpWidget(_wrap(const LobbyScreen()));
    expect(find.text('O Árbitro'), findsOneWidget);
  });

  testWidgets('lobby shows all three module cards', (tester) async {
    await tester.pumpWidget(_wrap(const LobbyScreen()));
    expect(find.text('Social Slots'), findsOneWidget);
    expect(find.text('Roleta do Destino'), findsOneWidget);
    expect(find.text('Absurdity Ledger'), findsOneWidget);
  });
}
EOF
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/ui/screens/lobby_screen_test.dart
```

Expected: FAIL — `lobby_screen.dart` not found

- [ ] **Step 3: Implement LobbyScreen**

```bash
cat > lib/ui/screens/lobby_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/glass_card.dart';
import '../components/arbitro_badge.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppBar(),
            const SizedBox(height: AppSpacing.xl),
            _FeaturedCard(),
            const SizedBox(height: AppSpacing.md),
            _SecondaryGrid(),
          ],
        ),
      ),
    ),
  );
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      RichText(
        text: TextSpan(
          style: AppTextStyles.heading,
          children: [
            const TextSpan(text: 'O '),
            TextSpan(
              text: 'Árbitro',
              style: AppTextStyles.heading.copyWith(color: AppColors.purpleLight),
            ),
          ],
        ),
      ),
      Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          gradient: AppColors.gradientPrimary,
          shape: BoxShape.circle,
        ),
      ),
    ],
  );
}

class _FeaturedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GlassCard(
    variant: GlassCardVariant.highlighted,
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Row(
      children: [
        const Text('🎰', style: TextStyle(fontSize: 48)),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Social Slots', style: AppTextStyles.heading),
              const SizedBox(height: AppSpacing.xs),
              Text('Consequências instantâneas', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.sm),
              const ArbitroBadge(label: 'Em Destaque', variant: BadgeVariant.purple),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SecondaryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎡', style: TextStyle(fontSize: 32)),
              const SizedBox(height: AppSpacing.sm),
              Text('Roleta do Destino', style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.xs),
              Text('Destino', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📜', style: TextStyle(fontSize: 32)),
              const SizedBox(height: AppSpacing.sm),
              Text('Absurdity Ledger', style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.xs),
              Text('Apostas', style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    ],
  );
}
EOF
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/ui/screens/lobby_screen_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/ui/screens/lobby_screen.dart test/ui/screens/lobby_screen_test.dart
git commit -m "feat: implement LobbyScreen with Grid Destacado layout"
```

---

### Task 12: Wire Up main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace main.dart**

```bash
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'navigation/app_router.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(const OArbitroApp());
}

class OArbitroApp extends StatelessWidget {
  const OArbitroApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'O Árbitro',
    theme: AppTheme.dark,
    debugShowCheckedModeBanner: false,
    home: const AppRouter(),
  );
}
EOF
```

- [ ] **Step 2: Run all tests**

```bash
flutter test
```

Expected: `All tests passed!`

- [ ] **Step 3: Run on device/emulator to verify visually**

```bash
flutter run
```

Expected: App launches with dark background, bottom nav with 4 tabs, lobby shows featured Social Slots card + two secondary cards.

- [ ] **Step 4: Final commit**

```bash
git add lib/main.dart
git commit -m "feat: wire up main.dart — app scaffold complete"
```

---

## Self-Review

**Spec coverage check:**

| Spec Section | Covered By |
|---|---|
| Colour palette + all tokens | Task 2 |
| Spacing tokens | Task 3 |
| Typography scale | Task 4 |
| ThemeData factory | Task 5 |
| Buttons (4 variants) | Task 6 |
| Glass Cards (4 variants) | Task 7 |
| Tags/Badges | Task 8 |
| Input fields | Task 9 |
| Modal handle | Task 9 |
| Bottom navigation (4 tabs) | Task 10 |
| Lobby — Grid Destacado | Task 11 |
| Screen shells for all 3 modules | Task 10 |
| Flutter pubspec + fonts | Task 1 |
| Dark-mode only | Task 5 (ThemeData brightness) |
| Rarity tier system | Not in this plan — belongs in Plan 2 (Social Slots) |

**Placeholder scan:** No TBDs found. All steps contain actual code.

**Type consistency:** All components use `AppColors`, `AppTextStyles`, `AppSpacing` consistently across tasks. `GlassCardVariant.defaultCard` used in Task 7 and imported correctly in Task 11. `BadgeVariant` used consistently in Tasks 8 and 11.
