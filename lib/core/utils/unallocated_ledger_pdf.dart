// lib/core/utils/unallocated_ledger_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart';

class UnallocatedLedgerPdf {
  static const primaryColor = PdfColor.fromInt(
    0xFF00695C,
  ); // استخدمنا لوناً مختلفاً (Teal) لتمييز المحفظة
  static const primaryLightColor = PdfColor.fromInt(0xFFE0F2F1);
  static const accentColor = PdfColor.fromInt(0xFFE64A19);
  static const greyBgColor = PdfColor.fromInt(0xFFF5F5F5);
  static const borderColor = PdfColor.fromInt(0xFFE0E0E0);

  static String _formatWithCommas(num number) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return number.toInt().toString().replaceAllMapped(
      reg,
      (Match match) => '${match[1]},',
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static Future<Uint8List> generatePdf({
    required List<PaymentsLedgerData> ledgerEntries,
    required Contract contract,
    required Client client,
  }) async {
    final pdf = pw.Document();
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    double totalPaid = ledgerEntries.fold(
      0,
      (sum, item) => sum + item.amountPaid,
    );
    double totalMeters = ledgerEntries.fold(
      0,
      (sum, item) => sum + item.convertedMeters,
    );

    final sortedEntries = List<PaymentsLedgerData>.from(ledgerEntries)
      ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));

