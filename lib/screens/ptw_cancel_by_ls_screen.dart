
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/checklist_controller.dart';
import 'package:mepco_esafety_app/controllers/ptw_cancel_by_ls_controller.dart';
import 'package:mepco_esafety_app/models/checklist_item.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
import 'package:mepco_esafety_app/widgets/upload_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mepco_esafety_app/widgets/geo_fencing_section.dart';

class PtwCancelByLsScreen extends StatefulWidget {
  const PtwCancelByLsScreen({super.key});

  @override
  State<PtwCancelByLsScreen> createState() => _PtwCancelByLsScreenState();
}

class _PtwCancelByLsScreenState extends State<PtwCancelByLsScreen> {
  final PtwCancelByLsController cancelController =
      Get.put(PtwCancelByLsController());
  late final ChecklistController checklistController;
  int? _ptwId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};
    _ptwId = args['ptw_id'] as int?;

    const tag = 'ChecklistType.ptwCancelByLs';
    checklistController = Get.isRegistered<ChecklistController>(tag: tag)
        ? Get.find<ChecklistController>(tag: tag)
        : Get.put(ChecklistController(ChecklistType.ptwCancelByLs), tag: tag);

    if (_ptwId != null) {
      checklistController.ptwId.value = _ptwId!;
    }
  }

  Future<void> _onSubmit() async {
    if (_ptwId == null) {
      Get.snackbar("Error", "PTW ID missing");
      return;
    }

    await cancelController.submitCancelByLs(
      ptwId: _ptwId!,
      checklistItems: checklistController.checklistItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: MainLayout(
        title: "Clearance For Cancelation of PTW",
        child: Obx(() {
          if (checklistController.isLoading.value) {
            return _buildShimmerEffect(context);
          }

          return ListView(
            children: [
              _buildChecklistSection(checklistController),
              const SizedBox(height: 14),
              _buildAttachmentsSection(cancelController),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: GeoFencingSection(
                  isFetchingLocation: cancelController.isFetchingLocation,
                  currentLocation: cancelController.currentLocation,
                  onMapCreated: (GoogleMapController mapController) {
                    cancelController.googleMapController = mapController;
                  },
                ),
              ),
              const SizedBox(height: 14),
              _buildDecisionBox(),
              const SizedBox(height: 16),
              _buildConfirmationCheckbox(),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BottomNavigationButtons(
                    onBackPressed: () => Get.back(),
                    onNextPressed: _onSubmit,
                    nextText: 'Submit',
                    isSubmitting: cancelController.isSubmitting.value,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDecisionBox() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Decision / Remarks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: cancelController.decisionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter decision or remarks...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Color(0xFF002997), // ⭐ BLUE BORDER
                  width: 1.3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Color(0xFF002997), // ⭐ BLUE BORDER (focus)
                  width: 1.6,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChecklistSection(ChecklistController controller) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.checklistTitle.value.isEmpty
                ? "Checklist"
                : controller.checklistTitle.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.checklistItems.length,
            itemBuilder: (_, index) {
              final item = controller.checklistItems[index];
              return _buildChecklistItem(controller, item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
      ChecklistController controller, ChecklistItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.textEnglish,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
              Text(item.textUrdu,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
        Obx(
          () => Checkbox(
            value: controller.checklistItems
                .firstWhere((e) => e.id == item.id)
                .value,
            onChanged: (v) => controller.toggleItem(item.id, v!),
            activeColor: const Color(0xFF002997),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(PtwCancelByLsController controller) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'After Work Pictures / کام کے بعد کی تصاویر ',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          UploadButton(onPressed: () => controller.pickImage()),
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
      ),
    );
  }

  Widget _buildImagePreviews(PtwCancelByLsController controller) {
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


  Widget _buildConfirmationCheckbox() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Row(
          children: [
            Checkbox(
              value: cancelController.isConfirmed.value,
              onChanged: cancelController.toggleConfirmation,
              activeColor: AppColors.primaryBlue,
            ),
            const Expanded(
              child: Text(
                'I confirm that all the information provided is correct to the best of my knowledge.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    return ListView(
      children: [
        ...List.generate(
          5,
          (_) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget.rectangular(height: 16, width: 200),
                      SizedBox(height: 8),
                      ShimmerWidget.rectangular(height: 14, width: 150),
                    ],
                  ),
                ),
                ShimmerWidget.rectangular(height: 24, width: 24),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: ShimmerWidget.rectangular(height: 150),
        ),
      ],
    );
  }
}
