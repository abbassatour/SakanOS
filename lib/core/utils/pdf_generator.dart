//lib\core\utils\pdf_generator.dart
// ==========================================
// 🟩 القسم 1: الاستيرادات (Imports)
// ==========================================
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erp_repository/erp_repository.dart';
import 'arabic_tafqeet.dart';
import 'package:local_storage_api/local_storage_api.dart';

class PdfGenerator {
  
  // ==========================================
  // 🟩 القسم 2: دالة التفقيط (تحويل الأرقام لنصوص)
  // ==========================================
  static String numberToArabicWords(double number) {
    String text = ArabicTafqeet.convert(number.toInt());
    return "فقط $text ليرة سورية لا غير.";
  }

  // ==========================================
  // 🟩 القسم 3: الدالة الرئيسية لتوليد الـ PDF
  // ==========================================
  static Future<Uint8List> generateReceiptPdf({
    required PaymentsLedgerData entry,
    required Contract contract,
    required Client client,
    double? originalInstallment,
    double? bonusPercentage,       // 👈 إضافة نسبة البونص
    double? meterPriceAfterBonus,  // 👈 إضافة سعر المتر بعد البونص
  }) async {
    final pdf = pw.Document();

    // إعدادات الخطوط والألوان الأساسية
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();
    const primaryColor = PdfColor.fromInt(0xFF1A2B3D);
    const accentColor = PdfColor.fromInt(0xFFE64A19);

    // ==========================================
    // 🟩 القسم 4: دالة بناء الإيصال المصغر (الواجهة والمحتوى)
    // ==========================================
    pw.Widget buildCompactReceipt(String copyType) {
      
      // ==========================================
      // 🟩 القسم 5: جلب بيانات الأسعار وحساب الخصم
      // ==========================================
      Map<String, dynamic> snapshot = {};
      try {
        if (entry.pricesSnapshot.isNotEmpty && entry.pricesSnapshot != '{}') {
          snapshot = jsonDecode(entry.pricesSnapshot);
        }
      } catch (e) {
        print('Error decoding prices snapshot: $e');
      }

      String getPrice(String key) {
        return (snapshot[key] as num?)?.toStringAsFixed(0) ?? '-';
      }

      final bool hasDiscount = originalInstallment != null && originalInstallment > entry.amountPaid;
      final double discountAmount = hasDiscount ? originalInstallment! - entry.amountPaid : 0.0;

      return pw.Container(
        margin: const pw.EdgeInsets.only(right: 40), // 👈 هذا هو الهامش اليميني
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children:[
            
            // ==========================================
            // 🟩 القسم 6: الترويسة العليا (اسم الشركة والعنوان)
            // ==========================================
            pw.Center(child: pw.Text('بيتنا Our Home', style: pw.TextStyle(font: arabicBoldFont, fontSize: 11, color: primaryColor))),
            pw.Center(child: pw.Text('إيصال دفع - $copyType', style: pw.TextStyle(font: arabicBoldFont, fontSize: 8, color: accentColor))),
            pw.SizedBox(height: 4),

            // ==========================================
            // 🟩 القسم 7: معلومات الإيصال والعميل والشقة
            // ==========================================
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children:[
              pw.Text('رقم: ${entry.id.split('-').first.toUpperCase()}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
              pw.Text('التاريخ: ${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
            ]),
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.Text('العميل: ${client.name}', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: primaryColor)),
            pw.Text('الشقة: ${contract.apartmentDetails} | م: ${contract.totalArea} م2', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
            pw.SizedBox(height: 6),

            // ==========================================
            // 🟩 القسم 8 و 9: جدول المواد والخلاصة المالية (جنباً إلى جنب)
            // ==========================================
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start, // محاذاة العناصر للأعلى
              children:[
                
                // 🌟 الجانب الأيمن: جدول المواد (عمودين فقط وخط صغير)
                pw.Expanded(
                  flex: 4, // يأخذ 40% من العرض
                  child: pw.TableHelper.fromTextArray(
                    context: null,
                    cellAlignment: pw.Alignment.center,
                    headerStyle: pw.TextStyle(font: arabicBoldFont, fontSize: 6, color: PdfColors.white),
                    headerDecoration: const pw.BoxDecoration(color: primaryColor),
                    cellStyle: pw.TextStyle(font: arabicFont, fontSize: 6), // تصغير الخط
                    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(0.8), // المادة
                      1: const pw.FlexColumnWidth(1.2), // السعر
                    },
                    headers: ['المادة', 'السعر'],
                    data: [['حديد', getPrice('iron')],
                      ['كوفراج', getPrice('formwork')],
                      ['اسمنت', getPrice('cement')],
                      ['حصويات', getPrice('aggregates')],
                      ['بلوك', getPrice('block')],
                      ['عمال', getPrice('worker')],
                    ],
                  ),
                ),

                pw.SizedBox(width: 6), // 🌟 مسافة فاصلة بين الجدول والخلاصة

                // 🌟 الجانب الأيسر: الخلاصة المالية
                pw.Expanded(
                  flex: 6, // يأخذ 60% من العرض (لأن نصوصه أطول)
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(4), 
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      border: pw.Border.all(color: accentColor, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      children:[
                        _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'سعر المتر بتاريخه:', value: '${entry.meterPriceAtPayment.toStringAsFixed(0)} ل.س'),
                        
                        if (bonusPercentage != null && bonusPercentage > 0)
                          _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'نسبة البونص:', value: '%${bonusPercentage.toStringAsFixed(1)}', valueColor: PdfColors.teal),

                        if (meterPriceAfterBonus != null)
                          _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'السعر بعد البونص:', value: '${meterPriceAfterBonus.toStringAsFixed(0)} ل.س', valueColor: PdfColors.blue800),
                        
                        if(hasDiscount) ...[
                          _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'أصل القسط:', value: '${originalInstallment!.toStringAsFixed(0)} ل.س'),
                          _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'الخصم الممنوح:', value: '${discountAmount.toStringAsFixed(0)} ل.س', valueColor: PdfColors.red),
                        ],

                        _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'المبلغ المدفوع:', value: '${entry.amountPaid.toStringAsFixed(0)} ل.س', isTotal: true, primaryColor: primaryColor),
                        
                        pw.SizedBox(height: 2),
                        pw.Center(
                          child: pw.Text(numberToArabicWords(entry.amountPaid), style: pw.TextStyle(font: arabicFont, fontSize: 5.5, color: PdfColors.grey700), textAlign: pw.TextAlign.center), // تصغير خط التفقيط
                        ),

                        pw.Divider(color: PdfColors.grey300, thickness: 0.5, height: 6),
                        
                        _buildFinancialRow(font: arabicFont, boldFont: arabicBoldFont, title: 'الأمتار المحولة:', value: '${entry.convertedMeters.toStringAsFixed(3)} م2', isTotal: true, valueColor: PdfColors.green800),
                      ]
                    )
                  ),
                ),
              ],
            ),

            pw.Spacer(),

            // ==========================================
            // 🟩 القسم 10: التذييل (معلومات العقد والتوقيع)
            // ==========================================
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children:[
                
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children:[
                    pw.Text('توقيع الشركة', style: pw.TextStyle(font: arabicBoldFont, fontSize: 8, color: primaryColor)),
                    pw.SizedBox(height: 20),
                  ]
                ),
              ]
            ),
          ],
        ),
      );
    }

    // ==========================================
    // 🟩 القسم 11: إعداد صفحة الطباعة (نصف A4 وتكرار الإيصال)
    // ==========================================
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
                children:[
                  pw.Expanded(child: buildCompactReceipt('نسخة الشركة')),
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

  // ==========================================
  // 🟩 القسم 12: الدوال المساعدة (تنسيق السطور المالية بحجم مصغر)
  // ==========================================
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
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5), // تقليل المسافة العمودية
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children:[
          // 🌟 تم تصغير الخطوط بدرجة إلى درجتين لتتناسب مع التخطيط الجديد
          pw.Expanded(
            child: pw.Text(title, style: pw.TextStyle(font: isTotal ? boldFont : font, fontSize: isTotal ? 7.5 : 6.5, color: isTotal ? primaryColor : PdfColors.black)),
          ),
          pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: isTotal ? 8.5 : 7.5, color: valueColor ?? (isTotal ? primaryColor : PdfColors.black))),
        ],
      ),
    );
  }
}