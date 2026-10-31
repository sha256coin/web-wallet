import 'package:flutter/material.dart';

// S256 "Digital Platinum" colours, taken from sha256coin.eu (theme.css) and
// the same as the Android wallet. Contrast on the card colour: text 15:1,
// textLight 6.7:1, amber 8.6:1; onPrimary on amber 9:1 (all above 4.5:1 AA).
class S256Colors {
  static const primary = Color(0xFFf5a524);      // Amber (coin logo)
  static const accent = Color(0xFFffbf55);       // Light amber, highlights
  static const onPrimary = Color(0xFF1a1206);    // Text on amber
  static const darkBg = Color(0xFF0c0e11);       // Graphite ground
  static const cardBg = Color(0xFF13161b);       // Card
  static const surface2 = Color(0xFF1a1e25);     // Raised surface, inputs
  static const text = Color(0xFFe7ebf1);
  static const textLight = Color(0xFF98a1b0);    // Secondary text
  static const line = Color(0x17d6deeb);         // Hairline, 9%
  static const lineStrong = Color(0x2ed6deeb);   // Stronger hairline, 18%
  static const danger = Color(0xFFff6b6b);
  static const dangerBg = Color(0xFF4a1c1c);    // Error snack bars
  static const success = Color(0xFF4ade80);
  static const glow = Color(0x1Ff5a524);         // Amber glow, 12%
  static const gridLine = Color(0x0Ad6deeb);     // Background grid, 4%

