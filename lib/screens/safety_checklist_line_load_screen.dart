import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/checklist_controller.dart';
import 'package:mepco_esafety_app/models/checklist_item.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';

class SafetyChecklistLineLoadScreen extends StatelessWidget {
  const SafetyChecklistLineLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Receive PTW data passed from previous screen
    final args = Get.arguments ?? {};
    final int? ptwId = args['ptw_id'];
    final String? ptwCode = args['ptw_code'];
    final String? workOrderNo = args['work_order_no'];

    final ChecklistController controller = Get.put(
      ChecklistController(
        ChecklistType.safety,
        initialPtwId: ptwId ?? 0,
      ),
      tag: ChecklistType.safety.toString(),
    );
    return Scaffold(
      extendBody: true,
      body: Obx(() => MainLayout(
        title: controller.checklistTitle.value,
        child: controller.isLoading.value
            ? _buildShimmerEffect(context)
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checklist items
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

              // BOTTOM BUTTONS THAT SCROLL
              Obx(() => BottomNavigationButtons(
                onBackPressed: () => Get.back(),
                onNextPressed: () async {
                  final success = await controller.submitChecklist();
                  if (success) {
                    Get.toNamed(
                      AppRoutes.hazardIdentification,
                      arguments: {
                        'ptw_id': ptwId,
                        'ptw_code': ptwCode,
                        'work_order_no': workOrderNo,
                      },
                    );
                  }
                },
                isSubmitting: controller.isSubmitting.value,
              )),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerWidget.rectangular(height: 15),
                    const SizedBox(height: 8),
                    ShimmerWidget.rectangular(
                        height: 14, width: MediaQuery.of(context).size.width * 0.6),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const ShimmerWidget.rectangular(height: 24, width: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChecklistItem(ChecklistController controller, ChecklistItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
}
