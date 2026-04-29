import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gal/gal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/ptw_review_sdo_controller.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';

import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';

class PtwReviewSdoScreen extends StatefulWidget {
  const PtwReviewSdoScreen({super.key});

  @override
  State<PtwReviewSdoScreen> createState() => _PtwReviewSdoScreenState();
}

class _PtwReviewSdoScreenState extends State<PtwReviewSdoScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PtwReviewSdoController>();
    final args = Get.arguments ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Obx(() {
        final userRole =
        (args['user_role'] as String? ?? controller.currentUserRole.value)
            .trim()
            .toUpperCase();
        final type = controller.ptwData['type']?.toString().toUpperCase() ?? '';
        final status =
            controller.ptwData['current_status']?.toString().toUpperCase() ??
                '';
        print('THE STATUS $status');
        final title = 'PTW Review';

        return MainLayout(
          title: title,
          child: controller.isLoading.value
              ? _buildShimmerLoading()
              : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Hero Status Header
                      _buildHeroHeader(controller, userRole),

                      // Quick Stats Grid
                      _buildQuickStats(controller),

                      const SizedBox(height: 20),

                      // Tab Headers (Non-sticky)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildTabButton('Details', 0),
                            _buildTabButton('Team', 1),
                            // if(type !='PLANNED')
                            _buildTabButton('Checklist', 2),
                            _buildTabButton('Timeline', 3),
                            _buildTabButton('Evidence', 4),
                            if (userRole == 'PDC' &&
                                [
                                  'XEN_APPROVED_TO_PDC',
                                  'LS_RESUBMIT_TO_PDC',
                                  'PTW_ISSUED',
                                  'RE_SUBMITTED_TO_PDC',
                                  'GRID_RESOLVE_REQUIRED',
                                ].contains(status))
                              _buildTabButton('Task', 5),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tab Content
                      _buildTabContent(controller),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Widget _buildFeederStatusSection(PtwReviewSdoController controller) {
  //   final args = Get.arguments ?? {};
  //   final userRole =
  //       ((args['user_role'] ?? controller.currentUserRole.value)
  //           ?.toString()
  //           .trim()
  //           .toUpperCase()) ??
  //       'LS';
  //
  //   final status =
  //       controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
  //
  //   // ✅ Check if we need to show feeder management section
  //   final showFeederManagement =
  //       status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC';
  //
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.04),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // ✅ HEADER
  //           Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: Icon(
  //                   showFeederManagement
  //                       ? Icons.power_settings_new_rounded
  //                       : Icons.assignment_rounded,
  //                   color: const Color(0xFF6A1B9A),
  //                   size: 20,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Obx(() => Text(
  //                 controller.showDelegationSection.value
  //                     ? 'PTW Delegation'
  //                     : (showFeederManagement
  //                     ? 'Feeder Status Confirmation'
  //                     : 'PTW Decision'),
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black87,
  //                 ),
  //               )),
  //             ],
  //           ),
  //           const SizedBox(height: 20),
  //
  //           // ✅ FEEDER MANAGEMENT SECTION (Only for PTW_ISSUED / RE_SUBMITTED_TO_PDC)
  //           Obx(() {
  //             // Hide if delegation checkbox is checked
  //             if (controller.showDelegationSection.value) {
  //               return const SizedBox.shrink();
  //             }
  //
  //             if (!showFeederManagement) {
  //               return const SizedBox.shrink();
  //             }
  //
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   'Manage Feeders',
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     color: Colors.black54,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 12),
  //
  //                 Obx(
  //                   () => InkWell(
  //                     onTap: () {
  //                       _showFeederSelectionDialog(Get.context!, controller);
  //                     },
  //                     child: Container(
  //                       padding: const EdgeInsets.symmetric(
  //                         horizontal: 16,
  //                         vertical: 14,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey.shade50,
  //                         borderRadius: BorderRadius.circular(12),
  //                         border: Border.all(
  //                           color: controller.turnedOffFeeders.isEmpty
  //                               ? Colors.grey.shade300
  //                               : Colors.orange.shade300,
  //                           width: controller.turnedOffFeeders.isEmpty ? 1 : 2,
  //                         ),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           Icon(
  //                             Icons.power_settings_new,
  //                             color: controller.turnedOffFeeders.isEmpty
  //                                 ? Colors.grey.shade400
  //                                 : Colors.orange,
  //                             size: 20,
  //                           ),
  //                           const SizedBox(width: 12),
  //                           Expanded(
  //                             child: Text(
  //                               controller.turnedOffFeeders.isEmpty
  //                                   ? 'All feeders are ON'
  //                                   : '${controller.turnedOffFeeders.length} feeder(s) turned OFF',
  //                               style: TextStyle(
  //                                 fontSize: 14,
  //                                 color: controller.turnedOffFeeders.isEmpty
  //                                     ? Colors.grey.shade600
  //                                     : Colors.orange.shade700,
  //                                 fontWeight:
  //                                     controller.turnedOffFeeders.isEmpty
  //                                     ? FontWeight.normal
  //                                     : FontWeight.w600,
  //                               ),
  //                             ),
  //                           ),
  //                           Icon(
  //                             Icons.arrow_drop_down,
  //                             color: Colors.grey.shade600,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //
  //                 // Turned OFF Feeders Chips
  //                 Obx(() {
  //                   if (controller.turnedOffFeeders.isEmpty)
  //                     return const SizedBox.shrink();
  //
  //                   final turnedOffFeedersList = controller.allFeeders
  //                       .where(
  //                         (f) => controller.turnedOffFeeders.contains(f['id']),
  //                       )
  //                       .toList();
  //
  //                   return Container(
  //                     margin: const EdgeInsets.only(top: 12),
  //                     padding: const EdgeInsets.all(12),
  //                     decoration: BoxDecoration(
  //                       color: Colors.orange.withValues(alpha: 0.05),
  //                       borderRadius: BorderRadius.circular(10),
  //                       border: Border.all(
  //                         color: Colors.orange.withValues(alpha: 0.2),
  //                       ),
  //                     ),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           children: [
  //                             Icon(
  //                               Icons.warning_rounded,
  //                               color: Colors.orange.shade700,
  //                               size: 16,
  //                             ),
  //                             const SizedBox(width: 6),
  //                             Text(
  //                               'Feeders Turned OFF:',
  //                               style: TextStyle(
  //                                 fontSize: 12,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.orange.shade700,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         const SizedBox(height: 10),
  //                         Wrap(
  //                           spacing: 8,
  //                           runSpacing: 8,
  //                           children: turnedOffFeedersList.map((feeder) {
  //                             final isPrimary = feeder['type'] == 'Primary';
  //                             return Container(
  //                               padding: const EdgeInsets.symmetric(
  //                                 horizontal: 10,
  //                                 vertical: 6,
  //                               ),
  //                               decoration: BoxDecoration(
  //                                 color: Colors.orange.withValues(alpha: 0.1),
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 border: Border.all(
  //                                   color: Colors.orange.withValues(alpha: 0.3),
  //                                 ),
  //                               ),
  //                               child: Row(
  //                                 mainAxisSize: MainAxisSize.min,
  //                                 children: [
  //                                   Icon(
  //                                     isPrimary
  //                                         ? Icons.star
  //                                         : Icons.electrical_services,
  //                                     size: 14,
  //                                     color: Colors.orange.shade700,
  //                                   ),
  //                                   const SizedBox(width: 6),
  //                                   Text(
  //                                     feeder['name'].toString(),
  //                                     style: TextStyle(
  //                                       fontSize: 12,
  //                                       fontWeight: FontWeight.w600,
  //                                       color: Colors.orange.shade800,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 6),
  //                                   GestureDetector(
  //                                     onTap: () {
  //                                       controller.turnedOffFeeders.remove(
  //                                         feeder['id'],
  //                                       );
  //                                       if (controller
  //                                           .turnedOffFeeders
  //                                           .isEmpty) {
  //                                         controller
  //                                                 .feederConfirmationConsent
  //                                                 .value =
  //                                             false;
  //                                       }
  //                                     },
  //                                     child: Icon(
  //                                       Icons.close,
  //                                       size: 16,
  //                                       color: Colors.orange.shade700,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           }).toList(),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }),
  //
  //                 // Consent Checkbox
  //                 Obx(() {
  //                   if (controller.turnedOffFeeders.isEmpty)
  //                     return const SizedBox.shrink();
  //
  //                   return Container(
  //                     margin: const EdgeInsets.only(top: 16),
  //                     padding: const EdgeInsets.all(14),
  //                     decoration: BoxDecoration(
  //                       color: Colors.orange.shade50,
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(
  //                         color: Colors.orange.shade300,
  //                         width: 1.5,
  //                       ),
  //                     ),
  //                     child: Row(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Obx(
  //                           () => InkWell(
  //                             onTap: () {
  //                               controller.feederConfirmationConsent.value =
  //                                   !controller.feederConfirmationConsent.value;
  //                             },
  //                             child: Container(
  //                               width: 22,
  //                               height: 22,
  //                               decoration: BoxDecoration(
  //                                 color:
  //                                     controller.feederConfirmationConsent.value
  //                                     ? const Color(0xFF6A1B9A)
  //                                     : Colors.white,
  //                                 borderRadius: BorderRadius.circular(6),
  //                                 border: Border.all(
  //                                   color:
  //                                       controller
  //                                           .feederConfirmationConsent
  //                                           .value
  //                                       ? const Color(0xFF6A1B9A)
  //                                       : Colors.grey.shade400,
  //                                   width: 2,
  //                                 ),
  //                               ),
  //                               child:
  //                                   controller.feederConfirmationConsent.value
  //                                   ? const Icon(
  //                                       Icons.check,
  //                                       size: 16,
  //                                       color: Colors.white,
  //                                     )
  //                                   : null,
  //                             ),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 12),
  //                         Expanded(
  //                           child: Text(
  //                             'I have confirmed that the above feeder(s) have been turned OFF and the information provided is accurate',
  //                             style: TextStyle(
  //                               fontSize: 13,
  //                               color: Colors.grey.shade800,
  //                               height: 1.4,
  //                               fontWeight: FontWeight.w500,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }),
  //
  //                 const SizedBox(height: 24),
  //               ],
  //             );
  //           }),
  //
  //           // ✅ NEW: DELEGATION CHECKBOX (Only for XEN_APPROVED_TO_PDC and LS_RESUBMIT_TO_PDC)
  //           if (userRole == 'PDC' &&
  //               [
  //                 'XEN_APPROVED_TO_PDC',
  //                 'LS_RESUBMIT_TO_PDC',
  //                 'PTW_ISSUED',
  //                 'RE_SUBMITTED_TO_PDC',
  //               ].contains(status)) ...[
  //             Container(
  //               padding: const EdgeInsets.all(14),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
  //                 borderRadius: BorderRadius.circular(12),
  //                 border: Border.all(
  //                   color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
  //                 ),
  //               ),
  //               child: Obx(
  //                 () => Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     InkWell(
  //                       onTap: () {
  //                         controller.showDelegationSection.value =
  //                             !controller.showDelegationSection.value;
  //
  //                         // Reset delegation selection when unchecking
  //                         if (!controller.showDelegationSection.value) {
  //                           controller.selectedDelegatedPdcId.value = null;
  //                           controller.decisionNotesController.clear();
  //                         }
  //                       },
  //                       child: Container(
  //                         width: 22,
  //                         height: 22,
  //                         decoration: BoxDecoration(
  //                           color: controller.showDelegationSection.value
  //                               ? const Color(0xFF6A1B9A)
  //                               : Colors.white,
  //                           borderRadius: BorderRadius.circular(6),
  //                           border: Border.all(
  //                             color: controller.showDelegationSection.value
  //                                 ? const Color(0xFF6A1B9A)
  //                                 : Colors.grey.shade400,
  //                             width: 2,
  //                           ),
  //                         ),
  //                         child: controller.showDelegationSection.value
  //                             ? const Icon(
  //                                 Icons.check,
  //                                 size: 16,
  //                                 color: Colors.white,
  //                               )
  //                             : null,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     Expanded(
  //                       child: Text(
  //                         'I want to delegate this PTW or add decision notes',
  //                         style: TextStyle(
  //                           fontSize: 14,
  //                           color: Colors.grey.shade800,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // ✅ DELEGATION SECTION (Only shown when checkbox is checked)
  //             Obx(() {
  //               if (!controller.showDelegationSection.value) {
  //                 return const SizedBox.shrink();
  //               }
  //
  //               return Column(
  //                 children: [
  //                   // Delegate to Another PDC
  //                   Container(
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: Colors.blue.shade50,
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(color: Colors.blue.shade200),
  //                     ),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           children: [
  //                             Icon(
  //                               Icons.person_add_alt_rounded,
  //                               color: Colors.blue.shade700,
  //                               size: 20,
  //                             ),
  //                             const SizedBox(width: 8),
  //                             Text(
  //                               'Delegate to Another PDC (Optional)',
  //                               style: TextStyle(
  //                                 fontSize: 14,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.blue.shade700,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         const SizedBox(height: 12),
  //
  //                         Obx(
  //                           () => DropdownButtonFormField<int>(
  //                             value: controller.selectedDelegatedPdcId.value,
  //                             decoration: InputDecoration(
  //                               labelText: 'Select PDC',
  //                               hintText: 'Choose a PDC to delegate',
  //                               border: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(10),
  //                               ),
  //                               filled: true,
  //                               fillColor: Colors.white,
  //                             ),
  //                             items: [
  //                               const DropdownMenuItem<int>(
  //                                 value: null,
  //                                 child: Text('None (Continue yourself)'),
  //                               ),
  //                               ...controller.pdcList.map((pdc) {
  //                                 return DropdownMenuItem<int>(
  //                                   value: pdc['id'],
  //                                   child: Text(pdc['name'] ?? 'Unknown'),
  //                                 );
  //                               }).toList(),
  //                             ],
  //                             onChanged: (value) {
  //                               controller.selectedDelegatedPdcId.value = value;
  //                             },
  //                           ),
  //                         ),
  //
  //                         const SizedBox(height: 8),
  //                         Text(
  //                           'If you select a PDC, this PTW will be delegated to them. Otherwise, you will continue processing it.',
  //                           style: TextStyle(
  //                             fontSize: 11,
  //                             color: Colors.grey.shade600,
  //                             fontStyle: FontStyle.italic,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //
  //                   const SizedBox(height: 16),
  //
  //                   // Decision Notes
  //                   Container(
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(
  //                         color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
  //                       ),
  //                     ),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           children: [
  //                             Icon(
  //                               Icons.note_add_rounded,
  //                               color: const Color(0xFF6A1B9A),
  //                               size: 20,
  //                             ),
  //                             const SizedBox(width: 8),
  //                             Text(
  //                               'Decision Notes',
  //                               style: TextStyle(
  //                                 fontSize: 14,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: const Color(0xFF6A1B9A),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         const SizedBox(height: 12),
  //                         CustomTextFormField(
  //                           labelText: 'Enter your decision notes...',
  //                           maxLines: 4,
  //                           controller: controller.decisionNotesController,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //
  //                   const SizedBox(height: 20),
  //
  //                   // Delegate to PDC Button
  //                   SizedBox(
  //                     width: double.infinity,
  //                     height: 52,
  //                     child: ElevatedButton(
  //                       onPressed: () async {
  //                         bool confirm = await showConfirmationDialog(
  //                           Get.context!,
  //                           "Are you sure you want to proceed with delegation?",
  //                         );
  //                         if (!confirm) return;
  //
  //                         final ptwId = controller.ptwData['id'];
  //                         final notes = controller.decisionNotesController.text
  //                             .trim();
  //
  //                         await controller.forwardPTW(
  //                           ptwId,
  //                           userRole,
  //                           notes,
  //                           action: PtwActionType.delegatePDC,
  //                         );
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: const Color(0xFF6A1B9A),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(14),
  //                         ),
  //                         elevation: 2,
  //                       ),
  //                       child: const Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Icon(
  //                             Icons.send_rounded,
  //                             color: Colors.white,
  //                             size: 20,
  //                           ),
  //                           SizedBox(width: 10),
  //                           Text(
  //                             'Delegate to PDC',
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 15,
  //                               fontWeight: FontWeight.w600,
  //                               letterSpacing: 0.3,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             }),
  //           ],
  //
  //           // ✅ BOTTOM ACTIONS (Hidden when delegation section is shown)
  //           Obx(() {
  //             // Hide bottom actions if delegation section is shown
  //             if (userRole == 'PDC' &&
  //                 [
  //                   'XEN_APPROVED_TO_PDC',
  //                   'LS_RESUBMIT_TO_PDC',
  //                   'PTW_ISSUED',
  //                   'RE_SUBMITTED_TO_PDC',
  //                 ].contains(status) &&
  //                 controller.showDelegationSection.value) {
  //               return const SizedBox.shrink();
  //             }
  //
  //             return _buildBottomActions(controller);
  //           }),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildFeederStatusSection(PtwReviewSdoController controller) {
    final args = Get.arguments ?? {};
    final userRole =
        ((args['user_role'] ?? controller.currentUserRole.value)
            ?.toString()
            .trim()
            .toUpperCase()) ??
            'LS';

    final status =
        controller.ptwData['current_status']?.toString().toUpperCase() ?? '';

    // ✅ Check if we need to show feeder management section
    final showFeederManagement =
        status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Obx(
                        () => Icon(
                      controller.showDelegationSection.value
                          ? Icons.assignment_rounded
                          : (showFeederManagement
                          ? Icons.power_settings_new_rounded
                          : Icons.assignment_rounded),
                      color: const Color(0xFF6A1B9A),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                      () => Text(
                    controller.showDelegationSection.value
                        ? 'PTW Delegation'
                        : (showFeederManagement
                        ? 'Feeder Status Confirmation'
                        : 'PTW Decision'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ DELEGATION CHECKBOX (NOW AT TOP - FIRST)
            if (userRole == 'PDC' &&
                [
                  'XEN_APPROVED_TO_PDC',
                  'LS_RESUBMIT_TO_PDC',
                  'PTW_ISSUED',
                  'RE_SUBMITTED_TO_PDC',
                  'GRID_RESOLVE_REQUIRED',
                ].contains(status)) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
                  ),
                ),
                child: Obx(
                      () => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          controller.showDelegationSection.value =
                          !controller.showDelegationSection.value;

                          // Reset delegation selection when unchecking
                          if (!controller.showDelegationSection.value) {
                            controller.selectedDelegatedPdcId.value = null;
                            controller.decisionNotesController.clear();
                          }
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: controller.showDelegationSection.value
                                ? const Color(0xFF6A1B9A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: controller.showDelegationSection.value
                                  ? const Color(0xFF6A1B9A)
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: controller.showDelegationSection.value
                              ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'I want to delegate this PTW or add decision notes',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ DELEGATION SECTION (Only shown when checkbox is checked)
              Obx(() {
                if (!controller.showDelegationSection.value) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    // Delegate to Another PDC
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_add_alt_rounded,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delegate to Another PDC (Optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Obx(
                                () => DropdownButtonFormField<int>(
                              value: controller.selectedDelegatedPdcId.value,
                              decoration: InputDecoration(
                                labelText: 'Select PDC',
                                hintText: 'Choose a PDC to delegate',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('None (Continue yourself)'),
                                ),
                                ...controller.pdcList.map((pdc) {
                                  return DropdownMenuItem<int>(
                                    value: pdc['id'],
                                    child: Text(pdc['name'] ?? 'Unknown'),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                controller.selectedDelegatedPdcId.value = value;
                              },
                            ),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            'If you select a PDC, this PTW will be delegated to them. Otherwise, you will continue processing it.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Decision Notes
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.note_add_rounded,
                                color: const Color(0xFF6A1B9A),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Decision Notes',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6A1B9A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          CustomTextFormField(
                            labelText: 'Enter your decision notes...',
                            maxLines: 4,
                            controller: controller.decisionNotesController,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Delegate to PDC Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool confirm = await showConfirmationDialog(
                            Get.context!,
                            "Are you sure you want to proceed with delegation?",
                          );
                          if (!confirm) return;

                          final ptwId = controller.ptwData['id'];
                          final notes = controller.decisionNotesController.text
                              .trim();

                          await controller.forwardPTW(
                            ptwId,
                            userRole,
                            notes,
                            action: PtwActionType.delegatePDC,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Delegate to PDC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                );
              }),
            ],

            // ✅ FEEDER MANAGEMENT SECTION (NOW SECOND - Hidden when delegation is active)
            Obx(() {
              // Hide feeder management if delegation checkbox is checked
              if (controller.showDelegationSection.value) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ FEEDER MANAGEMENT (only if showFeederManagement is true)
                  if (showFeederManagement) ...[
                    const Text(
                      'Manage Feeders',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Obx(
                          () => InkWell(
                        onTap: () {
                          _showFeederSelectionDialog(Get.context!, controller);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: controller.turnedOffFeeders.isEmpty
                                  ? Colors.grey.shade300
                                  : Colors.orange.shade300,
                              width: controller.turnedOffFeeders.isEmpty
                                  ? 1
                                  : 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.power_settings_new,
                                color: controller.turnedOffFeeders.isEmpty
                                    ? Colors.grey.shade400
                                    : Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.turnedOffFeeders.isEmpty
                                      ? 'All feeders are ON'
                                      : '${controller.turnedOffFeeders.length} feeder(s) turned OFF',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: controller.turnedOffFeeders.isEmpty
                                        ? Colors.grey.shade600
                                        : Colors.orange.shade700,
                                    fontWeight:
                                    controller.turnedOffFeeders.isEmpty
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Turned OFF Feeders Chips
                    Obx(() {
                      if (controller.turnedOffFeeders.isEmpty)
                        return const SizedBox.shrink();

                      final turnedOffFeedersList = controller.allFeeders
                          .where(
                            (f) =>
                            controller.turnedOffFeeders.contains(f['id']),
                      )
                          .toList();

                      return Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: Colors.orange.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Feeders Turned OFF:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: turnedOffFeedersList.map((feeder) {
                                final isPrimary = feeder['type'] == 'Primary';
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.orange.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPrimary
                                            ? Icons.star
                                            : Icons.electrical_services,
                                        size: 14,
                                        color: Colors.orange.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        feeder['name'].toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () {
                                          controller.turnedOffFeeders.remove(
                                            feeder['id'],
                                          );
                                          if (controller
                                              .turnedOffFeeders
                                              .isEmpty) {
                                            controller
                                                .feederConfirmationConsent
                                                .value =
                                            false;
                                          }
                                        },
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Consent Checkbox
                    Obx(() {
                      if (controller.turnedOffFeeders.isEmpty)
                        return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                                  () => InkWell(
                                onTap: () {
                                  controller.feederConfirmationConsent.value =
                                  !controller
                                      .feederConfirmationConsent
                                      .value;
                                },
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color:
                                    controller
                                        .feederConfirmationConsent
                                        .value
                                        ? const Color(0xFF6A1B9A)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color:
                                      controller
                                          .feederConfirmationConsent
                                          .value
                                          ? const Color(0xFF6A1B9A)
                                          : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child:
                                  controller.feederConfirmationConsent.value
                                      ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'I have confirmed that the above feeder(s) have been turned OFF and the information provided is accurate',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                  ],

                  // ✅ DECISION NOTES (Always show when delegation checkbox is UNCHECKED)
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(
                  //       color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
                  //     ),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           Icon(
                  //             Icons.note_add_rounded,
                  //             color: const Color(0xFF6A1B9A),
                  //             size: 20,
                  //           ),
                  //           const SizedBox(width: 8),
                  //           Text(
                  //             'Decision Notes',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               fontWeight: FontWeight.bold,
                  //               color: const Color(0xFF6A1B9A),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 12),
                  //       CustomTextFormField(
                  //         labelText: 'Enter your decision notes...',
                  //         maxLines: 4,
                  //         controller: controller.decisionNotesController,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                ],
              );
            }),
            // ✅ BOTTOM ACTIONS (Hidden when delegation section is shown)
            Obx(() {
              // Hide bottom actions if delegation section is shown
              if (userRole == 'PDC' &&
                  [
                    'XEN_APPROVED_TO_PDC',
                    'LS_RESUBMIT_TO_PDC',
                    'PTW_ISSUED',
                    'RE_SUBMITTED_TO_PDC',
                  ].contains(status) &&
                  controller.showDelegationSection.value) {
                return const SizedBox.shrink();
              }

              return _buildBottomActions(controller);
            }),
          ],
        ),
      ),
    );
  }

  // Widget _buildFeederStatusSection(PtwReviewSdoController controller) {
  //   final args = Get.arguments ?? {};
  //   final userRole =
  //       ((args['user_role'] ?? controller.currentUserRole.value)
  //           ?.toString()
  //           .trim()
  //           .toUpperCase()) ??
  //           'LS';
  //
  //   final status = controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
  //   // ✅ Check if we need to show feeder management section
  //   final showFeederManagement = status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC';
  //
  //   // ✅ Check if we need to show decision notes (only for main decision statuses)
  //   final showDecisionNotes = status == 'XEN_APPROVED_TO_PDC' || status == 'LS_RESUBMIT_TO_PDC';
  //
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.04),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // ✅ HEADER
  //           Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: Icon(
  //                   showFeederManagement
  //                       ? Icons.power_settings_new_rounded
  //                       : Icons.assignment_rounded,
  //                   color: const Color(0xFF6A1B9A),
  //                   size: 20,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Text(
  //                 showFeederManagement
  //                     ? 'Feeder Status Confirmation'
  //                     : 'PTW Decision',
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 20),
  //
  //           // ✅ FEEDER MANAGEMENT SECTION (Only for PTW_ISSUED / RE_SUBMITTED_TO_PDC)
  //           if (showFeederManagement) ...[
  //             const Text(
  //               'Manage Feeders',
  //               style: TextStyle(
  //                 fontSize: 13,
  //                 color: Colors.black54,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //
  //             Obx(() => InkWell(
  //               onTap: () {
  //                 _showFeederSelectionDialog(Get.context!, controller);
  //               },
  //               child: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade50,
  //                   borderRadius: BorderRadius.circular(12),
  //                   border: Border.all(
  //                     color: controller.turnedOffFeeders.isEmpty
  //                         ? Colors.grey.shade300
  //                         : Colors.orange.shade300,
  //                     width: controller.turnedOffFeeders.isEmpty ? 1 : 2,
  //                   ),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Icon(
  //                       Icons.power_settings_new,
  //                       color: controller.turnedOffFeeders.isEmpty
  //                           ? Colors.grey.shade400
  //                           : Colors.orange,
  //                       size: 20,
  //                     ),
  //                     const SizedBox(width: 12),
  //                     Expanded(
  //                       child: Text(
  //                         controller.turnedOffFeeders.isEmpty
  //                             ? 'All feeders are ON'
  //                             : '${controller.turnedOffFeeders.length} feeder(s) turned OFF',
  //                         style: TextStyle(
  //                           fontSize: 14,
  //                           color: controller.turnedOffFeeders.isEmpty
  //                               ? Colors.grey.shade600
  //                               : Colors.orange.shade700,
  //                           fontWeight: controller.turnedOffFeeders.isEmpty
  //                               ? FontWeight.normal
  //                               : FontWeight.w600,
  //                         ),
  //                       ),
  //                     ),
  //                     Icon(
  //                       Icons.arrow_drop_down,
  //                       color: Colors.grey.shade600,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             )),
  //
  //             // Turned OFF Feeders Chips
  //             Obx(() {
  //               if (controller.turnedOffFeeders.isEmpty) return const SizedBox.shrink();
  //
  //               final turnedOffFeedersList = controller.allFeeders
  //                   .where((f) => controller.turnedOffFeeders.contains(f['id']))
  //                   .toList();
  //
  //               return Container(
  //                 margin: const EdgeInsets.only(top: 12),
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: Colors.orange.withValues(alpha: 0.05),
  //                   borderRadius: BorderRadius.circular(10),
  //                   border: Border.all(
  //                     color: Colors.orange.withValues(alpha: 0.2),
  //                   ),
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         Icon(
  //                           Icons.warning_rounded,
  //                           color: Colors.orange.shade700,
  //                           size: 16,
  //                         ),
  //                         const SizedBox(width: 6),
  //                         Text(
  //                           'Feeders Turned OFF:',
  //                           style: TextStyle(
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.orange.shade700,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 10),
  //                     Wrap(
  //                       spacing: 8,
  //                       runSpacing: 8,
  //                       children: turnedOffFeedersList.map((feeder) {
  //                         final isPrimary = feeder['type'] == 'Primary';
  //                         return Container(
  //                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  //                           decoration: BoxDecoration(
  //                             color: Colors.orange.withValues(alpha: 0.1),
  //                             borderRadius: BorderRadius.circular(8),
  //                             border: Border.all(
  //                               color: Colors.orange.withValues(alpha: 0.3),
  //                             ),
  //                           ),
  //                           child: Row(
  //                             mainAxisSize: MainAxisSize.min,
  //                             children: [
  //                               Icon(
  //                                 isPrimary ? Icons.star : Icons.electrical_services,
  //                                 size: 14,
  //                                 color: Colors.orange.shade700,
  //                               ),
  //                               const SizedBox(width: 6),
  //                               Text(
  //                                 feeder['name'].toString(),
  //                                 style: TextStyle(
  //                                   fontSize: 12,
  //                                   fontWeight: FontWeight.w600,
  //                                   color: Colors.orange.shade800,
  //                                 ),
  //                               ),
  //                               const SizedBox(width: 6),
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   controller.turnedOffFeeders.remove(feeder['id']);
  //                                   if (controller.turnedOffFeeders.isEmpty) {
  //                                     controller.feederConfirmationConsent.value = false;
  //                                   }
  //                                 },
  //                                 child: Icon(
  //                                   Icons.close,
  //                                   size: 16,
  //                                   color: Colors.orange.shade700,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       }).toList(),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             }),
  //
  //             // Consent Checkbox
  //             Obx(() {
  //               if (controller.turnedOffFeeders.isEmpty) return const SizedBox.shrink();
  //
  //               return Container(
  //                 margin: const EdgeInsets.only(top: 16),
  //                 padding: const EdgeInsets.all(14),
  //                 decoration: BoxDecoration(
  //                   color: Colors.orange.shade50,
  //                   borderRadius: BorderRadius.circular(12),
  //                   border: Border.all(
  //                     color: Colors.orange.shade300,
  //                     width: 1.5,
  //                   ),
  //                 ),
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Obx(() => InkWell(
  //                       onTap: () {
  //                         controller.feederConfirmationConsent.value =
  //                         !controller.feederConfirmationConsent.value;
  //                       },
  //                       child: Container(
  //                         width: 22,
  //                         height: 22,
  //                         decoration: BoxDecoration(
  //                           color: controller.feederConfirmationConsent.value
  //                               ? const Color(0xFF6A1B9A)
  //                               : Colors.white,
  //                           borderRadius: BorderRadius.circular(6),
  //                           border: Border.all(
  //                             color: controller.feederConfirmationConsent.value
  //                                 ? const Color(0xFF6A1B9A)
  //                                 : Colors.grey.shade400,
  //                             width: 2,
  //                           ),
  //                         ),
  //                         child: controller.feederConfirmationConsent.value
  //                             ? const Icon(
  //                           Icons.check,
  //                           size: 16,
  //                           color: Colors.white,
  //                         )
  //                             : null,
  //                       ),
  //                     )),
  //                     const SizedBox(width: 12),
  //                     Expanded(
  //                       child: Text(
  //                         'I have confirmed that the above feeder(s) have been turned OFF and the information provided is accurate',
  //                         style: TextStyle(
  //                           fontSize: 13,
  //                           color: Colors.grey.shade800,
  //                           height: 1.4,
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             }),
  //
  //             const SizedBox(height: 24),
  //           ],
  //           if (userRole == 'PDC' &&
  //               (status == 'XEN_APPROVED_TO_PDC' || status == 'LS_RESUBMIT_TO_PDC')) ...[
  //             const SizedBox(height: 16),
  //
  //             Container(
  //               padding: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                 color: Colors.blue.shade50,
  //                 borderRadius: BorderRadius.circular(12),
  //                 border: Border.all(
  //                   color: Colors.blue.shade200,
  //                 ),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Icon(
  //                         Icons.person_add_alt_rounded,
  //                         color: Colors.blue.shade700,
  //                         size: 20,
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Text(
  //                         'Delegate to Another PDC (Optional)',
  //                         style: TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.blue.shade700,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 12),
  //
  //                   Obx(() => DropdownButtonFormField<int>(
  //                     value: controller.selectedDelegatedPdcId.value,
  //                     decoration: InputDecoration(
  //                       labelText: 'Select PDC',
  //                       hintText: 'Choose a PDC to delegate',
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       filled: true,
  //                       fillColor: Colors.white,
  //                     ),
  //                     items: [
  //                       const DropdownMenuItem<int>(
  //                         value: null,
  //                         child: Text('None (Continue yourself)'),
  //                       ),
  //                       ...controller.pdcList.map((pdc) {
  //                         return DropdownMenuItem<int>(
  //                           value: pdc['id'],
  //                           child: Text(pdc['name'] ?? 'Unknown'),
  //                         );
  //                       }).toList(),
  //                     ],
  //                     onChanged: (value) {
  //                       controller.selectedDelegatedPdcId.value = value;
  //                     },
  //                   )),
  //
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     'If you select a PDC, this PTW will be delegated to them. Otherwise, you will continue processing it.',
  //                     style: TextStyle(
  //                       fontSize: 11,
  //                       color: Colors.grey.shade600,
  //                       fontStyle: FontStyle.italic,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //           // ✅ DECISION NOTES SECTION (Only for XEN_APPROVED_TO_PDC / LS_RESUBMIT_TO_PDC)
  //           if (showDecisionNotes) ...[
  //             Container(
  //               padding: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
  //                 borderRadius: BorderRadius.circular(12),
  //                 border: Border.all(
  //                   color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
  //                 ),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Icon(
  //                         Icons.note_add_rounded,
  //                         color: const Color(0xFF6A1B9A),
  //                         size: 20,
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Text(
  //                         'Decision Notes',
  //                         style: TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                           color: const Color(0xFF6A1B9A),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 12),
  //                   CustomTextFormField(
  //                     labelText: 'Enter your decision notes...',
  //                     maxLines: 4,
  //                     controller: controller.decisionNotesController,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //           ],
  //
  //           // ✅ ACTION BUTTONS (For ALL PDC statuses)
  //           Obx(() => _buildBottomActions(controller)),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // ==================== REPLACE YOUR _showFeederSelectionDialog METHOD ====================
  void _showFeederSelectionDialog(
      BuildContext context,
      PtwReviewSdoController controller,
      ) {
    // Group feeders by grid station
    final Map<String, List<Map<String, dynamic>>> groupedFeeders = {};

    for (var feeder in controller.allFeeders) {
      final gridName = feeder['grid_name']?.toString() ?? 'Unknown Grid';
      final gridCode = feeder['grid_code']?.toString() ?? '';
      final operatorName = feeder['operator_name']?.toString() ?? '';
      final gridKey = '$gridName|$gridCode|$operatorName';

      if (!groupedFeeders.containsKey(gridKey)) {
        groupedFeeders[gridKey] = [];
      }
      groupedFeeders[gridKey]!.add(feeder);
    }

    // Count total OFF and PENDING feeders
    int getTotalOff() => controller.turnedOffFeeders.length;
    int getTotalPending() =>
        controller.allFeeders.length - controller.turnedOffFeeders.length;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================== HEADER ====================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6A1B9A),
                        const Color(0xFF6A1B9A).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.power_settings_new,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Feeder Status Confirmation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Status badges
                      Obx(
                            () => Row(
                          children: [
                            // OFF Badge
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${getTotalOff()}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'OFF',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // PENDING Badge
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.green.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${getTotalPending()}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'PENDING',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // TOTAL Badge
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${controller.allFeeders.length}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'TOTAL',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================== FEEDERS LIST BY GRID ====================
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: groupedFeeders.keys.length,
                    itemBuilder: (context, gridIndex) {
                      final gridKey = groupedFeeders.keys.elementAt(gridIndex);
                      final parts = gridKey.split('|');
                      final gridName = parts[0];
                      final gridCode = parts[1];
                      final operatorName = parts.length > 2 ? parts[2] : '';
                      final feeders = groupedFeeders[gridKey]!;

                      // Count OFF and PENDING for this grid
                      final offCount = feeders
                          .where(
                            (f) =>
                            controller.turnedOffFeeders.contains(f['id']),
                      )
                          .length;
                      final pendingCount = feeders.length - offCount;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Grid Header
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6A1B9A,
                                ).withValues(alpha: 0.05),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF6A1B9A,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.grid_view_rounded,
                                      size: 18,
                                      color: Color(0xFF6A1B9A),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          gridName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (gridCode.isNotEmpty)
                                          Text(
                                            'Code: $gridCode',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        if (operatorName.isNotEmpty)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                size: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  operatorName,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Grid status badges
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$offCount OFF',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$pendingCount ON',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Feeders in this grid
                            ...feeders.map((feeder) {
                              final feederId = feeder['id'] as int;
                              final isPrimary = feeder['type'] == 'Primary';

                              return Obx(() {
                                final isOff = controller.turnedOffFeeders
                                    .contains(feederId);

                                return InkWell(
                                  onTap: () {
                                    if (isOff) {
                                      // Turn ON (remove from turnedOffFeeders)
                                      controller.turnedOffFeeders.remove(
                                        feederId,
                                      );
                                      if (controller.turnedOffFeeders.isEmpty) {
                                        controller
                                            .feederConfirmationConsent
                                            .value =
                                        false;
                                      }
                                    } else {
                                      // Turn OFF (add to turnedOffFeeders)
                                      controller.turnedOffFeeders.add(feederId);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOff
                                          ? Colors.orange.withValues(
                                        alpha: 0.05,
                                      )
                                          : Colors.green.withValues(
                                        alpha: 0.05,
                                      ),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade100,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Toggle Switch
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          width: 44,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isOff
                                                ? Colors.orange.shade600
                                                : Colors.green.shade600,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              AnimatedPositioned(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                curve: Curves.easeInOut,
                                                left: isOff ? 2 : 22,
                                                top: 2,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                          alpha: 0.2,
                                                        ),
                                                        blurRadius: 3,
                                                        offset: const Offset(
                                                          0,
                                                          1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Feeder Type Icon
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isPrimary
                                                ? Colors.orange.withValues(
                                              alpha: 0.15,
                                            )
                                                : Colors.blue.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            isPrimary
                                                ? Icons.star
                                                : Icons.electrical_services,
                                            size: 16,
                                            color: isPrimary
                                                ? Colors.orange
                                                : Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Feeder Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                feeder['name'].toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isPrimary
                                                          ? Colors.orange
                                                          .withValues(
                                                        alpha: 0.2,
                                                      )
                                                          : Colors.blue
                                                          .withValues(
                                                        alpha: 0.2,
                                                      ),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                        4,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      feeder['type']
                                                          .toString()
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: isPrimary
                                                            ? Colors.orange
                                                            : Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Code: ${feeder['code']}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                      Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Status Badge
                                        // Container(
                                        //   padding: const EdgeInsets.symmetric(
                                        //     horizontal: 10,
                                        //     vertical: 5,
                                        //   ),
                                        //   decoration: BoxDecoration(
                                        //     color: isOff
                                        //         ? Colors.orange.withValues(alpha: 0.15)
                                        //         : Colors.green.withValues(alpha: 0.15),
                                        //     borderRadius: BorderRadius.circular(8),
                                        //   ),
                                        //   child: Text(
                                        //     isOff ? 'OFF' : 'ON',
                                        //     style: TextStyle(
                                        //       fontSize: 11,
                                        //       fontWeight: FontWeight.bold,
                                        //       color: isOff
                                        //           ? Colors.orange.shade700
                                        //           : Colors.green.shade700,
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ==================== FOOTER ====================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // Turn ALL ON
                            controller.turnedOffFeeders.clear();
                            controller.feederConfirmationConsent.value = false;
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Turn All ON',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Obx(
                                () => Text(
                              controller.turnedOffFeeders.isEmpty
                                  ? 'Done'
                                  : 'Confirm (${controller.turnedOffFeeders.length} OFF)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent(PtwReviewSdoController controller) {
    final args = Get.arguments ?? {};
    final userRole =
    ((args['user_role'] ?? controller.currentUserRole.value) ?? 'LS')
        .toString()
        .trim()
        .toUpperCase();
    final status =
        controller.ptwData['current_status']?.toString().toUpperCase() ?? '';

    switch (_selectedTab) {
      case 0:
        return _buildDetailsTab(controller);
      case 1:
        return _buildTeamTab(controller);
      case 2:
        return _buildSafetyTab(context, controller);
      case 3:
        return _buildTimelineTab(controller);
      case 4:
        return _buildAttachmentsContent(context, controller);
      case 5:
      // ✅ Task tab - Only for PDC with specific statuses
        return _buildFeederStatusSection(controller);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAttachmentsContent(
      BuildContext context,
      PtwReviewSdoController controller,
      ) {
    final ptw = controller.ptwData;
    final evidences = ptw['evidences'] as List? ?? [];

    if (evidences.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No attachments available')),
      );
    }

    /// --- GROUP EVIDENCES BY TYPE ---
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var e in evidences) {
      final type = (e['type'] ?? 'OTHER').toString().trim();
      if (!grouped.containsKey(type)) grouped[type] = [];
      grouped[type]!.add(e as Map<String, dynamic>);
    }

    /// --- NICE LABELS FROM TYPE NAMES ---
    String formatType(String t) {
      return t
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1);
      })
          .join(' ');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        children: grouped.entries.map((entry) {
          final type = entry.key;
          final items = entry.value;

          return Card(
            elevation: 2,
            color: const Color(0xFFF5F5F5),
            shadowColor: Colors.black12,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.transparent),
            ),

            child: Theme(
              // 🔥 Remove ExpansionTile horizontal lines
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),

              child: ExpansionTile(
                initiallyExpanded: false,

                title: Text(
                  formatType(type),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 4 / 3,
                      ),
                      itemBuilder: (context, index) {
                        final e = items[index];
                        final filePath = e['file_path']?.toString() ?? '';

                        if (filePath.isEmpty) return const SizedBox.shrink();

                        final imageUrl =
                            'http://mepco.myflexihr.com/storage/$filePath';

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.zero,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Close background tap
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(color: Colors.black54),
                                    ),

                                    // Image preview with LONG PRESS
                                    InteractiveViewer(
                                      child: GestureDetector(
                                        onLongPress: () {
                                          showModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.vertical(
                                                top: Radius.circular(32),
                                              ),
                                            ),
                                            builder: (_) {
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Wrap(
                                                  children: [
                                                    // SHARE
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.share,
                                                        color: Color(
                                                          0xFF0D47A1,
                                                        ),
                                                      ),
                                                      title: const Text(
                                                        'Share',
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);

                                                        Get.snackbar(
                                                          'Please wait',
                                                          'Preparing image to share...',
                                                          snackPosition:
                                                          SnackPosition.TOP,
                                                          backgroundColor:
                                                          Colors.orange,
                                                          colorText:
                                                          Colors.white,
                                                        );

                                                        final response =
                                                        await http.get(
                                                          Uri.parse(
                                                            imageUrl,
                                                          ),
                                                        );
                                                        final tempDir =
                                                        await getTemporaryDirectory();
                                                        final file = File(
                                                          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                                                        );
                                                        await file.writeAsBytes(
                                                          response.bodyBytes,
                                                        );

                                                        Share.shareXFiles([
                                                          XFile(file.path),
                                                        ]);
                                                      },
                                                    ),

                                                    // SAVE
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.download,
                                                        color: Color(
                                                          0xFF0D47A1,
                                                        ),
                                                      ),
                                                      title: const Text(
                                                        'Save to Gallery',
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);

                                                        // 🔔 show feedback immediately
                                                        Get.snackbar(
                                                          'Saving',
                                                          'Saving image to gallery...',
                                                          backgroundColor:
                                                          Colors.orange,
                                                          colorText:
                                                          Colors.white,
                                                          snackPosition:
                                                          SnackPosition
                                                              .BOTTOM,
                                                          duration:
                                                          const Duration(
                                                            seconds: 2,
                                                          ),
                                                        );

                                                        try {
                                                          final response =
                                                          await http.get(
                                                            Uri.parse(
                                                              imageUrl,
                                                            ),
                                                          );
                                                          final tempDir =
                                                          await getTemporaryDirectory();
                                                          final file = File(
                                                            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                                                          );
                                                          await file
                                                              .writeAsBytes(
                                                            response
                                                                .bodyBytes,
                                                          );

                                                          final hasAccess =
                                                          await Gal.hasAccess();
                                                          if (!hasAccess) {
                                                            await Gal.requestAccess();
                                                          }
                                                          await Gal.putImage(
                                                            file.path,
                                                          );

                                                          // ✅ success snackbar
                                                          SnackbarHelper.showSuccess(
                                                            title: 'Success',
                                                            message:
                                                            'Image saved to gallery',
                                                          );
                                                        } catch (e) {
                                                          SnackbarHelper.showError(
                                                            title: 'Error',
                                                            message:
                                                            'Failed to save image: $e',
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          loadingBuilder:
                                              (context, child, progress) {
                                            if (progress == null)
                                              return child;
                                            return const CircularProgressIndicator(
                                              color: Colors.white,
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    // Close button
                                    Positioned(
                                      top: 40,
                                      right: 20,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, _) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "ID: ${e['id']}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HERO HEADER ====================
  Widget _buildHeroHeader(PtwReviewSdoController controller, String userRole) {
    final ptw = controller.ptwData;
    final status = PtwHelper.getStatusText(_str(ptw['current_status']));
    final statusColor = PtwHelper.getStatusColor(_str(ptw['current_status']));
    final type = _str(ptw['type']);
    final ptwCode = _str(ptw['ptw_code']);
    final miscCode = _str(ptw['misc_code']);
    print("MISCCODE: $miscCode");
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Text(
                      (ptwCode.isEmpty || ptwCode == '—') ? miscCode : ptwCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Reviewing as $userRole',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== QUICK STATS ====================
  Widget _buildQuickStats(PtwReviewSdoController controller) {
    final ptw = controller.ptwData;
    final team = (ptw['team_members'] as List?) ?? [];
    final checklists = controller.checklists;
    final evidences = (ptw['evidences'] as List?) ?? [];

    int totalChecks = 0;
    checklists.forEach((key, value) {
      totalChecks +=
      ((value as List?)
          ?.where((it) => _str(it['value']).toUpperCase() == 'YES')
          .length ??
          0);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.groups_rounded,
              value: '${team.length}',
              label: 'Team',
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle_rounded,
              value: '$totalChecks',
              label: 'Checks',
              color: const Color(0xFF00D4AA),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.attach_file_rounded,
              value: '${evidences.length}',
              label: 'Files',
              color: const Color(0xFFFF6B9D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 4),
          Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: DETAILS ====================
  Widget _buildDetailsTab(PtwReviewSdoController controller) {
    if (_selectedTab != 0) return const SizedBox.shrink();

    final ptw = controller.ptwData;
    final type = _str(ptw['type']).toUpperCase();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildInfoSection(
            title: 'Basic Information',
            icon: Icons.info_outline_rounded,
            color: const Color(0xFF6C63FF),
            items: [
              {'label': 'Work Order', 'value': _str(ptw['work_order_no'])},
              // if(type != 'PLANNED')
              {
                'label': 'Duration',
                'value': '${ptw['estimated_duration_min'] ?? '—'} min',
              },
              {'label': 'LS', 'value': _str(ptw['ls_name'] ?? ptw['ls_id'])},
              {
                'label': 'Sub-Division',
                'value': _str(ptw['sub_division'] ?? ptw['sub_division_name']),
              },
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoSection(
            title: 'Technical Details',
            icon: Icons.engineering_rounded,
            color: const Color(0xFFFF6B9D),
            items: [
              // Primary Feeders
              ...(() {
                final primaryFeeders =
                ptw['primary_feeders'] as Map<String, dynamic>?;
                if (primaryFeeders == null || primaryFeeders.isEmpty) {
                  return [
                    {'label': 'Primary Feeders', 'value': '—'},
                  ];
                }

                final List<Map<String, dynamic>> items = [];

                primaryFeeders.forEach((gridId, gridData) {
                  final gridCode = _str(gridData['grid_code']);
                  // final operatorName = _str(gridData['operator']?['name']);
                  final feeders = gridData['feeders']?['primary'] as List?;

                  if (feeders != null && feeders.isNotEmpty) {
                    final feederNames = feeders
                        .map((f) => '${_str(f['name'])} (${_str(f['code'])})')
                        .join(', ');

                    items.add({
                      'label': 'Primary Feeders',
                      'value': feederNames,
                      'sublabel': 'Grid: $gridCode ',
                      'full': true,
                    });
                  }
                });

                return items.isEmpty
                    ? [
                  {'label': 'Primary Feeders', 'value': '—'},
                ]
                    : items;
              })(),

              const SizedBox(height: 8),

              // Secondary Feeders
              ...(() {
                final primaryFeeders =
                ptw['primary_feeders'] as Map<String, dynamic>?;
                if (primaryFeeders == null || primaryFeeders.isEmpty) return [];

                final List<Map<String, dynamic>> items = [];

                primaryFeeders.forEach((gridId, gridData) {
                  final gridCode = _str(gridData['grid_code']);
                  // final operatorName = _str(gridData['operator']?['name']);
                  final feeders = gridData['feeders']?['secondary'] as List?;

                  if (feeders != null && feeders.isNotEmpty) {
                    final feederNames = feeders
                        .map((f) => '${_str(f['name'])} (${_str(f['code'])})')
                        .join(', ');

                    items.add({
                      'label': 'Secondary Feeders',
                      'value': feederNames,
                      'sublabel': 'Grid: $gridCode ',
                      'full': true,
                    });
                  }
                });

                return items;
              })(),

              const SizedBox(height: 12),

              {'label': 'Transformer', 'value': _str(ptw['transformer_name'])},
              {
                'label': 'Feeder Incharge',
                'value': _str(ptw['feeder_incharge_name']),
              },
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Work Location & Scope',
            icon: Icons.location_on_rounded,
            color: const Color(0xFF00D4AA),
            items: [
              {
                'label': 'Place of Work',
                'value': _str(ptw['place_of_work']),
                'full': true,
              },
              {
                'label': 'Scope of Work',
                'value': _str(ptw['scope_of_work']),
                'full': true,
              },
              {
                'label': 'Safety Arrangements',
                'value': _str(ptw['safety_arrangements']),
                'full': true,
              },
            ],
          ),
          const SizedBox(height: 16),
          // ✅ UPDATED SCHEDULE SECTION
          _buildScheduleSection(controller, type),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(PtwReviewSdoController controller, String type) {
    final ptw = controller.ptwData;

    if (type == 'PLANNED') {
      // PLANNED PTW: Show planned_from_date, planned_to_date, and planned_schedule
      final plannedFromDate = _str(ptw['planned_from_date']);
      final plannedToDate = _str(ptw['planned_to_date']);
      final plannedSchedule = (ptw['planned_schedule'] as List?) ?? [];

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB020).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFFFFB020),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Date Range Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFB020).withValues(alpha: 0.1),
                      const Color(0xFFFFB020).withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFB020).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatDate(plannedFromDate),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFFFFB020).withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.event_rounded,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'End Date',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatDate(plannedToDate),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Schedule Details
            if (plannedSchedule.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB020).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Color(0xFFFFB020),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Daily Schedule (${plannedSchedule.length} days)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFB020),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: plannedSchedule.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value as Map<String, dynamic>;
                    final date = _formatDate(_str(item['date']));
                    final startTime = _str(item['start_time']);
                    final endTime = _str(item['end_time']);

                    return Container(
                      margin: EdgeInsets.only(
                        bottom: index < plannedSchedule.length - 1 ? 10 : 0,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          // Day Badge
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB020), Color(0xFFFF8F00)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFB020,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Date & Time Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$startTime - $endTime',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Duration Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF00D4AA,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _calculateDuration(startTime, endTime),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00D4AA),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      );
    } else {
      // Other PTW types: Show switch_off_time and restore_time with elegant UI
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB020).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFFFFB020),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Times Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Switch-off Time
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade50,
                          Colors.red.shade50.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.power_off_rounded,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Switch-off Time',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _fmtDT(ptw['switch_off_time']),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Restore Time
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade50,
                          Colors.green.shade50.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.power_rounded,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Restore Time',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _fmtDT(ptw['restore_time']),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // Add this helper method to calculate duration
  String _calculateDuration(String startTime, String endTime) {
    try {
      final start = TimeOfDay(
        hour: int.parse(startTime.split(':')[0]),
        minute: int.parse(startTime.split(':')[1]),
      );
      final end = TimeOfDay(
        hour: int.parse(endTime.split(':')[0]),
        minute: int.parse(endTime.split(':')[1]),
      );

      int startMinutes = start.hour * 60 + start.minute;
      int endMinutes = end.hour * 60 + end.minute;
      int duration = endMinutes - startMinutes;

      if (duration < 0) duration += 24 * 60;

      int hours = duration ~/ 60;
      int minutes = duration % 60;

      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}m';
      }
    } catch (e) {
      return '—';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '—') return '—';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _buildPlannedScheduleText(List<dynamic> schedule) {
    if (schedule.isEmpty) return '—';

    final buffer = StringBuffer();
    for (int i = 0; i < schedule.length; i++) {
      final item = schedule[i] as Map<String, dynamic>;
      final date = _formatDate(_str(item['date']));
      final startTime = _str(item['start_time']);
      final endTime = _str(item['end_time']);

      buffer.write('Day ${i + 1}: $date\n');
      buffer.write('Time: $startTime - $endTime');

      if (i < schedule.length - 1) {
        buffer.write('\n\n');
      }
    }

    return buffer.toString();
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<dynamic> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                // Handle SizedBox for spacing
                if (item is SizedBox) return item;

                final itemMap = item as Map<String, dynamic>;
                final isFull = itemMap['full'] == true;
                final sublabel = itemMap['sublabel'] as String?;

                if (isFull) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemMap['label'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: color.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemMap['value'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (sublabel != null && sublabel.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        sublabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          itemMap['label'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          itemMap['value'],
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: TEAM ====================
  Widget _buildTeamTab(PtwReviewSdoController controller) {
    if (_selectedTab != 1) return const SizedBox.shrink();

    final ptw = controller.ptwData;
    final team = (ptw['team_members'] as List?) ?? [];

    if (team.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.groups_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No team members assigned',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: team.map((member) {
          final name = _str(member['name']);
          final avatar = _str(
            member['avatar_url'],
            fallback:
            'http://mepco.myflexihr.com/storage/avatars/default-neutral.png',
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  avatar,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade300, Colors.purple.shade300],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                'Team Member #${team.indexOf(member) + 1}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== TAB 3: Checklist ====================
  Widget _buildSafetyTab(
      BuildContext context,
      PtwReviewSdoController controller,
      ) {
    if (_selectedTab != 2) return const SizedBox.shrink();

    final raw = controller.checklists;
    // final evidences = (controller.ptwData.value['evidences'] as List?) ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Checklists
          if (raw.isNotEmpty) ...[
            _buildSectionHeader(
              'Safety Checklists',
              Icons.checklist_rounded,
              const Color(0xFF00D4AA),
            ),
            const SizedBox(height: 12),
            ...raw.entries.map((entry) {
              final type = entry.key;
              final items = (entry.value as List?) ?? [];
              final yesItems = items
                  .where((it) => _str(it['value']).toUpperCase() == 'YES')
                  .toList();

              if (yesItems.isEmpty) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.all(16),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    type.replaceAll('_', ' '),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${yesItems.length} items confirmed',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  children: yesItems.map((it) {
                    return _bilingualChecklistRow(
                      _str(it['label_en']),
                      _str(it['label_ur']),
                      _str(it['value']),
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ==================== TAB 4: TIMELINE ====================
  // Widget _buildTimelineTab(PtwReviewSdoController controller) {
  //   if (_selectedTab != 3) return const SizedBox.shrink();
  //
  //   final args = Get.arguments ?? {};
  //   final userRole =
  //       ((args['user_role'] ?? controller.currentUserRole.value)
  //           ?.toString()
  //           .trim()
  //           .toUpperCase()) ??
  //       'LS';
  //
  //   final logs = (controller.ptwData['logs'] as List?) ?? [];
  //   final logsWithNotes = logs
  //       .where((log) => (log['notes']?.toString().trim().isNotEmpty ?? false))
  //       .toList();
  //
  //   final status =
  //       controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
  //
  //   // ✅ PDC ke liye timeline mein decision notes NAHI dikhaye
  //   final shouldShowDecisionNotes =
  //       userRole != 'PDC' && controller.shouldAskForNotes(userRole);
  //
  //   return Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       children: [
  //         // 🕒 Existing timeline items
  //         ...logsWithNotes.asMap().entries.map((entry) {
  //           final index = entry.key;
  //           final log = entry.value;
  //           final isLast =
  //               index == logsWithNotes.length - 1 && !shouldShowDecisionNotes;
  //
  //           String? feederStatus;
  //           try {
  //             final metaJson = log['meta_json'];
  //             if (metaJson != null && metaJson.toString().isNotEmpty) {
  //               final meta = jsonDecode(metaJson.toString());
  //               feederStatus = meta['feeder_status']?.toString();
  //             }
  //           } catch (e) {
  //             // If parsing fails, feederStatus remains null
  //           }
  //
  //           return _buildTimelineItem(
  //             role: log['role']?.toString() ?? '',
  //             action: log['action']?.toString() ?? '',
  //             notes: log['notes']?.toString() ?? '',
  //             feederStatus: feederStatus,
  //             editable: false,
  //             showLine: !isLast,
  //           );
  //         }),
  //
  //         // ✍️ Editable notes - ONLY for non-PDC roles
  //         if (shouldShowDecisionNotes)
  //           _buildTimelineItem(
  //             role: userRole,
  //             action: 'Decision Notes',
  //             notes: '',
  //             editable: true,
  //             controller: controller.decisionNotesController,
  //             showLine: false,
  //           ),
  //
  //         const SizedBox(height: 24),
  //
  //         // ✅ Buttons - Only for non-PDC roles
  //         if (userRole != 'PDC') Obx(() => _buildBottomActions(controller)),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildTimelineTab(PtwReviewSdoController controller) {
    if (_selectedTab != 3) return const SizedBox.shrink();

    final args = Get.arguments ?? {};
    final userRole =
        ((args['user_role'] ?? controller.currentUserRole.value)
            ?.toString()
            .trim()
            .toUpperCase()) ??
            'LS';

    final logs = (controller.ptwData['logs'] as List?) ?? [];

    // ✅ REMOVE FILTER - Show ALL logs, not just those with notes
    // final logsWithNotes = logs.where((log) => (log['notes']?.toString().trim().isNotEmpty ?? false)).toList();

    final status =
        controller.ptwData['current_status']?.toString().toUpperCase() ?? '';

    final shouldShowDecisionNotes =
        userRole != 'PDC' && controller.shouldAskForNotes(userRole);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🕒 ALL timeline items (with or without notes)
          ...logs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            final isLast = index == logs.length - 1 && !shouldShowDecisionNotes;

            String? feederStatus;
            try {
              final metaJson = log['meta_json'];
              if (metaJson != null && metaJson.toString().isNotEmpty) {
                final meta = jsonDecode(metaJson.toString());
                feederStatus = meta['feeder_status']?.toString();
              }
            } catch (e) {
              // If parsing fails, feederStatus remains null
            }

            return _buildTimelineItem(
              role: log['role']?.toString() ?? '',
              action: log['action']?.toString() ?? '',
              notes: log['notes']?.toString() ?? '', // ✅ Can be empty/null
              feederStatus: feederStatus,
              editable: false,
              showLine: !isLast,
              createdAt: log['created_at']?.toString(),
            );
          }),

          // ✍️ Editable notes - ONLY for non-PDC roles
          if (shouldShowDecisionNotes)
            _buildTimelineItem(
              role: userRole,
              action: 'Decision Notes',
              notes: '',
              editable: true,
              controller: controller.decisionNotesController,
              showLine: false,
            ),

          const SizedBox(height: 24),

          // ✅ Buttons - Only for non-PDC roles
          if (userRole != 'PDC') Obx(() => _buildBottomActions(controller)),
        ],
      ),
    );
  }
  // Widget _buildTimelineItem({
  //   required String role,
  //   required String action,
  //   required String notes,
  //   String? feederStatus, // ✅ NEW: Add feeder status parameter
  //   required bool editable,
  //   required bool showLine,
  //   TextEditingController? controller,
  // }) {
  //   final roleUpper = role.toUpperCase();
  //   final roleColor =
  //       {
  //         'LS': const Color(0xFF00897B),
  //         'SDO': const Color(0xFF1976D2),
  //         'XEN': const Color(0xFFF57C00),
  //         'PDC': const Color(0xFF7B1FA2),
  //         'GRIDOPERATOR': const Color(0xFFD32F2F),
  //       }[roleUpper] ??
  //       Colors.grey;
  //
  //   final roleIcon =
  //       {
  //         'LS': Icons.engineering,
  //         'SDO': Icons.supervisor_account,
  //         'XEN': Icons.admin_panel_settings,
  //         'PDC': Icons.assignment_ind,
  //         'GRIDOPERATOR': Icons.power,
  //       }[roleUpper] ??
  //       Icons.person;
  //
  //   final actionMap = {
  //     'FORWARD_XEN': 'Forwarded to XEN',
  //     'APPROVE_TO_PDC': 'Approved to PDC',
  //     'DELEGATE_GRID': 'Delegated to Grid',
  //     'PRECHECKS_DONE': 'Pre-checks Done',
  //     'EXECUTION_STARTED': 'Execution Started',
  //     'COMPLETION_SUBMITTED': 'Completed',
  //     'GRID_RESTORED_AND_CLOSED': 'Restored & Closed',
  //     'SDO_RETURNED': 'Returned to LS',
  //     'XEN_RETURNED_TO_LS': 'Returned to LS',
  //     'LS_RESUBMITTED': 'Resubmitted',
  //     'CANCELLATION_REQUESTED_BY_LS': 'Cancel Request',
  //     'Decision Notes': 'Decision Notes',
  //     'PDC_ISSUE': 'PTW Issued', // ✅ NEW: Add PDC Issue action
  //   };
  //
  //   final displayAction = actionMap[action] ?? action.replaceAll('_', ' ');
  //
  //   // ✅ NEW: Helper to format feeder status for display
  //   String formatFeederStatus(String status) {
  //     switch (status.toUpperCase()) {
  //       case 'NORMAL':
  //         return 'Normal';
  //       case 'ABNORMAL':
  //         return 'Abnormal';
  //       case 'UNDER_MAINTENANCE':
  //         return 'Under Maintenance';
  //       default:
  //         return status.replaceAll('_', ' ');
  //     }
  //   }
  //
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 24),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Timeline Dot & Line
  //         Column(
  //           children: [
  //             Container(
  //               width: 40,
  //               height: 40,
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   colors: [roleColor, roleColor.withValues(alpha: 0.7)],
  //                 ),
  //                 shape: BoxShape.circle,
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: roleColor.withValues(alpha: 0.3),
  //                     blurRadius: 8,
  //                     offset: const Offset(0, 4),
  //                   ),
  //                 ],
  //               ),
  //               child: Icon(roleIcon, color: Colors.white, size: 20),
  //             ),
  //             if (showLine)
  //               Container(
  //                 width: 2,
  //                 height: 60,
  //                 margin: const EdgeInsets.symmetric(vertical: 4),
  //                 decoration: BoxDecoration(
  //                   gradient: LinearGradient(
  //                     colors: [
  //                       roleColor.withValues(alpha: 0.3),
  //                       Colors.transparent,
  //                     ],
  //                     begin: Alignment.topCenter,
  //                     end: Alignment.bottomCenter,
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),
  //         const SizedBox(width: 16),
  //
  //         // Content Card
  //         Expanded(
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: editable
  //                   ? roleColor.withValues(alpha: 0.05)
  //                   : Colors.white,
  //               borderRadius: BorderRadius.circular(16),
  //               border: Border.all(
  //                 color: editable
  //                     ? roleColor.withValues(alpha: 0.3)
  //                     : Colors.grey.shade200,
  //                 width: editable ? 2 : 1,
  //               ),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withValues(alpha: 0.04),
  //                   blurRadius: 10,
  //                   offset: const Offset(0, 4),
  //                 ),
  //               ],
  //             ),
  //             child: Padding(
  //               padding: const EdgeInsets.all(16),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Container(
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 10,
  //                           vertical: 4,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           color: roleColor.withValues(alpha: 0.1),
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                         child: Text(
  //                           roleUpper,
  //                           style: TextStyle(
  //                             color: roleColor,
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 11,
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Expanded(
  //                         child: Text(
  //                           displayAction,
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 13,
  //                             color: roleColor,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 12),
  //
  //                   // Notes section
  //                   if (editable && controller != null)
  //                     CustomTextFormField(
  //                       labelText: 'Enter your decision notes...',
  //                       maxLines: 4,
  //                       controller: controller,
  //                     )
  //                   else if (notes.isNotEmpty)
  //                     Container(
  //                       padding: const EdgeInsets.all(12),
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey.shade50,
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: Text(
  //                         notes,
  //                         style: const TextStyle(
  //                           fontSize: 13,
  //                           color: Colors.black87,
  //                           height: 1.5,
  //                         ),
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildTimelineItem({
    required String role,
    required String action,
    required String notes,
    String? feederStatus,
    required bool editable,
    required bool showLine,
    TextEditingController? controller,
    String? createdAt,
  }) {
    final roleUpper = role.toUpperCase();
    final roleColor = {
      'LS': const Color(0xFF00897B),
      'SDO': const Color(0xFF1976D2),
      'XEN': const Color(0xFFF57C00),
      'PDC': const Color(0xFF7B1FA2),
      'GRIDOPERATOR': const Color(0xFFD32F2F),
    }[roleUpper] ?? Colors.grey;

    final roleIcon = {
      'LS': Icons.engineering,
      'SDO': Icons.supervisor_account,
      'XEN': Icons.admin_panel_settings,
      'PDC': Icons.assignment_ind,
      'GRIDOPERATOR': Icons.power,
    }[roleUpper] ?? Icons.person;

    final actionMap = {
      'FORWARD_XEN': 'Forwarded to XEN',
      'APPROVE_TO_PDC': 'Approved to PDC',
      'DELEGATE_GRID': 'Delegated to Grid',
      'PRECHECKS_DONE': 'Pre-checks Done',
      'EXECUTION_STARTED': 'Execution Started',
      'COMPLETION_SUBMITTED': 'Completed',
      'GRID_RESTORED_AND_CLOSED': 'Restored & Closed',
      'SDO_RETURNED': 'Returned to LS',
      'XEN_RETURNED_TO_LS': 'Returned to LS',
      'LS_RESUBMITTED': 'Resubmitted',
      'CANCELLATION_REQUESTED_BY_LS': 'Cancel Request',
      'Decision Notes': 'Decision Notes',
      'PDC_ISSUE': 'PTW Issued',
    };

    final displayAction = actionMap[action] ?? action.replaceAll('_', ' ');

    // ✅ Format date/time
    String formattedDateTime = '—';
    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      } catch (e) {
        formattedDateTime = createdAt;
      }
    }

    // ✅ Check if notes are empty/null
    final hasNotes = notes.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Dot & Line
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [roleColor, roleColor.withValues(alpha: 0.7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: roleColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(roleIcon, color: Colors.white, size: 20),
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        roleColor.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: editable
                    ? roleColor.withValues(alpha: 0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: editable
                      ? roleColor.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                  width: editable ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Role, Action
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            roleUpper,
                            style: TextStyle(
                              color: roleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayAction,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Date/Time Display (only for non-editable items)
                    if (!editable && createdAt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedDateTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Notes section
                    if (editable && controller != null)
                      CustomTextFormField(
                        labelText: 'Enter your decision notes...',
                        maxLines: 4,
                        controller: controller,
                      )
                    else if (hasNotes)
                    // ✅ Show actual notes
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          notes,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      )
                    else
                    // ✅ Show "No notes added" message
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No notes added by $roleUpper',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<bool> showConfirmationDialog(
      BuildContext context,
      String message,
      ) async {
    return await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Confirm",
      transitionDuration: const Duration(milliseconds: 220),

      pageBuilder: (_, __, ___) => const SizedBox.shrink(),

      transitionBuilder: (context, animation, secondary, child) {
        final curved = Curves.easeOut.transform(animation.value);

        return Transform.scale(
          scale: curved,
          child: Opacity(
            opacity: curved,
            child: Material(
              color: Colors.black.withValues(alpha: 0.01),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white, // WHITE BACKGROUND
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 4,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ICON
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 38,
                          color: Colors.red,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // TITLE
                      const Text(
                        "Confirmation Required",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // MESSAGE
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ACTION BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text(
                                "Confirm",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ) ??
        false;
  }

  // =======================================================
  //  MAIN ACTION BUILDER
  // =======================================================
  Widget _buildBottomActions(PtwReviewSdoController controller) {
    final context = Get.context!;
    final args = Get.arguments ?? {};
    final userRole =
    ((args['user_role'] ?? controller.currentUserRole.value) ?? 'LS')
        .toString()
        .trim()
        .toUpperCase();

    final status =
        controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
    if (userRole == 'GRIDOPERATOR' && status == 'GRID_RESOLVE_REQUIRED') {
      // Check if current user is assigned operator
      if (!controller.isCurrentUserAssignedOperator()) {
        return _buildNoAccessMessage();
      }
    }
    bool anyFeederOn =
        controller.turnedOffFeeders.length < controller.allFeeders.length;
    if (userRole == 'PDC' &&
        (status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC') &&
        anyFeederOn) {
      return Column(
        children: [
          // Decision Notes
          _buildTimelineItem(
            role: userRole,
            action: 'Decision Notes',
            notes: '',
            editable: true,
            controller: controller.decisionNotesController,
            showLine: false,
          ),
          const SizedBox(height: 16),

          // Return to Grid button
          _buildActionBar(
            buttons: [
              _ActionButton(
                text: 'Return to Grid',
                icon: Icons.keyboard_return_outlined,
                color: const Color(0xFFC62828),
                actionKey: 'return_grid',
                onPressed: (setLoading) async {
                  // ✅ Confirmation dialog
                  bool confirm = await showConfirmationDialog(
                    context,
                    "Are you sure you want to issue this PTW?",
                  );
                  if (!confirm) return;

                  setLoading(true);

                  final ptwId = controller.ptwData['id'];

                  // ✅ Optional: Get notes (if needed, otherwise pass empty string)
                  final notes = controller.decisionNotesController.text.trim();

                  // ✅ Call forwardPTW with PtwActionType.pdcIssue
                  await controller.forwardPTW(
                    ptwId,
                    userRole,
                    notes,
                    action: PtwActionType.returnGrid,
                  );

                  setLoading(false);
                },
              ),
            ],
          ),
        ],
      );
    }

    // ✅ Show only Issue PTW when ALL feeders are OFF
    if (userRole == 'PDC' &&
        (status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC') &&
        !anyFeederOn) {
      return _buildActionBar(
        buttons: [
          _ActionButton(
            text: 'Issue PTW',
            icon: Icons.forward,
            color: const Color(0xFF6A1B9A),
            actionKey: 'issue_ptw',
            onPressed: (setLoading) async {
              // ✅ Confirmation dialog
              bool confirm = await showConfirmationDialog(
                context,
                "Are you sure you want to issue this PTW?",
              );
              if (!confirm) return;

              setLoading(true);

              final ptwId = controller.ptwData['id'];

              // ✅ Optional: Get notes (if needed, otherwise pass empty string)
              final notes = controller.decisionNotesController.text.trim();

              // ✅ Call forwardPTW with PtwActionType.pdcIssue
              await controller.forwardPTW(
                ptwId,
                userRole,
                notes,
                action: PtwActionType.pdcIssue,
              );

              setLoading(false);
            },
          ),
        ],
      );
    }
    // LS → PDC_CONFIRMED (START PTW + CANCEL)
    // =======================================================
    if (userRole == 'LS' && status == 'PDC_CONFIRMED') {
      return _buildActionBar(
        buttons: [
          // ▶ START PTW
          _ActionButton(
            text: 'Start PTW',
            icon: Icons.play_circle_fill,
            color: Colors.green.shade700,
            actionKey: 'start_ptw',
            onPressed: (setLoading) async {
              bool confirm = await showConfirmationDialog(
                context,
                "Are you sure you want to start this PTW?",
              );
              if (!confirm) return;

              setLoading(true);

              bool serviceEnabled;
              LocationPermission permission;

              serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                await Geolocator.openLocationSettings();
                setLoading(false);
                return;
              }

              permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  SnackbarHelper.showError(
                    title: 'Permission Denied',
                    message: 'Location permission is required to start PTW.',
                  );
                  setLoading(false);
                  return;
                }
              }

              if (permission == LocationPermission.deniedForever) {
                SnackbarHelper.showError(
                  title: 'Permission Denied',
                  message:
                  'Location permission is permanently denied. Please enable it from settings.',
                );
                setLoading(false);
                return;
              }

              final ptwId = controller.ptwData['id'];
              if (ptwId != null) {
                Get.toNamed(AppRoutes.attachmentsSubmission, arguments: ptwId);
              }

              setLoading(false);
            },
          ),

          // ❌ CANCEL PTW
          _ActionButton(
            text: 'Cancel',
            icon: Icons.cancel_schedule_send,
            color: Colors.blueGrey,
            actionKey: 'cancel_ptw_ls',
            onPressed: (setLoading) async {
              bool confirm = await showConfirmationDialog(
                context,
                "Are you sure you want to cancel this PTW?",
              );
              if (!confirm) return;

              setLoading(true);

              final ptwId = controller.ptwData['id'];
              if (ptwId != null) {
                Get.toNamed(
                  AppRoutes.ptwCancelByLs,
                  arguments: {'ptw_id': ptwId, 'user_role': userRole},
                );
              }

              setLoading(false);
            },
          ),
        ],
      );
    }

    // =======================================================
    // LS → COMPLETE PTW (WHEN IN_EXECUTION)
    // =======================================================
    if (userRole == 'LS' && status == 'IN_EXECUTION') {
      return _buildActionBar(
        buttons: [
          _ActionButton(
            text: 'Complete',
            icon: Icons.check_circle_rounded,
            color: Colors.orange.shade700,
            actionKey: 'complete_ptw',
            onPressed: (setLoading) async {
              bool confirm = await showConfirmationDialog(
                context,
                "Are you sure you want to complete this PTW?",
              );
              if (!confirm) return;

              setLoading(true);

              bool serviceEnabled;
              LocationPermission permission;

              // 1️⃣ Check location service
              serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                await Geolocator.openLocationSettings();
                setLoading(false);
                return;
              }

              // 2️⃣ Check permission
              permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  SnackbarHelper.showError(
                    title: 'Permission Denied',
                    message: 'Location permission is required to complete PTW.',
                  );
                  setLoading(false);
                  return;
                }
              }

              if (permission == LocationPermission.deniedForever) {
                SnackbarHelper.showError(
                  title: 'Permission Denied',
                  message:
                  'Location permission is permanently denied. Please enable it from settings.',
                );
                setLoading(false);
                return;
              }

              // 3️⃣ Navigate to completion screen
              final ptwId = controller.ptwData['id'];
              if (ptwId != null) {
                Get.toNamed(AppRoutes.ptwCompleted, arguments: ptwId);
              }

              setLoading(false);
            },
          ),
        ],
      );
    }

    if (userRole == 'LS') {
      final returnedByRole =
          controller.ptwData['returned_by_role']?.toString().toUpperCase() ??
              '';

      final isDraft = status == 'DRAFT';
      final isReturned = [
        'SDO_RETURNED',
        'XEN_RETURNED_TO_LS',
        'PDC_RETURNED_TO_LS',
      ].contains(status);

      if (!isDraft && !isReturned) return const SizedBox.shrink();

      String forwardLabel;

      if (isDraft) {
        forwardLabel = 'Forward to SDO';
      } else {
        switch (returnedByRole) {
          case 'XEN':
            forwardLabel = 'Forward to XEN';
            break;
          case 'PDC':
            forwardLabel = 'Forward to PDC';
            break;
          case 'SDO':
          default:
            forwardLabel = 'Forward to SDO';
            break;
        }
      }

      return _buildActionBar(
        buttons: [
          _ActionButton(
            text: forwardLabel,
            icon: Icons.send_rounded,
            color: const Color(0xFF0D47A1),
            actionKey: 'ls_forward',
            onPressed: (setLoading) async {
              // ===============================
              // SHOW POPUP FIRST
              // ===============================
              bool confirm = await showConfirmationDialog(
                context,
                "Are you sure you want to forward this?",
              );
              if (!confirm) return;

              setLoading(true);

              final ptwId = controller.ptwData['id'] as int;
              final notes = controller.decisionNotesController.text.trim();

              if (controller.shouldAskForNotes('LS') && notes.isEmpty) {
                SnackbarHelper.showError(
                  title: 'Error',
                  message: 'Please enter decision notes',
                );
                setLoading(false);
                return;
              }

              await controller.forwardPTW(ptwId, 'LS', notes);
              setLoading(false);
            },
          ),
        ],
      );
    }
    final isPtwRequired = controller.ptwData['is_ptw_required'];
    if (userRole == 'SDO' && status == 'SUBMITTED' && isPtwRequired == false) {
      return _buildActionBar(
        buttons: [
          _ActionButton(
            text: 'Approve PTW',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF2E7D32),
            actionKey: 'approve_ptw',
            onPressed: (setLoading) async {
              bool confirm = await showConfirmationDialog(
                context,
                "Are you sure you want to approve this PTW?",
              );
              if (!confirm) return;

              setLoading(true);

              final ptwId = controller.ptwData['id'];
              final notes = controller.decisionNotesController.text.trim();

              await controller.forwardPTW(
                ptwId,
                userRole,
                notes,
                action: PtwActionType
                    .approve_no_ptw, // ✅ change if backend has special approve action
              );

              setLoading(false);
            },
          ),
        ],
      );
    }
    // =======================================================
    // GRID OPERATOR → CLOSE PTW (WITH LOCATION PERMISSION)
    // =======================================================
    if (userRole == 'GRIDOPERATOR' &&
        (status == 'COMPLETION_SUBMITTED' ||
            status == 'CANCELLATION_APPROVED_BY_SDO')) {
      return _buildActionBar(
        buttons: [
          _ActionButton(
            text: 'Close PTW',
            icon: Icons.close_outlined,
            color: Colors.blue.shade700,
            actionKey: 'grid_close_ptw',
            onPressed: (setLoading) async {
              bool confirm = await showConfirmationDialog(
                context,
                "Are you sure you want to close this PTW?",
              );
              if (!confirm) return;

              setLoading(true);

              bool serviceEnabled;
              LocationPermission permission;

              // 1️⃣ Check location service
              serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                await Geolocator.openLocationSettings();
                setLoading(false);
                return;
              }

              // 2️⃣ Check location permission
              permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  SnackbarHelper.showError(
                    title: 'Permission Denied',
                    message: 'Location permission is required to close PTW.',
                  );
                  setLoading(false);
                  return;
                }
              }

              if (permission == LocationPermission.deniedForever) {
                SnackbarHelper.showError(
                  title: 'Permission Denied',
                  message:
                  'Location permission is permanently denied. Please enable it from settings.',
                );
                setLoading(false);
                return;
              }

              // 3️⃣ Navigate to close PTW screen
              final ptwId = controller.ptwData['id'];
              if (ptwId != null) {
                Get.toNamed(AppRoutes.ptwGridClose, arguments: ptwId);
              }

              setLoading(false);
            },
          ),
        ],
      );
    }

    // =======================================================
    // OTHER ROLES CONFIGURATION
    // =======================================================
    final Map<String, Map<String, List<Map<String, dynamic>>>>
    roleStatusActions = {
      'LS': {
        'SUBMITTED': [
          {
            'text': 'Start Executuion',
            'action': PtwActionType.forward,
            'requiresNotes': false,
            'icon': Icons.arrow_forward_rounded,
            'color': Color(0xFF0D47A1),
            'key': 'forward_xen',
          },
        ],
      },
      'SDO': {
        'SUBMITTED': [
          {
            'text': 'Forward to XEN',
            'action': PtwActionType.forward,
            'requiresNotes': false,
            'icon': Icons.arrow_forward_rounded,
            'color': Color(0xFF0D47A1),
            'key': 'forward_xen',
          },
          {
            'text': 'Return to LS',
            'action': PtwActionType.returnBack,
            'requiresNotes': false,
            'icon': Icons.arrow_back_rounded,
            'color': Color(0xFFE65100),
            'key': 'return_ls',
          },
          {
            'text': 'Cancel Request',
            'action': PtwActionType.cancel,
            'requiresNotes': false,
            'icon': Icons.cancel_outlined,
            'color': Color(0xFFC62828),
            'key': 'cancel',
          },
        ],
        'CANCELLATION_REQUESTED_BY_LS': [
          {
            'text': 'Forward to Grid',
            'action': PtwActionType.cancelSDO,
            'requiresNotes': false,
            'icon': Icons.arrow_forward_rounded,
            'color': Color(0xFF0D47A1),
            'key': 'forward_grid',
          },
        ],
      },

      // XEN ACTIONS
      'XEN': {
        'SDO_FORWARDED_TO_XEN': [
          {
            'text': 'Approve to PDC',
            'action': PtwActionType.forward,
            'requiresNotes': false,
            'icon': Icons.check_circle_rounded,
            'color': Color(0xFF2E7D32),
            'key': 'approve_pdc',
          },
          {
            'text': 'Return to LS',
            'action': PtwActionType.xenReturnLS,
            'requiresNotes': false,
            'icon': Icons.arrow_back_rounded,
            'color': Color(0xFFE65100),
            'key': 'return_sdo',
          },
          {
            'text': 'Cancel Request',
            'action': PtwActionType.xenReject,
            'requiresNotes': false,
            'icon': Icons.cancel_outlined,
            'color': Color(0xFFC62828),
            'key': 'cancel',
          },
        ],
        'LS_RESUBMIT_TO_XEN': [
          {
            'text': 'Approve to PDC',
            'action': PtwActionType.forward,
            'requiresNotes': false,
            'icon': Icons.check_circle_rounded,
            'color': Color(0xFF2E7D32),
            'key': 'approve_pdc',
          },
          {
            'text': 'Return to LS',
            'action': PtwActionType.xenReturnLS,
            'requiresNotes': false,
            'icon': Icons.arrow_back_rounded,
            'color': Color(0xFFE65100),
            'key': 'return_sdo',
          },
          {
            'text': 'Cancel Request',
            'action': PtwActionType.xenReject,
            'requiresNotes': false,
            'icon': Icons.cancel_outlined,
            'color': Color(0xFFC62828),
            'key': 'cancel',
          },
        ],
      },

      // PDC ACTIONS
      'PDC': {
        'XEN_APPROVED_TO_PDC': [
          {
            'text': 'Delegate to GRID',
            'action': PtwActionType.forward,
            'requiresNotes': false,
            'icon': Icons.power_rounded,
            'color': Color(0xFF6A1B9A),
            'key': 'delegate_grid',
          },
          {
            'text': 'Return to LS',
            'action': PtwActionType.pdcReturnsLS,
            'requiresNotes': false,
            'icon': Icons.arrow_back_rounded,
            'color': Color(0xFFE65100),
            'key': 'return_ls',
          },
          {
            'text': 'Cancel Request',
            'action': PtwActionType.pdcReject,
            'requiresNotes': false,
            'icon': Icons.cancel_outlined,
            'color': Color(0xFFC62828),
            'key': 'cancel',
          },
        ],
        'LS_RESUBMIT_TO_PDC': [
          {
            'text': 'Delegate to GRID',
            'action': PtwActionType.forward,
            'requiresNotes': false,
            'icon': Icons.power_rounded,
            'color': Color(0xFF6A1B9A),
            'key': 'delegate_grid',
          },
          {
            'text': 'Return to LS',
            'action': PtwActionType.pdcReturnsLS,
            'requiresNotes': false,
            'icon': Icons.arrow_back_rounded,
            'color': Color(0xFFE65100),
            'key': 'return_ls',
          },
          {
            'text': 'Cancel Request',
            'action': PtwActionType.pdcReject,
            'requiresNotes': false,
            'icon': Icons.cancel_outlined,
            'color': Color(0xFFC62828),
            'key': 'cancel',
          },
        ],
        'PTW_ISSUED': [
          {
            'text': 'Issue PTW',
            'action': PtwActionType.pdcIssue,
            'requiresNotes': false,
            'icon': Icons.forward,
            'color': Color(0xFF6A1B9A),
            'key': 'issuePtw',
          },
          {
            'text': 'Return to grid',
            'action': PtwActionType.returnGrid,
            'requiresNotes': false,
            'icon': Icons.keyboard_return_outlined,
            'color': Color(0xFFC62828),
            'key': 'return_grid',
          },
        ],
        'RE_SUBMITTED_TO_PDC': [
          {
            'text': 'Issue PTW',
            'action': PtwActionType.pdcIssue,
            'requiresNotes': false,
            'icon': Icons.forward,
            'color': Color(0xFF6A1B9A),
            'key': 'issuePtw',
          },
          {
            'text': 'Return to grid',
            'action': PtwActionType.returnGrid,
            'requiresNotes': false,
            'icon': Icons.keyboard_return_outlined,
            'color': Color(0xFFC62828),
            'key': 'return_grid',
          },
        ],
      },

      // GRID OPERATOR
      'GRIDOPERATOR': {
        'PDC_DELEGATED_TO_GRID': [
          {
            'text': 'Confirm PTW',
            'action': null,
            'requiresNotes': false,
            'isGrid': true,
            'icon': Icons.verified_rounded,
            'color': Color(0xFF2E7D32),
            'key': 'confirm_ptw',
          },
        ],
        'GRID_RESOLVE_REQUIRED': [
          {
            'text': 'Confirm PTW',
            'action': null,
            'requiresNotes': false,
            'isGrid': true,
            'icon': Icons.verified_rounded,
            'color': Color(0xFF2E7D32),
            'key': 'confirm_ptw',
          },
        ],
      },
    };

    final actions = roleStatusActions[userRole]?[status];
    print('actions: $actions');
    if (actions == null || actions.isEmpty) return const SizedBox.shrink();

    return _buildActionBar(
      buttons: actions.map((btnConfig) {
        return _ActionButton(
          text: btnConfig['text'],
          icon: btnConfig['icon'],
          color: btnConfig['color'],
          actionKey: btnConfig['key'],
          onPressed: (setLoading) async {
            // ======================================
            // SHOW CONFIRM POPUP BEFORE ACTION
            // ======================================
            bool confirm = await showConfirmationDialog(
              context,
              "Are you sure you want to proceed?",
            );
            if (!confirm) return;

            setLoading(true);

            final ptwId = controller.ptwData['id'];
            final notes = controller.decisionNotesController.text.trim();

            if (btnConfig['isGrid'] == true) {
              Get.toNamed(
                AppRoutes.gridPtwIssueChecklist,
                arguments: {'ptw_id': ptwId},
              );
              setLoading(false);
              return;
            }

            if (btnConfig['requiresNotes'] == true && notes.isEmpty) {
              SnackbarHelper.showError(
                title: 'Error',
                message: 'Please enter decision notes',
              );
              setLoading(false);
              return;
            }

            await controller.forwardPTW(
              ptwId,
              userRole,
              notes,
              action: btnConfig['action'],
            );

            setLoading(false);
          },
        );
      }).toList(),
    );
  }

  Widget _buildNoAccessMessage() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Access Restricted',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This PTW is assigned to another Grid Operator',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Only the assigned operator can perform actions on this PTW',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTION BAR WITH INDIVIDUAL LOADING ====================
  Widget _buildActionBar({required List<_ActionButton> buttons}) {
    // Local state for each button's loading
    final loadingStates = <String, bool>{}.obs;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((btn) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Obx(() {
              final isLoading = loadingStates[btn.actionKey] ?? false;

              return SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    btn.onPressed((loading) {
                      loadingStates[btn.actionKey] = loading;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btn.color,
                    disabledBackgroundColor: btn.color.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: isLoading ? 0 : 2,
                    shadowColor: btn.color.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLoading) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Processing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Icon(btn.icon, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            btn.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  // ==================== SHIMMER ====================
  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        5,
            (_) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: const ShimmerWidget.rectangular(height: 150),
        ),
      ),
    );
  }

  // ==================== HELPERS ====================
  String _str(dynamic v, {String fallback = '—'}) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _fmtDT(dynamic v) {
    try {
      if (v == null) return '—';
      final raw = v.toString().replaceFirst(' ', 'T');
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return _str(v);
    }
  }

  // ==================== BILINGUAL CHECKLIST ROW ====================
  Widget _bilingualChecklistRow(String en, String ur, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    en,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (ur.isNotEmpty && ur != '—') ...[
                    const SizedBox(height: 4),
                    Text(
                      ur,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontFamily: 'Noto Nastaliq Urdu',
                      ),
                      // textDirection: TextDirection.RTL,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _yesNoChip(value),
          ],
        ),
      ),
    );
  }

  Widget _yesNoChip(String value) {
    final isYes = value.toUpperCase() == 'YES';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isYes ? Colors.green : Colors.red).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isYes ? Icons.check_circle : Icons.cancel,
            color: isYes ? Colors.green.shade700 : Colors.red.shade700,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isYes ? 'YES' : 'NO',
            style: TextStyle(
              color: isYes ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ACTION BUTTON CLASS ====================
class _ActionButton {
  final String text;
  final IconData icon;
  final Color color;
  final String actionKey;
  final Function(Function(bool) setLoading) onPressed;

  _ActionButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.actionKey,
    required this.onPressed,
  });
}

// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:gal/gal.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:mepco_esafety_app/constants/app_colors.dart';
// import 'package:mepco_esafety_app/controllers/ptw_review_sdo_controller.dart';
// import 'package:mepco_esafety_app/routes/app_routes.dart';
//
// import 'package:mepco_esafety_app/widgets/main_layout.dart';
// import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import '../widgets/custom_text_form_field.dart';
// import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
//
// class PtwReviewSdoScreen extends StatefulWidget {
//   const PtwReviewSdoScreen({super.key});
//
//   @override
//   State<PtwReviewSdoScreen> createState() => _PtwReviewSdoScreenState();
// }
//
// class _PtwReviewSdoScreenState extends State<PtwReviewSdoScreen> {
//   int _selectedTab = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<PtwReviewSdoController>();
//     final args = Get.arguments ?? {};
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       body: Obx(() {
//         final userRole =
//             (args['user_role'] as String? ?? controller.currentUserRole.value)
//                 .trim()
//                 .toUpperCase();
//         final type = controller.ptwData['type']?.toString().toUpperCase() ?? '';
//         final status =
//             controller.ptwData['current_status']?.toString().toUpperCase() ??
//             '';
//         print('THE STATUS $status');
//         final title = 'PTW Review';
//
//         return MainLayout(
//           title: title,
//           child: controller.isLoading.value
//               ? _buildShimmerLoading()
//               : Column(
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             // Hero Status Header
//                             _buildHeroHeader(controller, userRole),
//
//                             // Quick Stats Grid
//                             _buildQuickStats(controller),
//
//                             const SizedBox(height: 20),
//
//                             // Tab Headers (Non-sticky)
//                             Container(
//                               margin: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(16),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withValues(alpha: 0.04),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: Row(
//                                 children: [
//                                   _buildTabButton('Details', 0),
//                                   _buildTabButton('Team', 1),
//                                   // if(type !='PLANNED')
//                                   _buildTabButton('Checklist', 2),
//                                   _buildTabButton('Timeline', 3),
//                                   _buildTabButton('Evidence', 4),
//                                   if (userRole == 'PDC' &&
//                                       [
//                                         'XEN_APPROVED_TO_PDC',
//                                         'LS_RESUBMIT_TO_PDC',
//                                         'PTW_ISSUED',
//                                         'RE_SUBMITTED_TO_PDC',
//                                         'GRID_RESOLVE_REQUIRED'
//                                       ].contains(status))
//                                     _buildTabButton('Task', 5),
//                                 ],
//                               ),
//                             ),
//
//                             const SizedBox(height: 16),
//
//                             // Tab Content
//                             _buildTabContent(controller),
//                             const SizedBox(height: 24),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//         );
//       }),
//     );
//   }
//
//   // Widget _buildFeederStatusSection(PtwReviewSdoController controller) {
//   //   final args = Get.arguments ?? {};
//   //   final userRole =
//   //       ((args['user_role'] ?? controller.currentUserRole.value)
//   //           ?.toString()
//   //           .trim()
//   //           .toUpperCase()) ??
//   //       'LS';
//   //
//   //   final status =
//   //       controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
//   //
//   //   // ✅ Check if we need to show feeder management section
//   //   final showFeederManagement =
//   //       status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC';
//   //
//   //   return Container(
//   //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(16),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withValues(alpha: 0.04),
//   //           blurRadius: 10,
//   //           offset: const Offset(0, 4),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(16),
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           // ✅ HEADER
//   //           Row(
//   //             children: [
//   //               Container(
//   //                 padding: const EdgeInsets.all(8),
//   //                 decoration: BoxDecoration(
//   //                   color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
//   //                   borderRadius: BorderRadius.circular(10),
//   //                 ),
//   //                 child: Icon(
//   //                   showFeederManagement
//   //                       ? Icons.power_settings_new_rounded
//   //                       : Icons.assignment_rounded,
//   //                   color: const Color(0xFF6A1B9A),
//   //                   size: 20,
//   //                 ),
//   //               ),
//   //               const SizedBox(width: 12),
//   //               Obx(() => Text(
//   //                 controller.showDelegationSection.value
//   //                     ? 'PTW Delegation'
//   //                     : (showFeederManagement
//   //                     ? 'Feeder Status Confirmation'
//   //                     : 'PTW Decision'),
//   //                 style: const TextStyle(
//   //                   fontSize: 16,
//   //                   fontWeight: FontWeight.bold,
//   //                   color: Colors.black87,
//   //                 ),
//   //               )),
//   //             ],
//   //           ),
//   //           const SizedBox(height: 20),
//   //
//   //           // ✅ FEEDER MANAGEMENT SECTION (Only for PTW_ISSUED / RE_SUBMITTED_TO_PDC)
//   //           Obx(() {
//   //             // Hide if delegation checkbox is checked
//   //             if (controller.showDelegationSection.value) {
//   //               return const SizedBox.shrink();
//   //             }
//   //
//   //             if (!showFeederManagement) {
//   //               return const SizedBox.shrink();
//   //             }
//   //
//   //             return Column(
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: [
//   //                 const Text(
//   //                   'Manage Feeders',
//   //                   style: TextStyle(
//   //                     fontSize: 13,
//   //                     color: Colors.black54,
//   //                     fontWeight: FontWeight.w600,
//   //                   ),
//   //                 ),
//   //                 const SizedBox(height: 12),
//   //
//   //                 Obx(
//   //                   () => InkWell(
//   //                     onTap: () {
//   //                       _showFeederSelectionDialog(Get.context!, controller);
//   //                     },
//   //                     child: Container(
//   //                       padding: const EdgeInsets.symmetric(
//   //                         horizontal: 16,
//   //                         vertical: 14,
//   //                       ),
//   //                       decoration: BoxDecoration(
//   //                         color: Colors.grey.shade50,
//   //                         borderRadius: BorderRadius.circular(12),
//   //                         border: Border.all(
//   //                           color: controller.turnedOffFeeders.isEmpty
//   //                               ? Colors.grey.shade300
//   //                               : Colors.orange.shade300,
//   //                           width: controller.turnedOffFeeders.isEmpty ? 1 : 2,
//   //                         ),
//   //                       ),
//   //                       child: Row(
//   //                         children: [
//   //                           Icon(
//   //                             Icons.power_settings_new,
//   //                             color: controller.turnedOffFeeders.isEmpty
//   //                                 ? Colors.grey.shade400
//   //                                 : Colors.orange,
//   //                             size: 20,
//   //                           ),
//   //                           const SizedBox(width: 12),
//   //                           Expanded(
//   //                             child: Text(
//   //                               controller.turnedOffFeeders.isEmpty
//   //                                   ? 'All feeders are ON'
//   //                                   : '${controller.turnedOffFeeders.length} feeder(s) turned OFF',
//   //                               style: TextStyle(
//   //                                 fontSize: 14,
//   //                                 color: controller.turnedOffFeeders.isEmpty
//   //                                     ? Colors.grey.shade600
//   //                                     : Colors.orange.shade700,
//   //                                 fontWeight:
//   //                                     controller.turnedOffFeeders.isEmpty
//   //                                     ? FontWeight.normal
//   //                                     : FontWeight.w600,
//   //                               ),
//   //                             ),
//   //                           ),
//   //                           Icon(
//   //                             Icons.arrow_drop_down,
//   //                             color: Colors.grey.shade600,
//   //                           ),
//   //                         ],
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //
//   //                 // Turned OFF Feeders Chips
//   //                 Obx(() {
//   //                   if (controller.turnedOffFeeders.isEmpty)
//   //                     return const SizedBox.shrink();
//   //
//   //                   final turnedOffFeedersList = controller.allFeeders
//   //                       .where(
//   //                         (f) => controller.turnedOffFeeders.contains(f['id']),
//   //                       )
//   //                       .toList();
//   //
//   //                   return Container(
//   //                     margin: const EdgeInsets.only(top: 12),
//   //                     padding: const EdgeInsets.all(12),
//   //                     decoration: BoxDecoration(
//   //                       color: Colors.orange.withValues(alpha: 0.05),
//   //                       borderRadius: BorderRadius.circular(10),
//   //                       border: Border.all(
//   //                         color: Colors.orange.withValues(alpha: 0.2),
//   //                       ),
//   //                     ),
//   //                     child: Column(
//   //                       crossAxisAlignment: CrossAxisAlignment.start,
//   //                       children: [
//   //                         Row(
//   //                           children: [
//   //                             Icon(
//   //                               Icons.warning_rounded,
//   //                               color: Colors.orange.shade700,
//   //                               size: 16,
//   //                             ),
//   //                             const SizedBox(width: 6),
//   //                             Text(
//   //                               'Feeders Turned OFF:',
//   //                               style: TextStyle(
//   //                                 fontSize: 12,
//   //                                 fontWeight: FontWeight.bold,
//   //                                 color: Colors.orange.shade700,
//   //                               ),
//   //                             ),
//   //                           ],
//   //                         ),
//   //                         const SizedBox(height: 10),
//   //                         Wrap(
//   //                           spacing: 8,
//   //                           runSpacing: 8,
//   //                           children: turnedOffFeedersList.map((feeder) {
//   //                             final isPrimary = feeder['type'] == 'Primary';
//   //                             return Container(
//   //                               padding: const EdgeInsets.symmetric(
//   //                                 horizontal: 10,
//   //                                 vertical: 6,
//   //                               ),
//   //                               decoration: BoxDecoration(
//   //                                 color: Colors.orange.withValues(alpha: 0.1),
//   //                                 borderRadius: BorderRadius.circular(8),
//   //                                 border: Border.all(
//   //                                   color: Colors.orange.withValues(alpha: 0.3),
//   //                                 ),
//   //                               ),
//   //                               child: Row(
//   //                                 mainAxisSize: MainAxisSize.min,
//   //                                 children: [
//   //                                   Icon(
//   //                                     isPrimary
//   //                                         ? Icons.star
//   //                                         : Icons.electrical_services,
//   //                                     size: 14,
//   //                                     color: Colors.orange.shade700,
//   //                                   ),
//   //                                   const SizedBox(width: 6),
//   //                                   Text(
//   //                                     feeder['name'].toString(),
//   //                                     style: TextStyle(
//   //                                       fontSize: 12,
//   //                                       fontWeight: FontWeight.w600,
//   //                                       color: Colors.orange.shade800,
//   //                                     ),
//   //                                   ),
//   //                                   const SizedBox(width: 6),
//   //                                   GestureDetector(
//   //                                     onTap: () {
//   //                                       controller.turnedOffFeeders.remove(
//   //                                         feeder['id'],
//   //                                       );
//   //                                       if (controller
//   //                                           .turnedOffFeeders
//   //                                           .isEmpty) {
//   //                                         controller
//   //                                                 .feederConfirmationConsent
//   //                                                 .value =
//   //                                             false;
//   //                                       }
//   //                                     },
//   //                                     child: Icon(
//   //                                       Icons.close,
//   //                                       size: 16,
//   //                                       color: Colors.orange.shade700,
//   //                                     ),
//   //                                   ),
//   //                                 ],
//   //                               ),
//   //                             );
//   //                           }).toList(),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                   );
//   //                 }),
//   //
//   //                 // Consent Checkbox
//   //                 Obx(() {
//   //                   if (controller.turnedOffFeeders.isEmpty)
//   //                     return const SizedBox.shrink();
//   //
//   //                   return Container(
//   //                     margin: const EdgeInsets.only(top: 16),
//   //                     padding: const EdgeInsets.all(14),
//   //                     decoration: BoxDecoration(
//   //                       color: Colors.orange.shade50,
//   //                       borderRadius: BorderRadius.circular(12),
//   //                       border: Border.all(
//   //                         color: Colors.orange.shade300,
//   //                         width: 1.5,
//   //                       ),
//   //                     ),
//   //                     child: Row(
//   //                       crossAxisAlignment: CrossAxisAlignment.start,
//   //                       children: [
//   //                         Obx(
//   //                           () => InkWell(
//   //                             onTap: () {
//   //                               controller.feederConfirmationConsent.value =
//   //                                   !controller.feederConfirmationConsent.value;
//   //                             },
//   //                             child: Container(
//   //                               width: 22,
//   //                               height: 22,
//   //                               decoration: BoxDecoration(
//   //                                 color:
//   //                                     controller.feederConfirmationConsent.value
//   //                                     ? const Color(0xFF6A1B9A)
//   //                                     : Colors.white,
//   //                                 borderRadius: BorderRadius.circular(6),
//   //                                 border: Border.all(
//   //                                   color:
//   //                                       controller
//   //                                           .feederConfirmationConsent
//   //                                           .value
//   //                                       ? const Color(0xFF6A1B9A)
//   //                                       : Colors.grey.shade400,
//   //                                   width: 2,
//   //                                 ),
//   //                               ),
//   //                               child:
//   //                                   controller.feederConfirmationConsent.value
//   //                                   ? const Icon(
//   //                                       Icons.check,
//   //                                       size: 16,
//   //                                       color: Colors.white,
//   //                                     )
//   //                                   : null,
//   //                             ),
//   //                           ),
//   //                         ),
//   //                         const SizedBox(width: 12),
//   //                         Expanded(
//   //                           child: Text(
//   //                             'I have confirmed that the above feeder(s) have been turned OFF and the information provided is accurate',
//   //                             style: TextStyle(
//   //                               fontSize: 13,
//   //                               color: Colors.grey.shade800,
//   //                               height: 1.4,
//   //                               fontWeight: FontWeight.w500,
//   //                             ),
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                   );
//   //                 }),
//   //
//   //                 const SizedBox(height: 24),
//   //               ],
//   //             );
//   //           }),
//   //
//   //           // ✅ NEW: DELEGATION CHECKBOX (Only for XEN_APPROVED_TO_PDC and LS_RESUBMIT_TO_PDC)
//   //           if (userRole == 'PDC' &&
//   //               [
//   //                 'XEN_APPROVED_TO_PDC',
//   //                 'LS_RESUBMIT_TO_PDC',
//   //                 'PTW_ISSUED',
//   //                 'RE_SUBMITTED_TO_PDC',
//   //               ].contains(status)) ...[
//   //             Container(
//   //               padding: const EdgeInsets.all(14),
//   //               decoration: BoxDecoration(
//   //                 color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
//   //                 borderRadius: BorderRadius.circular(12),
//   //                 border: Border.all(
//   //                   color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
//   //                 ),
//   //               ),
//   //               child: Obx(
//   //                 () => Row(
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   children: [
//   //                     InkWell(
//   //                       onTap: () {
//   //                         controller.showDelegationSection.value =
//   //                             !controller.showDelegationSection.value;
//   //
//   //                         // Reset delegation selection when unchecking
//   //                         if (!controller.showDelegationSection.value) {
//   //                           controller.selectedDelegatedPdcId.value = null;
//   //                           controller.decisionNotesController.clear();
//   //                         }
//   //                       },
//   //                       child: Container(
//   //                         width: 22,
//   //                         height: 22,
//   //                         decoration: BoxDecoration(
//   //                           color: controller.showDelegationSection.value
//   //                               ? const Color(0xFF6A1B9A)
//   //                               : Colors.white,
//   //                           borderRadius: BorderRadius.circular(6),
//   //                           border: Border.all(
//   //                             color: controller.showDelegationSection.value
//   //                                 ? const Color(0xFF6A1B9A)
//   //                                 : Colors.grey.shade400,
//   //                             width: 2,
//   //                           ),
//   //                         ),
//   //                         child: controller.showDelegationSection.value
//   //                             ? const Icon(
//   //                                 Icons.check,
//   //                                 size: 16,
//   //                                 color: Colors.white,
//   //                               )
//   //                             : null,
//   //                       ),
//   //                     ),
//   //                     const SizedBox(width: 12),
//   //                     Expanded(
//   //                       child: Text(
//   //                         'I want to delegate this PTW or add decision notes',
//   //                         style: TextStyle(
//   //                           fontSize: 14,
//   //                           color: Colors.grey.shade800,
//   //                           fontWeight: FontWeight.w600,
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             ),
//   //             const SizedBox(height: 16),
//   //
//   //             // ✅ DELEGATION SECTION (Only shown when checkbox is checked)
//   //             Obx(() {
//   //               if (!controller.showDelegationSection.value) {
//   //                 return const SizedBox.shrink();
//   //               }
//   //
//   //               return Column(
//   //                 children: [
//   //                   // Delegate to Another PDC
//   //                   Container(
//   //                     padding: const EdgeInsets.all(16),
//   //                     decoration: BoxDecoration(
//   //                       color: Colors.blue.shade50,
//   //                       borderRadius: BorderRadius.circular(12),
//   //                       border: Border.all(color: Colors.blue.shade200),
//   //                     ),
//   //                     child: Column(
//   //                       crossAxisAlignment: CrossAxisAlignment.start,
//   //                       children: [
//   //                         Row(
//   //                           children: [
//   //                             Icon(
//   //                               Icons.person_add_alt_rounded,
//   //                               color: Colors.blue.shade700,
//   //                               size: 20,
//   //                             ),
//   //                             const SizedBox(width: 8),
//   //                             Text(
//   //                               'Delegate to Another PDC (Optional)',
//   //                               style: TextStyle(
//   //                                 fontSize: 14,
//   //                                 fontWeight: FontWeight.bold,
//   //                                 color: Colors.blue.shade700,
//   //                               ),
//   //                             ),
//   //                           ],
//   //                         ),
//   //                         const SizedBox(height: 12),
//   //
//   //                         Obx(
//   //                           () => DropdownButtonFormField<int>(
//   //                             value: controller.selectedDelegatedPdcId.value,
//   //                             decoration: InputDecoration(
//   //                               labelText: 'Select PDC',
//   //                               hintText: 'Choose a PDC to delegate',
//   //                               border: OutlineInputBorder(
//   //                                 borderRadius: BorderRadius.circular(10),
//   //                               ),
//   //                               filled: true,
//   //                               fillColor: Colors.white,
//   //                             ),
//   //                             items: [
//   //                               const DropdownMenuItem<int>(
//   //                                 value: null,
//   //                                 child: Text('None (Continue yourself)'),
//   //                               ),
//   //                               ...controller.pdcList.map((pdc) {
//   //                                 return DropdownMenuItem<int>(
//   //                                   value: pdc['id'],
//   //                                   child: Text(pdc['name'] ?? 'Unknown'),
//   //                                 );
//   //                               }).toList(),
//   //                             ],
//   //                             onChanged: (value) {
//   //                               controller.selectedDelegatedPdcId.value = value;
//   //                             },
//   //                           ),
//   //                         ),
//   //
//   //                         const SizedBox(height: 8),
//   //                         Text(
//   //                           'If you select a PDC, this PTW will be delegated to them. Otherwise, you will continue processing it.',
//   //                           style: TextStyle(
//   //                             fontSize: 11,
//   //                             color: Colors.grey.shade600,
//   //                             fontStyle: FontStyle.italic,
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                   ),
//   //
//   //                   const SizedBox(height: 16),
//   //
//   //                   // Decision Notes
//   //                   Container(
//   //                     padding: const EdgeInsets.all(16),
//   //                     decoration: BoxDecoration(
//   //                       color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
//   //                       borderRadius: BorderRadius.circular(12),
//   //                       border: Border.all(
//   //                         color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
//   //                       ),
//   //                     ),
//   //                     child: Column(
//   //                       crossAxisAlignment: CrossAxisAlignment.start,
//   //                       children: [
//   //                         Row(
//   //                           children: [
//   //                             Icon(
//   //                               Icons.note_add_rounded,
//   //                               color: const Color(0xFF6A1B9A),
//   //                               size: 20,
//   //                             ),
//   //                             const SizedBox(width: 8),
//   //                             Text(
//   //                               'Decision Notes',
//   //                               style: TextStyle(
//   //                                 fontSize: 14,
//   //                                 fontWeight: FontWeight.bold,
//   //                                 color: const Color(0xFF6A1B9A),
//   //                               ),
//   //                             ),
//   //                           ],
//   //                         ),
//   //                         const SizedBox(height: 12),
//   //                         CustomTextFormField(
//   //                           labelText: 'Enter your decision notes...',
//   //                           maxLines: 4,
//   //                           controller: controller.decisionNotesController,
//   //                         ),
//   //                       ],
//   //                     ),
//   //                   ),
//   //
//   //                   const SizedBox(height: 20),
//   //
//   //                   // Delegate to PDC Button
//   //                   SizedBox(
//   //                     width: double.infinity,
//   //                     height: 52,
//   //                     child: ElevatedButton(
//   //                       onPressed: () async {
//   //                         bool confirm = await showConfirmationDialog(
//   //                           Get.context!,
//   //                           "Are you sure you want to proceed with delegation?",
//   //                         );
//   //                         if (!confirm) return;
//   //
//   //                         final ptwId = controller.ptwData['id'];
//   //                         final notes = controller.decisionNotesController.text
//   //                             .trim();
//   //
//   //                         await controller.forwardPTW(
//   //                           ptwId,
//   //                           userRole,
//   //                           notes,
//   //                           action: PtwActionType.delegatePDC,
//   //                         );
//   //                       },
//   //                       style: ElevatedButton.styleFrom(
//   //                         backgroundColor: const Color(0xFF6A1B9A),
//   //                         shape: RoundedRectangleBorder(
//   //                           borderRadius: BorderRadius.circular(14),
//   //                         ),
//   //                         elevation: 2,
//   //                       ),
//   //                       child: const Row(
//   //                         mainAxisAlignment: MainAxisAlignment.center,
//   //                         children: [
//   //                           Icon(
//   //                             Icons.send_rounded,
//   //                             color: Colors.white,
//   //                             size: 20,
//   //                           ),
//   //                           SizedBox(width: 10),
//   //                           Text(
//   //                             'Delegate to PDC',
//   //                             style: TextStyle(
//   //                               color: Colors.white,
//   //                               fontSize: 15,
//   //                               fontWeight: FontWeight.w600,
//   //                               letterSpacing: 0.3,
//   //                             ),
//   //                           ),
//   //                         ],
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ],
//   //               );
//   //             }),
//   //           ],
//   //
//   //           // ✅ BOTTOM ACTIONS (Hidden when delegation section is shown)
//   //           Obx(() {
//   //             // Hide bottom actions if delegation section is shown
//   //             if (userRole == 'PDC' &&
//   //                 [
//   //                   'XEN_APPROVED_TO_PDC',
//   //                   'LS_RESUBMIT_TO_PDC',
//   //                   'PTW_ISSUED',
//   //                   'RE_SUBMITTED_TO_PDC',
//   //                 ].contains(status) &&
//   //                 controller.showDelegationSection.value) {
//   //               return const SizedBox.shrink();
//   //             }
//   //
//   //             return _buildBottomActions(controller);
//   //           }),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//   Widget _buildFeederStatusSection(PtwReviewSdoController controller) {
//     final args = Get.arguments ?? {};
//     final userRole =
//         ((args['user_role'] ?? controller.currentUserRole.value)
//             ?.toString()
//             .trim()
//             .toUpperCase()) ??
//             'LS';
//
//     final status = controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
//
//     // ✅ Check if we need to show feeder management section
//     final showFeederManagement = status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC';
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ✅ HEADER
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Obx(() => Icon(
//                     controller.showDelegationSection.value
//                         ? Icons.assignment_rounded
//                         : (showFeederManagement
//                         ? Icons.power_settings_new_rounded
//                         : Icons.assignment_rounded),
//                     color: const Color(0xFF6A1B9A),
//                     size: 20,
//                   )),
//                 ),
//                 const SizedBox(width: 12),
//                 Obx(() => Text(
//                   controller.showDelegationSection.value
//                       ? 'PTW Delegation'
//                       : (showFeederManagement
//                       ? 'Feeder Status Confirmation'
//                       : 'PTW Decision'),
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 )),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // ✅ DELEGATION CHECKBOX (NOW AT TOP - FIRST)
//             if (userRole == 'PDC' && [
//               'XEN_APPROVED_TO_PDC',
//               'LS_RESUBMIT_TO_PDC',
//               'PTW_ISSUED',
//               'RE_SUBMITTED_TO_PDC','GRID_RESOLVE_REQUIRED'
//             ].contains(status)) ...[
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
//                   ),
//                 ),
//                 child: Obx(() => Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         controller.showDelegationSection.value =
//                         !controller.showDelegationSection.value;
//
//                         // Reset delegation selection when unchecking
//                         if (!controller.showDelegationSection.value) {
//                           controller.selectedDelegatedPdcId.value = null;
//                           controller.decisionNotesController.clear();
//                         }
//                       },
//                       child: Container(
//                         width: 22,
//                         height: 22,
//                         decoration: BoxDecoration(
//                           color: controller.showDelegationSection.value
//                               ? const Color(0xFF6A1B9A)
//                               : Colors.white,
//                           borderRadius: BorderRadius.circular(6),
//                           border: Border.all(
//                             color: controller.showDelegationSection.value
//                                 ? const Color(0xFF6A1B9A)
//                                 : Colors.grey.shade400,
//                             width: 2,
//                           ),
//                         ),
//                         child: controller.showDelegationSection.value
//                             ? const Icon(
//                           Icons.check,
//                           size: 16,
//                           color: Colors.white,
//                         )
//                             : null,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'I want to delegate this PTW or add decision notes',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade800,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 )),
//               ),
//               const SizedBox(height: 16),
//
//               // ✅ DELEGATION SECTION (Only shown when checkbox is checked)
//               Obx(() {
//                 if (!controller.showDelegationSection.value) {
//                   return const SizedBox.shrink();
//                 }
//
//                 return Column(
//                   children: [
//                     // Delegate to Another PDC
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: Colors.blue.shade200,
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.person_add_alt_rounded,
//                                 color: Colors.blue.shade700,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Delegate to Another PDC (Optional)',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue.shade700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//
//                           Obx(() => DropdownButtonFormField<int>(
//                             value: controller.selectedDelegatedPdcId.value,
//                             decoration: InputDecoration(
//                               labelText: 'Select PDC',
//                               hintText: 'Choose a PDC to delegate',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               filled: true,
//                               fillColor: Colors.white,
//                             ),
//                             items: [
//                               const DropdownMenuItem<int>(
//                                 value: null,
//                                 child: Text('None (Continue yourself)'),
//                               ),
//                               ...controller.pdcList.map((pdc) {
//                                 return DropdownMenuItem<int>(
//                                   value: pdc['id'],
//                                   child: Text(pdc['name'] ?? 'Unknown'),
//                                 );
//                               }).toList(),
//                             ],
//                             onChanged: (value) {
//                               controller.selectedDelegatedPdcId.value = value;
//                             },
//                           )),
//
//                           const SizedBox(height: 8),
//                           Text(
//                             'If you select a PDC, this PTW will be delegated to them. Otherwise, you will continue processing it.',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: Colors.grey.shade600,
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // Decision Notes
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.note_add_rounded,
//                                 color: const Color(0xFF6A1B9A),
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Decision Notes',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: const Color(0xFF6A1B9A),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           CustomTextFormField(
//                             labelText: 'Enter your decision notes...',
//                             maxLines: 4,
//                             controller: controller.decisionNotesController,
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Delegate to PDC Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 52,
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           bool confirm = await showConfirmationDialog(
//                             Get.context!,
//                             "Are you sure you want to proceed with delegation?",
//                           );
//                           if (!confirm) return;
//
//                           final ptwId = controller.ptwData['id'];
//                           final notes = controller.decisionNotesController.text.trim();
//
//                           await controller.forwardPTW(
//                             ptwId,
//                             userRole,
//                             notes,
//                             action: PtwActionType.delegatePDC,
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF6A1B9A),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           elevation: 2,
//                         ),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.send_rounded, color: Colors.white, size: 20),
//                             SizedBox(width: 10),
//                             Text(
//                               'Delegate to PDC',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing: 0.3,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 24),
//                   ],
//                 );
//               }),
//             ],
//
//             // ✅ FEEDER MANAGEMENT SECTION (NOW SECOND - Hidden when delegation is active)
//             Obx(() {
//               // Hide feeder management if delegation checkbox is checked
//               if (controller.showDelegationSection.value) {
//                 return const SizedBox.shrink();
//               }
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ✅ FEEDER MANAGEMENT (only if showFeederManagement is true)
//                   if (showFeederManagement) ...[
//                     const Text(
//                       'Manage Feeders',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.black54,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     Obx(() => InkWell(
//                       onTap: () {
//                         _showFeederSelectionDialog(Get.context!, controller);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: controller.turnedOffFeeders.isEmpty
//                                 ? Colors.grey.shade300
//                                 : Colors.orange.shade300,
//                             width: controller.turnedOffFeeders.isEmpty ? 1 : 2,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.power_settings_new,
//                               color: controller.turnedOffFeeders.isEmpty
//                                   ? Colors.grey.shade400
//                                   : Colors.orange,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 controller.turnedOffFeeders.isEmpty
//                                     ? 'All feeders are ON'
//                                     : '${controller.turnedOffFeeders.length} feeder(s) turned OFF',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: controller.turnedOffFeeders.isEmpty
//                                       ? Colors.grey.shade600
//                                       : Colors.orange.shade700,
//                                   fontWeight: controller.turnedOffFeeders.isEmpty
//                                       ? FontWeight.normal
//                                       : FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             Icon(
//                               Icons.arrow_drop_down,
//                               color: Colors.grey.shade600,
//                             ),
//                           ],
//                         ),
//                       ),
//                     )),
//
//                     // Turned OFF Feeders Chips
//                     Obx(() {
//                       if (controller.turnedOffFeeders.isEmpty) return const SizedBox.shrink();
//
//                       final turnedOffFeedersList = controller.allFeeders
//                           .where((f) => controller.turnedOffFeeders.contains(f['id']))
//                           .toList();
//
//                       return Container(
//                         margin: const EdgeInsets.only(top: 12),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.withValues(alpha: 0.05),
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                             color: Colors.orange.withValues(alpha: 0.2),
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.warning_rounded,
//                                   color: Colors.orange.shade700,
//                                   size: 16,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   'Feeders Turned OFF:',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.orange.shade700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 10),
//                             Wrap(
//                               spacing: 8,
//                               runSpacing: 8,
//                               children: turnedOffFeedersList.map((feeder) {
//                                 final isPrimary = feeder['type'] == 'Primary';
//                                 return Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: Colors.orange.withValues(alpha: 0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(
//                                       color: Colors.orange.withValues(alpha: 0.3),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                         isPrimary ? Icons.star : Icons.electrical_services,
//                                         size: 14,
//                                         color: Colors.orange.shade700,
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         feeder['name'].toString(),
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.orange.shade800,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 6),
//                                       GestureDetector(
//                                         onTap: () {
//                                           controller.turnedOffFeeders.remove(feeder['id']);
//                                           if (controller.turnedOffFeeders.isEmpty) {
//                                             controller.feederConfirmationConsent.value = false;
//                                           }
//                                         },
//                                         child: Icon(
//                                           Icons.close,
//                                           size: 16,
//                                           color: Colors.orange.shade700,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ],
//                         ),
//                       );
//                     }),
//
//                     // Consent Checkbox
//                     Obx(() {
//                       if (controller.turnedOffFeeders.isEmpty) return const SizedBox.shrink();
//
//                       return Container(
//                         margin: const EdgeInsets.only(top: 16),
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.shade50,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: Colors.orange.shade300,
//                             width: 1.5,
//                           ),
//                         ),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Obx(() => InkWell(
//                               onTap: () {
//                                 controller.feederConfirmationConsent.value =
//                                 !controller.feederConfirmationConsent.value;
//                               },
//                               child: Container(
//                                 width: 22,
//                                 height: 22,
//                                 decoration: BoxDecoration(
//                                   color: controller.feederConfirmationConsent.value
//                                       ? const Color(0xFF6A1B9A)
//                                       : Colors.white,
//                                   borderRadius: BorderRadius.circular(6),
//                                   border: Border.all(
//                                     color: controller.feederConfirmationConsent.value
//                                         ? const Color(0xFF6A1B9A)
//                                         : Colors.grey.shade400,
//                                     width: 2,
//                                   ),
//                                 ),
//                                 child: controller.feederConfirmationConsent.value
//                                     ? const Icon(
//                                   Icons.check,
//                                   size: 16,
//                                   color: Colors.white,
//                                 )
//                                     : null,
//                               ),
//                             )),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 'I have confirmed that the above feeder(s) have been turned OFF and the information provided is accurate',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.grey.shade800,
//                                   height: 1.4,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }),
//
//                     const SizedBox(height: 24),
//                   ],
//
//                   // ✅ DECISION NOTES (Always show when delegation checkbox is UNCHECKED)
//                   // Container(
//                   //   padding: const EdgeInsets.all(16),
//                   //   decoration: BoxDecoration(
//                   //     color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
//                   //     borderRadius: BorderRadius.circular(12),
//                   //     border: Border.all(
//                   //       color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
//                   //     ),
//                   //   ),
//                   //   child: Column(
//                   //     crossAxisAlignment: CrossAxisAlignment.start,
//                   //     children: [
//                   //       Row(
//                   //         children: [
//                   //           Icon(
//                   //             Icons.note_add_rounded,
//                   //             color: const Color(0xFF6A1B9A),
//                   //             size: 20,
//                   //           ),
//                   //           const SizedBox(width: 8),
//                   //           Text(
//                   //             'Decision Notes',
//                   //             style: TextStyle(
//                   //               fontSize: 14,
//                   //               fontWeight: FontWeight.bold,
//                   //               color: const Color(0xFF6A1B9A),
//                   //             ),
//                   //           ),
//                   //         ],
//                   //       ),
//                   //       const SizedBox(height: 12),
//                   //       CustomTextFormField(
//                   //         labelText: 'Enter your decision notes...',
//                   //         maxLines: 4,
//                   //         controller: controller.decisionNotesController,
//                   //       ),
//                   //     ],
//                   //   ),
//                   // ),
//
//                   const SizedBox(height: 24),
//                 ],
//               );
//             }),
//             // ✅ BOTTOM ACTIONS (Hidden when delegation section is shown)
//             Obx(() {
//               // Hide bottom actions if delegation section is shown
//               if (userRole == 'PDC' &&
//                   ['XEN_APPROVED_TO_PDC', 'LS_RESUBMIT_TO_PDC',
//                     'PTW_ISSUED',
//                     'RE_SUBMITTED_TO_PDC'].contains(status) &&
//                   controller.showDelegationSection.value) {
//                 return const SizedBox.shrink();
//               }
//
//               return _buildBottomActions(controller);
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//   // Widget _buildFeederStatusSection(PtwReviewSdoController controller) {
//   //   final args = Get.arguments ?? {};
//   //   final userRole =
//   //       ((args['user_role'] ?? controller.currentUserRole.value)
//   //           ?.toString()
//   //           .trim()
//   //           .toUpperCase()) ??
//   //           'LS';
//   //
//   //   final status = controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
//   //   // ✅ Check if we need to show feeder management section
//   //   final showFeederManagement = status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC';
//   //
//   //   // ✅ Check if we need to show decision notes (only for main decision statuses)
//   //   final showDecisionNotes = status == 'XEN_APPROVED_TO_PDC' || status == 'LS_RESUBMIT_TO_PDC';
//   //
//   //   return Container(
//   //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(16),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withValues(alpha: 0.04),
//   //           blurRadius: 10,
//   //           offset: const Offset(0, 4),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(16),
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           // ✅ HEADER
//   //           Row(
//   //             children: [
//   //               Container(
//   //                 padding: const EdgeInsets.all(8),
//   //                 decoration: BoxDecoration(
//   //                   color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
//   //                   borderRadius: BorderRadius.circular(10),
//   //                 ),
//   //                 child: Icon(
//   //                   showFeederManagement
//   //                       ? Icons.power_settings_new_rounded
//   //                       : Icons.assignment_rounded,
//   //                   color: const Color(0xFF6A1B9A),
//   //                   size: 20,
//   //                 ),
//   //               ),
//   //               const SizedBox(width: 12),
//   //               Text(
//   //                 showFeederManagement
//   //                     ? 'Feeder Status Confirmation'
//   //                     : 'PTW Decision',
//   //                 style: const TextStyle(
//   //                   fontSize: 16,
//   //                   fontWeight: FontWeight.bold,
//   //                   color: Colors.black87,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //           const SizedBox(height: 20),
//   //
//   //           // ✅ FEEDER MANAGEMENT SECTION (Only for PTW_ISSUED / RE_SUBMITTED_TO_PDC)
//   //           if (showFeederManagement) ...[
//   //             const Text(
//   //               'Manage Feeders',
//   //               style: TextStyle(
//   //                 fontSize: 13,
//   //                 color: Colors.black54,
//   //                 fontWeight: FontWeight.w600,
//   //               ),
//   //             ),
//   //             const SizedBox(height: 12),
//   //
//   //             Obx(() => InkWell(
//   //               onTap: () {
//   //                 _showFeederSelectionDialog(Get.context!, controller);
//   //               },
//   //               child: Container(
//   //                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//   //                 decoration: BoxDecoration(
//   //                   color: Colors.grey.shade50,
//   //                   borderRadius: BorderRadius.circular(12),
//   //                   border: Border.all(
//   //                     color: controller.turnedOffFeeders.isEmpty
//   //                         ? Colors.grey.shade300
//   //                         : Colors.orange.shade300,
//   //                     width: controller.turnedOffFeeders.isEmpty ? 1 : 2,
//   //                   ),
//   //                 ),
//   //                 child: Row(
//   //                   children: [
//   //                     Icon(
//   //                       Icons.power_settings_new,
//   //                       color: controller.turnedOffFeeders.isEmpty
//   //                           ? Colors.grey.shade400
//   //                           : Colors.orange,
//   //                       size: 20,
//   //                     ),
//   //                     const SizedBox(width: 12),
//   //                     Expanded(
//   //                       child: Text(
//   //                         controller.turnedOffFeeders.isEmpty
//   //                             ? 'All feeders are ON'
//   //                             : '${controller.turnedOffFeeders.length} feeder(s) turned OFF',
//   //                         style: TextStyle(
//   //                           fontSize: 14,
//   //                           color: controller.turnedOffFeeders.isEmpty
//   //                               ? Colors.grey.shade600
//   //                               : Colors.orange.shade700,
//   //                           fontWeight: controller.turnedOffFeeders.isEmpty
//   //                               ? FontWeight.normal
//   //                               : FontWeight.w600,
//   //                         ),
//   //                       ),
//   //                     ),
//   //                     Icon(
//   //                       Icons.arrow_drop_down,
//   //                       color: Colors.grey.shade600,
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             )),
//   //
//   //             // Turned OFF Feeders Chips
//   //             Obx(() {
//   //               if (controller.turnedOffFeeders.isEmpty) return const SizedBox.shrink();
//   //
//   //               final turnedOffFeedersList = controller.allFeeders
//   //                   .where((f) => controller.turnedOffFeeders.contains(f['id']))
//   //                   .toList();
//   //
//   //               return Container(
//   //                 margin: const EdgeInsets.only(top: 12),
//   //                 padding: const EdgeInsets.all(12),
//   //                 decoration: BoxDecoration(
//   //                   color: Colors.orange.withValues(alpha: 0.05),
//   //                   borderRadius: BorderRadius.circular(10),
//   //                   border: Border.all(
//   //                     color: Colors.orange.withValues(alpha: 0.2),
//   //                   ),
//   //                 ),
//   //                 child: Column(
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   children: [
//   //                     Row(
//   //                       children: [
//   //                         Icon(
//   //                           Icons.warning_rounded,
//   //                           color: Colors.orange.shade700,
//   //                           size: 16,
//   //                         ),
//   //                         const SizedBox(width: 6),
//   //                         Text(
//   //                           'Feeders Turned OFF:',
//   //                           style: TextStyle(
//   //                             fontSize: 12,
//   //                             fontWeight: FontWeight.bold,
//   //                             color: Colors.orange.shade700,
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                     const SizedBox(height: 10),
//   //                     Wrap(
//   //                       spacing: 8,
//   //                       runSpacing: 8,
//   //                       children: turnedOffFeedersList.map((feeder) {
//   //                         final isPrimary = feeder['type'] == 'Primary';
//   //                         return Container(
//   //                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//   //                           decoration: BoxDecoration(
//   //                             color: Colors.orange.withValues(alpha: 0.1),
//   //                             borderRadius: BorderRadius.circular(8),
//   //                             border: Border.all(
//   //                               color: Colors.orange.withValues(alpha: 0.3),
//   //                             ),
//   //                           ),
//   //                           child: Row(
//   //                             mainAxisSize: MainAxisSize.min,
//   //                             children: [
//   //                               Icon(
//   //                                 isPrimary ? Icons.star : Icons.electrical_services,
//   //                                 size: 14,
//   //                                 color: Colors.orange.shade700,
//   //                               ),
//   //                               const SizedBox(width: 6),
//   //                               Text(
//   //                                 feeder['name'].toString(),
//   //                                 style: TextStyle(
//   //                                   fontSize: 12,
//   //                                   fontWeight: FontWeight.w600,
//   //                                   color: Colors.orange.shade800,
//   //                                 ),
//   //                               ),
//   //                               const SizedBox(width: 6),
//   //                               GestureDetector(
//   //                                 onTap: () {
//   //                                   controller.turnedOffFeeders.remove(feeder['id']);
//   //                                   if (controller.turnedOffFeeders.isEmpty) {
//   //                                     controller.feederConfirmationConsent.value = false;
//   //                                   }
//   //                                 },
//   //                                 child: Icon(
//   //                                   Icons.close,
//   //                                   size: 16,
//   //                                   color: Colors.orange.shade700,
//   //                                 ),
//   //                               ),
//   //                             ],
//   //                           ),
//   //                         );
//   //                       }).toList(),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               );
//   //             }),
//   //
//   //             // Consent Checkbox
//   //             Obx(() {
//   //               if (controller.turnedOffFeeders.isEmpty) return const SizedBox.shrink();
//   //
//   //               return Container(
//   //                 margin: const EdgeInsets.only(top: 16),
//   //                 padding: const EdgeInsets.all(14),
//   //                 decoration: BoxDecoration(
//   //                   color: Colors.orange.shade50,
//   //                   borderRadius: BorderRadius.circular(12),
//   //                   border: Border.all(
//   //                     color: Colors.orange.shade300,
//   //                     width: 1.5,
//   //                   ),
//   //                 ),
//   //                 child: Row(
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   children: [
//   //                     Obx(() => InkWell(
//   //                       onTap: () {
//   //                         controller.feederConfirmationConsent.value =
//   //                         !controller.feederConfirmationConsent.value;
//   //                       },
//   //                       child: Container(
//   //                         width: 22,
//   //                         height: 22,
//   //                         decoration: BoxDecoration(
//   //                           color: controller.feederConfirmationConsent.value
//   //                               ? const Color(0xFF6A1B9A)
//   //                               : Colors.white,
//   //                           borderRadius: BorderRadius.circular(6),
//   //                           border: Border.all(
//   //                             color: controller.feederConfirmationConsent.value
//   //                                 ? const Color(0xFF6A1B9A)
//   //                                 : Colors.grey.shade400,
//   //                             width: 2,
//   //                           ),
//   //                         ),
//   //                         child: controller.feederConfirmationConsent.value
//   //                             ? const Icon(
//   //                           Icons.check,
//   //                           size: 16,
//   //                           color: Colors.white,
//   //                         )
//   //                             : null,
//   //                       ),
//   //                     )),
//   //                     const SizedBox(width: 12),
//   //                     Expanded(
//   //                       child: Text(
//   //                         'I have confirmed that the above feeder(s) have been turned OFF and the information provided is accurate',
//   //                         style: TextStyle(
//   //                           fontSize: 13,
//   //                           color: Colors.grey.shade800,
//   //                           height: 1.4,
//   //                           fontWeight: FontWeight.w500,
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               );
//   //             }),
//   //
//   //             const SizedBox(height: 24),
//   //           ],
//   //           if (userRole == 'PDC' &&
//   //               (status == 'XEN_APPROVED_TO_PDC' || status == 'LS_RESUBMIT_TO_PDC')) ...[
//   //             const SizedBox(height: 16),
//   //
//   //             Container(
//   //               padding: const EdgeInsets.all(16),
//   //               decoration: BoxDecoration(
//   //                 color: Colors.blue.shade50,
//   //                 borderRadius: BorderRadius.circular(12),
//   //                 border: Border.all(
//   //                   color: Colors.blue.shade200,
//   //                 ),
//   //               ),
//   //               child: Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.start,
//   //                 children: [
//   //                   Row(
//   //                     children: [
//   //                       Icon(
//   //                         Icons.person_add_alt_rounded,
//   //                         color: Colors.blue.shade700,
//   //                         size: 20,
//   //                       ),
//   //                       const SizedBox(width: 8),
//   //                       Text(
//   //                         'Delegate to Another PDC (Optional)',
//   //                         style: TextStyle(
//   //                           fontSize: 14,
//   //                           fontWeight: FontWeight.bold,
//   //                           color: Colors.blue.shade700,
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                   const SizedBox(height: 12),
//   //
//   //                   Obx(() => DropdownButtonFormField<int>(
//   //                     value: controller.selectedDelegatedPdcId.value,
//   //                     decoration: InputDecoration(
//   //                       labelText: 'Select PDC',
//   //                       hintText: 'Choose a PDC to delegate',
//   //                       border: OutlineInputBorder(
//   //                         borderRadius: BorderRadius.circular(10),
//   //                       ),
//   //                       filled: true,
//   //                       fillColor: Colors.white,
//   //                     ),
//   //                     items: [
//   //                       const DropdownMenuItem<int>(
//   //                         value: null,
//   //                         child: Text('None (Continue yourself)'),
//   //                       ),
//   //                       ...controller.pdcList.map((pdc) {
//   //                         return DropdownMenuItem<int>(
//   //                           value: pdc['id'],
//   //                           child: Text(pdc['name'] ?? 'Unknown'),
//   //                         );
//   //                       }).toList(),
//   //                     ],
//   //                     onChanged: (value) {
//   //                       controller.selectedDelegatedPdcId.value = value;
//   //                     },
//   //                   )),
//   //
//   //                   const SizedBox(height: 8),
//   //                   Text(
//   //                     'If you select a PDC, this PTW will be delegated to them. Otherwise, you will continue processing it.',
//   //                     style: TextStyle(
//   //                       fontSize: 11,
//   //                       color: Colors.grey.shade600,
//   //                       fontStyle: FontStyle.italic,
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ],
//   //           // ✅ DECISION NOTES SECTION (Only for XEN_APPROVED_TO_PDC / LS_RESUBMIT_TO_PDC)
//   //           if (showDecisionNotes) ...[
//   //             Container(
//   //               padding: const EdgeInsets.all(16),
//   //               decoration: BoxDecoration(
//   //                 color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
//   //                 borderRadius: BorderRadius.circular(12),
//   //                 border: Border.all(
//   //                   color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
//   //                 ),
//   //               ),
//   //               child: Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.start,
//   //                 children: [
//   //                   Row(
//   //                     children: [
//   //                       Icon(
//   //                         Icons.note_add_rounded,
//   //                         color: const Color(0xFF6A1B9A),
//   //                         size: 20,
//   //                       ),
//   //                       const SizedBox(width: 8),
//   //                       Text(
//   //                         'Decision Notes',
//   //                         style: TextStyle(
//   //                           fontSize: 14,
//   //                           fontWeight: FontWeight.bold,
//   //                           color: const Color(0xFF6A1B9A),
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                   const SizedBox(height: 12),
//   //                   CustomTextFormField(
//   //                     labelText: 'Enter your decision notes...',
//   //                     maxLines: 4,
//   //                     controller: controller.decisionNotesController,
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //             const SizedBox(height: 20),
//   //           ],
//   //
//   //           // ✅ ACTION BUTTONS (For ALL PDC statuses)
//   //           Obx(() => _buildBottomActions(controller)),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//   // ==================== REPLACE YOUR _showFeederSelectionDialog METHOD ====================
//   void _showFeederSelectionDialog(
//     BuildContext context,
//     PtwReviewSdoController controller,
//   ) {
//     // Group feeders by grid station
//     final Map<String, List<Map<String, dynamic>>> groupedFeeders = {};
//
//     for (var feeder in controller.allFeeders) {
//       final gridName = feeder['grid_name']?.toString() ?? 'Unknown Grid';
//       final gridCode = feeder['grid_code']?.toString() ?? '';
//       final operatorName = feeder['operator_name']?.toString() ?? '';
//       final gridKey = '$gridName|$gridCode|$operatorName';
//
//       if (!groupedFeeders.containsKey(gridKey)) {
//         groupedFeeders[gridKey] = [];
//       }
//       groupedFeeders[gridKey]!.add(feeder);
//     }
//
//     // Count total OFF and PENDING feeders
//     int getTotalOff() => controller.turnedOffFeeders.length;
//     int getTotalPending() =>
//         controller.allFeeders.length - controller.turnedOffFeeders.length;
//
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Container(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.75,
//               maxWidth: MediaQuery.of(context).size.width * 0.95,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // ==================== HEADER ====================
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         const Color(0xFF6A1B9A),
//                         const Color(0xFF6A1B9A).withValues(alpha: 0.8),
//                       ],
//                     ),
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(20),
//                       topRight: Radius.circular(20),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withValues(alpha: 0.2),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Icon(
//                               Icons.power_settings_new,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Text(
//                               'Feeder Status Confirmation',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       // Status badges
//                       Obx(
//                         () => Row(
//                           children: [
//                             // OFF Badge
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.orange.withValues(alpha: 0.2),
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(
//                                     color: Colors.orange.withValues(alpha: 0.5),
//                                   ),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       '${getTotalOff()}',
//                                       style: const TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     const Text(
//                                       'OFF',
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white70,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             // PENDING Badge
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.green.withValues(alpha: 0.2),
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(
//                                     color: Colors.green.withValues(alpha: 0.5),
//                                   ),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       '${getTotalPending()}',
//                                       style: const TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     const Text(
//                                       'PENDING',
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white70,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             // TOTAL Badge
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withValues(alpha: 0.2),
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(
//                                     color: Colors.white.withValues(alpha: 0.5),
//                                   ),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       '${controller.allFeeders.length}',
//                                       style: const TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     const Text(
//                                       'TOTAL',
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white70,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // ==================== FEEDERS LIST BY GRID ====================
//                 Flexible(
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: groupedFeeders.keys.length,
//                     itemBuilder: (context, gridIndex) {
//                       final gridKey = groupedFeeders.keys.elementAt(gridIndex);
//                       final parts = gridKey.split('|');
//                       final gridName = parts[0];
//                       final gridCode = parts[1];
//                       final operatorName = parts.length > 2 ? parts[2] : '';
//                       final feeders = groupedFeeders[gridKey]!;
//
//                       // Count OFF and PENDING for this grid
//                       final offCount = feeders
//                           .where(
//                             (f) =>
//                                 controller.turnedOffFeeders.contains(f['id']),
//                           )
//                           .length;
//                       final pendingCount = feeders.length - offCount;
//
//                       return Container(
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(color: Colors.grey.shade200),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withValues(alpha: 0.05),
//                               blurRadius: 8,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             // Grid Header
//                             Container(
//                               padding: const EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 color: const Color(
//                                   0xFF6A1B9A,
//                                 ).withValues(alpha: 0.05),
//                                 borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(16),
//                                   topRight: Radius.circular(16),
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.all(8),
//                                     decoration: BoxDecoration(
//                                       color: const Color(
//                                         0xFF6A1B9A,
//                                       ).withValues(alpha: 0.1),
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: const Icon(
//                                       Icons.grid_view_rounded,
//                                       size: 18,
//                                       color: Color(0xFF6A1B9A),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 10),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           gridName,
//                                           style: const TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.black87,
//                                           ),
//                                         ),
//                                         if (gridCode.isNotEmpty)
//                                           Text(
//                                             'Code: $gridCode',
//                                             style: TextStyle(
//                                               fontSize: 11,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                           ),
//                                         if (operatorName.isNotEmpty)
//                                           Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.person_outline,
//                                                 size: 12,
//                                                 color: Colors.grey.shade600,
//                                               ),
//                                               const SizedBox(width: 4),
//                                               Expanded(
//                                                 child: Text(
//                                                   operatorName,
//                                                   style: TextStyle(
//                                                     fontSize: 11,
//                                                     color: Colors.grey.shade600,
//                                                     fontStyle: FontStyle.italic,
//                                                   ),
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                   // Grid status badges
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 4,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.orange.withValues(
//                                         alpha: 0.15,
//                                       ),
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     child: Text(
//                                       '$offCount OFF',
//                                       style: const TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.orange,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 4,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green.withValues(
//                                         alpha: 0.15,
//                                       ),
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     child: Text(
//                                       '$pendingCount ON',
//                                       style: const TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.green,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             // Feeders in this grid
//                             ...feeders.map((feeder) {
//                               final feederId = feeder['id'] as int;
//                               final isPrimary = feeder['type'] == 'Primary';
//
//                               return Obx(() {
//                                 final isOff = controller.turnedOffFeeders
//                                     .contains(feederId);
//
//                                 return InkWell(
//                                   onTap: () {
//                                     if (isOff) {
//                                       // Turn ON (remove from turnedOffFeeders)
//                                       controller.turnedOffFeeders.remove(
//                                         feederId,
//                                       );
//                                       if (controller.turnedOffFeeders.isEmpty) {
//                                         controller
//                                                 .feederConfirmationConsent
//                                                 .value =
//                                             false;
//                                       }
//                                     } else {
//                                       // Turn OFF (add to turnedOffFeeders)
//                                       controller.turnedOffFeeders.add(feederId);
//                                     }
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 12,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: isOff
//                                           ? Colors.orange.withValues(
//                                               alpha: 0.05,
//                                             )
//                                           : Colors.green.withValues(
//                                               alpha: 0.05,
//                                             ),
//                                       border: Border(
//                                         bottom: BorderSide(
//                                           color: Colors.grey.shade100,
//                                           width: 1,
//                                         ),
//                                       ),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         // Toggle Switch
//                                         AnimatedContainer(
//                                           duration: const Duration(
//                                             milliseconds: 250,
//                                           ),
//                                           width: 44,
//                                           height: 24,
//                                           decoration: BoxDecoration(
//                                             color: isOff
//                                                 ? Colors.orange.shade600
//                                                 : Colors.green.shade600,
//                                             borderRadius: BorderRadius.circular(
//                                               12,
//                                             ),
//                                           ),
//                                           child: Stack(
//                                             children: [
//                                               AnimatedPositioned(
//                                                 duration: const Duration(
//                                                   milliseconds: 250,
//                                                 ),
//                                                 curve: Curves.easeInOut,
//                                                 left: isOff ? 2 : 22,
//                                                 top: 2,
//                                                 child: Container(
//                                                   width: 20,
//                                                   height: 20,
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.white,
//                                                     shape: BoxShape.circle,
//                                                     boxShadow: [
//                                                       BoxShadow(
//                                                         color: Colors.black
//                                                             .withValues(
//                                                               alpha: 0.2,
//                                                             ),
//                                                         blurRadius: 3,
//                                                         offset: const Offset(
//                                                           0,
//                                                           1,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         const SizedBox(width: 14),
//
//                                         // Feeder Type Icon
//                                         Container(
//                                           padding: const EdgeInsets.all(8),
//                                           decoration: BoxDecoration(
//                                             color: isPrimary
//                                                 ? Colors.orange.withValues(
//                                                     alpha: 0.15,
//                                                   )
//                                                 : Colors.blue.withValues(
//                                                     alpha: 0.15,
//                                                   ),
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                           child: Icon(
//                                             isPrimary
//                                                 ? Icons.star
//                                                 : Icons.electrical_services,
//                                             size: 16,
//                                             color: isPrimary
//                                                 ? Colors.orange
//                                                 : Colors.blue,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//
//                                         // Feeder Details
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 feeder['name'].toString(),
//                                                 style: const TextStyle(
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: Colors.black87,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 2),
//                                               Row(
//                                                 children: [
//                                                   Container(
//                                                     padding:
//                                                         const EdgeInsets.symmetric(
//                                                           horizontal: 6,
//                                                           vertical: 2,
//                                                         ),
//                                                     decoration: BoxDecoration(
//                                                       color: isPrimary
//                                                           ? Colors.orange
//                                                                 .withValues(
//                                                                   alpha: 0.2,
//                                                                 )
//                                                           : Colors.blue
//                                                                 .withValues(
//                                                                   alpha: 0.2,
//                                                                 ),
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                             4,
//                                                           ),
//                                                     ),
//                                                     child: Text(
//                                                       feeder['type']
//                                                           .toString()
//                                                           .toUpperCase(),
//                                                       style: TextStyle(
//                                                         fontSize: 9,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: isPrimary
//                                                             ? Colors.orange
//                                                             : Colors.blue,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 6),
//                                                   Text(
//                                                     'Code: ${feeder['code']}',
//                                                     style: TextStyle(
//                                                       fontSize: 11,
//                                                       color:
//                                                           Colors.grey.shade600,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//
//                                         // Status Badge
//                                         // Container(
//                                         //   padding: const EdgeInsets.symmetric(
//                                         //     horizontal: 10,
//                                         //     vertical: 5,
//                                         //   ),
//                                         //   decoration: BoxDecoration(
//                                         //     color: isOff
//                                         //         ? Colors.orange.withValues(alpha: 0.15)
//                                         //         : Colors.green.withValues(alpha: 0.15),
//                                         //     borderRadius: BorderRadius.circular(8),
//                                         //   ),
//                                         //   child: Text(
//                                         //     isOff ? 'OFF' : 'ON',
//                                         //     style: TextStyle(
//                                         //       fontSize: 11,
//                                         //       fontWeight: FontWeight.bold,
//                                         //       color: isOff
//                                         //           ? Colors.orange.shade700
//                                         //           : Colors.green.shade700,
//                                         //     ),
//                                         //   ),
//                                         // ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               });
//                             }).toList(),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 // ==================== FOOTER ====================
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(20),
//                       bottomRight: Radius.circular(20),
//                     ),
//                     border: Border(
//                       top: BorderSide(color: Colors.grey.shade200),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextButton(
//                           onPressed: () {
//                             // Turn ALL ON
//                             controller.turnedOffFeeders.clear();
//                             controller.feederConfirmationConsent.value = false;
//                           },
//                           style: TextButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                           ),
//                           child: const Text(
//                             'Turn All ON',
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         flex: 2,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.of(dialogContext).pop();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF6A1B9A),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: Obx(
//                             () => Text(
//                               controller.turnedOffFeeders.isEmpty
//                                   ? 'Done'
//                                   : 'Confirm (${controller.turnedOffFeeders.length} OFF)',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTabContent(PtwReviewSdoController controller) {
//     final args = Get.arguments ?? {};
//     final userRole =
//         ((args['user_role'] ?? controller.currentUserRole.value) ?? 'LS')
//             .toString()
//             .trim()
//             .toUpperCase();
//     final status =
//         controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
//
//     switch (_selectedTab) {
//       case 0:
//         return _buildDetailsTab(controller);
//       case 1:
//         return _buildTeamTab(controller);
//       case 2:
//         return _buildSafetyTab(context, controller);
//       case 3:
//         return _buildTimelineTab(controller);
//       case 4:
//         return _buildAttachmentsContent(context, controller);
//       case 5:
//         // ✅ Task tab - Only for PDC with specific statuses
//         return _buildFeederStatusSection(controller);
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   Widget _buildAttachmentsContent(
//     BuildContext context,
//     PtwReviewSdoController controller,
//   ) {
//     final ptw = controller.ptwData;
//     final evidences = ptw['evidences'] as List? ?? [];
//
//     if (evidences.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Center(child: Text('No attachments available')),
//       );
//     }
//
//     /// --- GROUP EVIDENCES BY TYPE ---
//     Map<String, List<Map<String, dynamic>>> grouped = {};
//
//     for (var e in evidences) {
//       final type = (e['type'] ?? 'OTHER').toString().trim();
//       if (!grouped.containsKey(type)) grouped[type] = [];
//       grouped[type]!.add(e as Map<String, dynamic>);
//     }
//
//     /// --- NICE LABELS FROM TYPE NAMES ---
//     String formatType(String t) {
//       return t
//           .replaceAll('_', ' ')
//           .toLowerCase()
//           .split(' ')
//           .map((w) {
//             if (w.isEmpty) return w;
//             return w[0].toUpperCase() + w.substring(1);
//           })
//           .join(' ');
//     }
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
//       child: Column(
//         children: grouped.entries.map((entry) {
//           final type = entry.key;
//           final items = entry.value;
//
//           return Card(
//             elevation: 2,
//             color: const Color(0xFFF5F5F5),
//             shadowColor: Colors.black12,
//             margin: const EdgeInsets.only(bottom: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: BorderSide(color: Colors.transparent),
//             ),
//
//             child: Theme(
//               // 🔥 Remove ExpansionTile horizontal lines
//               data: Theme.of(
//                 context,
//               ).copyWith(dividerColor: Colors.transparent),
//
//               child: ExpansionTile(
//                 initiallyExpanded: false,
//
//                 title: Text(
//                   formatType(type),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: items.length,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 3,
//                             crossAxisSpacing: 10,
//                             mainAxisSpacing: 10,
//                             childAspectRatio: 4 / 3,
//                           ),
//                       itemBuilder: (context, index) {
//                         final e = items[index];
//                         final filePath = e['file_path']?.toString() ?? '';
//
//                         if (filePath.isEmpty) return const SizedBox.shrink();
//
//                         final imageUrl =
//                             'http://mepco.myflexihr.com/storage/$filePath';
//
//                         return GestureDetector(
//                           onTap: () {
//                             showDialog(
//                               context: context,
//                               builder: (_) => Dialog(
//                                 backgroundColor: Colors.transparent,
//                                 insetPadding: EdgeInsets.zero,
//                                 child: Stack(
//                                   alignment: Alignment.center,
//                                   children: [
//                                     // Close background tap
//                                     GestureDetector(
//                                       onTap: () => Navigator.pop(context),
//                                       child: Container(color: Colors.black54),
//                                     ),
//
//                                     // Image preview with LONG PRESS
//                                     InteractiveViewer(
//                                       child: GestureDetector(
//                                         onLongPress: () {
//                                           showModalBottomSheet(
//                                             context: context,
//                                             shape: const RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.vertical(
//                                                     top: Radius.circular(32),
//                                                   ),
//                                             ),
//                                             builder: (_) {
//                                               return Padding(
//                                                 padding: const EdgeInsets.all(
//                                                   16,
//                                                 ),
//                                                 child: Wrap(
//                                                   children: [
//                                                     // SHARE
//                                                     ListTile(
//                                                       leading: const Icon(
//                                                         Icons.share,
//                                                         color: Color(
//                                                           0xFF0D47A1,
//                                                         ),
//                                                       ),
//                                                       title: const Text(
//                                                         'Share',
//                                                       ),
//                                                       onTap: () async {
//                                                         Navigator.pop(context);
//
//                                                         Get.snackbar(
//                                                           'Please wait',
//                                                           'Preparing image to share...',
//                                                           snackPosition:
//                                                               SnackPosition.TOP,
//                                                           backgroundColor:
//                                                               Colors.orange,
//                                                           colorText:
//                                                               Colors.white,
//                                                         );
//
//                                                         final response =
//                                                             await http.get(
//                                                               Uri.parse(
//                                                                 imageUrl,
//                                                               ),
//                                                             );
//                                                         final tempDir =
//                                                             await getTemporaryDirectory();
//                                                         final file = File(
//                                                           '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
//                                                         );
//                                                         await file.writeAsBytes(
//                                                           response.bodyBytes,
//                                                         );
//
//                                                         Share.shareXFiles([
//                                                           XFile(file.path),
//                                                         ]);
//                                                       },
//                                                     ),
//
//                                                     // SAVE
//                                                     ListTile(
//                                                       leading: const Icon(
//                                                         Icons.download,
//                                                         color: Color(
//                                                           0xFF0D47A1,
//                                                         ),
//                                                       ),
//                                                       title: const Text(
//                                                         'Save to Gallery',
//                                                       ),
//                                                       onTap: () async {
//                                                         Navigator.pop(context);
//
//                                                         // 🔔 show feedback immediately
//                                                         Get.snackbar(
//                                                           'Saving',
//                                                           'Saving image to gallery...',
//                                                           backgroundColor:
//                                                               Colors.orange,
//                                                           colorText:
//                                                               Colors.white,
//                                                           snackPosition:
//                                                               SnackPosition
//                                                                   .BOTTOM,
//                                                           duration:
//                                                               const Duration(
//                                                                 seconds: 2,
//                                                               ),
//                                                         );
//
//                                                         try {
//                                                           final response =
//                                                               await http.get(
//                                                                 Uri.parse(
//                                                                   imageUrl,
//                                                                 ),
//                                                               );
//                                                           final tempDir =
//                                                               await getTemporaryDirectory();
//                                                           final file = File(
//                                                             '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
//                                                           );
//                                                           await file
//                                                               .writeAsBytes(
//                                                                 response
//                                                                     .bodyBytes,
//                                                               );
//
//                                                           final hasAccess =
//                                                               await Gal.hasAccess();
//                                                           if (!hasAccess) {
//                                                             await Gal.requestAccess();
//                                                           }
//                                                           await Gal.putImage(
//                                                             file.path,
//                                                           );
//
//                                                           // ✅ success snackbar
//                                                           SnackbarHelper.showSuccess(
//                                                             title: 'Success',
//                                                             message:
//                                                                 'Image saved to gallery',
//                                                           );
//                                                         } catch (e) {
//                                                           SnackbarHelper.showError(
//                                                             title: 'Error',
//                                                             message:
//                                                                 'Failed to save image: $e',
//                                                           );
//                                                         }
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           );
//                                         },
//                                         child: Image.network(
//                                           imageUrl,
//                                           fit: BoxFit.contain,
//                                           loadingBuilder:
//                                               (context, child, progress) {
//                                                 if (progress == null)
//                                                   return child;
//                                                 return const CircularProgressIndicator(
//                                                   color: Colors.white,
//                                                 );
//                                               },
//                                         ),
//                                       ),
//                                     ),
//
//                                     // Close button
//                                     Positioned(
//                                       top: 40,
//                                       right: 20,
//                                       child: IconButton(
//                                         icon: const Icon(
//                                           Icons.close,
//                                           color: Colors.white,
//                                           size: 30,
//                                         ),
//                                         onPressed: () => Navigator.pop(context),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Expanded(
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.network(
//                                     imageUrl,
//                                     fit: BoxFit.cover,
//                                     loadingBuilder: (context, child, progress) {
//                                       if (progress == null) return child;
//                                       return Container(
//                                         color: Colors.grey[200],
//                                         child: const Center(
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     errorBuilder: (context, error, _) {
//                                       return Container(
//                                         color: Colors.grey[200],
//                                         child: const Icon(
//                                           Icons.error,
//                                           color: Colors.red,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//
//                               const SizedBox(height: 6),
//
//                               Text(
//                                 "ID: ${e['id']}",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildTabButton(String text, int index) {
//     final isSelected = _selectedTab == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _selectedTab = index),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           margin: const EdgeInsets.all(4),
//           decoration: BoxDecoration(
//             color: isSelected ? AppColors.primaryBlue : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: isSelected ? Colors.white : Colors.black54,
//               fontWeight: FontWeight.bold,
//               fontSize: 11,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ==================== HERO HEADER ====================
//   Widget _buildHeroHeader(PtwReviewSdoController controller, String userRole) {
//     final ptw = controller.ptwData;
//     final status = PtwHelper.getStatusText(_str(ptw['current_status']));
//     final statusColor = PtwHelper.getStatusColor(_str(ptw['current_status']));
//     final type = _str(ptw['type']);
//     final ptwCode = _str(ptw['ptw_code']);
//     final miscCode = _str(ptw['misc_code']);
//     print("MISCCODE: $miscCode");
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [statusColor, statusColor.withValues(alpha: 0.7)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: statusColor.withValues(alpha: 0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // Decorative circles
//           Positioned(
//             right: -20,
//             top: -20,
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withValues(alpha: 0.1),
//               ),
//             ),
//           ),
//           Positioned(
//             left: -30,
//             bottom: -30,
//             child: Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withValues(alpha: 0.05),
//               ),
//             ),
//           ),
//
//           // Content
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Wrap(
//                   children: [
//                     Text(
//                       (ptwCode.isEmpty || ptwCode == '—') ? miscCode : ptwCode,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.25),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         status,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 3),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.25),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         type,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     const Icon(Icons.person, color: Colors.white70, size: 16),
//                     const SizedBox(width: 6),
//                     Text(
//                       'Reviewing as $userRole',
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ==================== QUICK STATS ====================
//   Widget _buildQuickStats(PtwReviewSdoController controller) {
//     final ptw = controller.ptwData;
//     final team = (ptw['team_members'] as List?) ?? [];
//     final checklists = controller.checklists;
//     final evidences = (ptw['evidences'] as List?) ?? [];
//
//     int totalChecks = 0;
//     checklists.forEach((key, value) {
//       totalChecks +=
//           ((value as List?)
//               ?.where((it) => _str(it['value']).toUpperCase() == 'YES')
//               .length ??
//           0);
//     });
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildStatCard(
//               icon: Icons.groups_rounded,
//               value: '${team.length}',
//               label: 'Team',
//               color: const Color(0xFF6C63FF),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildStatCard(
//               icon: Icons.check_circle_rounded,
//               value: '$totalChecks',
//               label: 'Checks',
//               color: const Color(0xFF00D4AA),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildStatCard(
//               icon: Icons.attach_file_rounded,
//               value: '${evidences.length}',
//               label: 'Files',
//               color: const Color(0xFFFF6B9D),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard({
//     required IconData icon,
//     required String value,
//     required String label,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(7),
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           const SizedBox(width: 4),
//           Column(
//             children: [
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//               SizedBox(width: 8),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 10,
//                   color: Colors.black54,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ==================== TAB 1: DETAILS ====================
//   Widget _buildDetailsTab(PtwReviewSdoController controller) {
//     if (_selectedTab != 0) return const SizedBox.shrink();
//
//     final ptw = controller.ptwData;
//     final type = _str(ptw['type']).toUpperCase();
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           _buildInfoSection(
//             title: 'Basic Information',
//             icon: Icons.info_outline_rounded,
//             color: const Color(0xFF6C63FF),
//             items: [
//               {'label': 'Work Order', 'value': _str(ptw['work_order_no'])},
//               // if(type != 'PLANNED')
//               {
//                 'label': 'Duration',
//                 'value': '${ptw['estimated_duration_min'] ?? '—'} min',
//               },
//               {'label': 'LS', 'value': _str(ptw['ls_name'] ?? ptw['ls_id'])},
//               {
//                 'label': 'Sub-Division',
//                 'value': _str(ptw['sub_division'] ?? ptw['sub_division_name']),
//               },
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           _buildInfoSection(
//             title: 'Technical Details',
//             icon: Icons.engineering_rounded,
//             color: const Color(0xFFFF6B9D),
//             items: [
//               // Primary Feeders
//               ...(() {
//                 final primaryFeeders =
//                     ptw['primary_feeders'] as Map<String, dynamic>?;
//                 if (primaryFeeders == null || primaryFeeders.isEmpty) {
//                   return [
//                     {'label': 'Primary Feeders', 'value': '—'},
//                   ];
//                 }
//
//                 final List<Map<String, dynamic>> items = [];
//
//                 primaryFeeders.forEach((gridId, gridData) {
//                   final gridCode = _str(gridData['grid_code']);
//                   // final operatorName = _str(gridData['operator']?['name']);
//                   final feeders = gridData['feeders']?['primary'] as List?;
//
//                   if (feeders != null && feeders.isNotEmpty) {
//                     final feederNames = feeders
//                         .map((f) => '${_str(f['name'])} (${_str(f['code'])})')
//                         .join(', ');
//
//                     items.add({
//                       'label': 'Primary Feeders',
//                       'value': feederNames,
//                       'sublabel': 'Grid: $gridCode ',
//                       'full': true,
//                     });
//                   }
//                 });
//
//                 return items.isEmpty
//                     ? [
//                         {'label': 'Primary Feeders', 'value': '—'},
//                       ]
//                     : items;
//               })(),
//
//               const SizedBox(height: 8),
//
//               // Secondary Feeders
//               ...(() {
//                 final primaryFeeders =
//                     ptw['primary_feeders'] as Map<String, dynamic>?;
//                 if (primaryFeeders == null || primaryFeeders.isEmpty) return [];
//
//                 final List<Map<String, dynamic>> items = [];
//
//                 primaryFeeders.forEach((gridId, gridData) {
//                   final gridCode = _str(gridData['grid_code']);
//                   // final operatorName = _str(gridData['operator']?['name']);
//                   final feeders = gridData['feeders']?['secondary'] as List?;
//
//                   if (feeders != null && feeders.isNotEmpty) {
//                     final feederNames = feeders
//                         .map((f) => '${_str(f['name'])} (${_str(f['code'])})')
//                         .join(', ');
//
//                     items.add({
//                       'label': 'Secondary Feeders',
//                       'value': feederNames,
//                       'sublabel': 'Grid: $gridCode ',
//                       'full': true,
//                     });
//                   }
//                 });
//
//                 return items;
//               })(),
//
//               const SizedBox(height: 12),
//
//               {'label': 'Transformer', 'value': _str(ptw['transformer_name'])},
//               {
//                 'label': 'Feeder Incharge',
//                 'value': _str(ptw['feeder_incharge_name']),
//               },
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildInfoSection(
//             title: 'Work Location & Scope',
//             icon: Icons.location_on_rounded,
//             color: const Color(0xFF00D4AA),
//             items: [
//               {
//                 'label': 'Place of Work',
//                 'value': _str(ptw['place_of_work']),
//                 'full': true,
//               },
//               {
//                 'label': 'Scope of Work',
//                 'value': _str(ptw['scope_of_work']),
//                 'full': true,
//               },
//               {
//                 'label': 'Safety Arrangements',
//                 'value': _str(ptw['safety_arrangements']),
//                 'full': true,
//               },
//             ],
//           ),
//           const SizedBox(height: 16),
//           // ✅ UPDATED SCHEDULE SECTION
//           _buildScheduleSection(controller, type),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildScheduleSection(PtwReviewSdoController controller, String type) {
//     final ptw = controller.ptwData;
//
//     if (type == 'PLANNED') {
//       // PLANNED PTW: Show planned_from_date, planned_to_date, and planned_schedule
//       final plannedFromDate = _str(ptw['planned_from_date']);
//       final plannedToDate = _str(ptw['planned_to_date']);
//       final plannedSchedule = (ptw['planned_schedule'] as List?) ?? [];
//
//       return Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.04),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFB020).withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(
//                       Icons.schedule_rounded,
//                       color: Color(0xFFFFB020),
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Schedule',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(height: 1),
//
//             // Date Range Section
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xFFFFB020).withValues(alpha: 0.1),
//                       const Color(0xFFFFB020).withValues(alpha: 0.05),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: const Color(0xFFFFB020).withValues(alpha: 0.2),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.calendar_today_rounded,
//                                 size: 14,
//                                 color: Colors.grey.shade600,
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 'Start Date',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.grey.shade600,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             _formatDate(plannedFromDate),
//                             style: const TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       width: 1,
//                       height: 40,
//                       color: const Color(0xFFFFB020).withValues(alpha: 0.3),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.event_rounded,
//                                 size: 14,
//                                 color: Colors.grey.shade600,
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 'End Date',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.grey.shade600,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             _formatDate(plannedToDate),
//                             style: const TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Schedule Details
//             if (plannedSchedule.isNotEmpty) ...[
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFB020).withValues(alpha: 0.15),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.access_time_rounded,
//                             size: 12,
//                             color: Color(0xFFFFB020),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Daily Schedule (${plannedSchedule.length} days)',
//                             style: const TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFFFFB020),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 child: Column(
//                   children: plannedSchedule.asMap().entries.map((entry) {
//                     final index = entry.key;
//                     final item = entry.value as Map<String, dynamic>;
//                     final date = _formatDate(_str(item['date']));
//                     final startTime = _str(item['start_time']);
//                     final endTime = _str(item['end_time']);
//
//                     return Container(
//                       margin: EdgeInsets.only(
//                         bottom: index < plannedSchedule.length - 1 ? 10 : 0,
//                       ),
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       child: Row(
//                         children: [
//                           // Day Badge
//                           Container(
//                             width: 36,
//                             height: 36,
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 colors: [Color(0xFFFFB020), Color(0xFFFF8F00)],
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: const Color(
//                                     0xFFFFB020,
//                                   ).withValues(alpha: 0.3),
//                                   blurRadius: 4,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Center(
//                               child: Text(
//                                 '${index + 1}',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//
//                           // Date & Time Info
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.calendar_today,
//                                       size: 13,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                     const SizedBox(width: 6),
//                                     Text(
//                                       date,
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.access_time,
//                                       size: 13,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                     const SizedBox(width: 6),
//                                     Text(
//                                       '$startTime - $endTime',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey.shade700,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           // Duration Badge
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color(
//                                 0xFF00D4AA,
//                               ).withValues(alpha: 0.1),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               _calculateDuration(startTime, endTime),
//                               style: const TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF00D4AA),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       );
//     } else {
//       // Other PTW types: Show switch_off_time and restore_time with elegant UI
//       return Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.04),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFB020).withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(
//                       Icons.schedule_rounded,
//                       color: Color(0xFFFFB020),
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Schedule',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(height: 1),
//
//             // Times Section
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Switch-off Time
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.red.shade50,
//                           Colors.red.shade50.withValues(alpha: 0.3),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.red.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.red.shade100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(
//                             Icons.power_off_rounded,
//                             color: Colors.red.shade700,
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Switch-off Time',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.grey.shade600,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 _fmtDT(ptw['switch_off_time']),
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // Restore Time
//                   Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.green.shade50,
//                           Colors.green.shade50.withValues(alpha: 0.3),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.green.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.green.shade100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(
//                             Icons.power_rounded,
//                             color: Colors.green.shade700,
//                             size: 20,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Restore Time',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.grey.shade600,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 _fmtDT(ptw['restore_time']),
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   // Add this helper method to calculate duration
//   String _calculateDuration(String startTime, String endTime) {
//     try {
//       final start = TimeOfDay(
//         hour: int.parse(startTime.split(':')[0]),
//         minute: int.parse(startTime.split(':')[1]),
//       );
//       final end = TimeOfDay(
//         hour: int.parse(endTime.split(':')[0]),
//         minute: int.parse(endTime.split(':')[1]),
//       );
//
//       int startMinutes = start.hour * 60 + start.minute;
//       int endMinutes = end.hour * 60 + end.minute;
//       int duration = endMinutes - startMinutes;
//
//       if (duration < 0) duration += 24 * 60;
//
//       int hours = duration ~/ 60;
//       int minutes = duration % 60;
//
//       if (hours > 0 && minutes > 0) {
//         return '${hours}h ${minutes}m';
//       } else if (hours > 0) {
//         return '${hours}h';
//       } else {
//         return '${minutes}m';
//       }
//     } catch (e) {
//       return '—';
//     }
//   }
//
//   String _formatDate(String? dateStr) {
//     if (dateStr == null || dateStr.isEmpty || dateStr == '—') return '—';
//     try {
//       final date = DateTime.parse(dateStr);
//       return DateFormat('dd MMM yyyy').format(date);
//     } catch (_) {
//       return dateStr;
//     }
//   }
//
//   String _buildPlannedScheduleText(List<dynamic> schedule) {
//     if (schedule.isEmpty) return '—';
//
//     final buffer = StringBuffer();
//     for (int i = 0; i < schedule.length; i++) {
//       final item = schedule[i] as Map<String, dynamic>;
//       final date = _formatDate(_str(item['date']));
//       final startTime = _str(item['start_time']);
//       final endTime = _str(item['end_time']);
//
//       buffer.write('Day ${i + 1}: $date\n');
//       buffer.write('Time: $startTime - $endTime');
//
//       if (i < schedule.length - 1) {
//         buffer.write('\n\n');
//       }
//     }
//
//     return buffer.toString();
//   }
//
//   Widget _buildInfoSection({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required List<dynamic> items,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: color.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(icon, color: color, size: 20),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: items.map((item) {
//                 // Handle SizedBox for spacing
//                 if (item is SizedBox) return item;
//
//                 final itemMap = item as Map<String, dynamic>;
//                 final isFull = itemMap['full'] == true;
//                 final sublabel = itemMap['sublabel'] as String?;
//
//                 if (isFull) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           itemMap['label'],
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.black54,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: color.withValues(alpha: 0.05),
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                               color: color.withValues(alpha: 0.2),
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 itemMap['value'],
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.black87,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               if (sublabel != null && sublabel.isNotEmpty) ...[
//                                 const SizedBox(height: 6),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.info_outline,
//                                       size: 14,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                     const SizedBox(width: 6),
//                                     Expanded(
//                                       child: Text(
//                                         sublabel,
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey.shade600,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Text(
//                           itemMap['label'],
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.black54,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 3,
//                         child: Text(
//                           itemMap['value'],
//                           textAlign: TextAlign.left,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.black87,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ==================== TAB 2: TEAM ====================
//   Widget _buildTeamTab(PtwReviewSdoController controller) {
//     if (_selectedTab != 1) return const SizedBox.shrink();
//
//     final ptw = controller.ptwData;
//     final team = (ptw['team_members'] as List?) ?? [];
//
//     if (team.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.all(40),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.groups_outlined,
//                 size: 64,
//                 color: Colors.grey.shade300,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'No team members assigned',
//                 style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: team.map((member) {
//           final name = _str(member['name']);
//           final avatar = _str(
//             member['avatar_url'],
//             fallback:
//                 'http://mepco.myflexihr.com/storage/avatars/default-neutral.png',
//           );
//
//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.04),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(12),
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   avatar,
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.blue.shade300, Colors.purple.shade300],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(Icons.person, color: Colors.white),
//                   ),
//                 ),
//               ),
//               title: Text(
//                 name,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15,
//                 ),
//               ),
//               subtitle: Text(
//                 'Team Member #${team.indexOf(member) + 1}',
//                 style: const TextStyle(fontSize: 12, color: Colors.black54),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   // ==================== TAB 3: Checklist ====================
//   Widget _buildSafetyTab(
//     BuildContext context,
//     PtwReviewSdoController controller,
//   ) {
//     if (_selectedTab != 2) return const SizedBox.shrink();
//
//     final raw = controller.checklists;
//     // final evidences = (controller.ptwData.value['evidences'] as List?) ?? [];
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           // Checklists
//           if (raw.isNotEmpty) ...[
//             _buildSectionHeader(
//               'Safety Checklists',
//               Icons.checklist_rounded,
//               const Color(0xFF00D4AA),
//             ),
//             const SizedBox(height: 12),
//             ...raw.entries.map((entry) {
//               final type = entry.key;
//               final items = (entry.value as List?) ?? [];
//               final yesItems = items
//                   .where((it) => _str(it['value']).toUpperCase() == 'YES')
//                   .toList();
//
//               if (yesItems.isEmpty) return const SizedBox.shrink();
//
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.04),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: ExpansionTile(
//                   tilePadding: const EdgeInsets.all(16),
//                   childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                   leading: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade50,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.verified,
//                       color: Colors.green.shade600,
//                       size: 20,
//                     ),
//                   ),
//                   title: Text(
//                     type.replaceAll('_', ' '),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                   subtitle: Text(
//                     '${yesItems.length} items confirmed',
//                     style: const TextStyle(fontSize: 12, color: Colors.black54),
//                   ),
//                   children: yesItems.map((it) {
//                     return _bilingualChecklistRow(
//                       _str(it['label_en']),
//                       _str(it['label_ur']),
//                       _str(it['value']),
//                     );
//                   }).toList(),
//                 ),
//               );
//             }),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, IconData icon, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ==================== TAB 4: TIMELINE ====================
//   Widget _buildTimelineTab(PtwReviewSdoController controller) {
//     if (_selectedTab != 3) return const SizedBox.shrink();
//
//     final args = Get.arguments ?? {};
//     final userRole =
//         ((args['user_role'] ?? controller.currentUserRole.value)
//             ?.toString()
//             .trim()
//             .toUpperCase()) ??
//         'LS';
//
//     final logs = (controller.ptwData['logs'] as List?) ?? [];
//     final logsWithNotes = logs
//         .where((log) => (log['notes']?.toString().trim().isNotEmpty ?? false))
//         .toList();
//
//     final status =
//         controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
//
//     // ✅ PDC ke liye timeline mein decision notes NAHI dikhaye
//     final shouldShowDecisionNotes =
//         userRole != 'PDC' && controller.shouldAskForNotes(userRole);
//
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // 🕒 Existing timeline items
//           ...logsWithNotes.asMap().entries.map((entry) {
//             final index = entry.key;
//             final log = entry.value;
//             final isLast =
//                 index == logsWithNotes.length - 1 && !shouldShowDecisionNotes;
//
//             String? feederStatus;
//             try {
//               final metaJson = log['meta_json'];
//               if (metaJson != null && metaJson.toString().isNotEmpty) {
//                 final meta = jsonDecode(metaJson.toString());
//                 feederStatus = meta['feeder_status']?.toString();
//               }
//             } catch (e) {
//               // If parsing fails, feederStatus remains null
//             }
//
//             return _buildTimelineItem(
//               role: log['role']?.toString() ?? '',
//               action: log['action']?.toString() ?? '',
//               notes: log['notes']?.toString() ?? '',
//               feederStatus: feederStatus,
//               editable: false,
//               showLine: !isLast,
//             );
//           }),
//
//           // ✍️ Editable notes - ONLY for non-PDC roles
//           if (shouldShowDecisionNotes)
//             _buildTimelineItem(
//               role: userRole,
//               action: 'Decision Notes',
//               notes: '',
//               editable: true,
//               controller: controller.decisionNotesController,
//               showLine: false,
//             ),
//
//           const SizedBox(height: 24),
//
//           // ✅ Buttons - Only for non-PDC roles
//           if (userRole != 'PDC') Obx(() => _buildBottomActions(controller)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTimelineItem({
//     required String role,
//     required String action,
//     required String notes,
//     String? feederStatus, // ✅ NEW: Add feeder status parameter
//     required bool editable,
//     required bool showLine,
//     TextEditingController? controller,
//   }) {
//     final roleUpper = role.toUpperCase();
//     final roleColor =
//         {
//           'LS': const Color(0xFF00897B),
//           'SDO': const Color(0xFF1976D2),
//           'XEN': const Color(0xFFF57C00),
//           'PDC': const Color(0xFF7B1FA2),
//           'GRIDOPERATOR': const Color(0xFFD32F2F),
//         }[roleUpper] ??
//         Colors.grey;
//
//     final roleIcon =
//         {
//           'LS': Icons.engineering,
//           'SDO': Icons.supervisor_account,
//           'XEN': Icons.admin_panel_settings,
//           'PDC': Icons.assignment_ind,
//           'GRIDOPERATOR': Icons.power,
//         }[roleUpper] ??
//         Icons.person;
//
//     final actionMap = {
//       'FORWARD_XEN': 'Forwarded to XEN',
//       'APPROVE_TO_PDC': 'Approved to PDC',
//       'DELEGATE_GRID': 'Delegated to Grid',
//       'PRECHECKS_DONE': 'Pre-checks Done',
//       'EXECUTION_STARTED': 'Execution Started',
//       'COMPLETION_SUBMITTED': 'Completed',
//       'GRID_RESTORED_AND_CLOSED': 'Restored & Closed',
//       'SDO_RETURNED': 'Returned to LS',
//       'XEN_RETURNED_TO_LS': 'Returned to LS',
//       'LS_RESUBMITTED': 'Resubmitted',
//       'CANCELLATION_REQUESTED_BY_LS': 'Cancel Request',
//       'Decision Notes': 'Decision Notes',
//       'PDC_ISSUE': 'PTW Issued', // ✅ NEW: Add PDC Issue action
//     };
//
//     final displayAction = actionMap[action] ?? action.replaceAll('_', ' ');
//
//     // ✅ NEW: Helper to format feeder status for display
//     String formatFeederStatus(String status) {
//       switch (status.toUpperCase()) {
//         case 'NORMAL':
//           return 'Normal';
//         case 'ABNORMAL':
//           return 'Abnormal';
//         case 'UNDER_MAINTENANCE':
//           return 'Under Maintenance';
//         default:
//           return status.replaceAll('_', ' ');
//       }
//     }
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 24),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Timeline Dot & Line
//           Column(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [roleColor, roleColor.withValues(alpha: 0.7)],
//                   ),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: roleColor.withValues(alpha: 0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Icon(roleIcon, color: Colors.white, size: 20),
//               ),
//               if (showLine)
//                 Container(
//                   width: 2,
//                   height: 60,
//                   margin: const EdgeInsets.symmetric(vertical: 4),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         roleColor.withValues(alpha: 0.3),
//                         Colors.transparent,
//                       ],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(width: 16),
//
//           // Content Card
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: editable
//                     ? roleColor.withValues(alpha: 0.05)
//                     : Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: editable
//                       ? roleColor.withValues(alpha: 0.3)
//                       : Colors.grey.shade200,
//                   width: editable ? 2 : 1,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.04),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: roleColor.withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             roleUpper,
//                             style: TextStyle(
//                               color: roleColor,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             displayAction,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13,
//                               color: roleColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//
//                     // Notes section
//                     if (editable && controller != null)
//                       CustomTextFormField(
//                         labelText: 'Enter your decision notes...',
//                         maxLines: 4,
//                         controller: controller,
//                       )
//                     else if (notes.isNotEmpty)
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           notes,
//                           style: const TextStyle(
//                             fontSize: 13,
//                             color: Colors.black87,
//                             height: 1.5,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<bool> showConfirmationDialog(
//     BuildContext context,
//     String message,
//   ) async {
//     return await showGeneralDialog<bool>(
//           context: context,
//           barrierDismissible: true,
//           barrierLabel: "Confirm",
//           transitionDuration: const Duration(milliseconds: 220),
//
//           pageBuilder: (_, __, ___) => const SizedBox.shrink(),
//
//           transitionBuilder: (context, animation, secondary, child) {
//             final curved = Curves.easeOut.transform(animation.value);
//
//             return Transform.scale(
//               scale: curved,
//               child: Opacity(
//                 opacity: curved,
//                 child: Material(
//                   color: Colors.black.withValues(alpha: 0.01),
//                   child: Center(
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.85,
//                       padding: const EdgeInsets.all(22),
//                       decoration: BoxDecoration(
//                         color: Colors.white, // WHITE BACKGROUND
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 20,
//                             spreadRadius: 4,
//                             offset: Offset(0, 8),
//                           ),
//                         ],
//                       ),
//
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // ICON
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.red.withValues(alpha: 0.12),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.warning_amber_rounded,
//                               size: 38,
//                               color: Colors.red,
//                             ),
//                           ),
//
//                           const SizedBox(height: 18),
//
//                           // TITLE
//                           const Text(
//                             "Confirmation Required",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.black87,
//                             ),
//                           ),
//
//                           const SizedBox(height: 10),
//
//                           // MESSAGE
//                           Text(
//                             message,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey.shade700,
//                               height: 1.4,
//                             ),
//                           ),
//
//                           const SizedBox(height: 25),
//
//                           // ACTION BUTTONS
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.primaryBlue,
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(32),
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   onPressed: () {
//                                     Navigator.pop(context, false);
//                                   },
//                                   child: const Text(
//                                     "Cancel",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//
//                               const SizedBox(width: 12),
//
//                               Expanded(
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.green.shade600,
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 10,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(32),
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   onPressed: () {
//                                     Navigator.pop(context, true);
//                                   },
//                                   child: const Text(
//                                     "Confirm",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ) ??
//         false;
//   }
//
//   // =======================================================
//   //  MAIN ACTION BUILDER
//   // =======================================================
//   Widget _buildBottomActions(PtwReviewSdoController controller) {
//     final context = Get.context!;
//     final args = Get.arguments ?? {};
//     final userRole =
//         ((args['user_role'] ?? controller.currentUserRole.value) ?? 'LS')
//             .toString()
//             .trim()
//             .toUpperCase();
//
//     final status =
//         controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
//     if (userRole == 'GRIDOPERATOR' && status == 'GRID_RESOLVE_REQUIRED') {
//       // Check if current user is assigned operator
//       if (!controller.isCurrentUserAssignedOperator()) {
//         return _buildNoAccessMessage();
//       }
//     }
//     bool anyFeederOn =
//         controller.turnedOffFeeders.length < controller.allFeeders.length;
//     if (userRole == 'PDC' &&
//         (status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC') &&
//         anyFeederOn) {
//       return Column(
//         children: [
//           // Decision Notes
//           _buildTimelineItem(
//             role: userRole,
//             action: 'Decision Notes',
//             notes: '',
//             editable: true,
//             controller: controller.decisionNotesController,
//             showLine: false,
//           ),
//           const SizedBox(height: 16),
//
//           // Return to Grid button
//           _buildActionBar(
//             buttons: [
//               _ActionButton(
//                 text: 'Return to Grid',
//                 icon: Icons.keyboard_return_outlined,
//                 color: const Color(0xFFC62828),
//                 actionKey: 'return_grid',
//                 onPressed: (setLoading) async {
//                   // ✅ Confirmation dialog
//                   bool confirm = await showConfirmationDialog(
//                     context,
//                     "Are you sure you want to issue this PTW?",
//                   );
//                   if (!confirm) return;
//
//                   setLoading(true);
//
//                   final ptwId = controller.ptwData['id'];
//
//                   // ✅ Optional: Get notes (if needed, otherwise pass empty string)
//                   final notes = controller.decisionNotesController.text.trim();
//
//                   // ✅ Call forwardPTW with PtwActionType.pdcIssue
//                   await controller.forwardPTW(
//                     ptwId,
//                     userRole,
//                     notes,
//                     action: PtwActionType.returnGrid,
//                   );
//
//                   setLoading(false);
//                 },
//               ),
//             ],
//           ),
//         ],
//       );
//     }
//
//     // ✅ Show only Issue PTW when ALL feeders are OFF
//     if (userRole == 'PDC' &&
//         (status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC') &&
//         !anyFeederOn) {
//       return _buildActionBar(
//         buttons: [
//           _ActionButton(
//             text: 'Issue PTW',
//             icon: Icons.forward,
//             color: const Color(0xFF6A1B9A),
//             actionKey: 'issue_ptw',
//             onPressed: (setLoading) async {
//               // ✅ Confirmation dialog
//               bool confirm = await showConfirmationDialog(
//                 context,
//                 "Are you sure you want to issue this PTW?",
//               );
//               if (!confirm) return;
//
//               setLoading(true);
//
//               final ptwId = controller.ptwData['id'];
//
//               // ✅ Optional: Get notes (if needed, otherwise pass empty string)
//               final notes = controller.decisionNotesController.text.trim();
//
//               // ✅ Call forwardPTW with PtwActionType.pdcIssue
//               await controller.forwardPTW(
//                 ptwId,
//                 userRole,
//                 notes,
//                 action: PtwActionType.pdcIssue,
//               );
//
//               setLoading(false);
//             },
//           ),
//         ],
//       );
//     }
//     // LS → PDC_CONFIRMED (START PTW + CANCEL)
//     // =======================================================
//     if (userRole == 'LS' && status == 'PDC_CONFIRMED') {
//       return _buildActionBar(
//         buttons: [
//           // ▶ START PTW
//           _ActionButton(
//             text: 'Start PTW',
//             icon: Icons.play_circle_fill,
//             color: Colors.green.shade700,
//             actionKey: 'start_ptw',
//             onPressed: (setLoading) async {
//               bool confirm = await showConfirmationDialog(
//                 context,
//                 "Are you sure you want to start this PTW?",
//               );
//               if (!confirm) return;
//
//               setLoading(true);
//
//               bool serviceEnabled;
//               LocationPermission permission;
//
//               serviceEnabled = await Geolocator.isLocationServiceEnabled();
//               if (!serviceEnabled) {
//                 await Geolocator.openLocationSettings();
//                 setLoading(false);
//                 return;
//               }
//
//               permission = await Geolocator.checkPermission();
//               if (permission == LocationPermission.denied) {
//                 permission = await Geolocator.requestPermission();
//                 if (permission == LocationPermission.denied) {
//                   SnackbarHelper.showError(
//                     title: 'Permission Denied',
//                     message: 'Location permission is required to start PTW.',
//                   );
//                   setLoading(false);
//                   return;
//                 }
//               }
//
//               if (permission == LocationPermission.deniedForever) {
//                 SnackbarHelper.showError(
//                   title: 'Permission Denied',
//                   message:
//                       'Location permission is permanently denied. Please enable it from settings.',
//                 );
//                 setLoading(false);
//                 return;
//               }
//
//               final ptwId = controller.ptwData['id'];
//               if (ptwId != null) {
//                 Get.toNamed(AppRoutes.attachmentsSubmission, arguments: ptwId);
//               }
//
//               setLoading(false);
//             },
//           ),
//
//           // ❌ CANCEL PTW
//           _ActionButton(
//             text: 'Cancel',
//             icon: Icons.cancel_schedule_send,
//             color: Colors.blueGrey,
//             actionKey: 'cancel_ptw_ls',
//             onPressed: (setLoading) async {
//               bool confirm = await showConfirmationDialog(
//                 context,
//                 "Are you sure you want to cancel this PTW?",
//               );
//               if (!confirm) return;
//
//               setLoading(true);
//
//               final ptwId = controller.ptwData['id'];
//               if (ptwId != null) {
//                 Get.toNamed(
//                   AppRoutes.ptwCancelByLs,
//                   arguments: {'ptw_id': ptwId, 'user_role': userRole},
//                 );
//               }
//
//               setLoading(false);
//             },
//           ),
//         ],
//       );
//     }
//
//     // =======================================================
//     // LS → COMPLETE PTW (WHEN IN_EXECUTION)
//     // =======================================================
//     if (userRole == 'LS' && status == 'IN_EXECUTION') {
//       return _buildActionBar(
//         buttons: [
//           _ActionButton(
//             text: 'Complete',
//             icon: Icons.check_circle_rounded,
//             color: Colors.orange.shade700,
//             actionKey: 'complete_ptw',
//             onPressed: (setLoading) async {
//               bool confirm = await showConfirmationDialog(
//                 context,
//                 "Are you sure you want to complete this PTW?",
//               );
//               if (!confirm) return;
//
//               setLoading(true);
//
//               bool serviceEnabled;
//               LocationPermission permission;
//
//               // 1️⃣ Check location service
//               serviceEnabled = await Geolocator.isLocationServiceEnabled();
//               if (!serviceEnabled) {
//                 await Geolocator.openLocationSettings();
//                 setLoading(false);
//                 return;
//               }
//
//               // 2️⃣ Check permission
//               permission = await Geolocator.checkPermission();
//               if (permission == LocationPermission.denied) {
//                 permission = await Geolocator.requestPermission();
//                 if (permission == LocationPermission.denied) {
//                   SnackbarHelper.showError(
//                     title: 'Permission Denied',
//                     message: 'Location permission is required to complete PTW.',
//                   );
//                   setLoading(false);
//                   return;
//                 }
//               }
//
//               if (permission == LocationPermission.deniedForever) {
//                 SnackbarHelper.showError(
//                   title: 'Permission Denied',
//                   message:
//                       'Location permission is permanently denied. Please enable it from settings.',
//                 );
//                 setLoading(false);
//                 return;
//               }
//
//               // 3️⃣ Navigate to completion screen
//               final ptwId = controller.ptwData['id'];
//               if (ptwId != null) {
//                 Get.toNamed(AppRoutes.ptwCompleted, arguments: ptwId);
//               }
//
//               setLoading(false);
//             },
//           ),
//         ],
//       );
//     }
//
//     if (userRole == 'LS') {
//       final returnedByRole =
//           controller.ptwData['returned_by_role']?.toString().toUpperCase() ??
//           '';
//
//       final isDraft = status == 'DRAFT';
//       final isReturned = [
//         'SDO_RETURNED',
//         'XEN_RETURNED_TO_LS',
//         'PDC_RETURNED_TO_LS',
//       ].contains(status);
//
//       if (!isDraft && !isReturned) return const SizedBox.shrink();
//
//       String forwardLabel;
//
//       if (isDraft) {
//         forwardLabel = 'Forward to SDO';
//       } else {
//         switch (returnedByRole) {
//           case 'XEN':
//             forwardLabel = 'Forward to XEN';
//             break;
//           case 'PDC':
//             forwardLabel = 'Forward to PDC';
//             break;
//           case 'SDO':
//           default:
//             forwardLabel = 'Forward to SDO';
//             break;
//         }
//       }
//
//       return _buildActionBar(
//         buttons: [
//           _ActionButton(
//             text: forwardLabel,
//             icon: Icons.send_rounded,
//             color: const Color(0xFF0D47A1),
//             actionKey: 'ls_forward',
//             onPressed: (setLoading) async {
//               // ===============================
//               // SHOW POPUP FIRST
//               // ===============================
//               bool confirm = await showConfirmationDialog(
//                 context,
//                 "Are you sure you want to forward this?",
//               );
//               if (!confirm) return;
//
//               setLoading(true);
//
//               final ptwId = controller.ptwData['id'] as int;
//               final notes = controller.decisionNotesController.text.trim();
//
//               if (controller.shouldAskForNotes('LS') && notes.isEmpty) {
//                 SnackbarHelper.showError(
//                   title: 'Error',
//                   message: 'Please enter decision notes',
//                 );
//                 setLoading(false);
//                 return;
//               }
//
//               await controller.forwardPTW(ptwId, 'LS', notes);
//               setLoading(false);
//             },
//           ),
//         ],
//       );
//     }
//     final isPtwRequired = controller.ptwData['is_ptw_required'];
//     if (userRole == 'SDO' && status == 'SUBMITTED' && isPtwRequired == false) {
//       return _buildActionBar(
//         buttons: [
//           _ActionButton(
//             text: 'Approve PTW',
//             icon: Icons.check_circle_rounded,
//             color: const Color(0xFF2E7D32),
//             actionKey: 'approve_ptw',
//             onPressed: (setLoading) async {
//               bool confirm = await showConfirmationDialog(
//                 context,
//                 "Are you sure you want to approve this PTW?",
//               );
//               if (!confirm) return;
//
//               setLoading(true);
//
//               final ptwId = controller.ptwData['id'];
//               final notes = controller.decisionNotesController.text.trim();
//
//               await controller.forwardPTW(
//                 ptwId,
//                 userRole,
//                 notes,
//                 action: PtwActionType
//                     .approve_no_ptw, // ✅ change if backend has special approve action
//               );
//
//               setLoading(false);
//             },
//           ),
//         ],
//       );
//     }
//     // =======================================================
//     // GRID OPERATOR → CLOSE PTW (WITH LOCATION PERMISSION)
//     // =======================================================
//     if (userRole == 'GRIDOPERATOR' &&
//         (status == 'COMPLETION_SUBMITTED' ||
//             status == 'CANCELLATION_APPROVED_BY_SDO')) {
//       return _buildActionBar(
//         buttons: [
//           _ActionButton(
//             text: 'Close PTW',
//             icon: Icons.close_outlined,
//             color: Colors.blue.shade700,
//             actionKey: 'grid_close_ptw',
//             onPressed: (setLoading) async {
//               bool confirm = await showConfirmationDialog(
//                 context,
//                 "Are you sure you want to close this PTW?",
//               );
//               if (!confirm) return;
//
//               setLoading(true);
//
//               bool serviceEnabled;
//               LocationPermission permission;
//
//               // 1️⃣ Check location service
//               serviceEnabled = await Geolocator.isLocationServiceEnabled();
//               if (!serviceEnabled) {
//                 await Geolocator.openLocationSettings();
//                 setLoading(false);
//                 return;
//               }
//
//               // 2️⃣ Check location permission
//               permission = await Geolocator.checkPermission();
//               if (permission == LocationPermission.denied) {
//                 permission = await Geolocator.requestPermission();
//                 if (permission == LocationPermission.denied) {
//                   SnackbarHelper.showError(
//                     title: 'Permission Denied',
//                     message: 'Location permission is required to close PTW.',
//                   );
//                   setLoading(false);
//                   return;
//                 }
//               }
//
//               if (permission == LocationPermission.deniedForever) {
//                 SnackbarHelper.showError(
//                   title: 'Permission Denied',
//                   message:
//                       'Location permission is permanently denied. Please enable it from settings.',
//                 );
//                 setLoading(false);
//                 return;
//               }
//
//               // 3️⃣ Navigate to close PTW screen
//               final ptwId = controller.ptwData['id'];
//               if (ptwId != null) {
//                 Get.toNamed(AppRoutes.ptwGridClose, arguments: ptwId);
//               }
//
//               setLoading(false);
//             },
//           ),
//         ],
//       );
//     }
//
//     // =======================================================
//     // OTHER ROLES CONFIGURATION
//     // =======================================================
//     final Map<String, Map<String, List<Map<String, dynamic>>>>
//     roleStatusActions = {
//       'LS': {
//         'SUBMITTED': [
//           {
//             'text': 'Start Executuion',
//             'action': PtwActionType.forward,
//             'requiresNotes': false,
//             'icon': Icons.arrow_forward_rounded,
//             'color': Color(0xFF0D47A1),
//             'key': 'forward_xen',
//           },
//         ],
//       },
//       'SDO': {
//         'SUBMITTED': [
//           {
//             'text': 'Forward to XEN',
//             'action': PtwActionType.forward,
//             'requiresNotes': false,
//             'icon': Icons.arrow_forward_rounded,
//             'color': Color(0xFF0D47A1),
//             'key': 'forward_xen',
//           },
//           {
//             'text': 'Return to LS',
//             'action': PtwActionType.returnBack,
//             'requiresNotes': false,
//             'icon': Icons.arrow_back_rounded,
//             'color': Color(0xFFE65100),
//             'key': 'return_ls',
//           },
//           {
//             'text': 'Cancel Request',
//             'action': PtwActionType.cancel,
//             'requiresNotes': false,
//             'icon': Icons.cancel_outlined,
//             'color': Color(0xFFC62828),
//             'key': 'cancel',
//           },
//         ],
//         'CANCELLATION_REQUESTED_BY_LS': [
//           {
//             'text': 'Forward to Grid',
//             'action': PtwActionType.cancelSDO,
//             'requiresNotes': false,
//             'icon': Icons.arrow_forward_rounded,
//             'color': Color(0xFF0D47A1),
//             'key': 'forward_grid',
//           },
//         ],
//       },
//
//       // XEN ACTIONS
//       'XEN': {
//         'SDO_FORWARDED_TO_XEN': [
//           {
//             'text': 'Approve to PDC',
//             'action': PtwActionType.forward,
//             'requiresNotes': false,
//             'icon': Icons.check_circle_rounded,
//             'color': Color(0xFF2E7D32),
//             'key': 'approve_pdc',
//           },
//           {
//             'text': 'Return to LS',
//             'action': PtwActionType.xenReturnLS,
//             'requiresNotes': false,
//             'icon': Icons.arrow_back_rounded,
//             'color': Color(0xFFE65100),
//             'key': 'return_sdo',
//           },
//           {
//             'text': 'Cancel Request',
//             'action': PtwActionType.xenReject,
//             'requiresNotes': false,
//             'icon': Icons.cancel_outlined,
//             'color': Color(0xFFC62828),
//             'key': 'cancel',
//           },
//         ],
//         'LS_RESUBMIT_TO_XEN': [
//           {
//             'text': 'Approve to PDC',
//             'action': PtwActionType.forward,
//             'requiresNotes': false,
//             'icon': Icons.check_circle_rounded,
//             'color': Color(0xFF2E7D32),
//             'key': 'approve_pdc',
//           },
//           {
//             'text': 'Return to LS',
//             'action': PtwActionType.xenReturnLS,
//             'requiresNotes': false,
//             'icon': Icons.arrow_back_rounded,
//             'color': Color(0xFFE65100),
//             'key': 'return_sdo',
//           },
//           {
//             'text': 'Cancel Request',
//             'action': PtwActionType.xenReject,
//             'requiresNotes': false,
//             'icon': Icons.cancel_outlined,
//             'color': Color(0xFFC62828),
//             'key': 'cancel',
//           },
//         ],
//       },
//
//       // PDC ACTIONS
//       'PDC': {
//         'XEN_APPROVED_TO_PDC': [
//           {
//             'text': 'Delegate to GRID',
//             'action': PtwActionType.forward,
//             'requiresNotes': false,
//             'icon': Icons.power_rounded,
//             'color': Color(0xFF6A1B9A),
//             'key': 'delegate_grid',
//           },
//           {
//             'text': 'Return to LS',
//             'action': PtwActionType.pdcReturnsLS,
//             'requiresNotes': false,
//             'icon': Icons.arrow_back_rounded,
//             'color': Color(0xFFE65100),
//             'key': 'return_ls',
//           },
//           {
//             'text': 'Cancel Request',
//             'action': PtwActionType.pdcReject,
//             'requiresNotes': false,
//             'icon': Icons.cancel_outlined,
//             'color': Color(0xFFC62828),
//             'key': 'cancel',
//           },
//         ],
//         'LS_RESUBMIT_TO_PDC': [
//           {
//             'text': 'Delegate to GRID',
//             'action': PtwActionType.forward,
//             'requiresNotes': false,
//             'icon': Icons.power_rounded,
//             'color': Color(0xFF6A1B9A),
//             'key': 'delegate_grid',
//           },
//           {
//             'text': 'Return to LS',
//             'action': PtwActionType.pdcReturnsLS,
//             'requiresNotes': false,
//             'icon': Icons.arrow_back_rounded,
//             'color': Color(0xFFE65100),
//             'key': 'return_ls',
//           },
//           {
//             'text': 'Cancel Request',
//             'action': PtwActionType.pdcReject,
//             'requiresNotes': false,
//             'icon': Icons.cancel_outlined,
//             'color': Color(0xFFC62828),
//             'key': 'cancel',
//           },
//         ],
//         'PTW_ISSUED': [
//           {
//             'text': 'Issue PTW',
//             'action': PtwActionType.pdcIssue,
//             'requiresNotes': false,
//             'icon': Icons.forward,
//             'color': Color(0xFF6A1B9A),
//             'key': 'issuePtw',
//           },
//           {
//             'text': 'Return to grid',
//             'action': PtwActionType.returnGrid,
//             'requiresNotes': false,
//             'icon': Icons.keyboard_return_outlined,
//             'color': Color(0xFFC62828),
//             'key': 'return_grid',
//           },
//         ],
//         'RE_SUBMITTED_TO_PDC': [
//           {
//             'text': 'Issue PTW',
//             'action': PtwActionType.pdcIssue,
//             'requiresNotes': false,
//             'icon': Icons.forward,
//             'color': Color(0xFF6A1B9A),
//             'key': 'issuePtw',
//           },
//           {
//             'text': 'Return to grid',
//             'action': PtwActionType.returnGrid,
//             'requiresNotes': false,
//             'icon': Icons.keyboard_return_outlined,
//             'color': Color(0xFFC62828),
//             'key': 'return_grid',
//           },
//         ],
//       },
//
//       // GRID OPERATOR
//       'GRIDOPERATOR': {
//         'PDC_DELEGATED_TO_GRID': [
//           {
//             'text': 'Confirm PTW',
//             'action': null,
//             'requiresNotes': false,
//             'isGrid': true,
//             'icon': Icons.verified_rounded,
//             'color': Color(0xFF2E7D32),
//             'key': 'confirm_ptw',
//           },
//         ],
//         'GRID_RESOLVE_REQUIRED': [
//           {
//             'text': 'Confirm PTW',
//             'action': null,
//             'requiresNotes': false,
//             'isGrid': true,
//             'icon': Icons.verified_rounded,
//             'color': Color(0xFF2E7D32),
//             'key': 'confirm_ptw',
//           },
//         ],
//       },
//     };
//
//     final actions = roleStatusActions[userRole]?[status];
//     print('actions: $actions');
//     if (actions == null || actions.isEmpty) return const SizedBox.shrink();
//
//     return _buildActionBar(
//       buttons: actions.map((btnConfig) {
//         return _ActionButton(
//           text: btnConfig['text'],
//           icon: btnConfig['icon'],
//           color: btnConfig['color'],
//           actionKey: btnConfig['key'],
//           onPressed: (setLoading) async {
//             // ======================================
//             // SHOW CONFIRM POPUP BEFORE ACTION
//             // ======================================
//             bool confirm = await showConfirmationDialog(
//               context,
//               "Are you sure you want to proceed?",
//             );
//             if (!confirm) return;
//
//             setLoading(true);
//
//             final ptwId = controller.ptwData['id'];
//             final notes = controller.decisionNotesController.text.trim();
//
//             if (btnConfig['isGrid'] == true) {
//               Get.toNamed(
//                 AppRoutes.gridPtwIssueChecklist,
//                 arguments: {'ptw_id': ptwId},
//               );
//               setLoading(false);
//               return;
//             }
//
//             if (btnConfig['requiresNotes'] == true && notes.isEmpty) {
//               SnackbarHelper.showError(
//                 title: 'Error',
//                 message: 'Please enter decision notes',
//               );
//               setLoading(false);
//               return;
//             }
//
//             await controller.forwardPTW(
//               ptwId,
//               userRole,
//               notes,
//               action: btnConfig['action'],
//             );
//
//             setLoading(false);
//           },
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildNoAccessMessage() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.orange.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.orange.shade200, width: 2),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.orange.shade100,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.lock_outline,
//               size: 48,
//               color: Colors.orange.shade700,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Access Restricted',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.orange.shade900,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'This PTW is assigned to another Grid Operator',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade700,
//               height: 1.4,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Only the assigned operator can perform actions on this PTW',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ==================== ACTION BAR WITH INDIVIDUAL LOADING ====================
//   Widget _buildActionBar({required List<_ActionButton> buttons}) {
//     // Local state for each button's loading
//     final loadingStates = <String, bool>{}.obs;
//
//     return Padding(
//       padding: const EdgeInsets.only(top: 16, bottom: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: buttons.map((btn) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Obx(() {
//               final isLoading = loadingStates[btn.actionKey] ?? false;
//
//               return SizedBox(
//                 height: 52,
//                 child: ElevatedButton(
//                   onPressed: isLoading
//                       ? null
//                       : () {
//                           btn.onPressed((loading) {
//                             loadingStates[btn.actionKey] = loading;
//                           });
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: btn.color,
//                     disabledBackgroundColor: btn.color.withValues(alpha: 0.5),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     elevation: isLoading ? 0 : 2,
//                     shadowColor: btn.color.withValues(alpha: 0.3),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       if (isLoading) ...[
//                         const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2.5,
//                             valueColor: AlwaysStoppedAnimation(Colors.white),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Text(
//                           'Processing...',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ] else ...[
//                         Icon(btn.icon, color: Colors.white, size: 20),
//                         const SizedBox(width: 10),
//                         Flexible(
//                           child: Text(
//                             btn.text,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   // ==================== SHIMMER ====================
//   Widget _buildShimmerLoading() {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: List.generate(
//         5,
//         (_) => Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           child: const ShimmerWidget.rectangular(height: 150),
//         ),
//       ),
//     );
//   }
//
//   // ==================== HELPERS ====================
//   String _str(dynamic v, {String fallback = '—'}) {
//     if (v == null) return fallback;
//     final s = v.toString().trim();
//     return s.isEmpty ? fallback : s;
//   }
//
//   String _fmtDT(dynamic v) {
//     try {
//       if (v == null) return '—';
//       final raw = v.toString().replaceFirst(' ', 'T');
//       final dt = DateTime.parse(raw);
//       return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
//     } catch (_) {
//       return _str(v);
//     }
//   }
//
//   // ==================== BILINGUAL CHECKLIST ROW ====================
//   Widget _bilingualChecklistRow(String en, String ur, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.green.shade50,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.green.shade200),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     en,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   if (ur.isNotEmpty && ur != '—') ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       ur,
//                       textAlign: TextAlign.right,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade700,
//                         fontFamily: 'Noto Nastaliq Urdu',
//                       ),
//                       // textDirection: TextDirection.RTL,
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             _yesNoChip(value),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _yesNoChip(String value) {
//     final isYes = value.toUpperCase() == 'YES';
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: (isYes ? Colors.green : Colors.red).withValues(alpha: 0.15),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             isYes ? Icons.check_circle : Icons.cancel,
//             color: isYes ? Colors.green.shade700 : Colors.red.shade700,
//             size: 14,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             isYes ? 'YES' : 'NO',
//             style: TextStyle(
//               color: isYes ? Colors.green.shade700 : Colors.red.shade700,
//               fontWeight: FontWeight.bold,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ==================== ACTION BUTTON CLASS ====================
// class _ActionButton {
//   final String text;
//   final IconData icon;
//   final Color color;
//   final String actionKey;
//   final Function(Function(bool) setLoading) onPressed;
//
//   _ActionButton({
//     required this.text,
//     required this.icon,
//     required this.color,
//     required this.actionKey,
//     required this.onPressed,
//   });
// }
//
// // import 'dart:convert';
// // import 'dart:io';
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_image_compress/flutter_image_compress.dart';
// // import 'package:gal/gal.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:get/get.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:intl/intl.dart';
// // import 'package:mepco_esafety_app/constants/app_colors.dart';
// // import 'package:mepco_esafety_app/controllers/ptw_review_sdo_controller.dart';
// // import 'package:mepco_esafety_app/routes/app_routes.dart';
// //
// // import 'package:mepco_esafety_app/widgets/main_layout.dart';
// // import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:share_plus/share_plus.dart';
// // import '../widgets/custom_text_form_field.dart';
// // import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
// //
// // class PtwReviewSdoScreen extends StatefulWidget {
// //   const PtwReviewSdoScreen({super.key});
// //
// //   @override
// //   State<PtwReviewSdoScreen> createState() => _PtwReviewSdoScreenState();
// // }
// //
// // class _PtwReviewSdoScreenState extends State<PtwReviewSdoScreen> {
// //   int _selectedTab = 0;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final controller = Get.find<PtwReviewSdoController>();
// //     final args = Get.arguments ?? {};
// //
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F7FA),
// //       body: Obx(() {
// //         final userRole =
// //             (args['user_role'] as String? ?? controller.currentUserRole.value)
// //                 .trim()
// //                 .toUpperCase();
// //         final type = controller.ptwData['type']?.toString().toUpperCase() ?? '';
// //         final status = controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
// //        print('THE STATUS $status');
// //         final title = 'PTW Review';
// //
// //         return MainLayout(
// //           title: title,
// //           child: controller.isLoading.value
// //               ? _buildShimmerLoading()
// //               : Column(
// //                   children: [
// //                     Expanded(
// //                       child: SingleChildScrollView(
// //                         child: Column(
// //                           children: [
// //                             // Hero Status Header
// //                             _buildHeroHeader(controller, userRole),
// //
// //                             // Quick Stats Grid
// //                             _buildQuickStats(controller),
// //
// //                             const SizedBox(height: 20),
// //
// //                             // Tab Headers (Non-sticky)
// //                             Container(
// //                               margin: const EdgeInsets.symmetric(
// //                                 horizontal: 16,
// //                               ),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.white,
// //                                 borderRadius: BorderRadius.circular(16),
// //                                 boxShadow: [
// //                                   BoxShadow(
// //                                     color: Colors.black.withValues(alpha: 0.04),
// //                                     blurRadius: 10,
// //                                     offset: const Offset(0, 4),
// //                                   ),
// //                                 ],
// //                               ),
// //                               child: Row(
// //                                 children: [
// //                                   _buildTabButton('Details', 0),
// //                                   _buildTabButton('Team', 1),
// //                                   // if(type !='PLANNED')
// //                                   _buildTabButton('Checklist', 2),
// //                                   _buildTabButton('Timeline', 3),
// //                                   _buildTabButton('Evidence', 4),
// //                                   if (userRole == 'PDC' && [
// //                                     'XEN_APPROVED_TO_PDC',
// //                                     'LS_RESUBMIT_TO_PDC',
// //                                     'PTW_ISSUED',
// //                                     'RE_SUBMITTED_TO_PDC'
// //                                   ].contains(status))
// //                                     _buildTabButton('Task', 5),
// //                                 ],
// //                               ),
// //                             ),
// //
// //                             const SizedBox(height: 16),
// //
// //                             // Tab Content
// //                             _buildTabContent(controller),
// //                             const SizedBox(height: 24),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //         );
// //       }),
// //     );
// //   }
// //   Widget _buildFeederStatusSection(PtwReviewSdoController controller) {
// //     final args = Get.arguments ?? {};
// //     final userRole =
// //         ((args['user_role'] ?? controller.currentUserRole.value)
// //             ?.toString()
// //             .trim()
// //             .toUpperCase()) ??
// //             'LS';
// //
// //     final status = controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
// //     // ✅ Check if we need to show feeder management section
// //     final showFeederManagement = status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC';
// //
// //     // ✅ Check if we need to show decision notes (only for main decision statuses)
// //     final showDecisionNotes = status == 'XEN_APPROVED_TO_PDC' || status == 'LS_RESUBMIT_TO_PDC';
// //
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withValues(alpha: 0.04),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // ✅ HEADER
// //             Row(
// //               children: [
// //                 Container(
// //                   padding: const EdgeInsets.all(8),
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: Icon(
// //                     showFeederManagement
// //                         ? Icons.power_settings_new_rounded
// //                         : Icons.assignment_rounded,
// //                     color: const Color(0xFF6A1B9A),
// //                     size: 20,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Text(
// //                   showFeederManagement
// //                       ? 'Feeder Status Confirmation'
// //                       : 'PTW Decision',
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black87,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 20),
// //
// //             // ✅ FEEDER MANAGEMENT SECTION (Only for PTW_ISSUED / RE_SUBMITTED_TO_PDC)
// //             if (showFeederManagement) ...[
// //               const Text(
// //                 'Manage Feeders',
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   color: Colors.black54,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //               const SizedBox(height: 12),
// //
// //               Obx(() => InkWell(
// //                 onTap: () {
// //                   _showFeederSelectionDialog(Get.context!, controller);
// //                 },
// //                 child: Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //                   decoration: BoxDecoration(
// //                     color: Colors.grey.shade50,
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(
// //                       color: controller.turnedOffFeeders.isEmpty
// //                           ? Colors.grey.shade300
// //                           : Colors.orange.shade300,
// //                       width: controller.turnedOffFeeders.isEmpty ? 1 : 2,
// //                     ),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Icon(
// //                         Icons.power_settings_new,
// //                         color: controller.turnedOffFeeders.isEmpty
// //                             ? Colors.grey.shade400
// //                             : Colors.orange,
// //                         size: 20,
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Text(
// //                           controller.turnedOffFeeders.isEmpty
// //                               ? 'All feeders are ON'
// //                               : '${controller.turnedOffFeeders.length} feeder(s) turned OFF',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             color: controller.turnedOffFeeders.isEmpty
// //                                 ? Colors.grey.shade600
// //                                 : Colors.orange.shade700,
// //                             fontWeight: controller.turnedOffFeeders.isEmpty
// //                                 ? FontWeight.normal
// //                                 : FontWeight.w600,
// //                           ),
// //                         ),
// //                       ),
// //                       Icon(
// //                         Icons.arrow_drop_down,
// //                         color: Colors.grey.shade600,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               )),
// //
// //               // Turned OFF Feeders Chips
// //               Obx(() {
// //                 if (controller.turnedOffFeeders.isEmpty) return const SizedBox.shrink();
// //
// //                 final turnedOffFeedersList = controller.allFeeders
// //                     .where((f) => controller.turnedOffFeeders.contains(f['id']))
// //                     .toList();
// //
// //                 return Container(
// //                   margin: const EdgeInsets.only(top: 12),
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: Colors.orange.withValues(alpha: 0.05),
// //                     borderRadius: BorderRadius.circular(10),
// //                     border: Border.all(
// //                       color: Colors.orange.withValues(alpha: 0.2),
// //                     ),
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           Icon(
// //                             Icons.warning_rounded,
// //                             color: Colors.orange.shade700,
// //                             size: 16,
// //                           ),
// //                           const SizedBox(width: 6),
// //                           Text(
// //                             'Feeders Turned OFF:',
// //                             style: TextStyle(
// //                               fontSize: 12,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.orange.shade700,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 10),
// //                       Wrap(
// //                         spacing: 8,
// //                         runSpacing: 8,
// //                         children: turnedOffFeedersList.map((feeder) {
// //                           final isPrimary = feeder['type'] == 'Primary';
// //                           return Container(
// //                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //                             decoration: BoxDecoration(
// //                               color: Colors.orange.withValues(alpha: 0.1),
// //                               borderRadius: BorderRadius.circular(8),
// //                               border: Border.all(
// //                                 color: Colors.orange.withValues(alpha: 0.3),
// //                               ),
// //                             ),
// //                             child: Row(
// //                               mainAxisSize: MainAxisSize.min,
// //                               children: [
// //                                 Icon(
// //                                   isPrimary ? Icons.star : Icons.electrical_services,
// //                                   size: 14,
// //                                   color: Colors.orange.shade700,
// //                                 ),
// //                                 const SizedBox(width: 6),
// //                                 Text(
// //                                   feeder['name'].toString(),
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: Colors.orange.shade800,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 6),
// //                                 GestureDetector(
// //                                   onTap: () {
// //                                     controller.turnedOffFeeders.remove(feeder['id']);
// //                                     if (controller.turnedOffFeeders.isEmpty) {
// //                                       controller.feederConfirmationConsent.value = false;
// //                                     }
// //                                   },
// //                                   child: Icon(
// //                                     Icons.close,
// //                                     size: 16,
// //                                     color: Colors.orange.shade700,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           );
// //                         }).toList(),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               }),
// //
// //               // Consent Checkbox
// //               Obx(() {
// //                 if (controller.turnedOffFeeders.isEmpty) return const SizedBox.shrink();
// //
// //                 return Container(
// //                   margin: const EdgeInsets.only(top: 16),
// //                   padding: const EdgeInsets.all(14),
// //                   decoration: BoxDecoration(
// //                     color: Colors.orange.shade50,
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(
// //                       color: Colors.orange.shade300,
// //                       width: 1.5,
// //                     ),
// //                   ),
// //                   child: Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Obx(() => InkWell(
// //                         onTap: () {
// //                           controller.feederConfirmationConsent.value =
// //                           !controller.feederConfirmationConsent.value;
// //                         },
// //                         child: Container(
// //                           width: 22,
// //                           height: 22,
// //                           decoration: BoxDecoration(
// //                             color: controller.feederConfirmationConsent.value
// //                                 ? const Color(0xFF6A1B9A)
// //                                 : Colors.white,
// //                             borderRadius: BorderRadius.circular(6),
// //                             border: Border.all(
// //                               color: controller.feederConfirmationConsent.value
// //                                   ? const Color(0xFF6A1B9A)
// //                                   : Colors.grey.shade400,
// //                               width: 2,
// //                             ),
// //                           ),
// //                           child: controller.feederConfirmationConsent.value
// //                               ? const Icon(
// //                             Icons.check,
// //                             size: 16,
// //                             color: Colors.white,
// //                           )
// //                               : null,
// //                         ),
// //                       )),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Text(
// //                           'I have confirmed that the above feeder(s) have been turned OFF and the information provided is accurate',
// //                           style: TextStyle(
// //                             fontSize: 13,
// //                             color: Colors.grey.shade800,
// //                             height: 1.4,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               }),
// //
// //               const SizedBox(height: 24),
// //             ],
// //
// //             // ✅ DECISION NOTES SECTION (Only for XEN_APPROVED_TO_PDC / LS_RESUBMIT_TO_PDC)
// //             if (showDecisionNotes) ...[
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(
// //                     color: const Color(0xFF6A1B9A).withValues(alpha: 0.2),
// //                   ),
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Icon(
// //                           Icons.note_add_rounded,
// //                           color: const Color(0xFF6A1B9A),
// //                           size: 20,
// //                         ),
// //                         const SizedBox(width: 8),
// //                         Text(
// //                           'Decision Notes',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.bold,
// //                             color: const Color(0xFF6A1B9A),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 12),
// //                     CustomTextFormField(
// //                       labelText: 'Enter your decision notes...',
// //                       maxLines: 4,
// //                       controller: controller.decisionNotesController,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
// //             ],
// //
// //             // ✅ ACTION BUTTONS (For ALL PDC statuses)
// //             Obx(() => _buildBottomActions(controller)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //   // ==================== REPLACE YOUR _showFeederSelectionDialog METHOD ====================
// //   void _showFeederSelectionDialog(BuildContext context, PtwReviewSdoController controller) {
// //     // Group feeders by grid station
// //     final Map<String, List<Map<String, dynamic>>> groupedFeeders = {};
// //
// //     for (var feeder in controller.allFeeders) {
// //       final gridName = feeder['grid_name']?.toString() ?? 'Unknown Grid';
// //       final gridCode = feeder['grid_code']?.toString() ?? '';
// //       final operatorName = feeder['operator_name']?.toString() ?? '';
// //       final gridKey = '$gridName|$gridCode|$operatorName';
// //
// //       if (!groupedFeeders.containsKey(gridKey)) {
// //         groupedFeeders[gridKey] = [];
// //       }
// //       groupedFeeders[gridKey]!.add(feeder);
// //     }
// //
// //     // Count total OFF and PENDING feeders
// //     int getTotalOff() => controller.turnedOffFeeders.length;
// //     int getTotalPending() => controller.allFeeders.length - controller.turnedOffFeeders.length;
// //
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext dialogContext) {
// //         return Dialog(
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(20),
// //           ),
// //           child: Container(
// //             constraints: BoxConstraints(
// //               maxHeight: MediaQuery.of(context).size.height * 0.75,
// //               maxWidth: MediaQuery.of(context).size.width * 0.95,
// //             ),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 // ==================== HEADER ====================
// //                 Container(
// //                   padding: const EdgeInsets.all(20),
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       colors: [
// //                         const Color(0xFF6A1B9A),
// //                         const Color(0xFF6A1B9A).withValues(alpha: 0.8),
// //                       ],
// //                     ),
// //                     borderRadius: const BorderRadius.only(
// //                       topLeft: Radius.circular(20),
// //                       topRight: Radius.circular(20),
// //                     ),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       Row(
// //                         children: [
// //                           Container(
// //                             padding: const EdgeInsets.all(10),
// //                             decoration: BoxDecoration(
// //                               color: Colors.white.withValues(alpha: 0.2),
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: const Icon(
// //                               Icons.power_settings_new,
// //                               color: Colors.white,
// //                               size: 24,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           const Expanded(
// //                             child: Text(
// //                               'Feeder Status Confirmation',
// //                               style: TextStyle(
// //                                 fontSize: 18,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 16),
// //                       // Status badges
// //                       Obx(() => Row(
// //                         children: [
// //                           // OFF Badge
// //                           Expanded(
// //                             child: Container(
// //                               padding: const EdgeInsets.symmetric(vertical: 8),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.orange.withValues(alpha: 0.2),
// //                                 borderRadius: BorderRadius.circular(10),
// //                                 border: Border.all(
// //                                   color: Colors.orange.withValues(alpha: 0.5),
// //                                 ),
// //                               ),
// //                               child: Column(
// //                                 children: [
// //                                   Text(
// //                                     '${getTotalOff()}',
// //                                     style: const TextStyle(
// //                                       fontSize: 24,
// //                                       fontWeight: FontWeight.bold,
// //                                       color: Colors.white,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 2),
// //                                   const Text(
// //                                     'OFF',
// //                                     style: TextStyle(
// //                                       fontSize: 10,
// //                                       fontWeight: FontWeight.w600,
// //                                       color: Colors.white70,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           // PENDING Badge
// //                           Expanded(
// //                             child: Container(
// //                               padding: const EdgeInsets.symmetric(vertical: 8),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.green.withValues(alpha: 0.2),
// //                                 borderRadius: BorderRadius.circular(10),
// //                                 border: Border.all(
// //                                   color: Colors.green.withValues(alpha: 0.5),
// //                                 ),
// //                               ),
// //                               child: Column(
// //                                 children: [
// //                                   Text(
// //                                     '${getTotalPending()}',
// //                                     style: const TextStyle(
// //                                       fontSize: 24,
// //                                       fontWeight: FontWeight.bold,
// //                                       color: Colors.white,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 2),
// //                                   const Text(
// //                                     'PENDING',
// //                                     style: TextStyle(
// //                                       fontSize: 10,
// //                                       fontWeight: FontWeight.w600,
// //                                       color: Colors.white70,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           // TOTAL Badge
// //                           Expanded(
// //                             child: Container(
// //                               padding: const EdgeInsets.symmetric(vertical: 8),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.white.withValues(alpha: 0.2),
// //                                 borderRadius: BorderRadius.circular(10),
// //                                 border: Border.all(
// //                                   color: Colors.white.withValues(alpha: 0.5),
// //                                 ),
// //                               ),
// //                               child: Column(
// //                                 children: [
// //                                   Text(
// //                                     '${controller.allFeeders.length}',
// //                                     style: const TextStyle(
// //                                       fontSize: 24,
// //                                       fontWeight: FontWeight.bold,
// //                                       color: Colors.white,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 2),
// //                                   const Text(
// //                                     'TOTAL',
// //                                     style: TextStyle(
// //                                       fontSize: 10,
// //                                       fontWeight: FontWeight.w600,
// //                                       color: Colors.white70,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       )),
// //                     ],
// //                   ),
// //                 ),
// //
// //                 // ==================== FEEDERS LIST BY GRID ====================
// //                 Flexible(
// //                   child: ListView.builder(
// //                     shrinkWrap: true,
// //                     itemCount: groupedFeeders.keys.length,
// //                     itemBuilder: (context, gridIndex) {
// //                       final gridKey = groupedFeeders.keys.elementAt(gridIndex);
// //                       final parts = gridKey.split('|');
// //                       final gridName = parts[0];
// //                       final gridCode = parts[1];
// //                       final operatorName = parts.length > 2 ? parts[2] : '';
// //                       final feeders = groupedFeeders[gridKey]!;
// //
// //                       // Count OFF and PENDING for this grid
// //                       final offCount = feeders.where((f) =>
// //                           controller.turnedOffFeeders.contains(f['id'])
// //                       ).length;
// //                       final pendingCount = feeders.length - offCount;
// //
// //                       return Container(
// //                         margin: const EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 8,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(16),
// //                           border: Border.all(
// //                             color: Colors.grey.shade200,
// //                           ),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withValues(alpha: 0.05),
// //                               blurRadius: 8,
// //                               offset: const Offset(0, 2),
// //                             ),
// //                           ],
// //                         ),
// //                         child: Column(
// //                           children: [
// //                             // Grid Header
// //                             Container(
// //                               padding: const EdgeInsets.all(14),
// //                               decoration: BoxDecoration(
// //                                 color: const Color(0xFF6A1B9A).withValues(alpha: 0.05),
// //                                 borderRadius: const BorderRadius.only(
// //                                   topLeft: Radius.circular(16),
// //                                   topRight: Radius.circular(16),
// //                                 ),
// //                               ),
// //                               child: Row(
// //                                 children: [
// //                                   Container(
// //                                     padding: const EdgeInsets.all(8),
// //                                     decoration: BoxDecoration(
// //                                       color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
// //                                       borderRadius: BorderRadius.circular(8),
// //                                     ),
// //                                     child: const Icon(
// //                                       Icons.grid_view_rounded,
// //                                       size: 18,
// //                                       color: Color(0xFF6A1B9A),
// //                                     ),
// //                                   ),
// //                                   const SizedBox(width: 10),
// //                                   Expanded(
// //                                     child: Column(
// //                                       crossAxisAlignment: CrossAxisAlignment.start,
// //                                       children: [
// //                                         Text(
// //                                           gridName,
// //                                           style: const TextStyle(
// //                                             fontSize: 14,
// //                                             fontWeight: FontWeight.bold,
// //                                             color: Colors.black87,
// //                                           ),
// //                                         ),
// //                                         if (gridCode.isNotEmpty)
// //                                           Text(
// //                                             'Code: $gridCode',
// //                                             style: TextStyle(
// //                                               fontSize: 11,
// //                                               color: Colors.grey.shade600,
// //                                             ),
// //                                           ),
// //                                         if (operatorName.isNotEmpty)
// //                                           Row(
// //                                             children: [
// //                                               Icon(
// //                                                 Icons.person_outline,
// //                                                 size: 12,
// //                                                 color: Colors.grey.shade600,
// //                                               ),
// //                                               const SizedBox(width: 4),
// //                                               Expanded(
// //                                                 child: Text(
// //                                                   operatorName,
// //                                                   style: TextStyle(
// //                                                     fontSize: 11,
// //                                                     color: Colors.grey.shade600,
// //                                                     fontStyle: FontStyle.italic,
// //                                                   ),
// //                                                   overflow: TextOverflow.ellipsis,
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                   // Grid status badges
// //                                   Container(
// //                                     padding: const EdgeInsets.symmetric(
// //                                       horizontal: 8,
// //                                       vertical: 4,
// //                                     ),
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.orange.withValues(alpha: 0.15),
// //                                       borderRadius: BorderRadius.circular(6),
// //                                     ),
// //                                     child: Text(
// //                                       '$offCount OFF',
// //                                       style: const TextStyle(
// //                                         fontSize: 10,
// //                                         fontWeight: FontWeight.bold,
// //                                         color: Colors.orange,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   const SizedBox(width: 6),
// //                                   Container(
// //                                     padding: const EdgeInsets.symmetric(
// //                                       horizontal: 8,
// //                                       vertical: 4,
// //                                     ),
// //                                     decoration: BoxDecoration(
// //                                       color: Colors.green.withValues(alpha: 0.15),
// //                                       borderRadius: BorderRadius.circular(6),
// //                                     ),
// //                                     child: Text(
// //                                       '$pendingCount ON',
// //                                       style: const TextStyle(
// //                                         fontSize: 10,
// //                                         fontWeight: FontWeight.bold,
// //                                         color: Colors.green,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //
// //                             // Feeders in this grid
// //                             ...feeders.map((feeder) {
// //                               final feederId = feeder['id'] as int;
// //                               final isPrimary = feeder['type'] == 'Primary';
// //
// //                               return Obx(() {
// //                                 final isOff = controller.turnedOffFeeders.contains(feederId);
// //
// //                                 return InkWell(
// //                                   onTap: () {
// //                                     if (isOff) {
// //                                       // Turn ON (remove from turnedOffFeeders)
// //                                       controller.turnedOffFeeders.remove(feederId);
// //                                       if (controller.turnedOffFeeders.isEmpty) {
// //                                         controller.feederConfirmationConsent.value = false;
// //                                       }
// //                                     } else {
// //                                       // Turn OFF (add to turnedOffFeeders)
// //                                       controller.turnedOffFeeders.add(feederId);
// //                                     }
// //                                   },
// //                                   child: Container(
// //                                     padding: const EdgeInsets.symmetric(
// //                                       horizontal: 16,
// //                                       vertical: 12,
// //                                     ),
// //                                     decoration: BoxDecoration(
// //                                       color: isOff
// //                                           ? Colors.orange.withValues(alpha: 0.05)
// //                                           : Colors.green.withValues(alpha: 0.05),
// //                                       border: Border(
// //                                         bottom: BorderSide(
// //                                           color: Colors.grey.shade100,
// //                                           width: 1,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     child: Row(
// //                                       children: [
// //                                         // Toggle Switch
// //                                         AnimatedContainer(
// //                                           duration: const Duration(milliseconds: 250),
// //                                           width: 44,
// //                                           height: 24,
// //                                           decoration: BoxDecoration(
// //                                             color: isOff
// //                                                 ? Colors.orange.shade600
// //                                                 : Colors.green.shade600,
// //                                             borderRadius: BorderRadius.circular(12),
// //                                           ),
// //                                           child: Stack(
// //                                             children: [
// //                                               AnimatedPositioned(
// //                                                 duration: const Duration(milliseconds: 250),
// //                                                 curve: Curves.easeInOut,
// //                                                 left: isOff ? 2 : 22,
// //                                                 top: 2,
// //                                                 child: Container(
// //                                                   width: 20,
// //                                                   height: 20,
// //                                                   decoration: BoxDecoration(
// //                                                     color: Colors.white,
// //                                                     shape: BoxShape.circle,
// //                                                     boxShadow: [
// //                                                       BoxShadow(
// //                                                         color: Colors.black.withValues(alpha: 0.2),
// //                                                         blurRadius: 3,
// //                                                         offset: const Offset(0, 1),
// //                                                       ),
// //                                                     ],
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                         const SizedBox(width: 14),
// //
// //                                         // Feeder Type Icon
// //                                         Container(
// //                                           padding: const EdgeInsets.all(8),
// //                                           decoration: BoxDecoration(
// //                                             color: isPrimary
// //                                                 ? Colors.orange.withValues(alpha: 0.15)
// //                                                 : Colors.blue.withValues(alpha: 0.15),
// //                                             borderRadius: BorderRadius.circular(8),
// //                                           ),
// //                                           child: Icon(
// //                                             isPrimary ? Icons.star : Icons.electrical_services,
// //                                             size: 16,
// //                                             color: isPrimary ? Colors.orange : Colors.blue,
// //                                           ),
// //                                         ),
// //                                         const SizedBox(width: 12),
// //
// //                                         // Feeder Details
// //                                         Expanded(
// //                                           child: Column(
// //                                             crossAxisAlignment: CrossAxisAlignment.start,
// //                                             children: [
// //                                               Text(
// //                                                 feeder['name'].toString(),
// //                                                 style: const TextStyle(
// //                                                   fontSize: 14,
// //                                                   fontWeight: FontWeight.w600,
// //                                                   color: Colors.black87,
// //                                                 ),
// //                                               ),
// //                                               const SizedBox(height: 2),
// //                                               Row(
// //                                                 children: [
// //                                                   Container(
// //                                                     padding: const EdgeInsets.symmetric(
// //                                                       horizontal: 6,
// //                                                       vertical: 2,
// //                                                     ),
// //                                                     decoration: BoxDecoration(
// //                                                       color: isPrimary
// //                                                           ? Colors.orange.withValues(alpha: 0.2)
// //                                                           : Colors.blue.withValues(alpha: 0.2),
// //                                                       borderRadius: BorderRadius.circular(4),
// //                                                     ),
// //                                                     child: Text(
// //                                                       feeder['type'].toString().toUpperCase(),
// //                                                       style: TextStyle(
// //                                                         fontSize: 9,
// //                                                         fontWeight: FontWeight.bold,
// //                                                         color: isPrimary ? Colors.orange : Colors.blue,
// //                                                       ),
// //                                                     ),
// //                                                   ),
// //                                                   const SizedBox(width: 6),
// //                                                   Text(
// //                                                     'Code: ${feeder['code']}',
// //                                                     style: TextStyle(
// //                                                       fontSize: 11,
// //                                                       color: Colors.grey.shade600,
// //                                                     ),
// //                                                   ),
// //                                                 ],
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //
// //                                         // Status Badge
// //                                         // Container(
// //                                         //   padding: const EdgeInsets.symmetric(
// //                                         //     horizontal: 10,
// //                                         //     vertical: 5,
// //                                         //   ),
// //                                         //   decoration: BoxDecoration(
// //                                         //     color: isOff
// //                                         //         ? Colors.orange.withValues(alpha: 0.15)
// //                                         //         : Colors.green.withValues(alpha: 0.15),
// //                                         //     borderRadius: BorderRadius.circular(8),
// //                                         //   ),
// //                                         //   child: Text(
// //                                         //     isOff ? 'OFF' : 'ON',
// //                                         //     style: TextStyle(
// //                                         //       fontSize: 11,
// //                                         //       fontWeight: FontWeight.bold,
// //                                         //       color: isOff
// //                                         //           ? Colors.orange.shade700
// //                                         //           : Colors.green.shade700,
// //                                         //     ),
// //                                         //   ),
// //                                         // ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 );
// //                               });
// //                             }).toList(),
// //                           ],
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //
// //                 // ==================== FOOTER ====================
// //                 Container(
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     color: Colors.grey.shade50,
// //                     borderRadius: const BorderRadius.only(
// //                       bottomLeft: Radius.circular(20),
// //                       bottomRight: Radius.circular(20),
// //                     ),
// //                     border: Border(
// //                       top: BorderSide(color: Colors.grey.shade200),
// //                     ),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         child: TextButton(
// //                           onPressed: () {
// //                             // Turn ALL ON
// //                             controller.turnedOffFeeders.clear();
// //                             controller.feederConfirmationConsent.value = false;
// //                           },
// //                           style: TextButton.styleFrom(
// //                             padding: const EdgeInsets.symmetric(vertical: 12),
// //                           ),
// //                           child: const Text(
// //                             'Turn All ON',
// //                             style: TextStyle(
// //                               color: Colors.green,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         flex: 2,
// //                         child: ElevatedButton(
// //                           onPressed: () {
// //                             Navigator.of(dialogContext).pop();
// //                           },
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: const Color(0xFF6A1B9A),
// //                             padding: const EdgeInsets.symmetric(vertical: 12),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                             ),
// //                           ),
// //                           child: Obx(() => Text(
// //                             controller.turnedOffFeeders.isEmpty
// //                                 ? 'Done'
// //                                 : 'Confirm (${controller.turnedOffFeeders.length} OFF)',
// //                             style: const TextStyle(
// //                               color: Colors.white,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           )),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //   Widget _buildTabContent(PtwReviewSdoController controller) {
// //     final args = Get.arguments ?? {};
// //     final userRole = ((args['user_role'] ?? controller.currentUserRole.value) ?? 'LS')
// //         .toString()
// //         .trim()
// //         .toUpperCase();
// //     final status = controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
// //
// //     switch (_selectedTab) {
// //       case 0:
// //         return _buildDetailsTab(controller);
// //       case 1:
// //         return _buildTeamTab(controller);
// //       case 2:
// //         return _buildSafetyTab(context, controller);
// //       case 3:
// //         return _buildTimelineTab(controller);
// //       case 4:
// //         return _buildAttachmentsContent(context, controller);
// //       case 5:
// //       // ✅ Task tab - Only for PDC with specific statuses
// //         return _buildFeederStatusSection(controller);
// //       default:
// //         return const SizedBox.shrink();
// //     }
// //   }
// //   Widget _buildAttachmentsContent(
// //     BuildContext context,
// //     PtwReviewSdoController controller,
// //    ) {
// //     final ptw = controller.ptwData;
// //     final evidences = ptw['evidences'] as List? ?? [];
// //
// //     if (evidences.isEmpty) {
// //       return const Padding(
// //         padding: EdgeInsets.all(16.0),
// //         child: Center(child: Text('No attachments available')),
// //       );
// //     }
// //
// //     /// --- GROUP EVIDENCES BY TYPE ---
// //     Map<String, List<Map<String, dynamic>>> grouped = {};
// //
// //     for (var e in evidences) {
// //       final type = (e['type'] ?? 'OTHER').toString().trim();
// //       if (!grouped.containsKey(type)) grouped[type] = [];
// //       grouped[type]!.add(e as Map<String, dynamic>);
// //     }
// //
// //     /// --- NICE LABELS FROM TYPE NAMES ---
// //     String formatType(String t) {
// //       return t
// //           .replaceAll('_', ' ')
// //           .toLowerCase()
// //           .split(' ')
// //           .map((w) {
// //             if (w.isEmpty) return w;
// //             return w[0].toUpperCase() + w.substring(1);
// //           })
// //           .join(' ');
// //     }
// //
// //     return Padding(
// //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
// //       child: Column(
// //         children: grouped.entries.map((entry) {
// //           final type = entry.key;
// //           final items = entry.value;
// //
// //           return Card(
// //             elevation: 2,
// //             color: const Color(0xFFF5F5F5),
// //             shadowColor: Colors.black12,
// //             margin: const EdgeInsets.only(bottom: 16),
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(12),
// //               side: BorderSide(color: Colors.transparent),
// //             ),
// //
// //             child: Theme(
// //               // 🔥 Remove ExpansionTile horizontal lines
// //               data: Theme.of(
// //                 context,
// //               ).copyWith(dividerColor: Colors.transparent),
// //
// //               child: ExpansionTile(
// //                 initiallyExpanded: false,
// //
// //                 title: Text(
// //                   formatType(type),
// //                   style: const TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black87,
// //                   ),
// //                 ),
// //
// //                 children: [
// //                   Padding(
// //                     padding: const EdgeInsets.all(12.0),
// //                     child: GridView.builder(
// //                       shrinkWrap: true,
// //                       physics: const NeverScrollableScrollPhysics(),
// //                       itemCount: items.length,
// //                       gridDelegate:
// //                           const SliverGridDelegateWithFixedCrossAxisCount(
// //                             crossAxisCount: 3,
// //                             crossAxisSpacing: 10,
// //                             mainAxisSpacing: 10,
// //                             childAspectRatio: 4 / 3,
// //                           ),
// //                       itemBuilder: (context, index) {
// //                         final e = items[index];
// //                         final filePath = e['file_path']?.toString() ?? '';
// //
// //                         if (filePath.isEmpty) return const SizedBox.shrink();
// //
// //                         final imageUrl =
// //                             'http://mepco.myflexihr.com/storage/$filePath';
// //
// //                         return GestureDetector(
// //                           onTap: () {
// //                             showDialog(
// //                               context: context,
// //                               builder: (_) => Dialog(
// //                                 backgroundColor: Colors.transparent,
// //                                 insetPadding: EdgeInsets.zero,
// //                                 child: Stack(
// //                                   alignment: Alignment.center,
// //                                   children: [
// //                                     // Close background tap
// //                                     GestureDetector(
// //                                       onTap: () => Navigator.pop(context),
// //                                       child: Container(color: Colors.black54),
// //                                     ),
// //
// //                                     // Image preview with LONG PRESS
// //                                     InteractiveViewer(
// //                                       child: GestureDetector(
// //                                         onLongPress: () {
// //                                           showModalBottomSheet(
// //                                             context: context,
// //                                             shape: const RoundedRectangleBorder(
// //                                               borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
// //                                             ),
// //                                             builder: (_) {
// //                                               return Padding(
// //                                                 padding: const EdgeInsets.all(16),
// //                                                 child: Wrap(
// //                                                   children: [
// //                                                     // SHARE
// //                                                     ListTile(
// //                                                       leading: const Icon(Icons.share, color: Color(0xFF0D47A1)),
// //                                                       title: const Text('Share'),
// //                                                       onTap: () async {
// //                                                         Navigator.pop(context);
// //
// //                                                         Get.snackbar(
// //                                                           'Please wait',
// //                                                           'Preparing image to share...',
// //                                                           snackPosition: SnackPosition.TOP,
// //                                                           backgroundColor: Colors.orange,
// //                                                           colorText: Colors.white,
// //                                                         );
// //
// //                                                         final response = await http.get(Uri.parse(imageUrl));
// //                                                         final tempDir = await getTemporaryDirectory();
// //                                                         final file = File(
// //                                                           '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
// //                                                         );
// //                                                         await file.writeAsBytes(response.bodyBytes);
// //
// //                                                         Share.shareXFiles([XFile(file.path)]);
// //                                                       },
// //                                                     ),
// //
// //                                                     // SAVE
// //                                                     ListTile(
// //                                                       leading: const Icon(Icons.download, color: Color(0xFF0D47A1)),
// //                                                       title: const Text('Save to Gallery'),
// //                                                       onTap: () async {
// //                                                         Navigator.pop(context);
// //
// //                                                         // 🔔 show feedback immediately
// //                                                         Get.snackbar(
// //                                                           'Saving',
// //                                                           'Saving image to gallery...',
// //                                                           backgroundColor: Colors.orange,
// //                                                           colorText: Colors.white,
// //                                                           snackPosition: SnackPosition.BOTTOM,
// //                                                           duration: const Duration(seconds: 2),
// //                                                         );
// //
// //                                                         try {
// //                                                           final response = await http.get(Uri.parse(imageUrl));
// //                                                           final tempDir = await getTemporaryDirectory();
// //                                                           final file = File(
// //                                                             '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
// //                                                           );
// //                                                           await file.writeAsBytes(response.bodyBytes);
// //
// //                                                           final hasAccess = await Gal.hasAccess();
// //                                                           if (!hasAccess) {
// //                                                             await Gal.requestAccess();
// //                                                           }
// //                                                           await Gal.putImage(file.path);
// //
// //                                                           // ✅ success snackbar
// //                                                           SnackbarHelper.showSuccess(
// //                                                             title: 'Success',
// //                                                             message: 'Image saved to gallery',
// //                                                           );
// //                                                         } catch (e) {
// //                                                           SnackbarHelper.showError(
// //                                                             title: 'Error',
// //                                                             message: 'Failed to save image: $e',
// //                                                           );
// //                                                         }
// //                                                       },
// //
// //
// //                                                     ),
// //                                                   ],
// //                                                 ),
// //                                               );
// //                                             },
// //                                           );
// //                                         },
// //                                         child: Image.network(
// //                                           imageUrl,
// //                                           fit: BoxFit.contain,
// //                                           loadingBuilder: (context, child, progress) {
// //                                             if (progress == null) return child;
// //                                             return const CircularProgressIndicator(color: Colors.white);
// //                                           },
// //                                         ),
// //                                       ),
// //                                     ),
// //
// //                                     // Close button
// //                                     Positioned(
// //                                       top: 40,
// //                                       right: 20,
// //                                       child: IconButton(
// //                                         icon: const Icon(Icons.close, color: Colors.white, size: 30),
// //                                         onPressed: () => Navigator.pop(context),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //
// //
// //
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.stretch,
// //                             children: [
// //                               Expanded(
// //                                 child: ClipRRect(
// //                                   borderRadius: BorderRadius.circular(8),
// //                                   child: Image.network(
// //                                     imageUrl,
// //                                     fit: BoxFit.cover,
// //                                     loadingBuilder: (context, child, progress) {
// //                                       if (progress == null) return child;
// //                                       return Container(
// //                                         color: Colors.grey[200],
// //                                         child: const Center(
// //                                           child: CircularProgressIndicator(
// //                                             strokeWidth: 2,
// //                                           ),
// //                                         ),
// //                                       );
// //                                     },
// //                                     errorBuilder: (context, error, _) {
// //                                       return Container(
// //                                         color: Colors.grey[200],
// //                                         child: const Icon(
// //                                           Icons.error,
// //                                           color: Colors.red,
// //                                         ),
// //                                       );
// //                                     },
// //                                   ),
// //                                 ),
// //                               ),
// //
// //                               const SizedBox(height: 6),
// //
// //                               Text(
// //                                 "ID: ${e['id']}",
// //                                 maxLines: 1,
// //                                 overflow: TextOverflow.ellipsis,
// //                                 textAlign: TextAlign.center,
// //                                 style: const TextStyle(
// //                                   fontSize: 12,
// //                                   fontWeight: FontWeight.w500,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTabButton(String text, int index) {
// //     final isSelected = _selectedTab == index;
// //     return Expanded(
// //       child: GestureDetector(
// //         onTap: () => setState(() => _selectedTab = index),
// //         child: Container(
// //           padding: const EdgeInsets.symmetric(vertical: 12),
// //           margin: const EdgeInsets.all(4),
// //           decoration: BoxDecoration(
// //             color: isSelected ? AppColors.primaryBlue : Colors.transparent,
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Text(
// //             text,
// //             textAlign: TextAlign.center,
// //             style: TextStyle(
// //               color: isSelected ? Colors.white : Colors.black54,
// //               fontWeight: FontWeight.bold,
// //               fontSize: 11,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ==================== HERO HEADER ====================
// //   Widget _buildHeroHeader(PtwReviewSdoController controller, String userRole) {
// //     final ptw = controller.ptwData;
// //     final status = PtwHelper.getStatusText(_str(ptw['current_status']));
// //     final statusColor = PtwHelper.getStatusColor(_str(ptw['current_status']));
// //     final type = _str(ptw['type']);
// //     final ptwCode = _str(ptw['ptw_code']);
// //     final miscCode = _str(ptw['misc_code']);
// //     print("MISCCODE: $miscCode");
// //     return Container(
// //       margin: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [statusColor, statusColor.withValues(alpha: 0.7)],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [
// //           BoxShadow(
// //             color: statusColor.withValues(alpha: 0.3),
// //             blurRadius: 20,
// //             offset: const Offset(0, 8),
// //           ),
// //         ],
// //       ),
// //       child: Stack(
// //         children: [
// //           // Decorative circles
// //           Positioned(
// //             right: -20,
// //             top: -20,
// //             child: Container(
// //               width: 100,
// //               height: 100,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: Colors.white.withValues(alpha:0.1),
// //               ),
// //             ),
// //           ),
// //           Positioned(
// //             left: -30,
// //             bottom: -30,
// //             child: Container(
// //               width: 120,
// //               height: 120,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: Colors.white.withValues(alpha:0.05),
// //               ),
// //             ),
// //           ),
// //
// //           // Content
// //           Padding(
// //             padding: const EdgeInsets.all(20),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Wrap(
// //                   children: [
// //             Text(
// //             (ptwCode.isEmpty || ptwCode == '—') ? miscCode : ptwCode,
// //             style: const TextStyle(
// //               color: Colors.white,
// //               fontSize: 17,
// //               fontWeight: FontWeight.bold,
// //               letterSpacing: 0.5,
// //             ),
// //           ),
// //                     SizedBox(width: 8),
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 12,
// //                         vertical: 6,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white.withValues(alpha:0.25),
// //                         borderRadius: BorderRadius.circular(20),
// //                       ),
// //                       child: Text(
// //                         status,
// //                         style: const TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 10,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 3),
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 12,
// //                         vertical: 6,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white.withValues(alpha:0.25),
// //                         borderRadius: BorderRadius.circular(20),
// //                       ),
// //                       child: Text(
// //                         type,
// //                         style: const TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.w600,
// //                           fontSize: 10,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 const SizedBox(height: 8),
// //                 Row(
// //                   children: [
// //                     const Icon(Icons.person, color: Colors.white70, size: 16),
// //                     const SizedBox(width: 6),
// //                     Text(
// //                       'Reviewing as $userRole',
// //                       style: const TextStyle(
// //                         color: Colors.white70,
// //                         fontSize: 13,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ==================== QUICK STATS ====================
// //   Widget _buildQuickStats(PtwReviewSdoController controller) {
// //     final ptw = controller.ptwData;
// //     final team = (ptw['team_members'] as List?) ?? [];
// //     final checklists = controller.checklists;
// //     final evidences = (ptw['evidences'] as List?) ?? [];
// //
// //     int totalChecks = 0;
// //     checklists.forEach((key, value) {
// //       totalChecks +=
// //           ((value as List?)
// //               ?.where((it) => _str(it['value']).toUpperCase() == 'YES')
// //               .length ??
// //           0);
// //     });
// //
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: _buildStatCard(
// //               icon: Icons.groups_rounded,
// //               value: '${team.length}',
// //               label: 'Team',
// //               color: const Color(0xFF6C63FF),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: _buildStatCard(
// //               icon: Icons.check_circle_rounded,
// //               value: '$totalChecks',
// //               label: 'Checks',
// //               color: const Color(0xFF00D4AA),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: _buildStatCard(
// //               icon: Icons.attach_file_rounded,
// //               value: '${evidences.length}',
// //               label: 'Files',
// //               color: const Color(0xFFFF6B9D),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatCard({
// //     required IconData icon,
// //     required String value,
// //     required String label,
// //     required Color color,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withValues(alpha:0.04),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(7),
// //             decoration: BoxDecoration(
// //               color: color.withValues(alpha:0.1),
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //             child: Icon(icon, color: color, size: 24),
// //           ),
// //           const SizedBox(width: 4),
// //           Column(
// //             children: [
// //               Text(
// //                 value,
// //                 style: TextStyle(
// //                   fontSize: 22,
// //                   fontWeight: FontWeight.bold,
// //                   color: color,
// //                 ),
// //               ),
// //               SizedBox(width: 8),
// //               Text(
// //                 label,
// //                 style: const TextStyle(
// //                   fontSize: 10,
// //                   color: Colors.black54,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ==================== TAB 1: DETAILS ====================
// //   Widget _buildDetailsTab(PtwReviewSdoController controller) {
// //     if (_selectedTab != 0) return const SizedBox.shrink();
// //
// //     final ptw = controller.ptwData;
// //     final type = _str(ptw['type']).toUpperCase();
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16),
// //       child: Column(
// //         children: [
// //           _buildInfoSection(
// //             title: 'Basic Information',
// //             icon: Icons.info_outline_rounded,
// //             color: const Color(0xFF6C63FF),
// //             items: [
// //               {'label': 'Work Order', 'value': _str(ptw['work_order_no'])},
// //               // if(type != 'PLANNED')
// //               {
// //                 'label': 'Duration',
// //                 'value': '${ptw['estimated_duration_min'] ?? '—'} min',
// //               },
// //               {'label': 'LS', 'value': _str(ptw['ls_name'] ?? ptw['ls_id'])},
// //               {
// //                 'label': 'Sub-Division',
// //                 'value': _str(ptw['sub_division'] ?? ptw['sub_division_name']),
// //               },
// //             ],
// //           ),
// //           const SizedBox(height: 16),
// //
// //           _buildInfoSection(
// //             title: 'Technical Details',
// //             icon: Icons.engineering_rounded,
// //             color: const Color(0xFFFF6B9D),
// //             items: [
// //               // Primary Feeders
// //               ...(() {
// //                 final primaryFeeders = ptw['primary_feeders'] as Map<String, dynamic>?;
// //                 if (primaryFeeders == null || primaryFeeders.isEmpty) {
// //                   return [
// //                     {'label': 'Primary Feeders', 'value': '—'},
// //                   ];
// //                 }
// //
// //                 final List<Map<String, dynamic>> items = [];
// //
// //                 primaryFeeders.forEach((gridId, gridData) {
// //                   final gridCode = _str(gridData['grid_code']);
// //                   // final operatorName = _str(gridData['operator']?['name']);
// //                   final feeders = gridData['feeders']?['primary'] as List?;
// //
// //                   if (feeders != null && feeders.isNotEmpty) {
// //                     final feederNames = feeders
// //                         .map((f) => '${_str(f['name'])} (${_str(f['code'])})')
// //                         .join(', ');
// //
// //                     items.add({
// //                       'label': 'Primary Feeders',
// //                       'value': feederNames,
// //                       'sublabel': 'Grid: $gridCode ',
// //                       'full': true,
// //                     });
// //                   }
// //                 });
// //
// //                 return items.isEmpty ? [{'label': 'Primary Feeders', 'value': '—'}] : items;
// //               })(),
// //
// //               const SizedBox(height: 8),
// //
// //               // Secondary Feeders
// //               ...(() {
// //                 final primaryFeeders = ptw['primary_feeders'] as Map<String, dynamic>?;
// //                 if (primaryFeeders == null || primaryFeeders.isEmpty) return [];
// //
// //                 final List<Map<String, dynamic>> items = [];
// //
// //                 primaryFeeders.forEach((gridId, gridData) {
// //                   final gridCode = _str(gridData['grid_code']);
// //                   // final operatorName = _str(gridData['operator']?['name']);
// //                   final feeders = gridData['feeders']?['secondary'] as List?;
// //
// //                   if (feeders != null && feeders.isNotEmpty) {
// //                     final feederNames = feeders
// //                         .map((f) => '${_str(f['name'])} (${_str(f['code'])})')
// //                         .join(', ');
// //
// //                     items.add({
// //                       'label': 'Secondary Feeders',
// //                       'value': feederNames,
// //                       'sublabel': 'Grid: $gridCode ',
// //                       'full': true,
// //                     });
// //                   }
// //                 });
// //
// //                 return items;
// //               })(),
// //
// //               const SizedBox(height: 12),
// //
// //               {'label': 'Transformer', 'value': _str(ptw['transformer_name'])},
// //               {
// //                 'label': 'Feeder Incharge',
// //                 'value': _str(ptw['feeder_incharge_name']),
// //               },
// //             ],
// //           ),
// //           const SizedBox(height: 16),
// //           _buildInfoSection(
// //             title: 'Work Location & Scope',
// //             icon: Icons.location_on_rounded,
// //             color: const Color(0xFF00D4AA),
// //             items: [
// //               {
// //                 'label': 'Place of Work',
// //                 'value': _str(ptw['place_of_work']),
// //                 'full': true,
// //               },
// //               {
// //                 'label': 'Scope of Work',
// //                 'value': _str(ptw['scope_of_work']),
// //                 'full': true,
// //               },
// //               {
// //                 'label': 'Safety Arrangements',
// //                 'value': _str(ptw['safety_arrangements']),
// //                 'full': true,
// //               },
// //             ],
// //           ),
// //           const SizedBox(height: 16),
// //           // ✅ UPDATED SCHEDULE SECTION
// //           _buildScheduleSection(controller, type),
// //         ],
// //       ),
// //     );
// //   }
// //     Widget _buildScheduleSection(PtwReviewSdoController controller, String type) {
// //     final ptw = controller.ptwData;
// //
// //     if (type == 'PLANNED') {
// //       // PLANNED PTW: Show planned_from_date, planned_to_date, and planned_schedule
// //       final plannedFromDate = _str(ptw['planned_from_date']);
// //       final plannedToDate = _str(ptw['planned_to_date']);
// //       final plannedSchedule = (ptw['planned_schedule'] as List?) ?? [];
// //
// //       return Container(
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withValues(alpha: 0.04),
// //               blurRadius: 10,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Header
// //             Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.all(8),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFFFB020).withValues(alpha: 0.1),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: const Icon(
// //                       Icons.schedule_rounded,
// //                       color: Color(0xFFFFB020),
// //                       size: 20,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Text(
// //                     'Schedule',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.black87,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const Divider(height: 1),
// //
// //             // Date Range Section
// //             Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: [
// //                       const Color(0xFFFFB020).withValues(alpha: 0.1),
// //                       const Color(0xFFFFB020).withValues(alpha: 0.05),
// //                     ],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(
// //                     color: const Color(0xFFFFB020).withValues(alpha: 0.2),
// //                   ),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             children: [
// //                               Icon(
// //                                 Icons.calendar_today_rounded,
// //                                 size: 14,
// //                                 color: Colors.grey.shade600,
// //                               ),
// //                               const SizedBox(width: 6),
// //                               Text(
// //                                 'Start Date',
// //                                 style: TextStyle(
// //                                   fontSize: 11,
// //                                   color: Colors.grey.shade600,
// //                                   fontWeight: FontWeight.w600,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 6),
// //                           Text(
// //                             _formatDate(plannedFromDate),
// //                             style: const TextStyle(
// //                               fontSize: 15,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black87,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     Container(
// //                       width: 1,
// //                       height: 40,
// //                       color: const Color(0xFFFFB020).withValues(alpha: 0.3),
// //                     ),
// //                     const SizedBox(width: 16),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             children: [
// //                               Icon(
// //                                 Icons.event_rounded,
// //                                 size: 14,
// //                                 color: Colors.grey.shade600,
// //                               ),
// //                               const SizedBox(width: 6),
// //                               Text(
// //                                 'End Date',
// //                                 style: TextStyle(
// //                                   fontSize: 11,
// //                                   color: Colors.grey.shade600,
// //                                   fontWeight: FontWeight.w600,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 6),
// //                           Text(
// //                             _formatDate(plannedToDate),
// //                             style: const TextStyle(
// //                               fontSize: 15,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black87,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //
// //             // Schedule Details
// //             if (plannedSchedule.isNotEmpty) ...[
// //               Padding(
// //                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
// //                 child: Row(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 8,
// //                         vertical: 4,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: const Color(0xFFFFB020).withValues(alpha: 0.15),
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           const Icon(
// //                             Icons.access_time_rounded,
// //                             size: 12,
// //                             color: Color(0xFFFFB020),
// //                           ),
// //                           const SizedBox(width: 4),
// //                           Text(
// //                             'Daily Schedule (${plannedSchedule.length} days)',
// //                             style: const TextStyle(
// //                               fontSize: 11,
// //                               fontWeight: FontWeight.bold,
// //                               color: Color(0xFFFFB020),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
// //                 child: Column(
// //                   children: plannedSchedule.asMap().entries.map((entry) {
// //                     final index = entry.key;
// //                     final item = entry.value as Map<String, dynamic>;
// //                     final date = _formatDate(_str(item['date']));
// //                     final startTime = _str(item['start_time']);
// //                     final endTime = _str(item['end_time']);
// //
// //                     return Container(
// //                       margin: EdgeInsets.only(
// //                         bottom: index < plannedSchedule.length - 1 ? 10 : 0,
// //                       ),
// //                       padding: const EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.grey.shade50,
// //                         borderRadius: BorderRadius.circular(10),
// //                         border: Border.all(
// //                           color: Colors.grey.shade200,
// //                         ),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           // Day Badge
// //                           Container(
// //                             width: 36,
// //                             height: 36,
// //                             decoration: BoxDecoration(
// //                               gradient: const LinearGradient(
// //                                 colors: [
// //                                   Color(0xFFFFB020),
// //                                   Color(0xFFFF8F00),
// //                                 ],
// //                               ),
// //                               borderRadius: BorderRadius.circular(8),
// //                               boxShadow: [
// //                                 BoxShadow(
// //                                   color: const Color(0xFFFFB020)
// //                                       .withValues(alpha: 0.3),
// //                                   blurRadius: 4,
// //                                   offset: const Offset(0, 2),
// //                                 ),
// //                               ],
// //                             ),
// //                             child: Center(
// //                               child: Text(
// //                                 '${index + 1}',
// //                                 style: const TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.white,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //
// //                           // Date & Time Info
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Row(
// //                                   children: [
// //                                     Icon(
// //                                       Icons.calendar_today,
// //                                       size: 13,
// //                                       color: Colors.grey.shade600,
// //                                     ),
// //                                     const SizedBox(width: 6),
// //                                     Text(
// //                                       date,
// //                                       style: const TextStyle(
// //                                         fontSize: 13,
// //                                         fontWeight: FontWeight.w600,
// //                                         color: Colors.black87,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 const SizedBox(height: 6),
// //                                 Row(
// //                                   children: [
// //                                     Icon(
// //                                       Icons.access_time,
// //                                       size: 13,
// //                                       color: Colors.grey.shade600,
// //                                     ),
// //                                     const SizedBox(width: 6),
// //                                     Text(
// //                                       '$startTime - $endTime',
// //                                       style: TextStyle(
// //                                         fontSize: 12,
// //                                         fontWeight: FontWeight.w500,
// //                                         color: Colors.grey.shade700,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //
// //                           // Duration Badge
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 8,
// //                               vertical: 4,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: const Color(0xFF00D4AA)
// //                                   .withValues(alpha: 0.1),
// //                               borderRadius: BorderRadius.circular(6),
// //                             ),
// //                             child: Text(
// //                               _calculateDuration(startTime, endTime),
// //                               style: const TextStyle(
// //                                 fontSize: 10,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Color(0xFF00D4AA),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     );
// //                   }).toList(),
// //                 ),
// //               ),
// //             ],
// //           ],
// //         ),
// //       );
// //     } else {
// //       // Other PTW types: Show switch_off_time and restore_time with elegant UI
// //       return Container(
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withValues(alpha: 0.04),
// //               blurRadius: 10,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Header
// //             Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.all(8),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFFFB020).withValues(alpha: 0.1),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: const Icon(
// //                       Icons.schedule_rounded,
// //                       color: Color(0xFFFFB020),
// //                       size: 20,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Text(
// //                     'Schedule',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.black87,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const Divider(height: 1),
// //
// //             // Times Section
// //             Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 children: [
// //                   // Switch-off Time
// //                   Container(
// //                     padding: const EdgeInsets.all(14),
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [
// //                           Colors.red.shade50,
// //                           Colors.red.shade50.withValues(alpha: 0.3),
// //                         ],
// //                       ),
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(
// //                         color: Colors.red.shade200,
// //                       ),
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Container(
// //                           padding: const EdgeInsets.all(8),
// //                           decoration: BoxDecoration(
// //                             color: Colors.red.shade100,
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: Icon(
// //                             Icons.power_off_rounded,
// //                             color: Colors.red.shade700,
// //                             size: 20,
// //                           ),
// //                         ),
// //                         const SizedBox(width: 12),
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 'Switch-off Time',
// //                                 style: TextStyle(
// //                                   fontSize: 11,
// //                                   color: Colors.grey.shade600,
// //                                   fontWeight: FontWeight.w600,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 4),
// //                               Text(
// //                                 _fmtDT(ptw['switch_off_time']),
// //                                 style: const TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.black87,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //
// //                   const SizedBox(height: 12),
// //
// //                   // Restore Time
// //                   Container(
// //                     padding: const EdgeInsets.all(14),
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [
// //                           Colors.green.shade50,
// //                           Colors.green.shade50.withValues(alpha: 0.3),
// //                         ],
// //                       ),
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(
// //                         color: Colors.green.shade200,
// //                       ),
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Container(
// //                           padding: const EdgeInsets.all(8),
// //                           decoration: BoxDecoration(
// //                             color: Colors.green.shade100,
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: Icon(
// //                             Icons.power_rounded,
// //                             color: Colors.green.shade700,
// //                             size: 20,
// //                           ),
// //                         ),
// //                         const SizedBox(width: 12),
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 'Restore Time',
// //                                 style: TextStyle(
// //                                   fontSize: 11,
// //                                   color: Colors.grey.shade600,
// //                                   fontWeight: FontWeight.w600,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 4),
// //                               Text(
// //                                 _fmtDT(ptw['restore_time']),
// //                                 style: const TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.black87,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //   }
// //
// // // Add this helper method to calculate duration
// //   String _calculateDuration(String startTime, String endTime) {
// //     try {
// //       final start = TimeOfDay(
// //         hour: int.parse(startTime.split(':')[0]),
// //         minute: int.parse(startTime.split(':')[1]),
// //       );
// //       final end = TimeOfDay(
// //         hour: int.parse(endTime.split(':')[0]),
// //         minute: int.parse(endTime.split(':')[1]),
// //       );
// //
// //       int startMinutes = start.hour * 60 + start.minute;
// //       int endMinutes = end.hour * 60 + end.minute;
// //       int duration = endMinutes - startMinutes;
// //
// //       if (duration < 0) duration += 24 * 60;
// //
// //       int hours = duration ~/ 60;
// //       int minutes = duration % 60;
// //
// //       if (hours > 0 && minutes > 0) {
// //         return '${hours}h ${minutes}m';
// //       } else if (hours > 0) {
// //         return '${hours}h';
// //       } else {
// //         return '${minutes}m';
// //       }
// //     } catch (e) {
// //       return '—';
// //     }
// //   }
// //
// //   String _formatDate(String? dateStr) {
// //     if (dateStr == null || dateStr.isEmpty || dateStr == '—') return '—';
// //     try {
// //       final date = DateTime.parse(dateStr);
// //       return DateFormat('dd MMM yyyy').format(date);
// //     } catch (_) {
// //       return dateStr;
// //     }
// //   }
// //
// //   String _buildPlannedScheduleText(List<dynamic> schedule) {
// //     if (schedule.isEmpty) return '—';
// //
// //     final buffer = StringBuffer();
// //     for (int i = 0; i < schedule.length; i++) {
// //       final item = schedule[i] as Map<String, dynamic>;
// //       final date = _formatDate(_str(item['date']));
// //       final startTime = _str(item['start_time']);
// //       final endTime = _str(item['end_time']);
// //
// //       buffer.write('Day ${i + 1}: $date\n');
// //       buffer.write('Time: $startTime - $endTime');
// //
// //       if (i < schedule.length - 1) {
// //         buffer.write('\n\n');
// //       }
// //     }
// //
// //     return buffer.toString();
// //   }
// //   Widget _buildInfoSection({
// //     required String title,
// //     required IconData icon,
// //     required Color color,
// //     required List<dynamic> items,
// //   }) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withValues(alpha: 0.04),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   padding: const EdgeInsets.all(8),
// //                   decoration: BoxDecoration(
// //                     color: color.withValues(alpha: 0.1),
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: Icon(icon, color: color, size: 20),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Text(
// //                   title,
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black87,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const Divider(height: 1),
// //           Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: items.map((item) {
// //                 // Handle SizedBox for spacing
// //                 if (item is SizedBox) return item;
// //
// //                 final itemMap = item as Map<String, dynamic>;
// //                 final isFull = itemMap['full'] == true;
// //                 final sublabel = itemMap['sublabel'] as String?;
// //
// //                 if (isFull) {
// //                   return Padding(
// //                     padding: const EdgeInsets.only(bottom: 16),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           itemMap['label'],
// //                           style: const TextStyle(
// //                             fontSize: 12,
// //                             color: Colors.black54,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 6),
// //                         Container(
// //                           padding: const EdgeInsets.all(12),
// //                           decoration: BoxDecoration(
// //                             color: color.withValues(alpha: 0.05),
// //                             borderRadius: BorderRadius.circular(10),
// //                             border: Border.all(
// //                               color: color.withValues(alpha: 0.2),
// //                             ),
// //                           ),
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 itemMap['value'],
// //                                 style: const TextStyle(
// //                                   fontSize: 14,
// //                                   color: Colors.black87,
// //                                   fontWeight: FontWeight.w600,
// //                                 ),
// //                               ),
// //                               if (sublabel != null && sublabel.isNotEmpty) ...[
// //                                 const SizedBox(height: 6),
// //                                 Row(
// //                                   children: [
// //                                     Icon(
// //                                       Icons.info_outline,
// //                                       size: 14,
// //                                       color: Colors.grey.shade600,
// //                                     ),
// //                                     const SizedBox(width: 6),
// //                                     Expanded(
// //                                       child: Text(
// //                                         sublabel,
// //                                         style: TextStyle(
// //                                           fontSize: 12,
// //                                           color: Colors.grey.shade600,
// //                                           fontWeight: FontWeight.w500,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //                 }
// //
// //                 return Padding(
// //                   padding: const EdgeInsets.only(bottom: 12),
// //                   child: Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Expanded(
// //                         flex: 2,
// //                         child: Text(
// //                           itemMap['label'],
// //                           style: const TextStyle(
// //                             fontSize: 12,
// //                             color: Colors.black54,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                       ),
// //                       Expanded(
// //                         flex: 3,
// //                         child: Text(
// //                           itemMap['value'],
// //                           textAlign: TextAlign.left,
// //                           style: const TextStyle(
// //                             fontSize: 14,
// //                             color: Colors.black87,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               }).toList(),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //   // ==================== TAB 2: TEAM ====================
// //   Widget _buildTeamTab(PtwReviewSdoController controller) {
// //     if (_selectedTab != 1) return const SizedBox.shrink();
// //
// //     final ptw = controller.ptwData;
// //     final team = (ptw['team_members'] as List?) ?? [];
// //
// //     if (team.isEmpty) {
// //       return Padding(
// //         padding: const EdgeInsets.all(40),
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(
// //                 Icons.groups_outlined,
// //                 size: 64,
// //                 color: Colors.grey.shade300,
// //               ),
// //               const SizedBox(height: 16),
// //               Text(
// //                 'No team members assigned',
// //                 style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16),
// //       child: Column(
// //         children: team.map((member) {
// //           final name = _str(member['name']);
// //           final avatar = _str(
// //             member['avatar_url'],
// //             fallback:
// //                 'http://mepco.myflexihr.com/storage/avatars/default-neutral.png',
// //           );
// //
// //           return Container(
// //             margin: const EdgeInsets.only(bottom: 12),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(16),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withValues(alpha:0.04),
// //                   blurRadius: 10,
// //                   offset: const Offset(0, 4),
// //                 ),
// //               ],
// //             ),
// //             child: ListTile(
// //               contentPadding: const EdgeInsets.all(12),
// //               leading: ClipRRect(
// //                 borderRadius: BorderRadius.circular(12),
// //                 child: Image.network(
// //                   avatar,
// //                   width: 50,
// //                   height: 50,
// //                   fit: BoxFit.cover,
// //                   errorBuilder: (_, __, ___) => Container(
// //                     width: 50,
// //                     height: 50,
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [Colors.blue.shade300, Colors.purple.shade300],
// //                       ),
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: const Icon(Icons.person, color: Colors.white),
// //                   ),
// //                 ),
// //               ),
// //               title: Text(
// //                 name,
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 15,
// //                 ),
// //               ),
// //               subtitle: Text(
// //                 'Team Member #${team.indexOf(member) + 1}',
// //                 style: const TextStyle(fontSize: 12, color: Colors.black54),
// //               ),
// //
// //             ),
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }
// //
// //   // ==================== TAB 3: Checklist ====================
// //   Widget _buildSafetyTab(
// //     BuildContext context,
// //     PtwReviewSdoController controller,
// //   ) {
// //     if (_selectedTab != 2) return const SizedBox.shrink();
// //
// //     final raw = controller.checklists;
// //     // final evidences = (controller.ptwData.value['evidences'] as List?) ?? [];
// //
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16),
// //       child: Column(
// //         children: [
// //           // Checklists
// //           if (raw.isNotEmpty) ...[
// //             _buildSectionHeader(
// //               'Safety Checklists',
// //               Icons.checklist_rounded,
// //               const Color(0xFF00D4AA),
// //             ),
// //             const SizedBox(height: 12),
// //             ...raw.entries.map((entry) {
// //               final type = entry.key;
// //               final items = (entry.value as List?) ?? [];
// //               final yesItems = items
// //                   .where((it) => _str(it['value']).toUpperCase() == 'YES')
// //                   .toList();
// //
// //               if (yesItems.isEmpty) return const SizedBox.shrink();
// //
// //               return Container(
// //                 margin: const EdgeInsets.only(bottom: 12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black.withValues(alpha:0.04),
// //                       blurRadius: 10,
// //                       offset: const Offset(0, 4),
// //                     ),
// //                   ],
// //                 ),
// //                 child: ExpansionTile(
// //                   tilePadding: const EdgeInsets.all(16),
// //                   childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
// //                   leading: Container(
// //                     padding: const EdgeInsets.all(8),
// //                     decoration: BoxDecoration(
// //                       color: Colors.green.shade50,
// //                       shape: BoxShape.circle,
// //                     ),
// //                     child: Icon(
// //                       Icons.verified,
// //                       color: Colors.green.shade600,
// //                       size: 20,
// //                     ),
// //                   ),
// //                   title: Text(
// //                     type.replaceAll('_', ' '),
// //                     style: const TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 14,
// //                     ),
// //                   ),
// //                   subtitle: Text(
// //                     '${yesItems.length} items confirmed',
// //                     style: const TextStyle(fontSize: 12, color: Colors.black54),
// //                   ),
// //                   children: yesItems.map((it) {
// //                     return _bilingualChecklistRow(
// //                       _str(it['label_en']),
// //                       _str(it['label_ur']),
// //                       _str(it['value']),
// //                     );
// //                   }).toList(),
// //                 ),
// //               );
// //             }),
// //           ],
// //
// //
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSectionHeader(String title, IconData icon, Color color) {
// //     return Row(
// //       children: [
// //         Container(
// //           padding: const EdgeInsets.all(8),
// //           decoration: BoxDecoration(
// //             color: color.withValues(alpha:0.1),
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           child: Icon(icon, color: color, size: 20),
// //         ),
// //         const SizedBox(width: 12),
// //         Text(
// //           title,
// //           style: const TextStyle(
// //             fontSize: 16,
// //             fontWeight: FontWeight.bold,
// //             color: Colors.black87,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   // ==================== TAB 4: TIMELINE ====================
// //   Widget _buildTimelineTab(PtwReviewSdoController controller) {
// //     if (_selectedTab != 3) return const SizedBox.shrink();
// //
// //     final args = Get.arguments ?? {};
// //     final userRole =
// //         ((args['user_role'] ?? controller.currentUserRole.value)
// //             ?.toString()
// //             .trim()
// //             .toUpperCase()) ??
// //             'LS';
// //
// //     final logs = (controller.ptwData['logs'] as List?) ?? [];
// //     final logsWithNotes = logs
// //         .where((log) => (log['notes']?.toString().trim().isNotEmpty ?? false))
// //         .toList();
// //
// //     final status = controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
// //
// //     // ✅ PDC ke liye timeline mein decision notes NAHI dikhaye
// //     final shouldShowDecisionNotes = userRole != 'PDC' &&
// //         controller.shouldAskForNotes(userRole);
// //
// //     return Padding(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         children: [
// //           // 🕒 Existing timeline items
// //           ...logsWithNotes.asMap().entries.map((entry) {
// //             final index = entry.key;
// //             final log = entry.value;
// //             final isLast = index == logsWithNotes.length - 1 && !shouldShowDecisionNotes;
// //
// //             String? feederStatus;
// //             try {
// //               final metaJson = log['meta_json'];
// //               if (metaJson != null && metaJson.toString().isNotEmpty) {
// //                 final meta = jsonDecode(metaJson.toString());
// //                 feederStatus = meta['feeder_status']?.toString();
// //               }
// //             } catch (e) {
// //               // If parsing fails, feederStatus remains null
// //             }
// //
// //             return _buildTimelineItem(
// //               role: log['role']?.toString() ?? '',
// //               action: log['action']?.toString() ?? '',
// //               notes: log['notes']?.toString() ?? '',
// //               feederStatus: feederStatus,
// //               editable: false,
// //               showLine: !isLast,
// //             );
// //           }),
// //
// //           // ✍️ Editable notes - ONLY for non-PDC roles
// //           if (shouldShowDecisionNotes)
// //             _buildTimelineItem(
// //               role: userRole,
// //               action: 'Decision Notes',
// //               notes: '',
// //               editable: true,
// //               controller: controller.decisionNotesController,
// //               showLine: false,
// //             ),
// //
// //           const SizedBox(height: 24),
// //
// //           // ✅ Buttons - Only for non-PDC roles
// //           if (userRole != 'PDC')
// //             Obx(() => _buildBottomActions(controller)),
// //         ],
// //       ),
// //     );
// //   }
// //   Widget _buildTimelineItem({
// //     required String role,
// //     required String action,
// //     required String notes,
// //     String? feederStatus,  // ✅ NEW: Add feeder status parameter
// //     required bool editable,
// //     required bool showLine,
// //     TextEditingController? controller,
// //   }) {
// //     final roleUpper = role.toUpperCase();
// //     final roleColor = {
// //       'LS': const Color(0xFF00897B),
// //       'SDO': const Color(0xFF1976D2),
// //       'XEN': const Color(0xFFF57C00),
// //       'PDC': const Color(0xFF7B1FA2),
// //       'GRIDOPERATOR': const Color(0xFFD32F2F),
// //     }[roleUpper] ?? Colors.grey;
// //
// //     final roleIcon = {
// //       'LS': Icons.engineering,
// //       'SDO': Icons.supervisor_account,
// //       'XEN': Icons.admin_panel_settings,
// //       'PDC': Icons.assignment_ind,
// //       'GRIDOPERATOR': Icons.power,
// //     }[roleUpper] ?? Icons.person;
// //
// //     final actionMap = {
// //       'FORWARD_XEN': 'Forwarded to XEN',
// //       'APPROVE_TO_PDC': 'Approved to PDC',
// //       'DELEGATE_GRID': 'Delegated to Grid',
// //       'PRECHECKS_DONE': 'Pre-checks Done',
// //       'EXECUTION_STARTED': 'Execution Started',
// //       'COMPLETION_SUBMITTED': 'Completed',
// //       'GRID_RESTORED_AND_CLOSED': 'Restored & Closed',
// //       'SDO_RETURNED': 'Returned to LS',
// //       'XEN_RETURNED_TO_LS': 'Returned to LS',
// //       'LS_RESUBMITTED': 'Resubmitted',
// //       'CANCELLATION_REQUESTED_BY_LS': 'Cancel Request',
// //       'Decision Notes': 'Decision Notes',
// //       'PDC_ISSUE': 'PTW Issued', // ✅ NEW: Add PDC Issue action
// //     };
// //
// //     final displayAction = actionMap[action] ?? action.replaceAll('_', ' ');
// //
// //     // ✅ NEW: Helper to format feeder status for display
// //     String formatFeederStatus(String status) {
// //       switch (status.toUpperCase()) {
// //         case 'NORMAL':
// //           return 'Normal';
// //         case 'ABNORMAL':
// //           return 'Abnormal';
// //         case 'UNDER_MAINTENANCE':
// //           return 'Under Maintenance';
// //         default:
// //           return status.replaceAll('_', ' ');
// //       }
// //     }
// //
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 24),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Timeline Dot & Line
// //           Column(
// //             children: [
// //               Container(
// //                 width: 40,
// //                 height: 40,
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: [roleColor, roleColor.withValues(alpha: 0.7)],
// //                   ),
// //                   shape: BoxShape.circle,
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: roleColor.withValues(alpha: 0.3),
// //                       blurRadius: 8,
// //                       offset: const Offset(0, 4),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Icon(roleIcon, color: Colors.white, size: 20),
// //               ),
// //               if (showLine)
// //                 Container(
// //                   width: 2,
// //                   height: 60,
// //                   margin: const EdgeInsets.symmetric(vertical: 4),
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       colors: [roleColor.withValues(alpha: 0.3), Colors.transparent],
// //                       begin: Alignment.topCenter,
// //                       end: Alignment.bottomCenter,
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //           const SizedBox(width: 16),
// //
// //           // Content Card
// //           Expanded(
// //             child: Container(
// //               decoration: BoxDecoration(
// //                 color: editable ? roleColor.withValues(alpha: 0.05) : Colors.white,
// //                 borderRadius: BorderRadius.circular(16),
// //                 border: Border.all(
// //                   color: editable
// //                       ? roleColor.withValues(alpha: 0.3)
// //                       : Colors.grey.shade200,
// //                   width: editable ? 2 : 1,
// //                 ),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withValues(alpha: 0.04),
// //                     blurRadius: 10,
// //                     offset: const Offset(0, 4),
// //                   ),
// //                 ],
// //               ),
// //               child: Padding(
// //                 padding: const EdgeInsets.all(16),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Container(
// //                           padding: const EdgeInsets.symmetric(
// //                             horizontal: 10,
// //                             vertical: 4,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             color: roleColor.withValues(alpha: 0.1),
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: Text(
// //                             roleUpper,
// //                             style: TextStyle(
// //                               color: roleColor,
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 11,
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 8),
// //                         Expanded(
// //                           child: Text(
// //                             displayAction,
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 13,
// //                               color: roleColor,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 12),
// //
// //                     // Notes section
// //                     if (editable && controller != null)
// //                       CustomTextFormField(
// //                         labelText: 'Enter your decision notes...',
// //                         maxLines: 4,
// //                         controller: controller,
// //                       )
// //                     else if (notes.isNotEmpty)
// //                       Container(
// //                         padding: const EdgeInsets.all(12),
// //                         decoration: BoxDecoration(
// //                           color: Colors.grey.shade50,
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                         child: Text(
// //                           notes,
// //                           style: const TextStyle(
// //                             fontSize: 13,
// //                             color: Colors.black87,
// //                             height: 1.5,
// //                           ),
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Future<bool> showConfirmationDialog(BuildContext context, String message) async {
// //     return await showGeneralDialog<bool>(
// //       context: context,
// //       barrierDismissible: true,
// //       barrierLabel: "Confirm",
// //       transitionDuration: const Duration(milliseconds: 220),
// //
// //       pageBuilder: (_, __, ___) => const SizedBox.shrink(),
// //
// //       transitionBuilder: (context, animation, secondary, child) {
// //         final curved = Curves.easeOut.transform(animation.value);
// //
// //         return Transform.scale(
// //           scale: curved,
// //           child: Opacity(
// //             opacity: curved,
// //             child: Material(
// //               color: Colors.black.withValues(alpha:0.01),
// //               child: Center(
// //                 child: Container(
// //                   width: MediaQuery.of(context).size.width * 0.85,
// //                   padding: const EdgeInsets.all(22),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,                      // WHITE BACKGROUND
// //                     borderRadius: BorderRadius.circular(20),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black12,
// //                         blurRadius: 20,
// //                         spreadRadius: 4,
// //                         offset: Offset(0, 8),
// //                       ),
// //                     ],
// //                   ),
// //
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       // ICON
// //                       Container(
// //                         padding: const EdgeInsets.all(16),
// //                         decoration: BoxDecoration(
// //                           color: Colors.red.withValues(alpha:0.12),
// //                           shape: BoxShape.circle,
// //                         ),
// //                         child: const Icon(
// //                           Icons.warning_amber_rounded,
// //                           size: 38,
// //                           color: Colors.red,
// //                         ),
// //                       ),
// //
// //                       const SizedBox(height: 18),
// //
// //                       // TITLE
// //                       const Text(
// //                         "Confirmation Required",
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.w700,
// //                           color: Colors.black87,
// //                         ),
// //                       ),
// //
// //                       const SizedBox(height: 10),
// //
// //                       // MESSAGE
// //                       Text(
// //                         message,
// //                         textAlign: TextAlign.center,
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.grey.shade700,
// //                           height: 1.4,
// //                         ),
// //                       ),
// //
// //                       const SizedBox(height: 25),
// //
// //                       // ACTION BUTTONS
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: ElevatedButton(
// //                               style: ElevatedButton.styleFrom(
// //                                 backgroundColor: AppColors.primaryBlue,
// //                                 padding: const EdgeInsets.symmetric(vertical: 10),
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius: BorderRadius.circular(32),
// //                                 ),
// //                                 elevation: 0,
// //                               ),
// //                               onPressed: () {
// //                                 Navigator.pop(context, false);
// //                               },
// //                               child: const Text(
// //                                 "Cancel",
// //                                 style: TextStyle(
// //                                   fontSize: 16,
// //                                   color: Colors.white,
// //                                   fontWeight: FontWeight.w600,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //
// //                           const SizedBox(width: 12),
// //
// //                           Expanded(
// //                             child: ElevatedButton(
// //                               style: ElevatedButton.styleFrom(
// //                                 backgroundColor: Colors.green.shade600,
// //                                 padding: const EdgeInsets.symmetric(vertical: 10),
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius: BorderRadius.circular(32),
// //                                 ),
// //                                 elevation: 0,
// //                               ),
// //                               onPressed: () {
// //                                 Navigator.pop(context, true);
// //                               },
// //                               child: const Text(
// //                                 "Confirm",
// //                                 style: TextStyle(
// //                                   fontSize: 16,
// //                                   color: Colors.white,
// //                                   fontWeight: FontWeight.w600,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       )
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     ) ??
// //         false;
// //   }
// //
// //
// // // =======================================================
// // //  MAIN ACTION BUILDER
// // // =======================================================
// //   Widget _buildBottomActions(PtwReviewSdoController controller) {
// //     final context = Get.context!;
// //     final args = Get.arguments ?? {};
// //     final userRole =
// //     ((args['user_role'] ?? controller.currentUserRole.value) ?? 'LS')
// //         .toString()
// //         .trim()
// //         .toUpperCase();
// //
// //     final status = controller.ptwData['current_status']?.toString().toUpperCase() ?? '';
// //     if (userRole == 'GRIDOPERATOR' && status == 'GRID_RESOLVE_REQUIRED') {
// //       // Check if current user is assigned operator
// //       if (!controller.isCurrentUserAssignedOperator()) {
// //         return _buildNoAccessMessage();
// //       }
// //     }
// //     bool anyFeederOn = controller.turnedOffFeeders.length < controller.allFeeders.length;
// //     if (userRole == 'PDC' &&
// //         (status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC') &&
// //         anyFeederOn) {
// //       return Column(
// //         children: [
// //           // Decision Notes
// //           _buildTimelineItem(
// //             role: userRole,
// //             action: 'Decision Notes',
// //             notes: '',
// //             editable: true,
// //             controller: controller.decisionNotesController,
// //             showLine: false,
// //           ),
// //           const SizedBox(height: 16),
// //
// //           // Return to Grid button
// //           _buildActionBar(
// //             buttons: [
// //               _ActionButton(
// //                 text: 'Return to Grid',
// //                 icon:Icons.keyboard_return_outlined,
// //                 color: const Color(0xFFC62828),
// //                 actionKey: 'return_grid',
// //                 onPressed: (setLoading) async {
// //                   // ✅ Confirmation dialog
// //                   bool confirm = await showConfirmationDialog(
// //                     context,
// //                     "Are you sure you want to issue this PTW?",
// //                   );
// //                   if (!confirm) return;
// //
// //                   setLoading(true);
// //
// //                   final ptwId = controller.ptwData['id'];
// //
// //                   // ✅ Optional: Get notes (if needed, otherwise pass empty string)
// //                   final notes = controller.decisionNotesController.text.trim();
// //
// //                   // ✅ Call forwardPTW with PtwActionType.pdcIssue
// //                   await controller.forwardPTW(
// //                     ptwId,
// //                     userRole,
// //                     notes,
// //                     action: PtwActionType.returnGrid,
// //                   );
// //
// //                   setLoading(false);
// //                 },
// //               ),
// //             ],
// //           ),
// //         ],
// //       );
// //     }
// //
// //     // ✅ Show only Issue PTW when ALL feeders are OFF
// //     if (userRole == 'PDC' &&
// //         (status == 'PTW_ISSUED' || status == 'RE_SUBMITTED_TO_PDC') &&
// //         !anyFeederOn) {
// //       return _buildActionBar(
// //         buttons: [
// //           _ActionButton(
// //             text: 'Issue PTW',
// //             icon: Icons.forward,
// //             color: const Color(0xFF6A1B9A),
// //             actionKey: 'issue_ptw',
// //             onPressed: (setLoading) async {
// //               // ✅ Confirmation dialog
// //               bool confirm = await showConfirmationDialog(
// //                 context,
// //                 "Are you sure you want to issue this PTW?",
// //               );
// //               if (!confirm) return;
// //
// //               setLoading(true);
// //
// //               final ptwId = controller.ptwData['id'];
// //
// //               // ✅ Optional: Get notes (if needed, otherwise pass empty string)
// //               final notes = controller.decisionNotesController.text.trim();
// //
// //               // ✅ Call forwardPTW with PtwActionType.pdcIssue
// //               await controller.forwardPTW(
// //                 ptwId,
// //                 userRole,
// //                 notes,
// //                 action: PtwActionType.pdcIssue,
// //               );
// //
// //               setLoading(false);
// //             },
// //           ),
// //         ],
// //       );
// //     }
// // // LS → PDC_CONFIRMED (START PTW + CANCEL)
// // // =======================================================
// //     if (userRole == 'LS' && status == 'PDC_CONFIRMED') {
// //       return _buildActionBar(
// //         buttons: [
// //           // ▶ START PTW
// //           _ActionButton(
// //             text: 'Start PTW',
// //             icon: Icons.play_circle_fill,
// //             color: Colors.green.shade700,
// //             actionKey: 'start_ptw',
// //             onPressed: (setLoading) async {
// //               bool confirm = await showConfirmationDialog(
// //                 context,
// //                 "Are you sure you want to start this PTW?",
// //               );
// //               if (!confirm) return;
// //
// //               setLoading(true);
// //
// //               bool serviceEnabled;
// //               LocationPermission permission;
// //
// //               serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //               if (!serviceEnabled) {
// //                 await Geolocator.openLocationSettings();
// //                 setLoading(false);
// //                 return;
// //               }
// //
// //               permission = await Geolocator.checkPermission();
// //               if (permission == LocationPermission.denied) {
// //                 permission = await Geolocator.requestPermission();
// //                 if (permission == LocationPermission.denied) {
// //                   SnackbarHelper.showError(
// //                     title: 'Permission Denied',
// //                     message: 'Location permission is required to start PTW.',
// //                   );
// //                   setLoading(false);
// //                   return;
// //                 }
// //               }
// //
// //               if (permission == LocationPermission.deniedForever) {
// //                 SnackbarHelper.showError(
// //                   title: 'Permission Denied',
// //                   message:
// //                   'Location permission is permanently denied. Please enable it from settings.',
// //                 );
// //                 setLoading(false);
// //                 return;
// //               }
// //
// //               final ptwId = controller.ptwData['id'];
// //               if (ptwId != null) {
// //                 Get.toNamed(
// //                   AppRoutes.attachmentsSubmission,
// //                   arguments: ptwId,
// //                 );
// //               }
// //
// //               setLoading(false);
// //             },
// //           ),
// //
// //           // ❌ CANCEL PTW
// //           _ActionButton(
// //             text: 'Cancel',
// //             icon: Icons.cancel_schedule_send,
// //             color: Colors.blueGrey,
// //             actionKey: 'cancel_ptw_ls',
// //             onPressed: (setLoading) async {
// //               bool confirm = await showConfirmationDialog(
// //                 context,
// //                 "Are you sure you want to cancel this PTW?",
// //               );
// //               if (!confirm) return;
// //
// //               setLoading(true);
// //
// //               final ptwId = controller.ptwData['id'];
// //               if (ptwId != null) {
// //                 Get.toNamed(
// //                   AppRoutes.ptwCancelByLs,
// //                   arguments: {
// //                     'ptw_id': ptwId,
// //                     'user_role': userRole,
// //                   },
// //                 );
// //               }
// //
// //               setLoading(false);
// //             },
// //           ),
// //         ],
// //       );
// //     }
// //
// // // =======================================================
// // // LS → COMPLETE PTW (WHEN IN_EXECUTION)
// // // =======================================================
// //     if (userRole == 'LS' && status == 'IN_EXECUTION') {
// //       return _buildActionBar(
// //         buttons: [
// //           _ActionButton(
// //             text: 'Complete',
// //             icon: Icons.check_circle_rounded,
// //             color: Colors.orange.shade700,
// //             actionKey: 'complete_ptw',
// //             onPressed: (setLoading) async {
// //               bool confirm = await showConfirmationDialog(
// //                 context,
// //                 "Are you sure you want to complete this PTW?",
// //               );
// //               if (!confirm) return;
// //
// //               setLoading(true);
// //
// //               bool serviceEnabled;
// //               LocationPermission permission;
// //
// //               // 1️⃣ Check location service
// //               serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //               if (!serviceEnabled) {
// //                 await Geolocator.openLocationSettings();
// //                 setLoading(false);
// //                 return;
// //               }
// //
// //               // 2️⃣ Check permission
// //               permission = await Geolocator.checkPermission();
// //               if (permission == LocationPermission.denied) {
// //                 permission = await Geolocator.requestPermission();
// //                 if (permission == LocationPermission.denied) {
// //                   SnackbarHelper.showError(
// //                     title: 'Permission Denied',
// //                     message: 'Location permission is required to complete PTW.',
// //                   );
// //                   setLoading(false);
// //                   return;
// //                 }
// //               }
// //
// //               if (permission == LocationPermission.deniedForever) {
// //                 SnackbarHelper.showError(
// //                   title: 'Permission Denied',
// //                   message:
// //                   'Location permission is permanently denied. Please enable it from settings.',
// //                 );
// //                 setLoading(false);
// //                 return;
// //               }
// //
// //               // 3️⃣ Navigate to completion screen
// //               final ptwId = controller.ptwData['id'];
// //               if (ptwId != null) {
// //                 Get.toNamed(
// //                   AppRoutes.ptwCompleted,
// //                   arguments: ptwId,
// //                 );
// //               }
// //
// //               setLoading(false);
// //             },
// //           ),
// //         ],
// //       );
// //     }
// //
// //     if (userRole == 'LS') {
// //       final returnedByRole =
// //           controller.ptwData['returned_by_role']
// //               ?.toString()
// //               .toUpperCase() ??
// //               '';
// //
// //       final isDraft = status == 'DRAFT';
// //       final isReturned = [
// //         'SDO_RETURNED',
// //         'XEN_RETURNED_TO_LS',
// //         'PDC_RETURNED_TO_LS',
// //       ].contains(status);
// //
// //       if (!isDraft && !isReturned) return const SizedBox.shrink();
// //
// //       String forwardLabel;
// //
// //       if (isDraft) {
// //         forwardLabel = 'Forward to SDO';
// //       } else {
// //         switch (returnedByRole) {
// //           case 'XEN':
// //             forwardLabel = 'Forward to XEN';
// //             break;
// //           case 'PDC':
// //             forwardLabel = 'Forward to PDC';
// //             break;
// //           case 'SDO':
// //           default:
// //             forwardLabel = 'Forward to SDO';
// //             break;
// //         }
// //       }
// //
// //       return _buildActionBar(
// //         buttons: [
// //           _ActionButton(
// //             text: forwardLabel,
// //             icon: Icons.send_rounded,
// //             color: const Color(0xFF0D47A1),
// //             actionKey: 'ls_forward',
// //             onPressed: (setLoading) async {
// //               // ===============================
// //               // SHOW POPUP FIRST
// //               // ===============================
// //               bool confirm = await showConfirmationDialog(
// //                   context, "Are you sure you want to forward this?");
// //               if (!confirm) return;
// //
// //               setLoading(true);
// //
// //               final ptwId = controller.ptwData['id'] as int;
// //               final notes = controller.decisionNotesController.text.trim();
// //
// //               if (controller.shouldAskForNotes('LS') && notes.isEmpty) {
// //                 SnackbarHelper.showError(
// //                     title: 'Error', message: 'Please enter decision notes');
// //                 setLoading(false);
// //                 return;
// //               }
// //
// //               await controller.forwardPTW(ptwId, 'LS', notes);
// //               setLoading(false);
// //             },
// //           ),
// //         ],
// //       );
// //     }
// //     final isPtwRequired =controller.ptwData['is_ptw_required'];
// //     if (userRole == 'SDO' && status == 'SUBMITTED' && isPtwRequired ==false) {
// //       return _buildActionBar(
// //         buttons: [
// //           _ActionButton(
// //             text: 'Approve PTW',
// //             icon: Icons.check_circle_rounded,
// //             color: const Color(0xFF2E7D32),
// //             actionKey: 'approve_ptw',
// //             onPressed: (setLoading) async {
// //               bool confirm = await showConfirmationDialog(
// //                 context,
// //                 "Are you sure you want to approve this PTW?",
// //               );
// //               if (!confirm) return;
// //
// //               setLoading(true);
// //
// //               final ptwId = controller.ptwData['id'];
// //               final notes = controller.decisionNotesController.text.trim();
// //
// //               await controller.forwardPTW(
// //                 ptwId,
// //                 userRole,
// //                 notes,
// //                 action: PtwActionType.approve_no_ptw, // ✅ change if backend has special approve action
// //               );
// //
// //               setLoading(false);
// //             },
// //           ),
// //         ],
// //       );
// //     }
// // // =======================================================
// // // GRID OPERATOR → CLOSE PTW (WITH LOCATION PERMISSION)
// // // =======================================================
// //     if (userRole == 'GRIDOPERATOR' &&
// //         (status == 'COMPLETION_SUBMITTED' ||
// //             status == 'CANCELLATION_APPROVED_BY_SDO')) {
// //       return _buildActionBar(
// //         buttons: [
// //           _ActionButton(
// //             text: 'Close PTW',
// //             icon: Icons.close_outlined,
// //             color: Colors.blue.shade700,
// //             actionKey: 'grid_close_ptw',
// //             onPressed: (setLoading) async {
// //               bool confirm = await showConfirmationDialog(
// //                 context,
// //                 "Are you sure you want to close this PTW?",
// //               );
// //               if (!confirm) return;
// //
// //               setLoading(true);
// //
// //               bool serviceEnabled;
// //               LocationPermission permission;
// //
// //               // 1️⃣ Check location service
// //               serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //               if (!serviceEnabled) {
// //                 await Geolocator.openLocationSettings();
// //                 setLoading(false);
// //                 return;
// //               }
// //
// //               // 2️⃣ Check location permission
// //               permission = await Geolocator.checkPermission();
// //               if (permission == LocationPermission.denied) {
// //                 permission = await Geolocator.requestPermission();
// //                 if (permission == LocationPermission.denied) {
// //                   SnackbarHelper.showError(
// //                     title: 'Permission Denied',
// //                     message:
// //                     'Location permission is required to close PTW.',
// //                   );
// //                   setLoading(false);
// //                   return;
// //                 }
// //               }
// //
// //               if (permission == LocationPermission.deniedForever) {
// //                 SnackbarHelper.showError(
// //                   title: 'Permission Denied',
// //                   message:
// //                   'Location permission is permanently denied. Please enable it from settings.',
// //                 );
// //                 setLoading(false);
// //                 return;
// //               }
// //
// //               // 3️⃣ Navigate to close PTW screen
// //               final ptwId = controller.ptwData['id'];
// //               if (ptwId != null) {
// //                 Get.toNamed(
// //                   AppRoutes.ptwGridClose,
// //                   arguments: ptwId,
// //                 );
// //               }
// //
// //               setLoading(false);
// //             },
// //           ),
// //         ],
// //       );
// //     }
// //
// //     // =======================================================
// //     // OTHER ROLES CONFIGURATION
// //     // =======================================================
// //     final Map<String, Map<String, List<Map<String, dynamic>>>>
// //     roleStatusActions = {
// //       'LS': {
// //         'SUBMITTED': [
// //           {
// //             'text': 'Start Executuion',
// //             'action': PtwActionType.forward,
// //             'requiresNotes': false,
// //             'icon': Icons.arrow_forward_rounded,
// //             'color': Color(0xFF0D47A1),
// //             'key': 'forward_xen',
// //           },
// //         ],
// //       },
// //       'SDO': {
// //         'SUBMITTED': [
// //           {
// //             'text': 'Forward to XEN',
// //             'action': PtwActionType.forward,
// //             'requiresNotes': false,
// //             'icon': Icons.arrow_forward_rounded,
// //             'color': Color(0xFF0D47A1),
// //             'key': 'forward_xen',
// //           },
// //           {
// //             'text': 'Return to LS',
// //             'action': PtwActionType.returnBack,
// //             'requiresNotes': false,
// //             'icon': Icons.arrow_back_rounded,
// //             'color': Color(0xFFE65100),
// //             'key': 'return_ls',
// //           },
// //           {
// //             'text': 'Cancel Request',
// //             'action': PtwActionType.cancel,
// //             'requiresNotes': false,
// //             'icon': Icons.cancel_outlined,
// //             'color': Color(0xFFC62828),
// //             'key': 'cancel',
// //           },
// //         ],
// //         'CANCELLATION_REQUESTED_BY_LS': [
// //       {
// //         'text': 'Forward to Grid',
// //         'action': PtwActionType.cancelSDO,
// //         'requiresNotes': false,
// //         'icon': Icons.arrow_forward_rounded,
// //         'color': Color(0xFF0D47A1),
// //         'key': 'forward_grid',
// //       },
// //       ],
// //       },
// //
// //       // XEN ACTIONS
// //       'XEN': {
// //         'SDO_FORWARDED_TO_XEN' : [
// //           {
// //             'text': 'Approve to PDC',
// //             'action': PtwActionType.forward,
// //             'requiresNotes': false,
// //             'icon': Icons.check_circle_rounded,
// //             'color': Color(0xFF2E7D32),
// //             'key': 'approve_pdc',
// //           },
// //           {
// //             'text': 'Return to LS',
// //             'action': PtwActionType.xenReturnLS,
// //             'requiresNotes': false,
// //             'icon': Icons.arrow_back_rounded,
// //             'color': Color(0xFFE65100),
// //             'key': 'return_sdo',
// //           },
// //           {
// //             'text': 'Cancel Request',
// //             'action': PtwActionType.xenReject,
// //             'requiresNotes': false,
// //             'icon': Icons.cancel_outlined,
// //             'color': Color(0xFFC62828),
// //             'key': 'cancel',
// //           },
// //         ],
// //         'LS_RESUBMIT_TO_XEN': [
// //           {
// //             'text': 'Approve to PDC',
// //             'action': PtwActionType.forward,
// //             'requiresNotes': false,
// //             'icon': Icons.check_circle_rounded,
// //             'color': Color(0xFF2E7D32),
// //             'key': 'approve_pdc',
// //           },
// //           {
// //             'text': 'Return to LS',
// //             'action': PtwActionType.xenReturnLS,
// //             'requiresNotes': false,
// //             'icon': Icons.arrow_back_rounded,
// //             'color': Color(0xFFE65100),
// //             'key': 'return_sdo',
// //           },
// //           {
// //             'text': 'Cancel Request',
// //             'action': PtwActionType.xenReject,
// //             'requiresNotes': false,
// //             'icon': Icons.cancel_outlined,
// //             'color': Color(0xFFC62828),
// //             'key': 'cancel',
// //           },
// //         ],
// //       },
// //
// //
// //       // PDC ACTIONS
// //       'PDC': {
// //         'XEN_APPROVED_TO_PDC': [
// //           {
// //             'text': 'Delegate to GRID',
// //             'action': PtwActionType.forward,
// //             'requiresNotes': false,
// //             'icon': Icons.power_rounded,
// //             'color': Color(0xFF6A1B9A),
// //             'key': 'delegate_grid',
// //           },
// //           {
// //             'text': 'Return to LS',
// //             'action': PtwActionType.pdcReturnsLS,
// //             'requiresNotes': false,
// //             'icon': Icons.arrow_back_rounded,
// //             'color': Color(0xFFE65100),
// //             'key': 'return_ls',
// //           },
// //           {
// //             'text': 'Cancel Request',
// //             'action': PtwActionType.pdcReject,
// //             'requiresNotes': false,
// //             'icon': Icons.cancel_outlined,
// //             'color': Color(0xFFC62828),
// //             'key': 'cancel',
// //           },
// //         ],
// //         'LS_RESUBMIT_TO_PDC': [
// //           {
// //             'text': 'Delegate to GRID',
// //             'action': PtwActionType.forward,
// //             'requiresNotes': false,
// //             'icon': Icons.power_rounded,
// //             'color': Color(0xFF6A1B9A),
// //             'key': 'delegate_grid',
// //           },
// //           {
// //             'text': 'Return to LS',
// //             'action': PtwActionType.pdcReturnsLS,
// //             'requiresNotes': false,
// //             'icon': Icons.arrow_back_rounded,
// //             'color': Color(0xFFE65100),
// //             'key': 'return_ls',
// //           },
// //           {
// //             'text': 'Cancel Request',
// //             'action': PtwActionType.pdcReject,
// //             'requiresNotes': false,
// //             'icon': Icons.cancel_outlined,
// //             'color': Color(0xFFC62828),
// //             'key': 'cancel',
// //           },
// //         ],
// //         'PTW_ISSUED': [
// //       {
// //         'text': 'Issue PTW',
// //         'action': PtwActionType.pdcIssue,
// //         'requiresNotes': false,
// //         'icon': Icons.forward,
// //         'color': Color(0xFF6A1B9A),
// //         'key': 'issuePtw',
// //       },
// //           {
// //         'text': 'Return to grid',
// //         'action': PtwActionType.returnGrid,
// //         'requiresNotes': false,
// //         'icon': Icons.keyboard_return_outlined,
// //         'color': Color(0xFFC62828),
// //         'key': 'return_grid',
// //       },
// //       ],
// //         'RE_SUBMITTED_TO_PDC': [
// //           {
// //             'text': 'Issue PTW',
// //             'action': PtwActionType.pdcIssue,
// //             'requiresNotes': false,
// //             'icon': Icons.forward,
// //             'color': Color(0xFF6A1B9A),
// //             'key': 'issuePtw',
// //           },
// //           {
// //             'text': 'Return to grid',
// //             'action': PtwActionType.returnGrid,
// //             'requiresNotes': false,
// //             'icon': Icons.keyboard_return_outlined,
// //             'color': Color(0xFFC62828),
// //             'key': 'return_grid',
// //           },
// //         ],
// //       },
// //
// //       // GRID OPERATOR
// //       'GRIDOPERATOR': {
// //         'PDC_DELEGATED_TO_GRID': [
// //           {
// //             'text': 'Confirm PTW',
// //             'action': null,
// //             'requiresNotes': false,
// //             'isGrid': true,
// //             'icon': Icons.verified_rounded,
// //             'color': Color(0xFF2E7D32),
// //             'key': 'confirm_ptw',
// //           },
// //         ],
// //         'GRID_RESOLVE_REQUIRED': [
// //           {
// //             'text': 'Confirm PTW',
// //             'action': null,
// //             'requiresNotes': false,
// //             'isGrid': true,
// //             'icon': Icons.verified_rounded,
// //             'color': Color(0xFF2E7D32),
// //             'key': 'confirm_ptw',
// //           },
// //         ],
// //       },
// //     };
// //
// //     final actions = roleStatusActions[userRole]?[status];
// //     print('actions: $actions');
// //     if (actions == null || actions.isEmpty) return const SizedBox.shrink();
// //
// //     return _buildActionBar(
// //       buttons: actions.map((btnConfig) {
// //         return _ActionButton(
// //           text: btnConfig['text'],
// //           icon: btnConfig['icon'],
// //           color: btnConfig['color'],
// //           actionKey: btnConfig['key'],
// //           onPressed: (setLoading) async {
// //             // ======================================
// //             // SHOW CONFIRM POPUP BEFORE ACTION
// //             // ======================================
// //             bool confirm = await showConfirmationDialog(
// //                 context, "Are you sure you want to proceed?");
// //             if (!confirm) return;
// //
// //             setLoading(true);
// //
// //             final ptwId = controller.ptwData['id'];
// //             final notes = controller.decisionNotesController.text.trim();
// //
// //             if (btnConfig['isGrid'] == true) {
// //               Get.toNamed(AppRoutes.gridPtwIssueChecklist,
// //                   arguments: {'ptw_id': ptwId});
// //               setLoading(false);
// //               return;
// //             }
// //
// //             if (btnConfig['requiresNotes'] == true && notes.isEmpty) {
// //               SnackbarHelper.showError(
// //                   title: 'Error', message: 'Please enter decision notes');
// //               setLoading(false);
// //               return;
// //             }
// //
// //             await controller.forwardPTW(
// //               ptwId,
// //               userRole,
// //               notes,
// //               action: btnConfig['action'],
// //             );
// //
// //             setLoading(false);
// //           },
// //         );
// //       }).toList(),
// //     );
// //
// //   }
// //   Widget _buildNoAccessMessage() {
// //     return Container(
// //       margin: const EdgeInsets.all(16),
// //       padding: const EdgeInsets.all(24),
// //       decoration: BoxDecoration(
// //         color: Colors.orange.shade50,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(
// //           color: Colors.orange.shade200,
// //           width: 2,
// //         ),
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               color: Colors.orange.shade100,
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(
// //               Icons.lock_outline,
// //               size: 48,
// //               color: Colors.orange.shade700,
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           Text(
// //             'Access Restricted',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.orange.shade900,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             'This PTW is assigned to another Grid Operator',
// //             textAlign: TextAlign.center,
// //             style: TextStyle(
// //               fontSize: 14,
// //               color: Colors.grey.shade700,
// //               height: 1.4,
// //             ),
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             'Only the assigned operator can perform actions on this PTW',
// //             textAlign: TextAlign.center,
// //             style: TextStyle(
// //               fontSize: 12,
// //               color: Colors.grey.shade600,
// //               fontStyle: FontStyle.italic,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //   // ==================== ACTION BAR WITH INDIVIDUAL LOADING ====================
// //   Widget _buildActionBar({required List<_ActionButton> buttons}) {
// //     // Local state for each button's loading
// //     final loadingStates = <String, bool>{}.obs;
// //
// //     return Padding(
// //       padding: const EdgeInsets.only(top: 16, bottom: 8),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.stretch,
// //         children: buttons.map((btn) {
// //           return Padding(
// //             padding: const EdgeInsets.only(bottom: 12),
// //             child: Obx(() {
// //               final isLoading = loadingStates[btn.actionKey] ?? false;
// //
// //               return SizedBox(
// //                 height: 52,
// //                 child: ElevatedButton(
// //                   onPressed: isLoading
// //                       ? null
// //                       : () {
// //                           btn.onPressed((loading) {
// //                             loadingStates[btn.actionKey] = loading;
// //                           });
// //                         },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: btn.color,
// //                     disabledBackgroundColor: btn.color.withValues(alpha:0.5),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(14),
// //                     ),
// //                     elevation: isLoading ? 0 : 2,
// //                     shadowColor: btn.color.withValues(alpha:0.3),
// //                   ),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       if (isLoading) ...[
// //                         const SizedBox(
// //                           width: 20,
// //                           height: 20,
// //                           child: CircularProgressIndicator(
// //                             strokeWidth: 2.5,
// //                             valueColor: AlwaysStoppedAnimation(Colors.white),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 12),
// //                         const Text(
// //                           'Processing...',
// //                           style: TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                       ] else ...[
// //                         Icon(btn.icon, color: Colors.white, size: 20),
// //                         const SizedBox(width: 10),
// //                         Flexible(
// //                           child: Text(
// //                             btn.text,
// //                             maxLines: 1,
// //                             overflow: TextOverflow.ellipsis,
// //                             style: const TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 15,
// //                               fontWeight: FontWeight.w600,
// //                               letterSpacing: 0.3,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             }),
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }
// //
// //   // ==================== SHIMMER ====================
// //   Widget _buildShimmerLoading() {
// //     return ListView(
// //       padding: const EdgeInsets.all(16),
// //       children: List.generate(
// //         5,
// //         (_) => Container(
// //           margin: const EdgeInsets.only(bottom: 16),
// //           child: const ShimmerWidget.rectangular(height: 150),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ==================== HELPERS ====================
// //   String _str(dynamic v, {String fallback = '—'}) {
// //     if (v == null) return fallback;
// //     final s = v.toString().trim();
// //     return s.isEmpty ? fallback : s;
// //   }
// //
// //   String _fmtDT(dynamic v) {
// //     try {
// //       if (v == null) return '—';
// //       final raw = v.toString().replaceFirst(' ', 'T');
// //       final dt = DateTime.parse(raw);
// //       return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
// //     } catch (_) {
// //       return _str(v);
// //     }
// //   }
// //
// //   // ==================== BILINGUAL CHECKLIST ROW ====================
// //   Widget _bilingualChecklistRow(String en, String ur, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 12),
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: Colors.green.shade50,
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border.all(color: Colors.green.shade200),
// //         ),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     en,
// //                     style: const TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.black87,
// //                     ),
// //                   ),
// //                   if (ur.isNotEmpty && ur != '—') ...[
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       ur,
// //                       textAlign: TextAlign.right,
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         color: Colors.grey.shade700,
// //                         fontFamily: 'Noto Nastaliq Urdu',
// //                       ),
// //                       // textDirection: TextDirection.RTL,
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //             _yesNoChip(value),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _yesNoChip(String value) {
// //     final isYes = value.toUpperCase() == 'YES';
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //       decoration: BoxDecoration(
// //         color: (isYes ? Colors.green : Colors.red).withValues(alpha:0.15),
// //         borderRadius: BorderRadius.circular(8),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(
// //             isYes ? Icons.check_circle : Icons.cancel,
// //             color: isYes ? Colors.green.shade700 : Colors.red.shade700,
// //             size: 14,
// //           ),
// //           const SizedBox(width: 4),
// //           Text(
// //             isYes ? 'YES' : 'NO',
// //             style: TextStyle(
// //               color: isYes ? Colors.green.shade700 : Colors.red.shade700,
// //               fontWeight: FontWeight.bold,
// //               fontSize: 11,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ==================== ACTION BUTTON CLASS ====================
// // class _ActionButton {
// //   final String text;
// //   final IconData icon;
// //   final Color color;
// //   final String actionKey;
// //   final Function(Function(bool) setLoading) onPressed;
// //
// //   _ActionButton({
// //     required this.text,
// //     required this.icon,
// //     required this.color,
// //     required this.actionKey,
// //     required this.onPressed,
// //   });
// // }
