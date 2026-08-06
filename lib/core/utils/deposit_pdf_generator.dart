// lib/core/utils/deposit_pdf_generator.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'arabic_tafqeet.dart';

class DepositPdfGenerator {
  static String _fmtMoney(double amount) =>
      NumberFormat("#,###", "en_US").format(amount.abs().round());
  static String _fmtMeters(double meters) => meters.abs().toStringAsFixed(4);
  static String _fmtArea(double area) {
    final f = NumberFormat.decimalPattern();
    f.minimumFractionDigits = 0;
    f.maximumFractionDigits = 2;
    return f.format(area);
  }

  static String _formatTafqeet(AppLocalizations l10n, double amount) {
    if (l10n.localeName == 'ar') {
      return "فقط ${ArabicTafqeet.convert(amount.abs().toInt())} ليرة سورية لا غير.";
    } else {
      return "Only ${NumberFormat('#,###', 'en_US').format(amount.abs().round())} Syrian Pounds.";
    }
  }

  static String _formatApartmentDetails(
    AppLocalizations l10n,
    String rawDetails,
  ) {
    if (rawDetails == 'أسهم/غير مخصص' ||
        rawDetails == 'أسهم استثمارية غير مخصصة' ||
        rawDetails == 'محفظة استثمارية (عقد لاحق التخصص)' ||
        rawDetails.contains('غير مخصص') ||
        rawDetails.contains('استثمارية')) {
      return l10n.contractAutoDetailsUnallocated;
    }
    return rawDetails;
  }

