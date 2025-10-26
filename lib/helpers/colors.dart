part of 'helpers.dart';

// Brand Colors - Dark Purple/Navy Theme (Matching Image)
const Color kColorPrimary = Color(0xFFFFC107); // Yellow/Amber accent
const Color kColorPrimaryDark = Color(0xFF2C2645); // Dark purple base

const Color kColorFocus = Color(0xFFFFD54F); // Light Yellow
const Color kColorAccent = Color(0xFFFFC107); // Accent Yellow

const Color kColorBack = Color(0xFF2C2645); // Dark purple base
const Color kColorBackDark = Color(0xFF1F1A2E); // Darker purple-navy

const Color kColorCardLight = Color(0xFF3A3352); // Card background
const Color kColorCardDark = Color(0xFF2F2840); // Darker card
const Color kColorCardDarkness = Color(0xFF1F1A2E); // Darkest background

const Color kColorHint = Color(0xFF9E9E9E); // Grey
const Color kColorHintGrey = Color(0xFF757575); // Darker Grey
const Color kColorFontLight = Color(0xFFFFFFFF); // White

// Gradient Backgrounds
BoxDecoration kDecorBackground = const BoxDecoration(
  gradient: RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFF2E2749), // Slightly lighter purple (center)
      Color(0xFF1F1A2E), // Dark navy
      Color(0xFF16131F), // Very dark purple-black (edges)
    ],
    stops: [0.0, 0.4, 1.0],
  ),
);

BoxDecoration kDecorIconCircle = const BoxDecoration(
  shape: BoxShape.circle,
  color: Color(0xFF3A3352), // Solid color instead of gradient
);
