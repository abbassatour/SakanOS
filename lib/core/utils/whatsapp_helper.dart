// lib/core/utils/whatsapp_helper.dart
import 'package:url_launcher/url_launcher.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class WhatsAppHelper {
  static Future<bool> sendReceiptMessage({
    required AppLocalizations l10n,
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

    final receiptNo = entry.receiptNumber != null
        ? entry.receiptNumber.toString()
        : entry.id.split('-').first.toUpperCase();
    final paymentDateStr =
        '${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}';

    final String message = l10n.waReceiptMessage(
      client.name,
      entry.amountPaid.toStringAsFixed(0),
      contract.apartmentDetails,
      receiptNo,
      paymentDateStr,
      entry.meterPriceAtPayment.toStringAsFixed(0),
      entry.convertedMeters.toStringAsFixed(3),
    );

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

  static Future<bool> sendReminderMessage({
    required AppLocalizations l10n,
    required InstallmentsScheduleData schedule,
    required Contract contract,
    required Client client,
  }) async {
    String phone = client.phone.replaceAll(RegExp(r'\D'), '');
    if (phone.startsWith('0')) {
      phone = '963${phone.substring(1)}';
    } else if (!phone.startsWith('963')) {
      phone = '963$phone';
    }

    final dueDateStr =
        '${schedule.dueDate.year}/${schedule.dueDate.month}/${schedule.dueDate.day}';

    final String message = l10n.waReminderMessage(
      client.name,
      schedule.installmentNumber,
      contract.apartmentDetails,
      dueDateStr,
    );

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
