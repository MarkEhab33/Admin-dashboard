# Coptic Font Installation

## Required Font

To enable Coptic text support in the quiz creation interface, you need to download and install the CS Avva Shenouda font.

### Download Instructions

1. **Download CS Avva Shenouda Font:**
   - Search for "CS Avva Shenouda font" online
   - Download from a reliable Coptic font repository
   - Or contact your system administrator for the font file

2. **Download the font file:**
   - Download `CS_avva-shenouda.ttf`

3. **Place the font file:**
   - Save the downloaded `CS_avva-shenouda.ttf` file in this directory (`assets/fonts/`)

### Alternative Fonts

If you prefer a different Coptic font, you can:

1. Replace `CS_avva-shenouda.ttf` with your preferred font
2. Update the font family name in:
   - `pubspec.yaml` (line 126)
   - `lib/widgets/coptic_keyboard.dart` (line 108)
   - `lib/widgets/coptic_text_field.dart` (line 113)

### Font Features

The Coptic keyboard supports:
- All 32 Coptic alphabet letters (uppercase and lowercase)
- Coptic diacritics and combining marks
- Coptic punctuation and symbols
- Unicode range: U+2C80–U+2CFF (Coptic block)
- Unicode range: U+03E2–U+03EF (Coptic in Greek block)

### Verification

After adding the font file:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Restart your app
4. Test the Coptic keyboard in quiz creation

### Troubleshooting

If Coptic characters don't display correctly:
1. Ensure the font file is in the correct location
2. Check that the font family name matches in all files
3. Verify the font supports the Coptic Unicode ranges
4. Try using a different Coptic font

### Why CS Avva Shenouda Font?

CS Avva Shenouda is specifically designed for Coptic text display and is preferred by many Coptic language educators and institutions. It provides:
- Clear, readable Coptic characters
- Proper diacritic support
- Optimized for educational use
- Good Unicode compliance
- Traditional Coptic styling

### License

Please ensure you have proper licensing for the CS Avva Shenouda font before using it in production.
