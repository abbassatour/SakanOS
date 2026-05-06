// lib/core/utils/ledger_pdf_helper.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'; 

class LedgerPdfHelper {
  static Future<Uint8List> generateLedgerReportPdf({
    required List<PaymentsLedgerData> ledgerEntries,
    required Contract contract,
    required Client client,
    Apartment? apartment, 
    Building? building,   
  }) async {
    final pdf = pw.Document();

    // 🌟 جلب الخطوط
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    const primaryColor = PdfColor.fromInt(0xFF1A2B3D); 
    const accentColor = PdfColor.fromInt(0xFFE64A19); 

    // الحسابات الذكية للموازين (ستخصم الأرقام السالبة تلقائياً)
    double totalPaid = ledgerEntries.fold(0, (sum, item) => sum + item.amountPaid);
    double totalMeters = ledgerEntries.fold(0, (sum, item) => sum + item.convertedMeters);
    double remainingMeters = contract.totalArea - totalMeters;

    String formatDate(DateTime date) => '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

    // ==========================================
    // 🌟 الترتيب الزمني: من الأقدم إلى الأحدث
    // ==========================================
    final sortedEntries = List<PaymentsLedgerData>.from(ledgerEntries)
      ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
        
        header: (pw.Context context) {
          return pw.Column(
            children:[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children:[
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children:[
                      pw.Text('بيتنا ', style: pw.TextStyle(font: arabicBoldFont, fontSize: 16, color: primaryColor)), 
                      pw.Text('Our Home ', style: pw.TextStyle(font: arabicFont, fontSize: 7, color: PdfColors.grey700)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children:[
                      pw.Text('كشف حساب العميل', style: pw.TextStyle(font: arabicBoldFont, fontSize: 14, color: accentColor)),
                      pw.SizedBox(height: 2),
                      pw.Text('تاريخ الإصدار: ${formatDate(DateTime.now())}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                    ]
                  ),
                ]
              ),
              pw.SizedBox(height: 8), 
              pw.Divider(color: primaryColor, thickness: 1),
              pw.SizedBox(height: 8), 
            ]
          );
        },

        build: (pw.Context context) {
          return[
            
            // --- هوية العميل ---
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              padding: const pw.EdgeInsets.all(8), 
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children:[
                  pw.Text(' هوية الفريق الثاني (العميل)', style: pw.TextStyle(font: arabicBoldFont, color: primaryColor, fontSize: 10)),
                  pw.SizedBox(height: 6), 
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children:[
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
                        pw.Text('الاسم: ${client.name}', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9)),
                        pw.SizedBox(height: 2),
                        pw.Text('رقم الهاتف: ${client.phone}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                      ]),
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
                        pw.Text('الرقم الوطني: ${client.nationalId ?? 'غير مدون'}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                        pw.SizedBox(height: 2),
                        pw.Text('كود العميل: ${client.id.split('-').first.toUpperCase()}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                      ]),
                    ]
                  ),
                ]
              )
            ),
            pw.SizedBox(height: 8), 

            // --- هوية العقد والشقة التفصيلية ---
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                border: pw.Border.all(color: primaryColor, width: 0.5),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              padding: const pw.EdgeInsets.all(8), 
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children:[
                  pw.Text(' تفاصيل العقد والمواصفات', style: pw.TextStyle(font: arabicBoldFont, color: primaryColor, fontSize: 10)),
                  pw.SizedBox(height: 6),
                  
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
                        pw.Text('نوع العقد: ${contract.contractType}', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: accentColor)),
                        pw.SizedBox(height: 2),
                        pw.Text('المحضر (البناء): ${building?.name ?? "غير محدد"}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                        pw.SizedBox(height: 2),
                        pw.Text('الموقع: ${building?.location ?? "غير محدد"}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                      ]),
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
                        pw.Text('رقم الشقة: ${apartment?.apartmentNumber ?? "-"}', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9)),
                        pw.SizedBox(height: 2),
                        pw.Text('الطابق: ${apartment?.floorName ?? "-"}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                        pw.SizedBox(height: 2),
                        pw.Text('الاتجاه: ${apartment?.directionName ?? "-"}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                      ]),
                    ]
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(color: PdfColors.grey400, thickness: 0.5),
                  pw.SizedBox(height: 4),
                  
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children:[
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
                        pw.Text('المساحة الإجمالية: ${contract.totalArea} م2', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9)),
                        pw.SizedBox(height: 2),
                        pw.Text('تاريخ التوقيع: ${formatDate(contract.contractDate)}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                        pw.SizedBox(height: 2),
                        pw.Text('الكفيل: ${contract.guarantorName}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                      ]),
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
                        pw.Text('مدة الأقساط: ${contract.installmentsCount} شهراً', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                        pw.SizedBox(height: 2),
                        pw.Text('سعر المتر عند التوقيع: ${contract.baseMeterPriceAtSigning.toStringAsFixed(0)} ل.س', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                        pw.SizedBox(height: 2),
                      ]),
                    ]
                  ),
                ]
              )
            ),
            pw.SizedBox(height: 12), 

            // --- الخلاصة المالية ---
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: pw.BoxDecoration(
                border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3)),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
                    pw.Text('صافي المبالغ المسددة', style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700)),
                    pw.SizedBox(height: 2),
                    pw.Text('${totalPaid.toStringAsFixed(0)} ل.س', style: pw.TextStyle(font: arabicBoldFont, fontSize: 10, color: primaryColor)),
                  ]),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
                    pw.Text('صافي الأمتار المملوكة', style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700)),
                    pw.SizedBox(height: 2),
                    pw.Text('${totalMeters.toStringAsFixed(3)} م2', style: pw.TextStyle(font: arabicBoldFont, fontSize: 10, color: PdfColors.green700)),
                  ]),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
                    pw.Text('الأمتار المتبقية للشركة', style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700)),
                    pw.SizedBox(height: 2),
                    pw.Text('${remainingMeters > 0 ? remainingMeters.toStringAsFixed(3) : "0 (مكتمل)"} م2', 
                      style: pw.TextStyle(font: arabicBoldFont, fontSize: 10, color: remainingMeters > 0 ? PdfColors.red700 : PdfColors.green700)),
                  ]),
                ]
              ),
            ),
            pw.SizedBox(height: 12),

            // --- جدول الحركات ---
            pw.Text('📊 السجل المالي المفصل ', style: pw.TextStyle(font: arabicBoldFont, fontSize: 10, color: primaryColor)),
            pw.SizedBox(height: 8),
            
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2), // الإيصال
                1: const pw.FlexColumnWidth(1.5), // التاريخ
                2: const pw.FlexColumnWidth(2.0), // المبلغ
                3: const pw.FlexColumnWidth(1.5), // سعر المتر
                4: const pw.FlexColumnWidth(1.2), // البونص
                5: const pw.FlexColumnWidth(1.5), // الأمتار
              },
              children:[
                // رأس الجدول
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: primaryColor),
                  children:[
                    'الإيصال', 'التاريخ', 'المبلغ (ل.س)', 'سعر المتر', 'نسبة البونص', 'الأمتار'
                  ].map((text) => pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Center(child: pw.Text(text, style: pw.TextStyle(font: arabicBoldFont, color: PdfColors.white, fontSize: 8))),
                  )).toList(),
                ),
                // بيانات الجدول مرتبة من الأقدم للأحدث
                ...sortedEntries.asMap().entries.map((mapEntry) {
                  final int index = mapEntry.key;
                  final entry = mapEntry.value;
                  
                  final bool isRefund = entry.amountPaid < 0;
                  final textColor = isRefund ? PdfColors.red800 : PdfColors.green800;
                  
                  // 🌟 تمييز الدفعة الأولى
                  final bool isFirstPayment = index == 0;

                  return pw.TableRow(
                    children:[
                      // الإيصال (مع إضافة عبارة دفعة أولى إذا كانت هي الدفعة الأولى)
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children:[
                            pw.Text(entry.id.split('-').first.toUpperCase(), style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                            if (isFirstPayment && !isRefund)
                              pw.Text('(دفعة أولى)', style: pw.TextStyle(font: arabicBoldFont, fontSize: 6, color: accentColor)),
                          ]
                        ),
                      ),
                      // التاريخ
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Center(child: pw.Text(formatDate(entry.paymentDate), style: pw.TextStyle(font: arabicFont, fontSize: 8))),
                      ),
                      // المبلغ
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Center(child: pw.Text('${isRefund ? "" : "+"}${entry.amountPaid.toStringAsFixed(0)}', style: pw.TextStyle(font: arabicBoldFont, fontSize: 8, color: textColor))),
                      ),
                      // سعر المتر
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Center(child: pw.Text(entry.meterPriceAtPayment.toStringAsFixed(0), style: pw.TextStyle(font: arabicFont, fontSize: 8))),
                      ),
                      // نسبة البونص
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Center(child: pw.Text('${entry.fees.toStringAsFixed(1)} %', style: pw.TextStyle(font: arabicFont, fontSize: 8))),
                      ),
                      // الأمتار
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Center(child: pw.Text('${isRefund ? "" : "+"}${entry.convertedMeters.toStringAsFixed(3)}', style: pw.TextStyle(font: arabicBoldFont, fontSize: 8, color: textColor))),
                      ),
                    ]
                  );
                }),
              ]
            ),
            
            pw.SizedBox(height: 8),
            
            pw.Text(
              '* ملاحظة: عدد الأمتار المشتراة يعتبر حقاً مكتسباً للعميل، وهو محمي ضد التضخم ولا يتأثر بتقلبات أسعار المواد المستقبلية. (اللون الأحمر في الجدول يشير لعمليات الاسترداد أو الخصم).',
              style: pw.TextStyle(font: arabicFont, fontSize: 7, color: PdfColors.grey600),
            ),
          ];
        },
        
        footer: (pw.Context context) {
          return pw.Column(
            children:[
              pw.Divider(color: PdfColors.grey300, thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children:[
                  pw.Text('Our Home ERP System', style: pw.TextStyle(font: arabicFont, color: PdfColors.grey600, fontSize: 7)),
                  pw.Text('صفحة ${context.pageNumber} من ${context.pagesCount}', style: pw.TextStyle(font: arabicFont, color: PdfColors.grey600, fontSize: 8)),
                  pw.Text('المدقق المالي: _______________', style: pw.TextStyle(font: arabicFont, color: PdfColors.grey600, fontSize: 8)),
                ]
              ),
            ]
          );
        },
      ),
    );

    return pdf.save();
  }
}