//lib\core\utils\excel_export_helper.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:erp_repository/erp_repository.dart';

class ExcelExportHelper {
  /// 🌟 دالة سحرية لتصدير "الأقساط" إلى ملف Excel (.xlsx) حقيقي
  static Future<String?> exportLedgerToExcel({
    required List<PaymentsLedgerData> ledgerEntries,
    required Contract contract,
    required Client client,
  }) async {
    try {
      // 1. إنشاء ملف إكسل جديد
      var excel = Excel.createExcel();

      // تغيير اسم الورقة الافتراضية
      String sheetName = ' الأمتار المحولة';
      excel.rename('Sheet1', sheetName);
      Sheet sheetObject = excel[sheetName];

      // 2. إعداد ترويسة الجدول (Headers)
      List<CellValue> headers = [
        TextCellValue('رقم الإيصال'),
        TextCellValue('المبلغ المدفوع (ل.س)'),
        TextCellValue('سعر المتر وقت الدفع (ل.س)'),
        TextCellValue('الأمتار المحولة (م2)'),
        TextCellValue('الرسوم (ل.س)'),
        TextCellValue('تاريخ الدفع'),
      ];
      sheetObject.appendRow(headers);

      // 3. تعبئة البيانات (Rows) بالترتيب
      for (final entry in ledgerEntries) {
        List<CellValue> row = [
          TextCellValue(
            // 🌟 التعديل هنا:
            entry.receiptNumber != null
                ? entry.receiptNumber.toString()
                : entry.id.split('-').first.toUpperCase(),
          ),
          DoubleCellValue(entry.amountPaid),
          DoubleCellValue(entry.meterPriceAtPayment),
          DoubleCellValue(entry.convertedMeters),
          DoubleCellValue(entry.fees),
          TextCellValue(
            '${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}',
          ),
        ];
        sheetObject.appendRow(row);
      }

      // 4. تحديد مسار الحفظ (سيبحث عن مجلد التنزيلات Downloads في الويندوز)
      Directory? directory = await getDownloadsDirectory();
      // إذا لم يجد مجلد التنزيلات، سيستخدم مجلد المستندات (Documents) كبديل آمن
      directory ??= await getApplicationDocumentsDirectory();

      // تنظيف اسم العميل من أي رموز قد يرفضها الويندوز في اسم الملف
      String safeClientName = client.name.replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '_',
      );
      String fileName = 'دفتر_الأستاذ_$safeClientName.xlsx';
      String fullPath = p.join(directory.path, fileName); // ✅ الحل الاحترافي

      // 5. حفظ الملف في الكمبيوتر
      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(fullPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        return fullPath; // نُرجع المسار لكي نخبر المحاسب أين تم حفظ الملف
      }
      return null;
    } catch (e) {
      print('Error exporting to Excel: $e');
      return null;
    }
  }
}
