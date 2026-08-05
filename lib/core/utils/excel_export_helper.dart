// lib/core/utils/excel_export_helper.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class ExcelExportHelper {
  static Future<String?> exportLedgerToExcel({
    required AppLocalizations l10n,
    required List<PaymentsLedgerData> ledgerEntries,
    required Contract contract,
    required Client client,
  }) async {
    try {
      var excel = Excel.createExcel();

      String sheetName = l10n.excelSheetName;
      excel.rename('Sheet1', sheetName);
      Sheet sheetObject = excel[sheetName];

      List<CellValue> headers = [
        TextCellValue(l10n.excelColReceipt),
        TextCellValue(l10n.excelColPaidAmount),
        TextCellValue(l10n.excelColMeterPrice),
        TextCellValue(l10n.excelColConvertedMeters),
        TextCellValue(l10n.excelColFees),
        TextCellValue(l10n.excelColDate),
      ];
      sheetObject.appendRow(headers);

      for (final entry in ledgerEntries) {
        List<CellValue> row = [
          TextCellValue(
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

      Directory? directory = await getDownloadsDirectory();
      directory ??= await getApplicationDocumentsDirectory();

      String safeClientName = client.name.replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '_',
      );
      String fileName = l10n.excelFileName(safeClientName);
      String fullPath = p.join(directory.path, fileName);

      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(fullPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        return fullPath;
      }
      return null;
    } catch (e) {
      print('Error exporting to Excel: $e');
      return null;
    }
  }
}
