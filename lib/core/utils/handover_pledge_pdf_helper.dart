// lib/core/utils/handover_pledge_pdf_helper.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:local_storage_api/local_storage_api.dart';

class HandoverPledgePdfHelper {
  static String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static Future<Uint8List> generatePdf({
    required Contract contract,
    required Client client,
    required Apartment apartment,
    required Building building,
  }) async {
    final pdf = pw.Document();

    // 🌟 جلب الخطوط العربية
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    const primaryColor = PdfColor.fromInt(0xFF1A237E);
    const borderColor = PdfColor.fromInt(0xFFE0E0E0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 🏢 1. الترويسة (Header)
              // ==========================================
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
                          fontSize: 24,
                          color: primaryColor,
                        ),
                      ),
                      pw.Text(
                        'للتطوير والاستثمار العقاري',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'محضر استلام مبدئي',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 18,
                          color: primaryColor,
                        ),
                      ),
                      pw.Text(
                        'وتعهد بالتجهيزات المشتركة',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 14,
                          color: PdfColors.red800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'تاريخ الطباعة: ${_formatDate(DateTime.now())}',
                        style: pw.TextStyle(font: arabicFont, fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: primaryColor, thickness: 2),
              pw.SizedBox(height: 24),

              // ==========================================
              // 👤 2. بيانات الطرفين والعقار
              // ==========================================
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor),
                  borderRadius: pw.BorderRadius.circular(8),
                  color: PdfColors.grey50,
                ),
                child: pw.Column(
                  children: [
                    _buildDataRow(
                      'بيانات العميل (المستلم):',
                      '${client.name}  |  هاتف: ${client.phone}  |  رقم وطني: ${client.nationalId ?? "غير مدون"}',
                      arabicFont,
                      arabicBoldFont,
                    ),
                    pw.Divider(color: borderColor),
                    _buildDataRow(
                      'تفاصيل العقار:',
                      'محضر (${building.name})  |  شقة رقم (${apartment.apartmentNumber})  |  ${apartment.floorName}',
                      arabicFont,
                      arabicBoldFont,
                    ),
                    pw.Divider(color: borderColor),
                    _buildDataRow(
                      'التاريخ الفعلي للاستلام:',
                      _formatDate(contract.actualHandoverDate),
                      arabicFont,
                      arabicBoldFont,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),

              // ==========================================
              // ⚖️ 3. النص القانوني للتعهد
              // ==========================================
              pw.Text(
                'إقرار وتعهد:',
                style: pw.TextStyle(
                  font: arabicBoldFont,
                  fontSize: 14,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Paragraph(
                text:
                    'أقر أنا الموقع أدناه (الفريق الثاني)، بأنني قد استلمت الوحدة العقارية المذكورة أعلاه من شركة Our Home للتطوير العقاري (الفريق الأول)، وذلك بعد معاينتها والتأكد من مطابقتها للمواصفات المتفق عليها في العقد الأساسي، وبذلك أُبرئ ذمة الفريق الأول من ناحية التسليم المبدئي للوحدة.',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 12,
                  lineSpacing: 2,
                ),
              ),
              pw.Paragraph(
                text:
                    'كما أتعهد التزاماً تاماً بدفع حصتي المالية المترتبة عليّ تجاه التجهيزات المشتركة للمحضر (وتشمل على سبيل المثال لا الحصر: كلف المصعد، الرخام، الكسوة الخارجية، التمديدات الصحية، وأي تجهيزات مشتركة أخرى) وذلك فور البدء بتنفيذها أو عند مطالبة الإدارة بها، وفقاً لنسب المعاملات المتفق عليها في العقد الأساسي.',
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 12,
                  lineSpacing: 2,
                ),
              ),
              pw.Paragraph(
                text:
                    'وأتعهد أيضاً بعدم إحداث أي تغييرات هندسية أو معمارية تمس بالواجهة الخارجية للمحضر أو الأقسام المشتركة دون الحصول على موافقة خطية مسبقة من إدارة الشركة.',
                style: pw.TextStyle(
                  font: arabicBoldFont,
                  fontSize: 12,
                  lineSpacing: 2,
                  color: PdfColors.red800,
                ),
              ),

              if (contract.handoverNotes != null &&
                  contract.handoverNotes!.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red300),
                    borderRadius: pw.BorderRadius.circular(8),
                    color: PdfColors.red50,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ملاحظات / نواقص تم رصدها عند التسليم:',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 11,
                          color: PdfColors.red800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        contract.handoverNotes!,
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 11,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              pw.Spacer(),

              // ==========================================
              // ✍️ 4. التواقيع
              // ==========================================
              pw.Divider(color: borderColor, thickness: 1),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'توقيع العميل (المُستلم)',
                        style: pw.TextStyle(font: arabicBoldFont, fontSize: 12),
                      ),
                      pw.SizedBox(height: 40),
                      // 🌟 التصحيح: وضعنا border داخل BoxDecoration
                      pw.Container(
                        width: 120,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColors.grey500,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'البصمة:',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'مندوب التسليم (المهندس)',
                        style: pw.TextStyle(font: arabicBoldFont, fontSize: 12),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Container(
                        width: 120,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColors.grey500,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'ختم الشركة (الفريق الأول)',
                        style: pw.TextStyle(font: arabicBoldFont, fontSize: 12),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Container(
                        width: 120,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColors.grey500,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildDataRow(
    String label,
    String value,
    pw.Font arabicFont,
    pw.Font arabicBoldFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 11,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: arabicBoldFont,
                fontSize: 11,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