  static const gradient = LinearGradient(
    colors: [Color(0xFFf7b53b), Color(0xFFe58b0f)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Brushed platinum for display type (the website's --platinum, dark theme).
  static const platinum = [
    Color(0xFFf5f7fa),
    Color(0xFFb8c0cb),
    Color(0xFFf0f3f7),
    Color(0xFF8f99a7),
  ];
}

/// "Digital Platinum": the look of sha256coin.eu. Graphite ground, flat
/// square cards with hairline borders, one amber accent from the coin logo.
class S256Theme {
  static const String display = 'ChakraPetch';
  static const String body = 'IBMPlexSans';
  static const String mono = 'IBMPlexMono';

  /// Corner radius of cards, buttons and inputs.
  static const double radius = 2;
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(radius));

  /// Width from which the side menu replaces the bottom bar.
  static const double wideLayout = 900;

  static const TextStyle monoStyle = TextStyle(fontFamily: mono, color: S256Colors.text);

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: S256Colors.primary,
      onPrimary: S256Colors.onPrimary,
      secondary: S256Colors.accent,
      onSecondary: S256Colors.onPrimary,
      tertiary: S256Colors.accent,
      surface: S256Colors.cardBg,
      onSurface: S256Colors.text,
      error: S256Colors.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: body,
      scaffoldBackgroundColor: S256Colors.darkBg,
      colorScheme: scheme,
      dividerColor: S256Colors.line,
    );

    // Headings and numbers in Chakra Petch, everything else in Plex Sans.
    TextStyle? heading(TextStyle? s) => s?.copyWith(fontFamily: display, fontWeight: FontWeight.w600);
    final text = base.textTheme.apply(bodyColor: S256Colors.text, displayColor: S256Colors.text);

    const shape = RoundedRectangleBorder(borderRadius: borderRadius);

    return base.copyWith(
      textTheme: text.copyWith(
        displayLarge: heading(text.displayLarge),
        displayMedium: heading(text.displayMedium),
        displaySmall: heading(text.displaySmall),
        headlineLarge: heading(text.headlineLarge),
        headlineMedium: heading(text.headlineMedium),
        headlineSmall: heading(text.headlineSmall),
        titleLarge: heading(text.titleLarge),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: S256Colors.darkBg,
        foregroundColor: S256Colors.text,
        titleTextStyle: TextStyle(
          fontFamily: display,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: 0.4,
          color: S256Colors.text,
        ),
        shape: Border(bottom: BorderSide(color: S256Colors.line)),
      ),
      cardTheme: const CardThemeData(
        color: S256Colors.cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: S256Colors.line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: S256Colors.primary,
          foregroundColor: S256Colors.onPrimary,
          disabledBackgroundColor: S256Colors.surface2,
          disabledForegroundColor: S256Colors.textLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: shape,
          textStyle: const TextStyle(fontFamily: display, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: S256Colors.primary,
          foregroundColor: S256Colors.onPrimary,
          shape: shape,
          textStyle: const TextStyle(fontFamily: display, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: S256Colors.text,
          side: const BorderSide(color: S256Colors.lineStrong),
          shape: shape,
          textStyle: const TextStyle(fontFamily: display, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: S256Colors.primary,
          shape: shape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(shape: shape),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: S256Colors.darkBg,
        labelStyle: TextStyle(color: S256Colors.textLight),
        hintStyle: TextStyle(color: S256Colors.textLight),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: S256Colors.lineStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: S256Colors.lineStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: S256Colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: S256Colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: S256Colors.danger, width: 1.5),
        ),
      ),
      // Dialogs float over the wallet like a heads-up display: amber
      // corner brackets on a hairline frame.
      dialogTheme: const DialogThemeData(
        backgroundColor: S256Colors.cardBg,
        elevation: 0,
        shape: BracketBorder(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: S256Colors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: S256Colors.lineStrong),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: S256Colors.surface2,
        contentTextStyle: TextStyle(color: S256Colors.text, fontFamily: body),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: S256Colors.lineStrong),
        ),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: S256Colors.surface2,
          borderRadius: borderRadius,
          border: Border.fromBorderSide(BorderSide(color: S256Colors.lineStrong)),
        ),
        textStyle: TextStyle(color: S256Colors.text, fontSize: 12, fontFamily: body),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: S256Colors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: S256Colors.lineStrong),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: S256Colors.primary,
        unselectedLabelColor: S256Colors.textLight,
        indicatorColor: S256Colors.primary,
        dividerColor: S256Colors.line,
        labelStyle: TextStyle(fontFamily: display, fontWeight: FontWeight.w600, letterSpacing: 0.4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? S256Colors.onPrimary : S256Colors.textLight),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? S256Colors.primary : S256Colors.surface2),
        trackOutlineColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? S256Colors.primary : S256Colors.lineStrong),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: borderRadius),
        side: const BorderSide(color: S256Colors.lineStrong, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? S256Colors.primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(S256Colors.onPrimary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: S256Colors.primary),
      dividerTheme: const DividerThemeData(color: S256Colors.line, thickness: 1),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(S256Colors.lineStrong),
        radius: const Radius.circular(radius),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: shape,
          selectedBackgroundColor: S256Colors.primary,
          selectedForegroundColor: S256Colors.onPrimary,
          side: const BorderSide(color: S256Colors.lineStrong),
        ),
      ),
    );
  }
}

/// A square frame with a hairline border and amber corner brackets, for
/// shapes that Flutter paints itself (dialogs).
class BracketBorder extends RoundedRectangleBorder {
  final Color bracketColor;

  const BracketBorder({this.bracketColor = S256Colors.primary})
      : super(
          borderRadius: S256Theme.borderRadius,
          side: const BorderSide(color: S256Colors.lineStrong),
        );

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    super.paint(canvas, rect, textDirection: textDirection);
    const len = 14.0;
    final p = Paint()
      ..color = bracketColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final l = rect.left, t = rect.top, r = rect.right, b = rect.bottom;
    canvas.drawPath(
      Path()
        ..moveTo(l, t + len)..lineTo(l, t)..lineTo(l + len, t)
        ..moveTo(r - len, t)..lineTo(r, t)..lineTo(r, t + len)
        ..moveTo(r, b - len)..lineTo(r, b)..lineTo(r - len, b)
        ..moveTo(l + len, b)..lineTo(l, b)..lineTo(l, b - len),
      p,
    );
  }

  @override
  ShapeBorder scale(double t) => this;
}
