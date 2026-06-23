// lib/payments/widgets/add_payment_sections/thousands_formatter.dart

import 'package:flutter/services.dart';

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return TextEditingValue.empty;
    final digitsOnly = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digitsOnly.isEmpty) return TextEditingValue.empty;

    var formatted = '';
    var count = 0;
    for (var i = digitsOnly.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) formatted = ',$formatted';
      formatted = digitsOnly[i] + formatted;
      count++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