    // --- دوال مساعدة داخلية خاصة بهذا الملف فقط ---
    pw.Widget buildSectionTitle(String title, pw.IconData icon) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 6, top: 12),
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const pw.BoxDecoration(
          color: primaryLightColor,
          border: pw.Border(
            right: pw.BorderSide(color: primaryColor, width: 3),
          ),
        ),
        child: pw.Row(
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                font: arabicBoldFont,
                fontSize: 11,
                color: primaryColor,
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget buildGridRow(List<String> labels, List<String> values) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: List.generate(labels.length, (index) {
            return pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    labels[index],
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 7,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 1),
                  pw.Text(
                    values[index],
                    style: pw.TextStyle(
                      font: arabicBoldFont,
                      fontSize: 9,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      );
    }

    pw.Widget buildSummaryCol(String label, String value, PdfColor valColor) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 8,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: arabicBoldFont,
              fontSize: 12,
              color: valColor,
            ),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),

        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Our Home',
                      style: pw.TextStyle(
                        font: arabicBoldFont,
                        fontSize: 18,
                        color: primaryColor,
                      ),
                    ),
                    pw.Text(
                      'للتطوير والاستثمار العقاري',
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'كشف حساب استثماري (محفظة)',
                      style: pw.TextStyle(
                        font: arabicBoldFont,
                        fontSize: 14,
                        color: accentColor,
                        letterSpacing: 1,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: pw.BoxDecoration(
                        color: greyBgColor,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'تاريخ الإصدار: ${_formatDate(DateTime.now())}',
                        style: pw.TextStyle(font: arabicFont, fontSize: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Divider(color: primaryColor, thickness: 1.5),
          ],
        ),

        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: borderColor, thickness: 1),
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'نظام Our Home العقاري لإدارة الأملاك',
                  style: pw.TextStyle(
                    font: arabicFont,
                    color: PdfColors.grey600,
                    fontSize: 8,
                  ),
                ),
                pw.Text(
                  'صفحة ${context.pageNumber} من ${context.pagesCount}',
                  style: pw.TextStyle(
                    font: arabicFont,
                    color: PdfColors.grey600,
                    fontSize: 8,
                  ),
                ),
                pw.Row(
                  children: [
                    pw.Text(
                      'توقيع المحاسب: ',
                      style: pw.TextStyle(
                        font: arabicFont,
                        color: PdfColors.grey600,
                        fontSize: 8,
                      ),
                    ),
                    pw.Container(
                      width: 80,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: PdfColors.grey400,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        build: (context) => [
          buildSectionTitle(
            'بيانات المستثمر (الفريق الثاني)',
            const pw.IconData(0xe7fd),
          ),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderColor),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                buildGridRow(
                  ['اسم المستثمر', 'رقم الهاتف', 'الرقم الوطني', 'كود العميل'],
                  [
                    client.name,
                    client.phone,
                    client.nationalId ?? 'غير مدون',
                    client.id.split('-').first.toUpperCase(),
                  ],
                ),
              ],
            ),
          ),

          buildSectionTitle(
            'التفاصيل التعاقدية للمحفظة الاستثمارية',
            const pw.IconData(0xe873),
          ),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderColor),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                buildGridRow(
                  [
                    'تاريخ فتح المحفظة',
                    'طبيعة العقد',
                    'الدفعة المقدمة',
                    'اسم الكفيل',
                  ],
                  [
                    _formatDate(contract.contractDate),
                    'أسهم غير مخصصة (يتم التخصيص لاحقاً)',
                    '${_formatWithCommas(contract.downPayment)} ل.س',
                    contract.guarantorName,
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                buildSummaryCol(
                  'إجمالي المبالغ المُستثمرة (المسددة)',
                  '${_formatWithCommas(totalPaid)} ل.س',
                  PdfColors.green400,
                ),
                pw.Container(width: 1, height: 30, color: PdfColors.grey500),
                buildSummaryCol(
                  'إجمالي الأمتار المكتسبة في المحفظة',
                  '${totalMeters.toStringAsFixed(3)} م²',
                  PdfColors.white,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),
          buildSectionTitle(
            'السجل المالي المفصل وحركة الأمتار',
            const pw.IconData(0xe85d),
          ),

          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(2.0),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: greyBgColor),
                children:
                    [
                          'رقم الإيصال',
                          'تاريخ الدفع',
                          'المبلغ (ل.س)',
                          'سعر المتر المعتمد',
                          'البونص %',
                          'الأمتار المكتسبة',
                        ]
                        .map(
                          (text) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                text,
                                style: pw.TextStyle(
                                  font: arabicBoldFont,
                                  color: primaryColor,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              ...sortedEntries.asMap().entries.map((mapEntry) {
                final int index = mapEntry.key;
                final entry = mapEntry.value;
                final bool isRefund = entry.amountPaid < 0;
                final textColor = isRefund
                    ? PdfColors.red800
                    : PdfColors.green800;
                final bool isFirstPayment = index == 0;

                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            entry.id.split('-').first.toUpperCase(),
                            style: pw.TextStyle(font: arabicFont, fontSize: 8),
                          ),
                          if (isFirstPayment && !isRefund)
                            pw.Text(
                              '(دفعة أولى)',
                              style: pw.TextStyle(
                                font: arabicBoldFont,
                                fontSize: 6,
                                color: accentColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(
                        child: pw.Text(
                          _formatDate(entry.paymentDate),
                          style: pw.TextStyle(font: arabicFont, fontSize: 8),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(
                        child: pw.Text(
                          '${isRefund ? "" : "+"}${_formatWithCommas(entry.amountPaid)}',
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 9,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(
                        child: pw.Text(
                          _formatWithCommas(entry.meterPriceAtPayment),
                          style: pw.TextStyle(font: arabicFont, fontSize: 8),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(
                        child: pw.Text(
                          '${entry.fees.toStringAsFixed(1)}%',
                          style: pw.TextStyle(font: arabicFont, fontSize: 8),
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(
                        child: pw.Text(
                          '${isRefund ? "" : "+"}${entry.convertedMeters.toStringAsFixed(3)}',
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 9,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            '* ملاحظة: هذا كشف حساب لمحفظة استثمارية، والأمتار المسجلة هنا هي أسهم غير مخصصة لعقار معين بعد. (اللون الأحمر في الجدول يشير لعمليات الاسترداد أو السحب).',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 7,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
    return pdf.save();
  }
}
