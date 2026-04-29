import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/checklist_controller.dart';
import 'package:mepco_esafety_app/models/checklist_item.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class PtwIssuerInstructionsScreen extends StatelessWidget {
  const PtwIssuerInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller specifically for issuer instructions

    final args = Get.arguments as Map<String, dynamic>?;
    final ptwId = args?['ptw_id'] as int?;
      final ChecklistController controller = Get.put(
      ChecklistController(
      ChecklistType.issuerInstructions,
      initialPtwId: ptwId ?? 0,
    ),
        tag: ChecklistType.issuerInstructions.toString(),
    );
    if (ptwId != null) {
      controller.ptwId.value = ptwId;
    }
    return Scaffold(
      extendBody: true,

      body: Obx(() => MainLayout(
        title: controller.checklistTitle.value,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: LoadingWidget());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.checklistItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.checklistItems[index];
                    return _buildChecklistItem(controller, item);
                  },
                ),

                const SizedBox(height: 40),

                Obx(() => BottomNavigationButtons(
                  onBackPressed: () => Get.back(),
                  onNextPressed: () async {
                    final isSubmitted =
                    await controller.submitChecklist();
                    if (isSubmitted) {
                      Get.toNamed(AppRoutes.ptwReviewSdo,
                          arguments: Get.arguments);
                    }
                  },
                  isSubmitting: controller.isSubmitting.value,
                )),

                // Extra bottom spacing so buttons NEVER overflow
                const SizedBox(height: 10),
              ],
            ),
          );
        }),
      )),
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

  // Widget _buildAcknowledgeButton(ChecklistController controller) {
  //   return Container(
  //     color: Colors.white,
  //     child: Padding(
  //       padding: const EdgeInsets.only(bottom: 24.0, left: 24, right: 24, top: 12),
  //       child: GradientButton(
  //         text: 'Acknowledge & Continue',
  //         onPressed: () {
  //           controller.submitChecklist();
  //           Get.toNamed(AppRoutes.ptwReviewSdo);
  //         },
  //       ),
  //     ),
  //   );
  // }
}
