import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CopticKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onClose;
  final bool isVisible;

  const CopticKeyboard({
    super.key,
    required this.controller,
    this.onClose,
    this.isVisible = false,
  });

  @override
  State<CopticKeyboard> createState() => _CopticKeyboardState();
}

class _CopticKeyboardState extends State<CopticKeyboard> {
  bool _isUpperCase = false;

  // Coptic alphabet letters
  static const List<String> _copticLetters = [
    'ⲁ', 'ⲃ', 'ⲅ', 'ⲇ', 'ⲉ', 'ⲋ', 'ⲍ', 'ⲏ', 'ⲑ', 'ⲓ',
    'ⲕ', 'ⲗ', 'ⲙ', 'ⲛ', 'ⲝ', 'ⲟ', 'ⲡ', 'ⲣ', 'ⲥ', 'ⲧ',
    'ⲩ', 'ⲫ', 'ⲭ', 'ⲯ', 'ⲱ', 'ϣ', 'ϥ', 'ϧ', 'ϩ', 'ϫ',
    'ϭ', 'ϯ'
  ];

  static const List<String> _copticLettersUpper = [
    'Ⲁ', 'Ⲃ', 'Ⲅ', 'Ⲇ', 'Ⲉ', 'Ⲋ', 'Ⲍ', 'Ⲏ', 'Ⲑ', 'Ⲓ',
    'Ⲕ', 'Ⲗ', 'Ⲙ', 'Ⲛ', 'Ⲝ', 'Ⲟ', 'Ⲡ', 'Ⲣ', 'Ⲥ', 'Ⲧ',
    'Ⲩ', 'Ⲫ', 'Ⲭ', 'Ⲯ', 'Ⲱ', 'Ϣ', 'Ϥ', 'Ϧ', 'Ϩ', 'Ϫ',
    'Ϭ', 'Ϯ'
  ];

  // Common Coptic diacritics and symbols
  static const List<String> _copticDiacritics = [
    '̀', '́', '̂', '̈', '̄', '̆', '̇', '̊', '̋', '̌',
    '⳹', '⳺', '⳻', '⳼', '⳽', '⳾', '⳿'
  ];

  void _insertText(String text) {
    final currentText = widget.controller.text;
    final selection = widget.controller.selection;
    
    if (selection.isValid) {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        text,
      );
      
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + text.length,
        ),
      );
    } else {
      widget.controller.text = currentText + text;
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
    }
  }

  void _deleteText() {
    final currentText = widget.controller.text;
    final selection = widget.controller.selection;
    
    if (selection.isValid && selection.start > 0) {
      final newText = currentText.replaceRange(
        selection.start - 1,
        selection.end,
        '',
      );
      
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start - 1,
        ),
      );
    }
  }

  Widget _buildKey(String text, {double? width, VoidCallback? onTap}) {
    return Container(
      width: width ?? 40,
      height: 40,
      margin: const EdgeInsets.all(2),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap ?? () => _insertText(text),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                // Always use Coptic font for keyboard keys
                fontFamily: 'CS_avva_shenouda',
                fontFamilyFallback: ['CS Avva Shenouda', 'Arial Unicode MS', 'Lucida Grande', 'serif'],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(IconData icon, VoidCallback onTap, {double? width}) {
    return Container(
      width: width ?? 40,
      height: 40,
      margin: const EdgeInsets.all(2),
      child: Material(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final letters = _isUpperCase ? _copticLettersUpper : _copticLetters;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.copticKeyboard,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.keyboard_hide),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Main Coptic letters (4 rows)
          ...List.generate(4, (rowIndex) {
            final startIndex = rowIndex * 8;
            final endIndex = (startIndex + 8).clamp(0, letters.length);
            final rowLetters = letters.sublist(startIndex, endIndex);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: rowLetters.map((letter) => _buildKey(letter)).toList(),
              ),
            );
          }),
          
          // Diacritics row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _copticDiacritics.take(8).map((diacritic) => 
                _buildKey(diacritic)).toList(),
            ),
          ),
          
          // Control keys
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSpecialKey(
                  _isUpperCase ? Icons.keyboard_capslock : Icons.keyboard_capslock_outlined,
                  () => setState(() => _isUpperCase = !_isUpperCase),
                  width: 60,
                ),
                _buildKey(' ', width: 120), // Space bar
                _buildSpecialKey(Icons.backspace, _deleteText, width: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
