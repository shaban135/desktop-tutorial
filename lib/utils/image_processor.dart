import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:native_exif/native_exif.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class ImageProcessor {
  // Google Maps API Key from AndroidManifest
  static const String _googleMapsApiKey = "AIzaSyCHt4889qXDmSbabayzrPaGBp_QJm-Eu-M";

  // ===========================================================
  //               📌 IMAGE COMPRESSION (< 500KB)
  // ===========================================================
  static Future<File?> _compressTo500KB(File file) async {
    final int maxSizeInBytes = 500 * 1024;
    var targetPath = "${file.parent.path}/compressed_${file.path.split('/').last}";

    final originalSize = file.lengthSync();
    log("📷 Original size: ${(originalSize / 1024).toStringAsFixed(0)} KB");

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      autoCorrectionAngle: true,
      keepExif: true,
    );

    if (result != null) {
      var resultFile = File(result.path);
      final compressedSize = resultFile.lengthSync();
      if (compressedSize < maxSizeInBytes) {
        return resultFile;
      }
    }

    img.Image? image = img.decodeImage(file.readAsBytesSync());
    if (image == null) return file;

    int targetWidth, targetHeight;
    if (image.width > image.height) {
      targetWidth = 1280;
      targetHeight = (image.height * 1280 / image.width).round();
    } else {
      targetHeight = 1280;
      targetWidth = (image.width * 1280 / image.height).round();
    }

    result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: targetWidth,
      minHeight: targetHeight,
      quality: 70,
      autoCorrectionAngle: true,
      keepExif: true,
    );

    if (result != null) {
      return File(result.path);
    }

    return file;
  }

  // ===========================================================
  //            📌 PICK IMAGE
  // ===========================================================
  static Future<XFile?> pickImage() async {
    final picker = ImagePicker();
    final XFile? captured = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    return captured;
  }

  // ===========================================================
  //            📌 PROCESS IMAGE
  // ===========================================================
  static Future<XFile> processImage(XFile rawImage, Rxn<LatLng> currentLocation, RxnString currentAddress) async {
    try {
      File original = File(rawImage.path);

      File? watermarked = await _addCameraStyleWatermark(original, currentLocation, currentAddress);
      File toCompress = watermarked ?? original;

      File? compressed = await _compressTo500KB(toCompress);
      File finalFile = compressed ?? toCompress;

      await _embedGpsData(finalFile, currentLocation);

      final finalSize = await finalFile.length();
      log("📸 Final image size: ${(finalSize / 1024).toStringAsFixed(0)} KB");

      return XFile(finalFile.path);
    } catch (e) {
      log("⚠️ Image processing failed: $e");
      return rawImage;
    }
  }

  // ===========================================================
  //         📌 FETCH STATIC MAP USING GOOGLE STATIC MAPS API
  // ===========================================================
  static Future<img.Image?> _getStaticMapImage(Rxn<LatLng> currentLocation) async {
    if (currentLocation.value == null) return null;

    try {
      final lat = currentLocation.value!.latitude;
      final lng = currentLocation.value!.longitude;
      
      // Request a 400x280 static map from Google
      final String url = "https://maps.googleapis.com/maps/api/staticmap?"
          "center=$lat,$lng"
          "&zoom=17"
          "&size=400x280"
          "&maptype=roadmap"
          "&markers=color:red%7C$lat,$lng"
          "&key=$_googleMapsApiKey";

      log("🗺️ Fetching Google Static Map...");
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        log("✅ Google Static Map fetched successfully");
        return img.decodeImage(response.bodyBytes);
      } else {
        log("⚠️ Google Static Map API Error: ${response.statusCode}");
      }
    } catch (e) {
      log("⚠️ Error fetching Google static map: $e");
    }
    return null;
  }

  // ===========================================================
  //     📌 ENHANCED CAMERA-STYLE WATERMARK (Premium Design)
  // ===========================================================
  static Future<File?> _addCameraStyleWatermark(File file, Rxn<LatLng> currentLocation, RxnString currentAddress) async {
    if (currentLocation.value == null) return file;

    try {
      final imageBytes = await file.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) return null;

      originalImage = img.bakeOrientation(originalImage);

      // Prepare data
      final now = DateTime.now();
      final gmtOffset = now.timeZoneOffset.inHours >= 0
          ? '+${now.timeZoneOffset.inHours}:00'
          : '${now.timeZoneOffset.inHours}:00';

      final dateStr = DateFormat('dd/MM/yyyy').format(now);
      final timeStr = DateFormat('hh:mm a').format(now);
      final dayStr = DateFormat('EEEE').format(now);

      final latStr = "${currentLocation.value!.latitude.toStringAsFixed(6)}°";
      final lngStr = "${currentLocation.value!.longitude.toStringAsFixed(6)}°";

      String addressStr = currentAddress.value ?? "Address not found";

      // Truncate long address
      if (addressStr.length > 50) {
        addressStr = addressStr.substring(0, 47) + "...";
      }

      // Dynamic sizing
      final isLargeImage = originalImage.width > 1500;
      final font = isLargeImage ? img.arial48 : img.arial24;
      final fontSmall = isLargeImage ? img.arial24 : img.arial24;
      final int lineHeight = isLargeImage ? 58 : 34;
      final int smallLineHeight = isLargeImage ? 34 : 28;

      // Fetch map
      log("🗺️ Fetching mini map...");
      final mapImage = await _getStaticMapImage(currentLocation);

      // LARGER MAP SIZE - 40% bigger
      final mapSize = isLargeImage ? 280 : 190;
      final margin = isLargeImage ? 18 : 12;

      // Calculate bar height - taller for better layout
      final barHeight = isLargeImage ? 320 : 210;
      final barY = originalImage.height - barHeight;

      // Draw gradient background bar (dark to darker)
      for (int i = 0; i < barHeight; i++) {
        final alpha = 160 + ((i / barHeight) * 60).toInt();
        img.drawLine(
          originalImage,
          x1: 0,
          y1: barY + i,
          x2: originalImage.width,
          y2: barY + i,
          color: img.ColorRgba8(0, 0, 0, alpha),
        );
      }

      // Draw mini map (bottom-left corner) with enhanced styling
      if (mapImage != null) {
        final resizedMap = img.copyResize(
          mapImage,
          width: mapSize,
          height: mapSize,
          interpolation: img.Interpolation.cubic,
        );

        final mapX = margin;
        final mapY = originalImage.height - mapSize - margin;

        // Draw shadow for map
        img.fillRect(
          originalImage,
          x1: mapX + 4,
          y1: mapY + 4,
          x2: mapX + mapSize + 4,
          y2: mapY + mapSize + 4,
          color: img.ColorRgba8(0, 0, 0, 120),
        );

        // Double border (blue + white)
        final borderWidth = 4;

        // Outer blue border
        img.drawRect(
          originalImage,
          x1: mapX - borderWidth - 2,
          y1: mapY - borderWidth - 2,
          x2: mapX + mapSize + borderWidth + 2,
          y2: mapY + mapSize + borderWidth + 2,
          color: img.ColorRgb8(13, 71, 161), // Dark blue
        );

        // Inner white border
        img.drawRect(
          originalImage,
          x1: mapX - borderWidth,
          y1: mapY - borderWidth,
          x2: mapX + mapSize + borderWidth,
          y2: mapY + mapSize + borderWidth,
          color: img.ColorRgb8(255, 255, 255),
        );

        // Composite map
        img.compositeImage(
          originalImage,
          resizedMap,
          dstX: mapX,
          dstY: mapY,
        );

        // Enhanced red pin with shadow
        final pinX = mapX + (mapSize ~/ 2);
        final pinY = mapY + (mapSize ~/ 2);
        _drawEnhancedPin(originalImage, pinX, pinY, isLargeImage);

        log("✅ Mini map added");
      }

      // Text overlay (right of map) with better spacing
      final textStartX = margin + mapSize + (margin * 3);
      int textY = barY + (isLargeImage ? 20 : 15);

      // Header: "GPS Details" with icon
      img.drawString(
        originalImage,
        "GPS Details",
        font: font,
        x: textStartX,
        y: textY,
        color: img.ColorRgb8(100, 200, 255), // Light blue
      );
      textY += lineHeight + (isLargeImage ? 5 : 3);

      // Divider line
      img.drawLine(
        originalImage,
        x1: textStartX,
        y1: textY,
        x2: textStartX + (isLargeImage ? 400 : 250),
        y2: textY,
        color: img.ColorRgba8(255, 255, 255, 100),
      );
      textY += (isLargeImage ? 12 : 8);

      // Address with location icon
      img.drawString(
        originalImage,
        addressStr,
        font: fontSmall,
        x: textStartX,
        y: textY,
        color: img.ColorRgb8(220, 220, 220),
      );
      textY += smallLineHeight + 5;

      // GPS Coordinates with better formatting
      img.drawString(
        originalImage,
        "LAT: $latStr  |  LNG: $lngStr",
        font: fontSmall,
        x: textStartX,
        y: textY,
        color: img.ColorRgb8(100, 255, 150), // Bright green
      );
      textY += smallLineHeight + 5;

      // Date & Time with icons
      final dateTimeStr = "$dayStr, $dateStr  $timeStr GMT $gmtOffset";
      img.drawString(
        originalImage,
        dateTimeStr,
        font: fontSmall,
        x: textStartX,
        y: textY,
        color: img.ColorRgb8(255, 220, 100), // Gold
      );

      // Top-right corner badge: "GPS Map" with modern styling
      final labelX = originalImage.width - (isLargeImage ? 300 : 200);
      final labelY = barY + (isLargeImage ? 20 : 15);
      final labelWidth = isLargeImage ? 240 : 160;
      final labelHeight = isLargeImage ? 50 : 35;

      // Badge background with gradient effect
      img.fillRect(
        originalImage,
        x1: labelX,
        y1: labelY,
        x2: labelX + labelWidth,
        y2: labelY + labelHeight,
        color: img.ColorRgba8(13, 71, 161, 200), // Blue gradient start
      );

      // Badge text
      img.drawString(
        originalImage,
        "GPS Map",
        font: font,
        x: labelX + (isLargeImage ? 30 : 20),
        y: labelY + (isLargeImage ? 12 : 8),
        color: img.ColorRgb8(255, 255, 255),
      );

      // Bottom-right corner: "MEPCO eSafety" watermark
      final watermarkText = "MEPCO eSafety";
      final watermarkX = originalImage.width - (isLargeImage ? 300 : 200);
      final watermarkY = originalImage.height - (isLargeImage ? 45 : 38);

      img.drawString(
        originalImage,
        watermarkText,
        font: fontSmall,
        x: watermarkX,
        y: watermarkY,
        color: img.ColorRgba8(255, 255, 255, 150),
      );

      // Save with optimized quality
      final newPath = "${file.path}_watermarked.jpg";
      final newFile = File(newPath)..writeAsBytesSync(img.encodeJpg(originalImage, quality: 85));

      return newFile;
    } catch (e) {
      log("⚠️ Error adding watermark: $e");
      return file;
    }
  }

  // Enhanced pin with 3D effect
  static void _drawEnhancedPin(img.Image image, int x, int y, bool large) {
    final radius = large ? 18 : 12;

    // Shadow (bottom-right offset)
    img.fillCircle(
      image,
      x: x + 3,
      y: y + 3,
      radius: radius,
      color: img.ColorRgba8(0, 0, 0, 150),
    );

    // Outer glow
    img.fillCircle(
      image,
      x: x,
      y: y,
      radius: radius + 2,
      color: img.ColorRgba8(255, 200, 0, 100), // Yellow glow
    );

    // Main red circle
    img.fillCircle(
      image,
      x: x,
      y: y,
      radius: radius,
      color: img.ColorRgb8(234, 67, 53), // Google red
    );

    // White ring
    img.drawCircle(
      image,
      x: x,
      y: y,
      radius: radius - 2,
      color: img.ColorRgb8(255, 255, 255),
    );

    // Inner circle
    img.fillCircle(
      image,
      x: x,
      y: y,
      radius: radius - 3,
      color: img.ColorRgb8(200, 50, 40),
    );

    // Center white dot
    img.fillCircle(
      image,
      x: x,
      y: y,
      radius: radius ~/ 3,
      color: img.ColorRgb8(255, 255, 255),
    );
  }

  static Future<void> _embedGpsData(File file, Rxn<LatLng> currentLocation) async {
    if (currentLocation.value == null) {
      log("Current location is null. Skipping GPS embedding.");
      return;
    }

    try {
      final exif = await Exif.fromPath(file.path);
      await exif.writeAttributes({
        'GPSLatitude': currentLocation.value!.latitude,
        'GPSLongitude': currentLocation.value!.longitude,
      });
      await exif.close();
      log("✅ GPS metadata written to image: ${file.path}");
    } catch (e) {
      log("⚠️ Error writing GPS metadata: $e");
    }
  }
}
// import 'dart:developer';
// import 'dart:io';
// import 'dart:math' as math;
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:native_exif/native_exif.dart';
// import 'package:image/image.dart' as img;
// import 'package:intl/intl.dart';
//
// class ImageProcessor {
//   // ===========================================================
//   //               📌 IMAGE COMPRESSION (< 500KB)
//   //               OPTIMIZED FOR MEPCO SERVER CAPACITY
//   // ===========================================================
//   static Future<File?> _compressTo500KB(File file) async {
//     final int maxSizeInBytes = 500 * 1024; // 500KB target
//     var targetPath = "${file.parent.path}/compressed_${file.path.split('/').last}";
//
//     // Get original size for logging
//     final originalSize = file.lengthSync();
//     log("📷 Original size: ${(originalSize / 1024).toStringAsFixed(0)} KB");
//
//     // First attempt: quality 70
//     var result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: 70,
//       autoCorrectionAngle: true,
//       keepExif: true,
//     );
//
//     if (result != null) {
//       var resultFile = File(result.path);
//       final compressedSize = resultFile.lengthSync();
//       log("📦 Compressed (q70): ${(compressedSize / 1024).toStringAsFixed(0)} KB");
//
//       if (compressedSize < maxSizeInBytes) {
//         log("✅ Compression successful (${((1 - compressedSize / originalSize) * 100).toStringAsFixed(0)}% reduction)");
//         return resultFile;
//       }
//     }
//
//     // Second attempt: resize to 1280 + quality 70
//     img.Image? image = img.decodeImage(file.readAsBytesSync());
//     if (image == null) {
//       log("⚠️ Could not decode image, returning original");
//       return file;
//     }
//
//     // Calculate proportional dimensions for 1280 max
//     int targetWidth, targetHeight;
//     if (image.width > image.height) {
//       // Landscape
//       targetWidth = 1280;
//       targetHeight = (image.height * 1280 / image.width).round();
//     } else {
//       // Portrait
//       targetHeight = 1280;
//       targetWidth = (image.width * 1280 / image.height).round();
//     }
//
//     result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       minWidth: targetWidth,
//       minHeight: targetHeight,
//       quality: 70,
//       autoCorrectionAngle: true,
//       keepExif: true,
//     );
//
//     if (result != null) {
//       var resultFile = File(result.path);
//       final compressedSize = resultFile.lengthSync();
//       log("📦 Compressed (1280, q70): ${(compressedSize / 1024).toStringAsFixed(0)} KB");
//
//       if (compressedSize < maxSizeInBytes) {
//         log("✅ Compression successful (${((1 - compressedSize / originalSize) * 100).toStringAsFixed(0)}% reduction)");
//         return resultFile;
//       }
//     }
//
//     // Third attempt: more aggressive (1024 + quality 60)
//     if (image.width > image.height) {
//       targetWidth = 1024;
//       targetHeight = (image.height * 1024 / image.width).round();
//     } else {
//       targetHeight = 1024;
//       targetWidth = (image.width * 1024 / image.height).round();
//     }
//
//     result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       minWidth: targetWidth,
//       minHeight: targetHeight,
//       quality: 60,
//       autoCorrectionAngle: true,
//       keepExif: true,
//     );
//
//     if (result != null) {
//       var resultFile = File(result.path);
//       final compressedSize = resultFile.lengthSync();
//       log("📦 Compressed (1024, q60): ${(compressedSize / 1024).toStringAsFixed(0)} KB");
//       log("✅ Compression successful (${((1 - compressedSize / originalSize) * 100).toStringAsFixed(0)}% reduction)");
//       return resultFile;
//     }
//
//     log("⚠️ All compression attempts completed, returning best result");
//     return file;
//   }
//
//   // ===========================================================
//   //            📌 PICK IMAGE (Optimized dimensions)
//   // ===========================================================
//   static Future<XFile?> pickImage() async {
//     final picker = ImagePicker();
//
//     final XFile? captured = await picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 85,
//       maxWidth: 1600,
//       maxHeight: 1600,
//     );
//
//     return captured;
//   }
//
//   // ===========================================================
//   //            📌 PROCESS IMAGE
//   // ===========================================================
//   static Future<XFile> processImage(XFile rawImage, Rxn<LatLng> currentLocation, RxnString currentAddress) async {
//     try {
//       File original = File(rawImage.path);
//
//       File? watermarked = await _addCameraStyleWatermark(original, currentLocation, currentAddress);
//       File toCompress = watermarked ?? original;
//
//       File? compressed = await _compressTo500KB(toCompress);
//       File finalFile = compressed ?? toCompress;
//
//       await _embedGpsData(finalFile, currentLocation);
//
//       // Log final size
//       final finalSize = await finalFile.length();
//       log("📸 Final image size: ${(finalSize / 1024).toStringAsFixed(0)} KB");
//
//       return XFile(finalFile.path);
//     } catch (e) {
//       log("⚠️ Image processing failed: $e");
//       return rawImage;
//     }
//   }
//
//   // ===========================================================
//   //         📌 FETCH STATIC MAP WITH EXACT CENTER
//   // ===========================================================
//   static Future<img.Image?> _getStaticMapImage(Rxn<LatLng> currentLocation) async {
//     if (currentLocation.value == null) return null;
//
//     try {
//       final lat = currentLocation.value!.latitude;
//       final lng = currentLocation.value!.longitude;
//
//       final zoom = 17;
//       final tileSize = 256;
//
//       final worldX = (lng + 180) / 360 * (1 << zoom);
//       final latRad = lat * math.pi / 180;
//       final worldY = (1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) / 2 * (1 << zoom);
//
//       final centerTileX = worldX.floor();
//       final centerTileY = worldY.floor();
//
//       final pixelX = ((worldX - centerTileX) * tileSize).toInt();
//       final pixelY = ((worldY - centerTileY) * tileSize).toInt();
//
//       img.Image? compositeMap = img.Image(width: tileSize * 3, height: tileSize * 3);
//
//       bool anyTileLoaded = false;
//
//       for (int dx = -1; dx <= 1; dx++) {
//         for (int dy = -1; dy <= 1; dy++) {
//           final tileX = centerTileX + dx;
//           final tileY = centerTileY + dy;
//
//           final url = 'https://tile.openstreetmap.org/$zoom/$tileX/$tileY.png';
//
//           try {
//             final response = await http.get(
//               Uri.parse(url),
//               headers: {
//                 'User-Agent': 'MEPCO eSafety App/1.0',
//               },
//             ).timeout(const Duration(seconds: 3));
//
//             if (response.statusCode == 200) {
//               final tile = img.decodeImage(response.bodyBytes);
//               if (tile != null) {
//                 final dstX = (dx + 1) * tileSize;
//                 final dstY = (dy + 1) * tileSize;
//                 img.compositeImage(
//                     compositeMap,
//                     tile,
//                     dstX: dstX,
//                     dstY: dstY
//                 );
//                 anyTileLoaded = true;
//               }
//             }
//
//             await Future.delayed(const Duration(milliseconds: 100));
//           } catch (e) {
//             log("⚠️ Failed to load tile ($tileX, $tileY): $e");
//           }
//         }
//       }
//
//       if (anyTileLoaded) {
//         final exactX = tileSize + pixelX;
//         final exactY = tileSize + pixelY;
//
//         final cropWidth = 400;
//         final cropHeight = 280;
//
//         final cropX = (exactX - cropWidth ~/ 2).clamp(0, compositeMap.width - cropWidth);
//         final cropY = (exactY - cropHeight ~/ 2).clamp(0, compositeMap.height - cropHeight);
//
//         final croppedMap = img.copyCrop(
//           compositeMap,
//           x: cropX,
//           y: cropY,
//           width: cropWidth,
//           height: cropHeight,
//         );
//
//         log("✅ Map centered on exact location");
//         return croppedMap;
//       }
//     } catch (e) {
//       log("⚠️ Error creating map: $e");
//     }
//     return null;
//   }
//
//   // ===========================================================
//   //     📌 ENHANCED CAMERA-STYLE WATERMARK (Premium Design)
//   // ===========================================================
//   static Future<File?> _addCameraStyleWatermark(File file, Rxn<LatLng> currentLocation, RxnString currentAddress) async {
//     if (currentLocation.value == null) return file;
//
//     try {
//       final imageBytes = await file.readAsBytes();
//       img.Image? originalImage = img.decodeImage(imageBytes);
//
//       if (originalImage == null) return null;
//
//       originalImage = img.bakeOrientation(originalImage);
//
//       // Prepare data
//       final now = DateTime.now();
//       final gmtOffset = now.timeZoneOffset.inHours >= 0
//           ? '+${now.timeZoneOffset.inHours}:00'
//           : '${now.timeZoneOffset.inHours}:00';
//
//       final dateStr = DateFormat('dd/MM/yyyy').format(now);
//       final timeStr = DateFormat('hh:mm a').format(now);
//       final dayStr = DateFormat('EEEE').format(now);
//
//       final latStr = "${currentLocation.value!.latitude.toStringAsFixed(6)}°";
//       final lngStr = "${currentLocation.value!.longitude.toStringAsFixed(6)}°";
//
//       String addressStr = currentAddress.value ?? "Address not found";
//
//       // Truncate long address
//       if (addressStr.length > 50) {
//         addressStr = addressStr.substring(0, 47) + "...";
//       }
//
//       // Dynamic sizing
//       final isLargeImage = originalImage.width > 1500;
//       final font = isLargeImage ? img.arial48 : img.arial24;
//       final fontSmall = isLargeImage ? img.arial24 : img.arial24;
//       final int lineHeight = isLargeImage ? 58 : 34;
//       final int smallLineHeight = isLargeImage ? 34 : 28;
//
//       // Fetch map
//       log("🗺️ Fetching mini map...");
//       final mapImage = await _getStaticMapImage(currentLocation);
//
//       // LARGER MAP SIZE - 40% bigger
//       final mapSize = isLargeImage ? 280 : 190;
//       final margin = isLargeImage ? 18 : 12;
//
//       // Calculate bar height - taller for better layout
//       final barHeight = isLargeImage ? 320 : 210;
//       final barY = originalImage.height - barHeight;
//
//       // Draw gradient background bar (dark to darker)
//       for (int i = 0; i < barHeight; i++) {
//         final alpha = 160 + ((i / barHeight) * 60).toInt();
//         img.drawLine(
//           originalImage,
//           x1: 0,
//           y1: barY + i,
//           x2: originalImage.width,
//           y2: barY + i,
//           color: img.ColorRgba8(0, 0, 0, alpha),
//         );
//       }
//
//       // Draw mini map (bottom-left corner) with enhanced styling
//       if (mapImage != null) {
//         final resizedMap = img.copyResize(
//           mapImage,
//           width: mapSize,
//           height: mapSize,
//           interpolation: img.Interpolation.cubic,
//         );
//
//         final mapX = margin;
//         final mapY = originalImage.height - mapSize - margin;
//
//         // Draw shadow for map
//         img.fillRect(
//           originalImage,
//           x1: mapX + 4,
//           y1: mapY + 4,
//           x2: mapX + mapSize + 4,
//           y2: mapY + mapSize + 4,
//           color: img.ColorRgba8(0, 0, 0, 120),
//         );
//
//         // Double border (blue + white)
//         final borderWidth = 4;
//
//         // Outer blue border
//         img.drawRect(
//           originalImage,
//           x1: mapX - borderWidth - 2,
//           y1: mapY - borderWidth - 2,
//           x2: mapX + mapSize + borderWidth + 2,
//           y2: mapY + mapSize + borderWidth + 2,
//           color: img.ColorRgb8(13, 71, 161), // Dark blue
//         );
//
//         // Inner white border
//         img.drawRect(
//           originalImage,
//           x1: mapX - borderWidth,
//           y1: mapY - borderWidth,
//           x2: mapX + mapSize + borderWidth,
//           y2: mapY + mapSize + borderWidth,
//           color: img.ColorRgb8(255, 255, 255),
//         );
//
//         // Composite map
//         img.compositeImage(
//           originalImage,
//           resizedMap,
//           dstX: mapX,
//           dstY: mapY,
//         );
//
//         // Enhanced red pin with shadow
//         final pinX = mapX + (mapSize ~/ 2);
//         final pinY = mapY + (mapSize ~/ 2);
//         _drawEnhancedPin(originalImage, pinX, pinY, isLargeImage);
//
//         log("✅ Mini map added");
//       }
//
//       // Text overlay (right of map) with better spacing
//       final textStartX = margin + mapSize + (margin * 3);
//       int textY = barY + (isLargeImage ? 20 : 15);
//
//       // Header: "GPS Details" with icon
//       img.drawString(
//         originalImage,
//         "GPS Details",
//         font: font,
//         x: textStartX,
//         y: textY,
//         color: img.ColorRgb8(100, 200, 255), // Light blue
//       );
//       textY += lineHeight + (isLargeImage ? 5 : 3);
//
//       // Divider line
//       img.drawLine(
//         originalImage,
//         x1: textStartX,
//         y1: textY,
//         x2: textStartX + (isLargeImage ? 400 : 250),
//         y2: textY,
//         color: img.ColorRgba8(255, 255, 255, 100),
//       );
//       textY += (isLargeImage ? 12 : 8);
//
//       // Address with location icon
//       img.drawString(
//         originalImage,
//         addressStr,
//         font: fontSmall,
//         x: textStartX,
//         y: textY,
//         color: img.ColorRgb8(220, 220, 220),
//       );
//       textY += smallLineHeight + 5;
//
//       // GPS Coordinates with better formatting
//       img.drawString(
//         originalImage,
//         "LAT: $latStr  |  LNG: $lngStr",
//         font: fontSmall,
//         x: textStartX,
//         y: textY,
//         color: img.ColorRgb8(100, 255, 150), // Bright green
//       );
//       textY += smallLineHeight + 5;
//
//       // Date & Time with icons
//       final dateTimeStr = "$dayStr, $dateStr  $timeStr GMT $gmtOffset";
//       img.drawString(
//         originalImage,
//         dateTimeStr,
//         font: fontSmall,
//         x: textStartX,
//         y: textY,
//         color: img.ColorRgb8(255, 220, 100), // Gold
//       );
//
//       // Top-right corner badge: "GPS Map" with modern styling
//       final labelX = originalImage.width - (isLargeImage ? 300 : 200);
//       final labelY = barY + (isLargeImage ? 20 : 15);
//       final labelWidth = isLargeImage ? 240 : 160;
//       final labelHeight = isLargeImage ? 50 : 35;
//
//       // Badge background with gradient effect
//       img.fillRect(
//         originalImage,
//         x1: labelX,
//         y1: labelY,
//         x2: labelX + labelWidth,
//         y2: labelY + labelHeight,
//         color: img.ColorRgba8(13, 71, 161, 200), // Blue gradient start
//       );
//
//       // Badge text
//       img.drawString(
//         originalImage,
//         "GPS Map",
//         font: font,
//         x: labelX + (isLargeImage ? 30 : 20),
//         y: labelY + (isLargeImage ? 12 : 8),
//         color: img.ColorRgb8(255, 255, 255),
//       );
//
//       // Bottom-right corner: "MEPCO eSafety" watermark
//       final watermarkText = "MEPCO eSafety";
//       final watermarkX = originalImage.width - (isLargeImage ? 300 : 200);
//       final watermarkY = originalImage.height - (isLargeImage ? 45 : 38);
//
//       img.drawString(
//         originalImage,
//         watermarkText,
//         font: fontSmall,
//         x: watermarkX,
//         y: watermarkY,
//         color: img.ColorRgba8(255, 255, 255, 150),
//       );
//
//       // Save with optimized quality
//       final newPath = "${file.path}_watermarked.jpg";
//       final newFile = File(newPath)..writeAsBytesSync(img.encodeJpg(originalImage, quality: 85));
//
//       return newFile;
//     } catch (e) {
//       log("⚠️ Error adding watermark: $e");
//       return file;
//     }
//   }
//
//   // Enhanced pin with 3D effect
//   static void _drawEnhancedPin(img.Image image, int x, int y, bool large) {
//     final radius = large ? 18 : 12;
//
//     // Shadow (bottom-right offset)
//     img.fillCircle(
//       image,
//       x: x + 3,
//       y: y + 3,
//       radius: radius,
//       color: img.ColorRgba8(0, 0, 0, 150),
//     );
//
//     // Outer glow
//     img.fillCircle(
//       image,
//       x: x,
//       y: y,
//       radius: radius + 2,
//       color: img.ColorRgba8(255, 200, 0, 100), // Yellow glow
//     );
//
//     // Main red circle
//     img.fillCircle(
//       image,
//       x: x,
//       y: y,
//       radius: radius,
//       color: img.ColorRgb8(234, 67, 53), // Google red
//     );
//
//     // White ring
//     img.drawCircle(
//       image,
//       x: x,
//       y: y,
//       radius: radius - 2,
//       color: img.ColorRgb8(255, 255, 255),
//     );
//
//     // Inner circle
//     img.fillCircle(
//       image,
//       x: x,
//       y: y,
//       radius: radius - 3,
//       color: img.ColorRgb8(200, 50, 40),
//     );
//
//     // Center white dot
//     img.fillCircle(
//       image,
//       x: x,
//       y: y,
//       radius: radius ~/ 3,
//       color: img.ColorRgb8(255, 255, 255),
//     );
//   }
//
//   static Future<void> _embedGpsData(File file, Rxn<LatLng> currentLocation) async {
//     if (currentLocation.value == null) {
//       log("Current location is null. Skipping GPS embedding.");
//       return;
//     }
//
//     try {
//       final exif = await Exif.fromPath(file.path);
//       await exif.writeAttributes({
//         'GPSLatitude': currentLocation.value!.latitude,
//         'GPSLongitude': currentLocation.value!.longitude,
//       });
//       await exif.close();
//       log("✅ GPS metadata written to image: ${file.path}");
//     } catch (e) {
//       log("⚠️ Error writing GPS metadata: $e");
//     }
//   }
// }
