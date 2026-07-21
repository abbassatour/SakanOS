// lib/core/utils/pdf_generator.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; // 🌟 أضفنا هذا الاستيراد للتنسيق الاحترافي
import 'package:local_storage_api/local_storage_api.dart';
import 'arabic_tafqeet.dart';

class PdfGenerator {
  // ==========================================
  // 🛡️ مساعدات التنسيق البصري (للإيصال فقط)
  // ==========================================

  // تنسيق مالي: 1250340.0 -> 1,250,340
  static String _fmtMoney(double amount) {
    return NumberFormat("#,###", "en_US").format(amount.abs().round());
  }

  // تنسيق الأمتار (4 خانات): 0.830655 -> 0.8306
  static String _fmtMeters(double meters) {
    return meters.abs().toStringAsFixed(4);
  }

  // تنسيق المساحة الإجمالية: 125.5000 -> 125.5
  static String _fmtArea(double area) {
    final f = NumberFormat.decimalPattern();
    f.minimumFractionDigits = 0;
    f.maximumFractionDigits = 2;
    return f.format(area);
  }

  static String numberToArabicWords(double number) {
    String text = ArabicTafqeet.convert(number.abs().toInt());
    return "فقط $text ليرة سورية لا غير.";
  }

  // ==========================================
  // 🟩 توليد الـ PDF
  // ==========================================
  static Future<Uint8List> generateReceiptPdf({
    required PaymentsLedgerData entry,
    required Contract contract,
    required Client client,
    double? originalInstallment,
    double? bonusPercentage,
    double? meterPriceAfterBonus,
  }) async {
    final pdf = pw.Document();

    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();
    const primaryColor = PdfColor.fromInt(0xFF1A2B3D);

    final bool isDeposit = entry.amountPaid >= 0;
    final accentColor = isDeposit
        ? const PdfColor.fromInt(0xFFE64A19)
        : PdfColors.red800;

    pw.Widget buildCompactReceipt(String copyType) {
      Map<String, dynamic> snapshot = {};
      try {
        if (entry.pricesSnapshot.isNotEmpty && entry.pricesSnapshot != '{}') {
          snapshot = jsonDecode(entry.pricesSnapshot) as Map<String, dynamic>;
        }
      } catch (e) {
        print('Error decoding prices snapshot: $e');
      }

      String getPriceFormatted(String key) {
        final val = (snapshot[key] as num?)?.toDouble();
        return val != null ? _fmtMoney(val) : '-';
      }

      final double absAmountPaid = entry.amountPaid.abs();
      final double absConvertedMeters = entry.convertedMeters.abs();

      final bool hasDiscount =
          originalInstallment != null &&
          originalInstallment > absAmountPaid &&
          isDeposit;
      final double discountAmount = hasDiscount
          ? originalInstallment - absAmountPaid
          : 0.0;

      return pw.Container(
        margin: const pw.EdgeInsets.only(right: 40),
        padding: const pw.EdgeInsets.all(6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                ' SakanOS',
                style: pw.TextStyle(
                  font: arabicBoldFont,
                  fontSize: 11,
                  color: primaryColor,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                isDeposit
                    ? 'إيصال دفع - $copyType'
                    : 'سند استرداد نقدي - $copyType',
                style: pw.TextStyle(
                  font: arabicBoldFont,
                  fontSize: 8,
                  color: accentColor,
                ),
              ),
            ),
            pw.SizedBox(height: 4),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'رقم: ${entry.id.split('-').first.toUpperCase()}',
                  style: pw.TextStyle(font: arabicFont, fontSize: 8),
                ),
                pw.Text(
                  'التاريخ: ${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}',
                  style: pw.TextStyle(font: arabicFont, fontSize: 8),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.Text(
              'العميل: ${client.name}',
              style: pw.TextStyle(
                font: arabicBoldFont,
                fontSize: 9,
                color: primaryColor,
              ),
            ),
            // 🌟 تنسيق المساحة الإجمالية هنا
            pw.Text(
              'الشقة: ${contract.apartmentDetails} | م: ${_fmtArea(contract.totalArea)} م2',
              style: pw.TextStyle(font: arabicFont, fontSize: 8),
            ),
            pw.SizedBox(height: 6),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.TableHelper.fromTextArray(
                    context: null,
                    cellAlignment: pw.Alignment.center,
                    headerStyle: pw.TextStyle(
                      font: arabicBoldFont,
                      fontSize: 6,
                      color: PdfColors.white,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: primaryColor,
                    ),
                    cellStyle: pw.TextStyle(font: arabicFont, fontSize: 6),
                    border: pw.TableBorder.all(
                      color: PdfColors.grey400,
                      width: 0.5,
                    ),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(0.8),
                      1: const pw.FlexColumnWidth(1.2),
                    },
                    headers: ['المادة', 'السعر'],
                    // 🌟 تنسيق أسعار المواد بالجدول
                    data: [
                      ['حديد', getPriceFormatted('iron')],
                      ['كوفراج', getPriceFormatted('formwork')],
                      ['اسمنت', getPriceFormatted('cement')],
                      ['حصويات', getPriceFormatted('aggregates')],
                      ['بلوك', getPriceFormatted('block')],
                      ['عمال', getPriceFormatted('worker')],
                    ],
                  ),
                ),

                pw.SizedBox(width: 6),

                pw.Expanded(
                  flex: 6,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    decoration: pw.BoxDecoration(
                      color: isDeposit ? PdfColors.grey100 : PdfColors.red50,
                      border: pw.Border.all(color: accentColor, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      children: [
                        // 🌟 تنسيق سعر المتر
                        _buildFinancialRow(
                          font: arabicFont,
                          boldFont: arabicBoldFont,
                          title: 'سعر المتر المعتمد:',
                          value: '${_fmtMoney(entry.meterPriceAtPayment)} ل.س',
                        ),

                        if (bonusPercentage != null && bonusPercentage > 0)
                          _buildFinancialRow(
                            font: arabicFont,
                            boldFont: arabicBoldFont,
                            title: isDeposit
                                ? 'نسبة البونص:'
                                : 'البونص المسترد:',
                            value: '%${bonusPercentage.toStringAsFixed(1)}',
                            valueColor: isDeposit
                                ? PdfColors.teal
                                : PdfColors.red,
                          ),

                        if (meterPriceAfterBonus != null)
                          _buildFinancialRow(
                            font: arabicFont,
                            boldFont: arabicBoldFont,
                            title: 'السعر بعد البونص:',
                            value: '${_fmtMoney(meterPriceAfterBonus)} ل.س',
                            valueColor: PdfColors.blue800,
                          ),

                        if (hasDiscount) ...[
                          _buildFinancialRow(
                            font: arabicFont,
                            boldFont: arabicBoldFont,
                            title: 'أصل القسط:',
                            value: '${_fmtMoney(originalInstallment)} ل.س',
                          ),
                          _buildFinancialRow(
                            font: arabicFont,
                            boldFont: arabicBoldFont,
                            title: 'الخصم الممنوح:',
                            value: '${_fmtMoney(discountAmount)} ل.س',
                            valueColor: PdfColors.red,
                          ),
                        ],

                        // 🌟 تنسيق المبلغ المدفوع النهائي
                        _buildFinancialRow(
                          font: arabicFont,
                          boldFont: arabicBoldFont,
                          title: isDeposit
                              ? 'المبلغ المدفوع:'
                              : 'المبلغ المسترد:',
                          value: '${_fmtMoney(absAmountPaid)} ل.س',
                          isTotal: true,
                          primaryColor: isDeposit
                              ? primaryColor
                              : PdfColors.red900,
                        ),

                        pw.SizedBox(height: 2),
                        pw.Center(
                          child: pw.Text(
                            numberToArabicWords(absAmountPaid),
                            style: pw.TextStyle(
                              font: arabicFont,
                              fontSize: 5.5,
                              color: PdfColors.grey700,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),

                        pw.Divider(
                          color: PdfColors.grey300,
                          thickness: 0.5,
                          height: 6,
                        ),

                        // 🌟 تنسيق الأمتار (4 خانات عشرية)
                        _buildFinancialRow(
                          font: arabicFont,
                          boldFont: arabicBoldFont,
                          title: isDeposit
                              ? 'الأمتار المحولة:'
                              : 'الأمتار المخصومة:',
                          value:
                              '${isDeposit ? '' : '-'}${_fmtMeters(absConvertedMeters)} م2',
                          isTotal: true,
                          valueColor: isDeposit
                              ? PdfColors.green800
                              : PdfColors.red900,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.Spacer(),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'توقيع المكتب',
                      style: pw.TextStyle(
                        font: arabicBoldFont,
                        fontSize: 8,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),
                if (!isDeposit)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'توقيع المستلم ',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 8,
                          color: PdfColors.red800,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
        margin: const pw.EdgeInsets.all(3),
        build: (pw.Context context) {
          return pw.Align(
            alignment: pw.Alignment.topCenter,
            child: pw.SizedBox(
              height: 148 * PdfPageFormat.mm,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Expanded(child: buildCompactReceipt('نسخة المكتب')),
                  pw.SizedBox(width: 20),
                  pw.Expanded(child: buildCompactReceipt('نسخة العميل')),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildFinancialRow({
    required pw.Font font,
    required pw.Font boldFont,
    required String title,
    required String value,
    bool isTotal = false,
    PdfColor? valueColor,
    PdfColor? primaryColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: isTotal ? boldFont : font,
                fontSize: isTotal ? 7.5 : 6.5,
                color: isTotal ? primaryColor : PdfColors.black,
              ),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: isTotal ? 8.5 : 7.5,
              color: valueColor ?? (isTotal ? primaryColor : PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
