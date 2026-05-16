import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'arabic_tafqeet.dart';

class PdfConstants {
  static const primaryColor = PdfColor.fromInt(0xFF1A2B3D); // أزرق رسمي
  static const depositAccent = PdfColor.fromInt(0xFFE64A19); // برتقالي للدفع
  static const refundAccent = PdfColors.red900; // أحمر للاسترداد

  static String fmtMoney(double amount) => NumberFormat("#,###", "en_US").format(amount.abs().round());
  static String fmtMeters(double meters) => meters.abs().toStringAsFixed(4);
  static String fmtArea(double area) => NumberFormat.decimalPattern().format(area);
  
  static String tafqeet(double number) {
    return "فقط ${ArabicTafqeet.convert(number.abs().toInt())} ليرة سورية لا غير.";
  }

  static pw.Widget buildFinancialRow({
    required pw.Font font,
    required pw.Font boldFont,
    required String title,
    required String value,
    bool isTotal = false,
    PdfColor? valueColor,
    PdfColor? labelColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(font: isTotal ? boldFont : font, fontSize: isTotal ? 7.5 : 6.5, color: labelColor ?? PdfColors.black)),
          pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: isTotal ? 8.5 : 7.5, color: valueColor ?? (isTotal ? primaryColor : PdfColors.black))),
        ],
      ),
    );
  }
}