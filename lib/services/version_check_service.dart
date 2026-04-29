import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckService {
  static const String baseUrl = 'https://mepco.myflexihr.com/api';

  static Future<VersionCheckResponse?> checkVersion() async {
    try {
      // Get current app version info
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String currentBuildNumber = packageInfo.buildNumber;
      print("version & build number: $currentVersion.+.$currentBuildNumber");
      String platform = Platform.isAndroid ? 'android' : 'ios';

      print('🔍 Checking version...');
      print('Current: v$currentVersion (Build $currentBuildNumber)');
      print('Platform: $platform');

      // Call API
      final uri = Uri.parse(
        '$baseUrl/app/version-check?platform=$platform&version_code=$currentBuildNumber',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        return VersionCheckResponse.fromJson(data);
      } else {
        print('❌ API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Version check error: $e');
      // Return null on error - app will continue normally
      return null;
    }
  }
}

class VersionCheckResponse {
  final bool success;
  final bool needsUpdate;
  final bool forceUpdate;
  final bool canContinue;
  final CurrentVersion? currentVersion;
  final LatestVersion? latestVersion;
  final String? updateUrl;
  final String? message;
  final BuildInfo? buildInfo;

  VersionCheckResponse({
    required this.success,
    required this.needsUpdate,
    required this.forceUpdate,
    required this.canContinue,
    this.currentVersion,
    this.latestVersion,
    this.updateUrl,
    this.message,
    this.buildInfo,
  });

  factory VersionCheckResponse.fromJson(Map<String, dynamic> json) {
    return VersionCheckResponse(
      success: json['success'] ?? false,
      needsUpdate: json['needs_update'] ?? false,
      forceUpdate: json['force_update'] ?? false,
      canContinue: json['can_continue'] ?? true,
      currentVersion: json['current_version'] != null
          ? CurrentVersion.fromJson(json['current_version'])
          : null,
      latestVersion: json['latest_version'] != null
          ? LatestVersion.fromJson(json['latest_version'])
          : null,
      updateUrl: json['update_url'],
      message: json['message'],
      buildInfo: json['build_info'] != null
          ? BuildInfo.fromJson(json['build_info'])
          : null,
    );
  }
}

class CurrentVersion {
  final int code;

  CurrentVersion({required this.code});

  factory CurrentVersion.fromJson(Map<String, dynamic> json) {
    // Handle both String and int
    final codeValue = json['code'];
    return CurrentVersion(
      code: codeValue is String ? int.parse(codeValue) : (codeValue ?? 0),
    );
  }
}

class LatestVersion {
  final String name;
  final int code;
  final String fullVersion;
  final String releaseDate;
  final List<String> features;

  LatestVersion({
    required this.name,
    required this.code,
    required this.fullVersion,
    required this.releaseDate,
    required this.features,
  });

  factory LatestVersion.fromJson(Map<String, dynamic> json) {
    // Handle both String and int for code
    final codeValue = json['code'];
    final int parsedCode = codeValue is String ? int.parse(codeValue) : (codeValue ?? 0);

    return LatestVersion(
      name: json['name']?.toString() ?? '',
      code: parsedCode,
      fullVersion: json['full_version']?.toString() ?? '',
      releaseDate: json['release_date']?.toString() ?? '',
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}

class BuildInfo {
  final String fileName;
  final String fileSize;
  final int downloadCount;

  BuildInfo({
    required this.fileName,
    required this.fileSize,
    required this.downloadCount,
  });

  factory BuildInfo.fromJson(Map<String, dynamic> json) {
    // Handle both String and int for downloadCount
    final downloadValue = json['download_count'];
    return BuildInfo(
      fileName: json['file_name']?.toString() ?? '',
      fileSize: json['file_size']?.toString() ?? '',
      downloadCount: downloadValue is String
          ? int.parse(downloadValue)
          : (downloadValue ?? 0),
    );
  }
}