import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/checklist_controller.dart';
import 'package:mepco_esafety_app/controllers/ptw_grid_close_controller.dart';
import 'package:mepco_esafety_app/models/checklist_item.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
import 'package:mepco_esafety_app/widgets/upload_button.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/geo_fencing_section.dart';

class PtwGridCloseScreen extends StatelessWidget {
  const PtwGridCloseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PtwGridCloseController controller = Get.find<PtwGridCloseController>();
    // Initialize the controller specifically for completion checklist
    final ChecklistController checklistController = Get.put(
      ChecklistController(ChecklistType.ptwGridClose),
      tag: ChecklistType.ptwGridClose.toString(), // Unique tag
    );

    final ptwId = Get.arguments as int?;
    if (ptwId != null) {
      checklistController.ptwId.value = ptwId;
    }

    final decisionController = TextEditingController();

    return Scaffold(
      extendBody: true,
      body:MainLayout(
        title:  "Completion of PTW" ,

        child: Obx(() {
          if (checklistController.isLoading.value) {
            return const Center(child: LoadingWidget());
          }

          return ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 50),
            children: [
              // Checklist Section
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: checklistController.checklistItems.length,
                itemBuilder: (context, index) {
                  final item = checklistController.checklistItems[index];
                  return _buildChecklistItem(checklistController, item);
                },
              ),
              const SizedBox(height: 15),

              _buildAttachmentsSection(controller),
              const SizedBox(height: 24),
              GeoFencingSection(
                isFetchingLocation: controller.isFetchingLocation,
                currentLocation: controller.currentLocation,
                onMapCreated: (GoogleMapController mapController) {
                  controller.googleMapController = mapController;
                },
              ),
              const SizedBox(height: 24),
              _buildDecisionBox(decisionController),
              const SizedBox(height: 24),
              Obx(() => BottomNavigationButtons(
                onBackPressed: controller.isLoading.value || checklistController.isSubmitting.value ? null : () => Get.back(),
                onNextPressed: (controller.isLoading.value || checklistController.isSubmitting.value)
                    ? null
                    : () async {
                  if (ptwId != null) {
                    // Submit checklist first
                    controller.submitPtwCompletion(
                      ptwId: ptwId,
                      notes: decisionController.text,
                      checklistItems: checklistController.checklistItems,
                    );
                  }
                },
                nextText: 'Submit',
                isSubmitting: controller.isLoading.value || checklistController.isSubmitting.value,
              )),
              // SizedBox(height: MediaQuery.of(context).padding.bottom)
            ],
          );
        }),
      ),
    );
  }

  Widget _buildChecklistItem(ChecklistController controller, ChecklistItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.textEnglish,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500)),
                Text(item.textUrdu,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Obx(() => Checkbox(
            value: controller.checklistItems
                .firstWhere((e) => e.id == item.id, orElse: () => item)
                .value,
            onChanged: (newValue) {
              controller.toggleItem(item.id, newValue!);
            },
            activeColor: Color(0xFF002997),
            checkColor: Colors.white,
            side: const BorderSide(color: Colors.grey, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(PtwGridCloseController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feeder racked in snaps/pictures\nفیڈر کو تصویروں/سنیپ شاٹس میں ریک کیا گیا',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 16),
        UploadButton(onPressed: () => controller.pickImages()),
        Obx(() {
          if (controller.images.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _buildImagePreviews(controller),
          );
        })
      ],
    );
  }

  Widget _buildImagePreviews(PtwGridCloseController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (context, index) {
        return _buildImagePreview(controller.images[index], () => controller.removeImage(controller.images[index]));
      },
    );
  }

  Widget _buildImagePreview(XFile imageFile, VoidCallback onRemove) {
    return Stack(
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
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF002171),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ),
      ],
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
              leading: const Icon(Icons.share, color: AppColors.primaryBlue),
              title: const Text('Share'),
              onTap: () {
                Get.back();
                Share.shareXFiles([XFile(imagePath)]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: AppColors.primaryBlue),
              title: const Text('Download to Gallery'),
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

  Widget _buildDecisionBox(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Decision / Notes',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter decision or notes...',
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
