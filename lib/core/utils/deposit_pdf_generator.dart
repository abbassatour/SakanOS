import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'arabic_tafqeet.dart';

class DepositPdfGenerator {
  static String _fmtMoney(double amount) => NumberFormat("#,###", "en_US").format(amount.abs().round());
  static String _fmtMeters(double meters) => meters.abs().toStringAsFixed(4);
  static String _fmtArea(double area) {
    final f = NumberFormat.decimalPattern();
    f.minimumFractionDigits = 0;
    f.maximumFractionDigits = 2;
    return f.format(area);
  }

  static Future<Uint8List> generate({
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
      try { if (entry.pricesSnapshot.isNotEmpty) snapshot = jsonDecode(entry.pricesSnapshot); } catch (_) {}

      String getPriceFormatted(String key) {
        final val = (snapshot[key] as num?)?.toDouble();
        return val != null ? _fmtMoney(val) : '-';
      }

      final double absAmountPaid = entry.amountPaid.abs();
      final double absConvertedMeters = entry.convertedMeters.abs();
      final bool hasDiscount = originalInstallment != null && originalInstallment > absAmountPaid;
      final double discountAmount = hasDiscount ? originalInstallment! - absAmountPaid : 0.0;

      // 🌟 التمييز الذكي: هل هي غرامة أم بونص؟ (بناءً على إشارة الرقم)
      final bool isPenalty = bonusPercentage != null && bonusPercentage < 0;

      return pw.Container(
        margin: const pw.EdgeInsets.only(right: 40), 
        padding: const pw.EdgeInsets.all(6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children:[
            pw.Center(child: pw.Text('بيتنا Our Home', style: pw.TextStyle(font: arabicBoldFont, fontSize: 11, color: primaryColor))),
            pw.Center(child: pw.Text('إيصال دفع - $copyType', style: pw.TextStyle(font: arabicBoldFont, fontSize: 8, color: accentColor))),
            pw.SizedBox(height: 4),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children:[
              pw.Text('رقم: ${entry.id.split('-').first.toUpperCase()}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
              pw.Text('التاريخ: ${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
            ]),
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.Text('العميل: ${client.name}', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: primaryColor)),
            pw.Text('الشقة: ${contract.apartmentDetails} | م: ${_fmtArea(contract.totalArea)} م2', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
            pw.SizedBox(height: 6),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start, 
              children:[
                pw.Expanded(
                  flex: 4, 
                  child: pw.TableHelper.fromTextArray(
                    context: null,
                    cellAlignment: pw.Alignment.center,
                    headerStyle: pw.TextStyle(font: arabicBoldFont, fontSize: 6, color: PdfColors.white),
                    headerDecoration: pw.BoxDecoration(color: primaryColor),
                    cellStyle: pw.TextStyle(font: arabicFont, fontSize: 6), 
                    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                    columnWidths: {0: const pw.FlexColumnWidth(0.8), 1: const pw.FlexColumnWidth(1.2)},
                    headers:['المادة', 'السعر'],
                    data: [['حديد', getPriceFormatted('iron')],['كوفراج', getPriceFormatted('formwork')],['اسمنت', getPriceFormatted('cement')],['حصويات', getPriceFormatted('aggregates')],['بلوك', getPriceFormatted('block')],['عمال', getPriceFormatted('worker')]],
                  ),
                ),
                pw.SizedBox(width: 6), 
                pw.Expanded(
                  flex: 6, 
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(4), 
                    decoration: pw.BoxDecoration(color: PdfColors.grey100, border: pw.Border.all(color: accentColor, width: 0.5), borderRadius: pw.BorderRadius.circular(4)),
                    child: pw.Column(children:[
                      _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'سعر المتر المعتمد:', value: '${_fmtMoney(entry.meterPriceAtPayment)} ل.س'),
                      
                      // 🌟 التغيير الذكي للمسمى واللون
                      if (bonusPercentage != null && bonusPercentage != 0)
                        _buildFinancialRow(
                          font: arabicFont, 
                          boldFont: arabicBoldFont, 
                          title: isPenalty ? 'غرامة تأخير:' : 'نسبة البونص:', 
                          value: '%${bonusPercentage.abs().toStringAsFixed(1)}', 
                          valueColor: isPenalty ? PdfColors.red : PdfColors.teal // أحمر للغرامة، تيل للبونص
                        ),
                      
                      if (meterPriceAfterBonus != null)
                        _buildFinancialRow(
                          font: arabicFont, 
                          boldFont: arabicBoldFont, 
                          title: isPenalty ? 'السعر بعد الغرامة:' : 'السعر بعد البونص:', 
                          value: '${_fmtMoney(meterPriceAfterBonus)} ل.س', 
                          valueColor: PdfColors.blue800
                        ),
                        
                      if(hasDiscount) ...[
                        _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'أصل القسط:', value: '${_fmtMoney(originalInstallment!)} ل.س'),
                        _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'الخصم الممنوح:', value: '${_fmtMoney(discountAmount)} ل.س', valueColor: PdfColors.red),
                      ],
                      _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'المبلغ المدفوع:', value: '${_fmtMoney(absAmountPaid)} ل.س', isTotal: true, primaryColor: primaryColor),
                      pw.SizedBox(height: 2),
                      pw.Center(child: pw.Text("فقط ${ArabicTafqeet.convert(absAmountPaid.toInt())} ليرة سورية لا غير.", style: pw.TextStyle(font: arabicFont, fontSize: 5.5, color: PdfColors.grey700), textAlign: pw.TextAlign.center)), 
                      pw.Divider(color: PdfColors.grey300, thickness: 0.5, height: 6),
                      _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'الأمتار المحولة:', value: '${_fmtMeters(absConvertedMeters)} م2', isTotal: true, valueColor: isPenalty ? PdfColors.orange900 : PdfColors.green800), // لون مميز للأمتار إذا كان هناك تأخير
                    ])
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children:[
              pw.Text('توقيع الشركة', style: pw.TextStyle(font: arabicBoldFont, fontSize: 8, color: primaryColor)),
              pw.Text('توقيع العميل', style: pw.TextStyle(font: arabicBoldFont, fontSize: 8, color: primaryColor)),
            ]),
          ],
        ),
      );
    }

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
      margin: const pw.EdgeInsets.all(3),
      build: (context) => pw.Align(
        alignment: pw.Alignment.topCenter,
        child: pw.SizedBox(height: 148 * PdfPageFormat.mm, child: pw.Row(children:[pw.Expanded(child: buildCompactReceipt('نسخة الشركة')), pw.SizedBox(width: 20), pw.Expanded(child: buildCompactReceipt('نسخة العميل'))])),
      ),
    ));
    return pdf.save();
  }

  static pw.Widget _buildFinancialRow({required pw.Font font, required pw.Font boldFont, required String title, required String value, bool isTotal = false, PdfColor? valueColor, PdfColor? primaryColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5), 
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children:[
        pw.Expanded(child: pw.Text(title, style: pw.TextStyle(font: isTotal ? boldFont : font, fontSize: isTotal ? 7.5 : 6.5, color: isTotal ? primaryColor : PdfColors.black))),
        pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: isTotal ? 8.5 : 7.5, color: valueColor ?? (isTotal ? primaryColor : PdfColors.black))),
      ]),
    );
  }
}