  static Future<Uint8List> generate({
    required AppLocalizations l10n,
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
    const accentColor = PdfColor.fromInt(0xFFE64A19);

    pw.Widget buildCompactReceipt(String copyType) {
      Map<String, dynamic> snapshot = {};
      try {
        if (entry.pricesSnapshot.isNotEmpty) {
          snapshot = jsonDecode(entry.pricesSnapshot) as Map<String, dynamic>;
        }
      } catch (_) {}

      String getPriceFormatted(String key) {
        final val = (snapshot[key] as num?)?.toDouble();
        return val != null ? _fmtMoney(val) : '-';
      }

      final double absAmountPaid = entry.amountPaid.abs();
      final double absConvertedMeters = entry.convertedMeters.abs();
      final bool hasDiscount =
          originalInstallment != null && originalInstallment > absAmountPaid;
      final double discountAmount = hasDiscount
          ? originalInstallment - absAmountPaid
          : 0.0;

      final bool isPenalty = bonusPercentage != null && bonusPercentage < 0;

      final receiptNo = entry.receiptNumber != null
          ? entry.receiptNumber.toString()
          : entry.id.split('-').first.toUpperCase();
      final dateStr =
          '${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}';

      final formattedDetails = _formatApartmentDetails(
        l10n,
        contract.apartmentDetails,
      );

      return pw.Container(
        margin: const pw.EdgeInsets.only(right: 20, left: 10),
        padding: const pw.EdgeInsets.all(6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'SakanOS',
                style: pw.TextStyle(
                  font: arabicBoldFont,
                  fontSize: 11,
                  color: primaryColor,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                l10n.pdfDepositReceipt(copyType),
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
                  l10n.pdfReceiptNo(receiptNo),
                  style: pw.TextStyle(font: arabicFont, fontSize: 8),
                ),
                pw.Text(
                  l10n.pdfReceiptDate(dateStr),
                  style: pw.TextStyle(font: arabicFont, fontSize: 8),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.Text(
              l10n.pdfReceiptClient(client.name),
              style: pw.TextStyle(
                font: arabicBoldFont,
                fontSize: 9,
                color: primaryColor,
              ),
            ),
            pw.Text(
              l10n.pdfReceiptApartment(
                formattedDetails,
                _fmtArea(contract.totalArea),
              ),
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
                    headers: [l10n.pdfHeaderMaterial, l10n.pdfHeaderPrice],
                    data: [
                      [l10n.pdfMatIron, getPriceFormatted('iron')],
                      [l10n.pdfMatFormwork, getPriceFormatted('formwork')],
                      [l10n.pdfMatCement, getPriceFormatted('cement')],
                      [l10n.pdfMatAggregates, getPriceFormatted('aggregates')],
                      [l10n.pdfMatBlock, getPriceFormatted('block')],
                      [l10n.pdfMatWorker, getPriceFormatted('worker')],
                    ],
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  flex: 6,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      border: pw.Border.all(color: accentColor, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      children: [
                        _buildFinancialRow(
                          font: arabicFont,
                          boldFont: arabicBoldFont,
                          title: l10n.pdfApprovedMeterPrice,
                          value: '${_fmtMoney(entry.meterPriceAtPayment)} SYP',
                        ),
                        if (bonusPercentage != null && bonusPercentage != 0)
                          _buildFinancialRow(
                            font: arabicFont,
                            boldFont: arabicBoldFont,
                            title: isPenalty
                                ? l10n.pdfDelayPenalty
                                : l10n.pdfBonusPercentage,
                            value:
                                '%${bonusPercentage.abs().toStringAsFixed(1)}',
                            valueColor: isPenalty
                                ? PdfColors.red
                                : PdfColors.teal,
                          ),
                        if (meterPriceAfterBonus != null)
                          _buildFinancialRow(
                            font: arabicFont,
                            boldFont: arabicBoldFont,
                            title: isPenalty
                                ? l10n.pdfPriceAfterPenalty
                                : l10n.pdfPriceAfterBonus,
                            value: '${_fmtMoney(meterPriceAfterBonus)} SYP',
                            valueColor: PdfColors.blue800,
                          ),
                        if (hasDiscount) ...[
                          _buildFinancialRow(
                            font: arabicFont,
                            boldFont: arabicBoldFont,
                            title: l10n.pdfOriginalInstallment,
                            value: '${_fmtMoney(originalInstallment)} SYP',
                          ),
                          _buildFinancialRow(
                            font: arabicFont,
                            boldFont: arabicBoldFont,
                            title: l10n.pdfDiscountGranted,
                            value: '${_fmtMoney(discountAmount)} SYP',
                            valueColor: PdfColors.red,
                          ),
                        ],
                        _buildFinancialRow(
                          font: arabicFont,
                          boldFont: arabicBoldFont,
                          title: l10n.pdfAmountPaid,
                          value: '${_fmtMoney(absAmountPaid)} SYP',
                          isTotal: true,
                          primaryColor: primaryColor,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Center(
                          child: pw.Text(
                            _formatTafqeet(l10n, absAmountPaid),
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
                        _buildFinancialRow(
                          font: arabicFont,
                          boldFont: arabicBoldFont,
                          title: l10n.pdfConvertedMeters,
                          value: '${_fmtMeters(absConvertedMeters)} m²',
                          isTotal: true,
                          valueColor: isPenalty
                              ? PdfColors.orange900
                              : PdfColors.green800,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  l10n.pdfOfficeSignature,
                  style: pw.TextStyle(
                    font: arabicBoldFont,
                    fontSize: 8,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  l10n.pdfClientSignature,
                  style: pw.TextStyle(
                    font: arabicBoldFont,
                    fontSize: 8,
                    color: primaryColor,
                  ),
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
        textDirection: l10n.localeName == 'ar'
            ? pw.TextDirection.rtl
            : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
        margin: const pw.EdgeInsets.all(3),
        build: (context) => pw.Align(
          alignment: pw.Alignment.topCenter,
          child: pw.SizedBox(
            height: 148 * PdfPageFormat.mm,
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: buildCompactReceipt(l10n.pdfOfficeCopy),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: buildCompactReceipt(l10n.pdfClientCopy),
                ),
              ],
            ),
          ),
        ),
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
