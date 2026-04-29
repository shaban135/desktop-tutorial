
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/checklist_controller.dart';
import 'package:mepco_esafety_app/controllers/ptw_review_sdo_controller.dart';
import 'package:mepco_esafety_app/models/checklist_item.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
import 'package:mepco_esafety_app/widgets/upload_button.dart';
import 'package:share_plus/share_plus.dart';


class GridPtwIssueChecklistScreen extends StatefulWidget {
  const GridPtwIssueChecklistScreen({super.key});

  @override
  State<GridPtwIssueChecklistScreen> createState() =>
      _GridPtwIssueChecklistScreenState();
}

class _GridPtwIssueChecklistScreenState
    extends State<GridPtwIssueChecklistScreen> {

  bool _isConfirmed = false;
  final _decisionController = TextEditingController();

  late final PtwReviewSdoController ptwController;
  late final ChecklistController checklistController;
  int? _ptwId;

  @override
  void initState() {
    super.initState();

    ptwController = Get.isRegistered<PtwReviewSdoController>()
        ? Get.find<PtwReviewSdoController>()
        : Get.put(PtwReviewSdoController());

    final args = Get.arguments ?? {};
    _ptwId = args['ptw_id'] as int?;

    const tag = 'ChecklistType.gridPtwIssue';
    checklistController = Get.isRegistered<ChecklistController>(tag: tag)
        ? Get.find<ChecklistController>(tag: tag)
        : Get.put(ChecklistController(ChecklistType.gridPtwIssue), tag: tag);

    if (_ptwId != null) {
      checklistController.ptwId.value = _ptwId!;
    }
  }

  @override
  void dispose() {
    _decisionController.dispose();
    super.dispose();
  }


  Future<void> _onSubmit() async {
    if (!_isConfirmed) {
      Get.snackbar('Error', 'Please confirm all information is correct.',
          backgroundColor: AppColors.primaryBlue, colorText: Colors.white);
      return;
    }

    if (_ptwId == null) {
      Get.snackbar("Error", "PTW ID missing");
      return;
    }

    await ptwController.submitGridOperatorPrechecks(
      _ptwId!,
      _decisionController.text.trim(),
      checklistController.checklistItems,
      ptwController.images,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: MainLayout(
        title: "Grid Pre-Issue Checklist",
        child: Obx(() {
          if (checklistController.isLoading.value) {
            return _buildShimmerEffect(context);
          }

          return ListView(
            children: [
              _buildChecklistSection(checklistController),
              const SizedBox(height: 14),
              _buildAttachmentsSection(ptwController),
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
                    isSubmitting: ptwController.isSubmitting.value,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // UI ------------------------------------------------------

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
            controller: _decisionController,
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
                  color: Color(0xFF002997),  // ⭐ BLUE BORDER
                  width: 1.3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Color(0xFF002997),  // ⭐ BLUE BORDER (focus)
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

  Widget _buildChecklistItem(ChecklistController controller, ChecklistItem item) {
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
                activeColor: Color(0xFF002997),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(PtwReviewSdoController controller) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feeder racked out Pictures\nفیڈر کے باہر رکھی تصویریں',
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
      ),
    );
  }

  Widget _buildImagePreviews(PtwReviewSdoController controller) {
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
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Checkbox(
            value: _isConfirmed,
            onChanged: (value) =>
                setState(() => _isConfirmed = value!),
            activeColor: Color(0xFF002997),
          ),
          const Expanded(
            child: Text(
              'I confirm all information provided is correct and attachments are complete.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 10,
      itemBuilder: (_, __) =>
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ShimmerWidget.rectangular(height: 20),
      ),
    );
  }
}
