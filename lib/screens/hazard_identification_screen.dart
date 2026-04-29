import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/checklist_controller.dart';
import 'package:mepco_esafety_app/models/checklist_item.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class HazardIdentificationScreen extends StatelessWidget {
  const HazardIdentificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final ptwId = args?['ptw_id'] as int?;
    final ChecklistController controller = Get.put(
      ChecklistController(ChecklistType.hazard),
      tag: ChecklistType.hazard.toString(),
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
                    return _buildChecklistItemWithDropdown(controller, item);
                  },
                ),
                const SizedBox(height: 40),
                Obx(() => BottomNavigationButtons(
                  onBackPressed: () => Get.back(),
                  onNextPressed: () {
                    controller.submitChecklist();
                    Get.toNamed(
                      AppRoutes.ptwReviewSdo,
                      arguments: Get.arguments,
                    );
                  },
                  isSubmitting: controller.isSubmitting.value,
                )),
              ],
            ),
          );
        }),
      )),
    );
  }

  Widget _buildChecklistItemWithDropdown(
      ChecklistController controller,
      ChecklistItem item,
      ) {
    return Obx(() {
      final autoPrecautions = controller.getAutoPrecautions(item.id);
      final isExpanded = controller.isDropdownExpanded(item.id);
      final hasAutoPrecautions = autoPrecautions.isNotEmpty;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasAutoPrecautions ? Colors.blue.shade200 : Colors.grey.shade300,
            width: hasAutoPrecautions ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Main checklist item
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.textEnglish,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.textUrdu,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      // Dropdown toggle button (only show if has auto precautions)
                      if (hasAutoPrecautions)
                        InkWell(
                          onTap: () => controller.toggleDropdown(item.id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.blue.shade600,
                              size: 24,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Checkbox
                      Checkbox(
                        value: controller.checklistItems
                            .firstWhere(
                              (e) => e.id == item.id,
                          orElse: () => item,
                        )
                            .value,
                        onChanged: (newValue) {
                          controller.toggleItem(item.id, newValue!);
                        },
                        activeColor: const Color(0xFF002997),
                        checkColor: Colors.white,
                        side: const BorderSide(color: Colors.grey, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Auto precautions dropdown
            if (hasAutoPrecautions && isExpanded)
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.blue.shade200, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_mode,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Safety PPE (Auto Selected)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Precautions list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: autoPrecautions.length,
                      itemBuilder: (context, index) {
                        final precaution = autoPrecautions[index];
                        return _buildAutoPrecautionItem(precaution);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildAutoPrecautionItem(ChecklistItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          // Disabled checkbox (always checked)
          AbsorbPointer(
            child: Checkbox(
              value: true,
              onChanged: null,
              activeColor: Colors.blue.shade400,
              checkColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade400, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.textEnglish,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.textUrdu,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mepco_esafety_app/controllers/checklist_controller.dart';
// import 'package:mepco_esafety_app/models/checklist_item.dart';
// import 'package:mepco_esafety_app/routes/app_routes.dart';
// import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
// import 'package:mepco_esafety_app/widgets/loading_widget.dart';
// import 'package:mepco_esafety_app/widgets/main_layout.dart';
//
// class HazardIdentificationScreen extends StatelessWidget {
//   const HazardIdentificationScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // ✅ Correctly receive arguments as a Map
//     final args = Get.arguments as Map<String, dynamic>?;
//     final ptwId = args?['ptw_id'] as int?;
//     final ChecklistController controller = Get.put(
//       ChecklistController(ChecklistType.hazard),
//       tag: ChecklistType.hazard.toString(), // Unique tag for this instance
//     );
//     if (ptwId != null) {
//       controller.ptwId.value = ptwId;
//     }
//
//     return Scaffold(
//       extendBody: true,
//
//       body: Obx(() => MainLayout(
//         title: controller.checklistTitle.value,
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return const Center(child: LoadingWidget());
//           }
//           return SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: controller.checklistItems.length,
//                   itemBuilder: (context, index) {
//                     final item = controller.checklistItems[index];
//                     return _buildChecklistItem(controller, item);
//                   },
//                 ),
//                 SizedBox(height: 40,),
//                 Obx( ()=> BottomNavigationButtons(
//                   onBackPressed: () => Get.back(),
//                   onNextPressed: () {
//                     controller.submitChecklist();
//                     Get.toNamed(AppRoutes.ptwIssuerInstructions, arguments: Get.arguments); // Pass arguments to the next screen
//                   },
//                   isSubmitting:  controller.isSubmitting.value,
//                 ),),
//               ],
//             ),
//           );
//         }),
//       )),
//     );
//   }
//
//   Widget _buildChecklistItem(ChecklistController controller, ChecklistItem item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.textEnglish,
//                     style: const TextStyle(
//                         fontSize: 15,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w500)),
//                 Text(item.textUrdu,
//                     style: const TextStyle(fontSize: 14, color: Colors.grey)),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           Obx(() => Checkbox(
//                 value: controller.checklistItems
//                     .firstWhere((e) => e.id == item.id, orElse: () => item)
//                     .value,
//                 onChanged: (newValue) {
//                   controller.toggleItem(item.id, newValue!);
//                 },
//                 activeColor: Color(0xFF002997),
//                 checkColor: Colors.white,
//                 side: const BorderSide(color: Colors.grey, width: 1.5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
// }
