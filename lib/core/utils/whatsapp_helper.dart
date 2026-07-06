//lib\core\utils\whatsapp_helper.dart
import 'package:url_launcher/url_launcher.dart';
import 'package:erp_repository/erp_repository.dart';

class WhatsAppHelper {
  // ==========================================
  // 1. دالة إرسال (وصل استلام) بعد الدفع
  // ==========================================
  static Future<bool> sendReceiptMessage({
    required PaymentsLedgerData entry,
    required Contract contract,
    required Client client,
  }) async {
    String phone = client.phone.replaceAll(RegExp(r'\D'), '');
    if (phone.startsWith('0')) {
      phone = '963${phone.substring(1)}';
    } else if (!phone.startsWith('963')) {
      phone = '963$phone';
    }

    final String message =
        '''
مرحباً أستاذ/ة ${client.name}،
تم استلام الدفعة الخاصة بكم بنجاح بمبلغ قدره *${entry.amountPaid.toStringAsFixed(0)} ل.س*.
وذلك عن شقة (${contract.apartmentDetails}).

*تفاصيل الدفعة:*
- رقم الإيصال: ${entry.id.split('-').first}
- تاريخ الدفع: ${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}
- سعر المتر المعتمد وقت الدفع: ${entry.meterPriceAtPayment.toStringAsFixed(0)} ل.س
- الأمتار المحولة بهذه الدفعة: ${entry.convertedMeters.toStringAsFixed(3)} م2

شكراً لثقتكم بنا في "بيتنا Our Home". 🏢
''';

    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$phone?text=$encodedMessage',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      return true;
    } else {
      return false;
    }
  }

  // ==========================================
  // 2. 🌟 الدالة الجديدة: إرسال (تذكير ودي) بالدفع من شاشة المراقبة
  // ==========================================
  static Future<bool> sendReminderMessage({
    required InstallmentsScheduleData schedule,
    required Contract contract,
    required Client client,
  }) async {
    // تجهيز رقم الهاتف
    String phone = client.phone.replaceAll(RegExp(r'\D'), '');
    if (phone.startsWith('0')) {
      phone = '963${phone.substring(1)}';
    } else if (!phone.startsWith('963')) {
      phone = '963$phone';
    }

    // 🌟 صياغة رسالة التذكير اللطيفة
    final String message =
        '''
مرحباً أستاذ/ة ${client.name}،
هذا تذكير ودي باقتراب موعد سداد القسط الشهري رقم (${schedule.installmentNumber}) الخاص بشقة (${contract.apartmentDetails}).

🗓️ *تاريخ الاستحقاق:* ${schedule.dueDate.year}/${schedule.dueDate.month}/${schedule.dueDate.day}

نتمنى لكم يوماً سعيداً، وشكراً لتعاونكم مع شركة "بيتنا Our Home". 🏢
''';

    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$phone?text=$encodedMessage',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      return true;
    } else {
      return false;
    }
  }
}
