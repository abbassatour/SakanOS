import 'package:flutter/foundation.dart';

class SecureTime {
  static Duration _offset = Duration.zero;

  static void setOffset(Duration offset) {
    _offset = offset;
    debugPrint(
      '🕒 [SecureTime] Offset adjusted by: ${_offset.inSeconds} seconds',
    );
  }

  static DateTime now() {
    // 🌟 يجب أن نستخدم DateTime.now هنا لكي لا ندخل في حلقة مفرغة
    return DateTime.now().toUtc().add(_offset);
  }
}
