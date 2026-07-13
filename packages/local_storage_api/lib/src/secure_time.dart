import 'package:flutter/foundation.dart';

/// كلاس يوفر التوقيت الحقيقي (المتزامن مع السحابة) في كل أنحاء التطبيق
/// لتجنب الاعتماد على ساعة نظام التشغيل (الويندوز) التي يمكن التلاعب بها.
class SecureTime {
  static Duration _offset = Duration.zero;

  /// يتم استدعاء هذه الدالة عند نجاح المزامنة مع السحابة لضبط الفجوة
  static void setOffset(Duration offset) {
    _offset = offset;
    debugPrint(
      '🕒 [SecureTime] Offset adjusted by: ${_offset.inSeconds} seconds',
    );
  }

  /// استخدم هذه الدالة دائماً بدلاً من DateTime.now().toUtc() في قواعد البيانات
  static DateTime now() {
    return DateTime.now().toUtc().add(_offset);
  }
}
