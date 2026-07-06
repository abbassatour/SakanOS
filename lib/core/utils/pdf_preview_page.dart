//lib\core\utils\pdf_preview_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatelessWidget {
  const PdfPreviewPage({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  final Uint8List pdfBytes;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'معاينة: $title',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // هذه هي الأداة السحرية من مكتبة printing
      body: PdfPreview(
        build: (format) => pdfBytes,
        allowSharing: true, // يتيح زر حفظ كـ PDF
        allowPrinting: true, // يتيح زر الطابعة
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: '$title.pdf',
      ),
    );
  }
}
