// lib/core/utils/ledger_pdf_helper.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'; 

class LedgerPdfHelper {
  
  // دالة مساعدة لتنسيق الأرقام
  static String formatWithCommas(num number) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
  }

  // دالة مساعدة لتنسيق التواريخ
  static String formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static Future<Uint8List> generateLedgerReportPdf({
    required List<PaymentsLedgerData> ledgerEntries,
    required Contract contract,
    required Client client,
    Apartment? apartment, 
    Building? building,   
  }) async {
    final pdf = pw.Document();

    // جلب الخطوط العربية
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    // لوحة الألوان الاحترافية (مصححة لمكتبة PDF)
    const primaryColor = PdfColor.fromInt(0xFF1A237E); // أزرق داكن (كحلي)
    const primaryLightColor = PdfColor.fromInt(0xFFE8EAF6); // لون كحلي فاتح جداً (بديل للشفافية)
    const accentColor = PdfColor.fromInt(0xFFE64A19);  // برتقالي داكن
    const greyBgColor = PdfColor.fromInt(0xFFF5F5F5);  // رمادي فاتح جداً للخلفيات
    const borderColor = PdfColor.fromInt(0xFFE0E0E0);  // لون الحدود

    // الحسابات الذكية
    double totalPaid = ledgerEntries.fold(0, (sum, item) => sum + item.amountPaid);
    double totalMeters = ledgerEntries.fold(0, (sum, item) => sum + item.convertedMeters);
    double remainingMeters = contract.totalArea - totalMeters;
    final bool isAllocated = contract.contractType == 'متخصص';

    // الترتيب الزمني للسجل
    final sortedEntries = List<PaymentsLedgerData>.from(ledgerEntries)
      ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));

    // ==========================================
    // 🛠️ دوال مساعدة لرسم الـ PDF باحترافية
    // ==========================================
    pw.Widget buildSectionTitle(String title, pw.IconData icon) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 6, top: 12),
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const pw.BoxDecoration(
          color: primaryLightColor, // 🌟 استخدمنا اللون الصريح بدلاً من opacity
          border: pw.Border(right: pw.BorderSide(color: primaryColor, width: 3)),
        ),
        child: pw.Row(
          children:[
            pw.Text(title, style: pw.TextStyle(font: arabicBoldFont, fontSize: 11, color: primaryColor)),
          ]
        ),
      );
    }

    pw.Widget buildGridRow(List<String> labels, List<String> values) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: borderColor, width: 0.5))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: List.generate(labels.length, (index) {
            return pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children:[
                  pw.Text(labels[index], style: pw.TextStyle(font: arabicFont, fontSize: 7, color: PdfColors.grey700)),
                  pw.SizedBox(height: 1),
                  pw.Text(values[index], style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: PdfColors.black)),
                ]
              ),
            );
          }),
        ),
      );
    }

    // ==========================================
    // 📄 بناء الصفحة
    // ==========================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
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
                      pw.Text('Our Home', style: pw.TextStyle(font: arabicBoldFont, fontSize: 18, color: primaryColor)), 
                      pw.Text('للتطوير والاستثمار العقاري', style: pw.TextStyle(font: arabicFont, fontSize: 9, color: PdfColors.grey700)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children:[
                      pw.Text('كشف حساب ', style: pw.TextStyle(font: arabicBoldFont, fontSize: 16, color: accentColor, letterSpacing: 1)),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: pw.BoxDecoration(color: greyBgColor, borderRadius: pw.BorderRadius.circular(4)),
                        child: pw.Text('تاريخ الإصدار: ${formatDate(DateTime.now())}', style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                      )
                    ]
                  ),
                ]
              ),
              pw.SizedBox(height: 12), 
              pw.Divider(color: primaryColor, thickness: 1.5),
            ]
          );
        },

        build: (pw.Context context) {
          return[
            
            // ==========================================
            // 👤 1. بيانات العميل والعقار
            // ==========================================
            buildSectionTitle('بيانات الفريق الثاني (العميل) والعقار المخصص', const pw.IconData(0xe7fd)),
            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(color: borderColor), borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Column(
                children:[
                  buildGridRow(['اسم العميل', 'رقم الهاتف', 'الرقم الوطني', 'كود العميل'],[client.name, client.phone, client.nationalId ?? 'غير مدون', client.id.split('-').first.toUpperCase()]
                  ),
                  buildGridRow(['نوع العقد', 'المحضر (المشروع)', 'رقم الشقة', 'الطابق والاتجاه'],[
                      contract.contractType, 
                      building?.name ?? "غير محدد", 
                      apartment?.apartmentNumber ?? "أسهم / غير مخصص", 
                      isAllocated ? '${apartment?.floorName ?? "-"} | ${apartment?.directionName ?? "-"}' : 'غير محدد'
                    ]
                  ),
                ]
              )
            ),

            // ==========================================
            // 📄 2. الشروط التعاقدية والتسليم
            // ==========================================
            buildSectionTitle('التفاصيل التعاقدية وشروط التسليم', const pw.IconData(0xe873)),
            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(color: borderColor), borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Column(
                children:[
                  buildGridRow(['تاريخ التوقيع', 'المساحة الإجمالية', 'سعر المتر الأساسي', 'اسم الكفيل الضامن'],[
                      formatDate(contract.contractDate), 
                      '${contract.totalArea} م²', 
                      '${formatWithCommas(contract.baseMeterPriceAtSigning)} ل.س', 
                      contract.guarantorName
                    ]
                  ),
                  buildGridRow(['الدفعة المقدمة', 'القسط الشهري المتفق عليه', 'مدة التقسيط المسجلة', 'حالة التسليم الفعلي'],[
                      '${formatWithCommas(contract.downPayment)} ل.س', 
                      '${formatWithCommas(contract.agreedMonthlyAmount)} ل.س', 
                      '${contract.installmentsCount} أشهر', 
                      isAllocated 
                        ? (contract.isHandedOver ? 'مُسلّمة للعميل' : 'قيد الإنشاء') 
                        : 'لا يوجد تسليم (محفظة)'
                    ]
                  ),
                  
                  // إظهار سطر الغرامات والتسليم فقط للعقود المتخصصة
                  if (isAllocated)
                    buildGridRow(['الموعد المتفق عليه للتسليم', 'تاريخ التسليم الفعلي', 'فترة السماح (للمطور)', 'غرامة التأخير (بعد التسليم)'],[
                        formatDate(contract.agreedHandoverDate), 
                        contract.isHandedOver ? formatDate(contract.actualHandoverDate) : 'لم تسلم بعد', 
                        '${contract.gracePeriodMonths} أشهر', 
                        (contract.isPenaltyActive ?? false) 
                          ? 'مفعلة (${contract.penaltyPercentage}% كل ${contract.penaltyIntervalMonths} شهر)' 
                          : 'غير مفعلة'
                      ]
                    ),
                ]
              )
            ),

            pw.SizedBox(height: 16),

            // ==========================================
            // 💰 3. الخلاصة المالية (شريط بارز)
            // ==========================================
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children:[
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children:[
                    pw.Text('إجمالي المبالغ المسددة', style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text('${formatWithCommas(totalPaid)} ل.س', style: pw.TextStyle(font: arabicBoldFont, fontSize: 12, color: PdfColors.green400)),
                  ]),
                  // 🌟 استبدلنا الشفافية بلون رمادي ثابت
                  pw.Container(width: 1, height: 24, color: PdfColors.grey500),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children:[
                    pw.Text('صافي الأمتار المملوكة للعميل', style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text('${totalMeters.toStringAsFixed(3)} م²', style: pw.TextStyle(font: arabicBoldFont, fontSize: 12, color: PdfColors.white)),
                  ]),
                  pw.Container(width: 1, height: 24, color: PdfColors.grey500),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children:[
                    pw.Text('الأمتار المتبقية لصالح الشركة', style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text('${remainingMeters > 0 ? remainingMeters.toStringAsFixed(3) : "0 (مكتمل)"} م²', 
                      style: pw.TextStyle(font: arabicBoldFont, fontSize: 12, color: remainingMeters > 0 ? PdfColors.red300 : PdfColors.green400)),
                  ]),
                ]
              ),
            ),
            
            pw.SizedBox(height: 16),

            // ==========================================
            // 📊 4. السجل المالي المفصل (الجدول)
            // ==========================================
            buildSectionTitle('السجل المالي المفصل وحركة الأمتار', const pw.IconData(0xe85d)),
            
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
              children:[
                // رأس الجدول
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: greyBgColor),
                  children:[
                    'رقم الإيصال', 'تاريخ الدفع', 'المبلغ (ل.س)', 'سعر المتر المعتمد', 'البونص %', 'الأمتار المحولة'
                  ].map((text) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: pw.Center(child: pw.Text(text, style: pw.TextStyle(font: arabicBoldFont, color: primaryColor, fontSize: 8))),
                  )).toList(),
                ),
                // بيانات الجدول
                ...sortedEntries.asMap().entries.map((mapEntry) {
                  final int index = mapEntry.key;
                  final entry = mapEntry.value;
                  
                  final bool isRefund = entry.amountPaid < 0;
                  final textColor = isRefund ? PdfColors.red800 : PdfColors.green800;
                  final bool isFirstPayment = index == 0;

                  return pw.TableRow(
                    children:[
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children:[
                            pw.Text(entry.id.split('-').first.toUpperCase(), style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                            if (isFirstPayment && !isRefund)
                              pw.Text('(دفعة أولى)', style: pw.TextStyle(font: arabicBoldFont, fontSize: 6, color: accentColor)),
                          ]
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Center(child: pw.Text(formatDate(entry.paymentDate), style: pw.TextStyle(font: arabicFont, fontSize: 8))),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Center(child: pw.Text('${isRefund ? "" : "+"}${formatWithCommas(entry.amountPaid)}', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: textColor))),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Center(child: pw.Text(formatWithCommas(entry.meterPriceAtPayment), style: pw.TextStyle(font: arabicFont, fontSize: 8))),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Center(child: pw.Text('${entry.fees.toStringAsFixed(1)}%', style: pw.TextStyle(font: arabicFont, fontSize: 8))),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Center(child: pw.Text('${isRefund ? "" : "+"}${entry.convertedMeters.toStringAsFixed(3)}', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: textColor))),
                      ),
                    ]
                  );
                }),
              ]
            ),
            
            pw.SizedBox(height: 12),
            
            pw.Text(
              '* ملاحظة هامة: عدد الأمتار المشتراة يعتبر حقاً مكتسباً للعميل، وهو محمي ضد التضخم ولا يتأثر بتقلبات أسعار المواد المستقبلية. (اللون الأحمر في الجدول يشير لعمليات الاسترداد أو خصم الرصيد).',
              style: pw.TextStyle(font: arabicFont, fontSize: 7, color: PdfColors.grey600),
            ),
          ];
        },
        
        footer: (pw.Context context) {
          return pw.Column(
            children:[
              pw.Divider(color: borderColor, thickness: 1),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children:[
                  pw.Text('نظام Our Home العقاري لإدارة الأملاك', style: pw.TextStyle(font: arabicFont, color: PdfColors.grey600, fontSize: 8)),
                  pw.Text('صفحة ${context.pageNumber} من ${context.pagesCount}', style: pw.TextStyle(font: arabicFont, color: PdfColors.grey600, fontSize: 8)),
                  pw.Row(
                    children:[
                      pw.Text('توقيع المحاسب: ', style: pw.TextStyle(font: arabicFont, color: PdfColors.grey600, fontSize: 8)),
                      // 🌟 التصحيح: وضعنا الـ border داخل pw.BoxDecoration
                      pw.Container(
                        width: 80, 
                        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5)))
                      ),
                    ]
                  )
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