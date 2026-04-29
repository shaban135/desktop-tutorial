import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../services/version_check_service.dart';

class UpdateDialog extends StatefulWidget {
  final VersionCheckResponse versionCheck;

  const UpdateDialog({
    Key? key,
    required this.versionCheck,
  }) : super(key: key);

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';
  String? _downloadFilePath;
  bool _downloadComplete = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkExistingDownload();
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 26) {
        final status = await Permission.requestInstallPackages.status;

        if (status.isGranted) {
          setState(() {
            _hasPermission = true;
          });
        } else {
          final result = await Permission.requestInstallPackages.request();
          setState(() {
            _hasPermission = result.isGranted;
          });
        }
      } else {
        setState(() {
          _hasPermission = true;
        });
      }
    }
  }

  Future<void> _checkExistingDownload() async {
    try {
      final directory = await getExternalStorageDirectory();
      final downloadsPath = directory?.path ?? '/storage/emulated/0/Download';
      final filePath = '$downloadsPath/mepco_esafety_update.apk';
      final file = File(filePath);

      if (await file.exists()) {
        final fileSize = await file.length();
        final totalSize = _parseSizeFromAPI(widget.versionCheck.buildInfo?.fileSize);

        if (totalSize > 0 && fileSize < totalSize) {
          setState(() {
            _downloadFilePath = filePath;
            _downloadProgress = fileSize / totalSize;
            _downloadStatus = '${_formatBytes(fileSize)} / ${widget.versionCheck.buildInfo?.fileSize ?? ''}';
          });
        } else if (totalSize > 0 && fileSize >= totalSize) {
          setState(() {
            _downloadFilePath = filePath;
            _downloadProgress = 1.0;
            _downloadComplete = true;
          });
        }
      }
    } catch (e) {
      print('Error checking existing download: $e');
    }
  }

  int _parseSizeFromAPI(String? sizeString) {
    if (sizeString == null || sizeString.isEmpty) return 0;

    try {
      final cleanSize = sizeString.replaceAll(RegExp(r'[^0-9.]'), '').trim();
      final size = double.parse(cleanSize);

      if (sizeString.toUpperCase().contains('GB')) {
        return (size * 1024 * 1024 * 1024).toInt();
      } else if (sizeString.toUpperCase().contains('MB')) {
        return (size * 1024 * 1024).toInt();
      } else if (sizeString.toUpperCase().contains('KB')) {
        return (size * 1024).toInt();
      }
      return size.toInt();
    } catch (e) {
      return 0;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    // Prevent closing dialog during download or when installation is ready
    return WillPopScope(
      onWillPop: () async => !widget.versionCheck.forceUpdate && !_isDownloading && !_downloadComplete,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        // If downloading or complete, don't allow clicking outside to close
        child: GestureDetector(
          onTap: () {}, // Intercept taps inside dialog
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _downloadComplete
                        ? Colors.green.shade100
                        : widget.versionCheck.forceUpdate
                        ? Colors.red.shade100
                        : Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _downloadComplete
                        ? Icons.check_circle_rounded
                        : widget.versionCheck.forceUpdate
                        ? Icons.warning_rounded
                        : Icons.system_update_rounded,
                    size: 48,
                    color: _downloadComplete
                        ? Colors.green.shade600
                        : widget.versionCheck.forceUpdate
                        ? Colors.red.shade600
                        : Colors.blue.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  _downloadComplete
                      ? 'Ready to Install'
                      : widget.versionCheck.forceUpdate
                      ? 'Update Required'
                      : 'Update Available',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // Download Complete Instructions
                if (_downloadComplete) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 40,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Download Complete!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button below to start the installation.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _autoInstall,
                      icon: const Icon(Icons.install_mobile_rounded, color: Colors.white),
                      label: const Text(
                        'INSTALL NOW',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],

                // Permission Warning
                if (!_hasPermission && !_downloadComplete) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Install permission needed',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await openAppSettings();
                          },
                          child: Text(
                            'Enable',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Version Info
                if (!_downloadComplete) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Current',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Build ${widget.versionCheck.currentVersion?.code ?? 0}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.grey.shade400,
                        ),
                        Column(
                          children: [
                            Text(
                              'Latest',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.versionCheck.latestVersion?.fullVersion ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // File Size Info
                if (!_downloadComplete && widget.versionCheck.buildInfo?.fileSize != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.file_download_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Size: ${widget.versionCheck.buildInfo!.fileSize}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // What's New
                if (!_downloadComplete && (widget.versionCheck.latestVersion?.features.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'What\'s New:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.versionCheck.latestVersion!.features.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.versionCheck.latestVersion!.features[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Download Progress
                if (_isDownloading || (_downloadProgress > 0 && !_downloadComplete)) ...[
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _downloadProgress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _downloadStatus,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Buttons (Only show when not complete)
                if (!_downloadComplete) ...[
                  Row(
                    children: [
                      if (!widget.versionCheck.forceUpdate && !_isDownloading)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: const Text(
                              'Later',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (!widget.versionCheck.forceUpdate && !_isDownloading)
                        const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: _isDownloading
                              ? null
                              : () => _downloadAndInstallUpdate(widget.versionCheck.updateUrl),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.versionCheck.forceUpdate
                                ? Colors.red.shade600
                                : Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _isDownloading
                                ? 'Downloading...'
                                : (_downloadProgress > 0 && _downloadProgress < 1.0)
                                ? 'Resume'
                                : 'Update Now',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (widget.versionCheck.forceUpdate && !_downloadComplete) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.versionCheck.message ??
                        'Please update to continue using the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      height: 1.25,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _autoInstall() async {
    if (_downloadFilePath == null) {
       // Re-check path if it's null
       final directory = await getExternalStorageDirectory();
       final downloadsPath = directory?.path ?? '/storage/emulated/0/Download';
       _downloadFilePath = '$downloadsPath/mepco_esafety_update.apk';
    }

    if (!_hasPermission) {
       await _checkAndRequestPermission();
       if (!_hasPermission) {
          Get.snackbar('Permission Required', 'Please allow installation of unknown apps.');
          return;
       }
    }

    try {
      final file = File(_downloadFilePath!);
      if (!await file.exists()) {
        Get.snackbar('Error', 'Installation file not found. Please download again.');
        setState(() {
          _downloadComplete = false;
          _downloadProgress = 0.0;
        });
        return;
      }

      print('Installing APK from: $_downloadFilePath');
      
      final result = await OpenFilex.open(
        _downloadFilePath!,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type != ResultType.done) {
        Get.snackbar('Error', 'Could not open installer: ${result.message}');
      }

    } catch (e) {
      print('Auto-install error: $e');
      Get.snackbar('Error', 'An error occurred while opening the installer.');
    }
  }

  Future<void> _downloadAndInstallUpdate(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar('Error', 'Update URL not available');
      return;
    }

    if (!_hasPermission) {
      final result = await Permission.requestInstallPackages.request();
      setState(() {
        _hasPermission = result.isGranted;
      });
      if (!result.isGranted) {
        Get.snackbar('Permission Required', 'Enable "Install unknown apps" to update.');
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      if (_downloadProgress == 0) {
        _downloadStatus = 'Starting download...';
      }
    });

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 29) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            Get.snackbar('Permission Required', 'Storage permission is required');
            setState(() => _isDownloading = false);
            return;
          }
        }
      }

      final directory = await getExternalStorageDirectory();
      final downloadsPath = directory?.path ?? '/storage/emulated/0/Download';
      final filePath = '$downloadsPath/mepco_esafety_update.apk';
      _downloadFilePath = filePath;

      final totalSize = _parseSizeFromAPI(widget.versionCheck.buildInfo?.fileSize);
      final totalSizeFormatted = widget.versionCheck.buildInfo?.fileSize ?? 'Unknown';

      final file = File(filePath);
      var existingBytes = 0;

      if (await file.exists()) {
        existingBytes = await file.length();
      }
      
      if (existingBytes == 0) await _incrementDownloadCount(url);
      
      final client = http.Client();
      final headers = <String, String>{};

      if (existingBytes > 0 && totalSize > 0 && existingBytes < totalSize) {
        headers['Range'] = 'bytes=$existingBytes-';
      }

      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);
      final response = await client.send(request);

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception('Failed to download: ${response.statusCode}');
      }

      var contentLength = totalSize > 0 ? totalSize : (response.contentLength ?? 0);
      var downloadedBytes = existingBytes;

      final fileMode = (existingBytes > 0 && response.statusCode == 206)
          ? FileMode.append
          : FileMode.write;

      if (existingBytes > 0 && response.statusCode == 200) {
        await file.delete();
        downloadedBytes = 0;
      }

      final fileSink = file.openWrite(mode: fileMode);

      try {
        await for (var chunk in response.stream) {
          fileSink.add(chunk);
          downloadedBytes += chunk.length;

          if (contentLength > 0) {
            setState(() {
              _downloadProgress = downloadedBytes / contentLength;
              _downloadStatus = '${_formatBytes(downloadedBytes)} / $totalSizeFormatted';
            });
          }
        }
      } finally {
        await fileSink.close();
      }

      setState(() {
        _downloadStatus = 'Download complete!';
        _downloadProgress = 1.0;
        _isDownloading = false;
        _downloadComplete = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      await _autoInstall();

    } catch (e) {
      print('Download error: $e');
      setState(() {
        _isDownloading = false;
        _downloadStatus = 'Download failed. Please try again.';
      });
      Get.snackbar('Error', 'Download failed. Please check your connection.');
    }
  }

  Future<void> _incrementDownloadCount(String url) async {
    try {
      final buildId = Uri.parse(url).pathSegments.last;
      final baseUrl = Uri.parse(url).origin;
      await http.post(Uri.parse('$baseUrl/api/app/increment-download/$buildId'));
    } catch (e) {
      print('⚠️ Count error: $e');
    }
  }
}
