// lib/core/utils/handover_pledge_pdf_helper.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:our_home_erp_app/l10n/l10n.dart'; // 🌟 إضافة استيراد الترجمة

class HandoverPledgePdfHelper {
  static String _formatDate(DateTime? date, AppLocalizations l10n) {
    if (date == null) return l10n.bldUnspecified;
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static Future<Uint8List> generatePdf({
    required AppLocalizations l10n, // 🌟 إضافة متطلب الترجمة
    required Contract contract,
    required Client client,
    required Apartment apartment,
    required Building building,
  }) async {
    final pdf = pw.Document();

    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    const primaryColor = PdfColor.fromInt(0xFF1A237E);
    const borderColor = PdfColor.fromInt(0xFFE0E0E0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        // 🌟 جعل اتجاه النص ديناميكي
        textDirection: l10n.localeName == 'ar'
            ? pw.TextDirection.rtl
            : pw.TextDirection.ltr,
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
                        'SakanOS',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 24,
                          color: primaryColor,
                        ),
                      ),
                      pw.Text(
                        l10n.pdfSakanOsSub,
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
                        l10n.pdfHandoverTitleMain,
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 18,
                          color: primaryColor,
                        ),
                      ),
                      pw.Text(
                        l10n.pdfHandoverTitleSub,
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 14,
                          color: PdfColors.red800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '${l10n.pdfHandoverPrintDate} ${_formatDate(DateTime.now(), l10n)}',
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
                      l10n.pdfHandoverClientInfo,
                      l10n.pdfHandoverClientDetails(
                        client.name,
                        client.phone,
                        client.nationalId ?? l10n.pdfHandoverNotRecorded,
                      ),
                      arabicFont,
                      arabicBoldFont,
                    ),
                    pw.Divider(color: borderColor),
                    _buildDataRow(
                      l10n.pdfHandoverPropertyDetails,
                      l10n.pdfHandoverBuildingAptFloor(
                        building.name,
                        apartment.apartmentNumber,
                        apartment.floorName,
                      ),
                      arabicFont,
                      arabicBoldFont,
                    ),
                    pw.Divider(color: borderColor),
                    _buildDataRow(
                      l10n.pdfHandoverActualDate,
                      _formatDate(contract.actualHandoverDate, l10n),
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
                l10n.pdfHandoverPledgeTitle,
                style: pw.TextStyle(
                  font: arabicBoldFont,
                  fontSize: 14,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Paragraph(
                text: l10n.pdfHandoverPledgeP1,
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 12,
                  lineSpacing: 2,
                ),
              ),
              pw.Paragraph(
                text: l10n.pdfHandoverPledgeP2,
                style: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 12,
                  lineSpacing: 2,
                ),
              ),
              pw.Paragraph(
                text: l10n.pdfHandoverPledgeP3,
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
                        l10n.pdfHandoverNotesTitle,
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
                        l10n.pdfHandoverSignClient,
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
                      pw.SizedBox(height: 8),
                      pw.Text(
                        l10n.pdfHandoverFingerprint,
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
                        l10n.pdfHandoverSignEngineer,
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
                        l10n.pdfHandoverSignOffice,
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
