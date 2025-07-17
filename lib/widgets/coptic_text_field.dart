import 'package:flutter/material.dart';
import 'coptic_keyboard.dart';
import '../l10n/app_localizations.dart';

class CopticTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const CopticTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.decoration,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.onTap,
    this.onChanged,
  });

  @override
  State<CopticTextField> createState() => _CopticTextFieldState();
}

class _CopticTextFieldState extends State<CopticTextField> {
  bool _showCopticKeyboard = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleCopticKeyboard() {
    setState(() {
      _showCopticKeyboard = !_showCopticKeyboard;
    });
    
    if (_showCopticKeyboard) {
      _focusNode.requestFocus();
    }
  }

  void _closeCopticKeyboard() {
    setState(() {
      _showCopticKeyboard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field with Coptic keyboard button
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                decoration: (widget.decoration ?? InputDecoration(
                  labelText: widget.labelText,
                  hintText: widget.hintText,
                  border: const OutlineInputBorder(),
                )).copyWith(
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Coptic keyboard toggle button
                      IconButton(
                        onPressed: _toggleCopticKeyboard,
                        icon: Icon(
                          _showCopticKeyboard 
                            ? Icons.keyboard_hide 
                            : Icons.language,
                          color: _showCopticKeyboard 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                        ),
                        tooltip: _showCopticKeyboard 
                          ? AppLocalizations.of(context)!.hideCopticKeyboard
                          : AppLocalizations.of(context)!.showCopticKeyboard,
                      ),
                      // Original suffix icon if any
                      if (widget.decoration?.suffixIcon != null)
                        widget.decoration!.suffixIcon!,
                    ],
                  ),
                ),
                validator: widget.validator,
                maxLines: widget.maxLines,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                keyboardType: widget.keyboardType,
                onTap: widget.onTap,
                onChanged: widget.onChanged,
                style: CopticTextUtils.getCopticInputStyle(),
              ),
            ),
          ],
        ),
        
        // Coptic keyboard
        if (_showCopticKeyboard)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: CopticKeyboard(
              controller: widget.controller,
              onClose: _closeCopticKeyboard,
              isVisible: _showCopticKeyboard,
            ),
          ),
      ],
    );
  }
}

// Helper widget for quiz creation with Coptic support
class QuizCopticTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;

  const QuizCopticTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CopticTextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'Use the language button (🌐) for Coptic keyboard',
        hintStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}

// Widget for displaying text with automatic Coptic font detection
class CopticText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CopticText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCopticText = CopticTextUtils.containsCopticText(text);

    return Text(
      text,
      style: hasCopticText
        ? (style ?? const TextStyle()).copyWith(
            fontFamilyFallback: ['CS_avva_shenouda', 'CS Avva Shenouda', 'Arial Unicode MS', 'Lucida Grande', 'serif'],
          )
        : style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Utility class for Coptic text handling
class CopticTextUtils {
  // Check if text contains Coptic characters
  static bool containsCopticText(String text) {
    final copticRange = RegExp(r'[\u2C80-\u2CFF\u03E2-\u03EF]');
    return copticRange.hasMatch(text);
  }

  // Get Coptic character count
  static int getCopticCharacterCount(String text) {
    final copticRange = RegExp(r'[\u2C80-\u2CFF\u03E2-\u03EF]');
    return copticRange.allMatches(text).length;
  }

  // Validate Coptic text input
  static String? validateCopticText(String? value, {bool required = false}) {
    if (required && (value == null || value.isEmpty)) {
      return 'This field is required';
    }

    if (value != null && value.isNotEmpty) {
      // Check for valid Coptic characters
      final validCopticRange = RegExp(r'^[\u2C80-\u2CFF\u03E2-\u03EF\s\p{P}\p{N}\p{L}]*$', unicode: true);
      if (!validCopticRange.hasMatch(value)) {
        return 'Contains invalid characters';
      }
    }

    return null;
  }

  // Format Coptic text for display
  static String formatCopticText(String text) {
    // Add any specific Coptic text formatting here
    return text.trim();
  }

  // Get appropriate TextStyle for text that may contain Coptic characters
  static TextStyle getCopticTextStyle(TextStyle? baseStyle) {
    return (baseStyle ?? const TextStyle()).copyWith(
      fontFamily: 'CS_avva_shenouda',
      fontFamilyFallback: ['CS Avva Shenouda', 'Arial Unicode MS', 'Lucida Grande', 'serif'],
    );
  }

  // Get TextStyle specifically for input fields to always show Coptic font
  static TextStyle getCopticInputStyle({double fontSize = 18}) {
    return TextStyle(
      fontFamily: 'CS_avva_shenouda',
      fontFamilyFallback: const ['CS Avva Shenouda', 'Arial Unicode MS', 'Lucida Grande', 'serif'],
      fontSize: fontSize,
      height: 1.4, // Better line height for Coptic characters
    );
  }

  // Sample Coptic text for testing
  static const String sampleCopticText = 'ⲛⲓⲙ ⲡⲉ ⲡⲉⲛⲛⲟⲩϯ; (Who is our God?)';

  // Common Coptic phrases for quiz creation
  static const List<String> commonCopticPhrases = [
    'ⲛⲓⲙ ⲡⲉ ⲡⲉⲛⲛⲟⲩϯ;', // Who is our God?
    'ⲓⲏⲥⲟⲩⲥ ⲡⲉⲭⲣⲓⲥⲧⲟⲥ', // Jesus Christ
    'ⲡⲓⲁⲅⲓⲟⲥ ⲙⲁⲣⲕⲟⲥ', // Saint Mark
    'ⲧⲉⲛⲛⲁⲩ ⲉⲣⲟⲕ', // We see you
  ];
}
