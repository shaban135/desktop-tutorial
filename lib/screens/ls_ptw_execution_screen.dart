
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/controllers/ls_ptw_execution_controller.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
import 'package:mepco_esafety_app/widgets/upload_button.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mepco_esafety_app/widgets/geo_fencing_section.dart';

class LsPtwExecutionScreen extends GetView<LsPtwExecutionController> {
  const LsPtwExecutionScreen({super.key});

  final Map<String, String> _urduAttachments = const {
    'Crew Pictures': 'عملہ کی تصاویر',
    'T&P/PPE Picture': 'ٹول اینڈ پلاسٹک/شخصی حفاظتی سامان کی تصویر',
    'HT/LT Earthing Pictures': 'ایچ ٹی/ایل ٹی ارتھنگ کی تصاویر',
    'Additional Pictures (Optional)': 'اضافی دستاویزات',
  };
  @override
  Widget build(BuildContext context) {
    Get.put(LsPtwExecutionController());
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          MainLayout(
            title: 'Attachments & Submission',
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Attachments (Mandatory)',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    itemCount: controller.attachments.length + 6,
                    itemBuilder: (context, index) {
                      if (index < controller.attachments.length) {
                        String key = controller.attachments.keys.elementAt(index);
                        String displayTitle = key.replaceAll(RegExp(r' \\d+\$'), '');
                        return Obx(() => _buildUploadItem(
                            key,
                          _urduAttachments[displayTitle] ?? '',
                          controller.attachments[key] ?? <XFile>[],));
                      } else if (index == controller.attachments.length) {
                        return GeoFencingSection(
                          isFetchingLocation: controller.isFetchingLocation,
                          currentLocation: controller.currentLocation,
                          onMapCreated: (GoogleMapController mapController) {
                            controller.googleMapController = mapController;
                          },
                        );
                      }
                      else if (index == controller.attachments.length + 1) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: CustomTextFormField(
                            onChanged: (value) => controller.notes.value = value,
                            labelText: 'Add Notes',
                            hintText: 'Enter any notes here...',
                            maxLines: 3,
                          ),
                        );
                      }
                      else if (index == controller.attachments.length + 2) {
                        return _buildConfirmationCheckbox();
                      }
                      else if (index == controller.attachments.length + 3) {
                        return const SizedBox(height: 40);
                      }
                      else if (index == controller.attachments.length + 4) {
                        return Obx(() => BottomNavigationButtons(
                          onNextPressed: controller.isLoading.value
                              ? null
                              : controller.startExecution,
                          nextText: controller.isLoading.value ? 'Submitting...' : 'Submit',
                          showBackButton: false,
                        ));
                      }
                      else {
                        return const SizedBox(height: 50);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Separate Obx for loading overlay
          Obx(() {
            if (controller.isLoading.value) {
              return Material(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingWidget(),
                      SizedBox(height: 20),
                      Text(
                        'Submitting attachments...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  } Widget _buildUploadItem(String title, String subtitle, List<XFile> images) {
    String displayTitle = title.replaceAll(RegExp(r' \\d+\$'), '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Title & Subtitle ----
          Text(displayTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'NotoNastaliqUrdu')),

          const SizedBox(height: 10),

          // ---- Upload Button ----
          UploadButton(onPressed: () => controller.pickImage(title)),

          const SizedBox(height: 20),

          // ---- Multiple Images List (Under Upload Button) ----
          if (images.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return _buildImagePreview(
                    images[index],
                        () => controller.removeImage(title, images[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildImagePreview(XFile imageFile, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              Get.dialog(
                Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(10),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      InteractiveViewer(
                        child: GestureDetector(
                          onLongPress: () => _showImageOptions(imageFile.path),
                          child: Image.file(
                            File(imageFile.path),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                File(imageFile.path),
                width: 100,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: -10,
            right: -10,
            child: InkWell(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFF0D47A1),
                child: Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

 void _showImageOptions(String imagePath) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF0D47A1)),
              title: const Text('Share'),
              onTap: () {
                Get.back();
                Share.shareXFiles([XFile(imagePath)]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Color(0xFF0D47A1)),
              title: const Text('Save to Gallery'),
              onTap: () async {
                Get.back();
                try {
                  final hasAccess = await Gal.hasAccess();
                  if (!hasAccess) {
                    await Gal.requestAccess();
                  }
                  await Gal.putImage(imagePath);
                  Get.snackbar(
                    'Success',
                    'Image saved to gallery',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to save image: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Obx(() => Checkbox(
                value: controller.isConfirmed.value,
                onChanged: (newValue) {
                  controller.isConfirmed.value = newValue!;
                },
                activeColor: const Color(0xFF0D47A1),
                checkColor: Colors.white,
                side: const BorderSide(color: Colors.grey, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
          const Expanded(
            child: Text(
              'I confirm all information provided is correct and attachments are complete',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
