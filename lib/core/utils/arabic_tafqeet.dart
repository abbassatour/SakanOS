// lib/core/utils/arabic_tafqeet.dart

class ArabicTafqeet {
  static const List<String> _ones = [
    "",
    "واحد",
    "اثنان",
    "ثلاثة",
    "أربعة",
    "خمسة",
    "ستة",
    "سبعة",
    "ثمانية",
    "تسعة",
    "عشرة",
    "أحد عشر",
    "اثنا عشر",
    "ثلاثة عشر",
    "أربعة عشر",
    "خمسة عشر",
    "ستة عشر",
    "سبعة عشر",
    "ثمانية عشر",
    "تسعة عشر",
  ];

  static const List<String> _tens = [
    "",
    "",
    "عشرون",
    "ثلاثون",
    "أربعون",
    "خمسون",
    "ستون",
    "سبعون",
    "ثمانون",
    "تسعون",
  ];

  static const List<String> _hundreds = [
    "",
    "مائة",
    "مائتان",
    "ثلاثمائة",
    "أربعمائة",
    "خمسمائة",
    "ستمائة",
    "سبعمائة",
    "ثمانمائة",
    "تسعمائة",
  ];

  static String convert(int number) {
    if (number == 0) return "صفر";
    if (number < 0) return "سالب ${convert(number.abs())}";

    String result = "";

    // المليارات
    int billions = (number / 1000000000).floor();
    int rem = number % 1000000000;
    if (billions > 0) {
      result += _processGroup(
        billions,
        "مليار",
        "ملياران",
        "مليارات",
        "ملياراً",
      );
    }

    // الملايين
    int millions = (rem / 1000000).floor();
    rem = rem % 1000000;
    if (millions > 0) {
      if (result.isNotEmpty) result += " و";
      result += _processGroup(
        millions,
        "مليون",
        "مليونان",
        "ملايين",
        "مليوناً",
      );
    }

    // الآلاف
    int thousands = (rem / 1000).floor();
    rem = rem % 1000;
    if (thousands > 0) {
      if (result.isNotEmpty) result += " و";
      result += _processGroup(thousands, "ألف", "ألفان", "آلاف", "ألفاً");
    }

    // المئات والعشرات والآحاد
    if (rem > 0) {
      if (result.isNotEmpty) result += " و";
      result += _processThreeDigits(rem);
    }

    return result.trim();
  }

  static String _processGroup(
    int number,
    String singular,
    String dual,
    String plural,
    String accusative,
  ) {
    if (number == 1) return singular;
    if (number == 2) return dual;
    if (number >= 3 && number <= 10)
      return "${_processThreeDigits(number)} $plural";
    return "${_processThreeDigits(number)} $accusative";
  }

  static String _processThreeDigits(int number) {
    int h = (number / 100).floor();
    int rem = number % 100;
    String res = "";

    if (h > 0) {
      res = _hundreds[h];
    }

    if (rem > 0) {
      if (res.isNotEmpty) res += " و";
      if (rem < 20) {
        res += _ones[rem];
      } else {
        int t = (rem / 10).floor();
        int o = rem % 10;
        if (o > 0) {
          res += "${_ones[o]} و${_tens[t]}";
        } else {
          res += _tens[t];
        }
      }
    }
    return res.trim();
  }
}
