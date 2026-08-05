// lib/contracts/view/contract_attachments_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show Contract, ContractAttachment;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

import '../cubit/contracts_cubit.dart';

class ContractAttachmentsPage extends StatefulWidget {
  final Contract contract;
  final bool canManage;

  const ContractAttachmentsPage({
    super.key,
    required this.contract,
    required this.canManage,
  });

  static Route<void> route(
    Contract contract,
    bool canManage,
    ContractsCubit cubit,
  ) {
    return MaterialPageRoute(
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: ContractAttachmentsPage(
          contract: contract,
          canManage: canManage,
        ),
      ),
    );
  }

  @override
  State<ContractAttachmentsPage> createState() =>
      _ContractAttachmentsPageState();
}

class _ContractAttachmentsPageState extends State<ContractAttachmentsPage> {
  bool isUploading = false;
  bool isCancelling = false;
  int totalFilesToUpload = 0;
  int currentUploadIndex = 0;
  double totalSizeMB = 0.0;
  double uploadedMB = 0.0;
  String currentSpeedStr = "0.00 MB/s";
  String? errorMessage;

  void _openImageInApp(String urlOrPath, String fileName, bool isLocal) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isLocal
                    ? Image.file(File(urlOrPath), fit: BoxFit.contain)
                    : Image.network(
                        urlOrPath,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.broken_image,
                                color: Colors.red,
                                size: 50,
                              ),
                              const SizedBox(height: 10),
                              Text(l10n.attImageLoadError),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(dialogCtx),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndOpenFile(String urlOrPath, String fileName) async {
    final l10n = context.l10n;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.attOpeningFile(fileName)),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      if (!urlOrPath.startsWith('http')) {
        final result = await OpenFilex.open(urlOrPath);
        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.attLocalFileError(result.message)),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      if (!await file.exists()) {
        final response = await http.get(Uri.parse(urlOrPath));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to download');
        }
      }

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.attFileError(result.message)),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.attOpenError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('supabase.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _startUploadProcess() async {
    final l10n = context.l10n;

    bool hasNet = await _hasInternetConnection();
    if (!hasNet) {
      setState(() => errorMessage = l10n.attErrorNoInternet);
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'doc',
        'docx',
        'xls',
        'xlsx',
      ],
    );

    if (result == null || result.files.isEmpty) return;

    double totalBytes = result.files.fold(0, (sum, file) => sum + file.size);

    setState(() {
      isUploading = true;
      isCancelling = false;
      errorMessage = null;
      totalFilesToUpload = result.files.length;
      currentUploadIndex = 0;
      totalSizeMB = totalBytes / (1024 * 1024);
      uploadedMB = 0.0;
      currentSpeedStr = "0.00 MB/s";
    });

    await Future.delayed(const Duration(milliseconds: 300));
    Stopwatch stopwatch = Stopwatch()..start();
    final cubit = context.read<ContractsCubit>();

    for (int i = 0; i < result.files.length; i++) {
      if (isCancelling) {
        setState(
          () => errorMessage = l10n.attUploadCancelled(currentUploadIndex),
        );
        break;
      }

      setState(() => currentUploadIndex = i + 1);
      await Future.delayed(const Duration(milliseconds: 100));

      final file = result.files[i];

      if (file.path != null) {
        try {
          await cubit.attachFileToContractGallery(
            contractId: widget.contract.id,
            filePath: file.path!,
            extension: file.extension ?? 'unknown',
            originalFileName: file.name,
          );

          double currentFileMB = file.size / (1024 * 1024);
          uploadedMB += currentFileMB;
          double elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;
          double speed = elapsedSec > 0 ? (uploadedMB / elapsedSec) : 0.0;

          setState(() => currentSpeedStr = "${speed.toStringAsFixed(2)} MB/s");
        } catch (e) {
          if (mounted) {
            if (e is SocketException ||
                e.toString().toLowerCase().contains('socket')) {
              setState(() => errorMessage = l10n.attInternetLostDuringUpload);
            } else {
              setState(
                () =>
                    errorMessage = l10n.attUploadError(file.name, e.toString()),
              );
            }
          }
          break;
        }
      }
    }

    stopwatch.stop();

    if (!isCancelling && errorMessage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.attUploadSuccess(totalFilesToUpload)),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => isUploading = false);
      }
    } else {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopScope(
      canPop: !isUploading,
      onPopInvoked: (didPop) {
        if (!didPop && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.attWaitUploadNotice),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            l10n.contractAttPageTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
          actions: [
            if (widget.canManage && !isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                  label: Text(
                    l10n.attBtnUploadNew,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal.shade700,
                    elevation: 0,
                  ),
                  onPressed: _startUploadProcess,
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: isUploading
              ? _buildUploadProgressView()
              : BlocBuilder<ContractsCubit, ContractsState>(
                  builder: (context, state) {
                    final attachments =
                        state.attachmentsMap[widget.contract.id] ??
                        <ContractAttachment>[];
                    return _buildGalleryView(attachments);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildUploadProgressView() {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.teal),
            const SizedBox(height: 24),
            Text(
              l10n.attUploadProgress(currentUploadIndex, totalFilesToUpload),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 500,
              child: LinearProgressIndicator(
                value: totalSizeMB > 0 ? (uploadedMB / totalSizeMB) : 0,
                backgroundColor: Colors.teal.shade100,
                color: Colors.teal,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 500,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.attUploadSpeed(currentSpeedStr),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${uploadedMB.toStringAsFixed(2)} / ${totalSizeMB.toStringAsFixed(2)} MB',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.cancel),
              label: Text(
                isCancelling ? l10n.attBtnCancelling : l10n.attBtnCancel,
                style: const TextStyle(fontSize: 16),
              ),
              onPressed: isCancelling
                  ? null
                  : () => setState(() => isCancelling = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryView(List<ContractAttachment> attachments) {
    final l10n = context.l10n;

    return Column(
      children: [
        if (errorMessage != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (attachments.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.perm_media_outlined,
                    size: 100,
                    color: Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.contractAttEmptyGallery,
                    style: const TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final att = attachments[index];
                final ext = att.fileType?.toLowerCase() ?? '';
                final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
                final isPdf = ext == 'pdf';
                final isExcel = ['xls', 'xlsx'].contains(ext);

                IconData fileIcon = Icons.insert_drive_file;
                Color fileColor = Colors.blueGrey;
                if (isPdf) {
                  fileIcon = Icons.picture_as_pdf;
                  fileColor = Colors.red;
                } else if (isExcel) {
                  fileIcon = Icons.table_chart;
                  fileColor = Colors.green;
                } else if (['doc', 'docx'].contains(ext)) {
                  fileIcon = Icons.description;
                  fileColor = Colors.blue.shade800;
                }

                return FutureBuilder<String?>(
                  future: context.read<ContractsCubit>().getSecureAttachmentUrl(
                    att.fileUrl,
                  ),
                  builder: (context, snapshot) {
                    final secureUrl = snapshot.data;
                    final isLoading =
                        snapshot.connectionState == ConnectionState.waiting;
                    final isLocal =
                        secureUrl != null && !secureUrl.startsWith('http');

                    return Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Stack(
                        children: [
                          InkWell(
                            onTap: secureUrl == null
                                ? null
                                : () {
                                    if (isImage) {
                                      _openImageInApp(
                                        secureUrl,
                                        att.fileName ?? l10n.attUnnamed,
                                        isLocal,
                                      );
                                    } else {
                                      _downloadAndOpenFile(
                                        secureUrl,
                                        att.fileName ?? 'file.$ext',
                                      );
                                    }
                                  },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ColoredBox(
                                    color: isImage
                                        ? Colors.black12
                                        : Colors.grey.shade100,
                                    child: isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.teal,
                                            ),
                                          )
                                        : isImage
                                        ? (isLocal
                                              ? Image.file(
                                                  File(secureUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  secureUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) =>
                                                      const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                        size: 50,
                                                      ),
                                                ))
                                        : Icon(
                                            fileIcon,
                                            size: 80,
                                            color: fileColor,
                                          ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        att.fileName ?? l10n.attUnnamed,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat(
                                          'yyyy/MM/dd',
                                        ).format(att.createdAt.toLocal()),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.canManage)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => context
                                      .read<ContractsCubit>()
                                      .deleteContractAttachment(att.id),
                                ),
                              ),
                            ),
                          if (isImage)
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ext.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
