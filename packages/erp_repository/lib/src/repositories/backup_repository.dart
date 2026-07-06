// packages/erp_repository/lib/src/repositories/backup_repository.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupRepository {
  const BackupRepository({required LocalStorageApi localApi})
    : _localApi = localApi;

  final LocalStorageApi _localApi;
  static const String _dbFileName = 'our_home_erp_v14_legal_system.sqlite';

  Future<void> autoBackupSilent() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(supportDir.path, _dbFileName));

      if (!await dbFile.exists()) return;

      final docsDir = await getApplicationDocumentsDirectory();
      final backupFolder = Directory(
        p.join(docsDir.path, 'OurHomeERP_AutoBackups'),
      );

      if (!await backupFolder.exists()) {
        await backupFolder.create(recursive: true);
      }

      final dateOnly = DateTime.now().toIso8601String().split('T')[0];
      final backupPath = p.join(
        backupFolder.path,
        'AutoBackup_$dateOnly.sqlite',
      );

      await dbFile.copy(backupPath);
      // ignore: avoid_print
      print('🛡️[Auto-Backup]: تم أخذ نسخة احتياطية بنجاح ليوم $dateOnly');
    } on Exception catch (e) {
      // ignore: avoid_print
      print('⚠️ [Auto-Backup] فشل النسخ التلقائي: $e');
    }
  }

  Future<String> backupDatabaseManually() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(supportDir.path, _dbFileName));

      if (!await dbFile.exists()) {
        return '❌ لا توجد قاعدة بيانات لنسخها بعد.';
      }

      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'اختر مجلداً لحفظ النسخة الاحتياطية',
      );

      if (selectedDirectory == null) {
        return '⚠️ تم إلغاء العملية.';
      }

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];

      final backupPath = p.join(
        selectedDirectory,
        'ERP_ManualBackup_$timestamp.sqlite',
      );

      await dbFile.copy(backupPath);
      return '✅ تم الحفظ بنجاح في:\n$backupPath';
    } on Exception catch (e) {
      return '❌ حدث خطأ أثناء النسخ: $e';
    }
  }

  Future<String> restoreDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'اختر ملف النسخة الاحتياطية (sqlite)',
        type: FileType.custom,
        allowedExtensions: ['sqlite', 'db'],
      );

      if (result == null || result.files.single.path == null) {
        return '⚠️ تم إلغاء الاستعادة.';
      }

      final backupFile = File(result.files.single.path!);
      final supportDir = await getApplicationSupportDirectory();
      final targetDbPath = p.join(supportDir.path, _dbFileName);

      await _localApi.database.close();
      await backupFile.copy(targetDbPath);

      return '✅ تمت الاستعادة! \n🚨 يرجى إغلاق البرنامج وإعادة فتحه.';
    } on Exception catch (e) {
      return '❌ فشلت الاستعادة: $e';
    }
  }
}
