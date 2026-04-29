// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mepco_esafety_app/controllers/hse_field_check_controller.dart';
// import 'package:mepco_esafety_app/widgets/main_layout.dart';
//
// class HseFieldCheckScreen extends StatelessWidget {
//   const HseFieldCheckScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final HseFieldCheckController controller =
//     Get.find<HseFieldCheckController>();
//
//     return Scaffold(
//       extendBody: true,
//       body: MainLayout(
//         title: 'HSE Field Check',
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── PERFORMA TITLE ─────────────────────────────────────────
//               _buildTitle(),
//               const SizedBox(height: 16),
//
//               // ── INSPECTION TYPE ────────────────────────────────────────
//               _buildSectionCard(
//                 title: 'Inspection Type',
//                 child: Obx(
//                       () => Row(
//                     children: ['Routine', 'Surprise', 'Follow-up'].map((type) {
//                       final selected = controller.inspectionType.value == type;
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: ChoiceChip(
//                           label: Text(type),
//                           selected: selected,
//                           onSelected: (_) =>
//                           controller.inspectionType.value = type,
//                           selectedColor: const Color(0xFF002997),
//                           labelStyle: TextStyle(
//                             color: selected ? Colors.white : Colors.black87,
//                             fontWeight: FontWeight.w500,
//                           ),
//                           backgroundColor: Colors.grey.shade100,
//                           side: BorderSide(
//                             color: selected
//                                 ? const Color(0xFF002997)
//                                 : Colors.grey.shade300,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               // ── HEADER FIELDS ──────────────────────────────────────────
//               _buildSectionCard(
//                 title: 'Inspection Details',
//                 child: Column(
//                   children: [
//                     _buildTextField(
//                       controller.locationCtrl,
//                       'Location',
//                       Icons.location_on_outlined,
//                       maxLines: null,
//                       readOnly: true,
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildTextField(
//                             controller.dateCtrl,
//                             'Date of Inspection',
//                             Icons.calendar_today_outlined,
//                             readOnly: true,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _buildTextField(
//                             controller.timeCtrl,
//                             'Time',
//                             Icons.access_time_outlined,
//                             readOnly: true,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     _buildTextField(
//                       controller.circleDivCtrl,
//                       'Circle / Division / Sub Division',
//                       Icons.account_tree_outlined,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               // ── STAFF INFO ─────────────────────────────────────────────
//               _buildSectionCard(
//                 title: 'Staff Information',
//                 child: Column(
//                   children: [
//                     _buildTextField(
//                       controller.supervisorCtrl,
//                       'Supervisor',
//                       Icons.person_outlined,
//                     ),
//                     const SizedBox(height: 10),
//                     _buildTextField(
//                       controller.staffDetailCtrl,
//                       'Detail of Staff',
//                       Icons.group_outlined,
//                     ),
//                     const SizedBox(height: 10),
//                     _buildTextField(
//                       controller.natureOfWorkCtrl,
//                       'Nature of Work',
//                       Icons.construction_outlined,
//                       maxLines: 2,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               // ── CHECKLIST TABLE ────────────────────────────────────────
//               _buildSectionCard(
//                 title: 'HSE Checklist',
//                 child: Column(
//                   children: [
//                     // Table header
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF002997),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: const Row(
//                         children: [
//                           SizedBox(
//                             width: 30,
//                             child: Text(
//                               'Sr.',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           Expanded(
//                             flex: 3,
//                             child: Text(
//                               'Description',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 110,
//                             child: Text(
//                               'Yes / No / NA',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 11,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     // Rows
//                     Obx(
//                           () => ListView.separated(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: controller.checklistRows.length,
//                         separatorBuilder: (_, __) =>
//                             Divider(height: 1, color: Colors.grey.shade200),
//                         itemBuilder: (context, index) {
//                           final row = controller.checklistRows[index];
//                           return _buildChecklistRow(controller, index, row);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//
//
//               // ── NON-COMPLIANCE REPORT ──────────────────────────────────
//               _buildSectionCard(
//                 title: 'Non-Compliance Report',
//                 child: Column(
//                   children: [
//                     // Table header
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade700,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: const Row(
//                         children: [
//                           SizedBox(
//                             width: 28,
//                             child: Text(
//                               'Sr.',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 11,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           Expanded(
//                             child: Text(
//                               'Description',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 11,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               'Immediate Action',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 11,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               'Responsible Person',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 11,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Obx(
//                       () => ListView.separated(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: controller.nonComplianceRows.length,
//                         separatorBuilder: (_, __) =>
//                             Divider(height: 1, color: Colors.grey.shade200),
//                         itemBuilder: (context, index) =>
//                             _buildNonComplianceRow(controller, index),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton.icon(
//                         onPressed: controller.addNonComplianceRow,
//                         icon: const Icon(Icons.add_circle_outline, size: 18),
//                         label: const Text('Add Row'),
//                         style: TextButton.styleFrom(
//                           foregroundColor: Colors.red.shade700,
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
// // ── OBSERVATIONS / REMARKS ─────────────────────────────────
//               _buildSectionCard(
//                 title: 'Observations & Remarks',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Add observations for each checklist item above, or general remarks below:',
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildTextField(
//                       controller.remarksCtrl,
//                       'Remarks (If Any)',
//                       Icons.notes_outlined,
//                       maxLines: 3,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // ── FOOTER ────────────────────────────────────────────────
//               _buildSectionCard(
//                 title: 'Forwarding Details',
//                 child: Column(
//                   children: [
//                     _buildTextField(
//                       controller.nameDesignationCtrl,
//                       'Name / Designation',
//                       Icons.badge_outlined,
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF002997).withOpacity(0.06),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: const Color(0xFF002997).withOpacity(0.2),
//                         ),
//                       ),
//                       child: const Row(
//                         children: [
//                           Icon(
//                             Icons.send_outlined,
//                             color: Color(0xFF002997),
//                             size: 16,
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Report forwarded to Director (HSE) MEPCO.',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Color(0xFF002997),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // ── SUBMIT BUTTON ─────────────────────────────────────────
//               Obx(
//                     () => SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: controller.isLoading.value
//                         ? null
//                         : controller.submitForm,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF002997),
//                       foregroundColor: Colors.white,
//                       disabledBackgroundColor: Colors.grey.shade300,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 2,
//                     ),
//                     child: controller.isLoading.value
//                         ? const SizedBox(
//                       width: 22,
//                       height: 22,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2.5,
//                       ),
//                     )
//                         : const Text(
//                       'Submit HSE Field Check',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── WIDGETS ────────────────────────────────────────────────────────────────
//
//   Widget _buildTitle() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF001f7a), Color(0xFF002997)],
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           // const Text(
//           //   'MEPCO',
//           //   style: TextStyle(
//           //     color: Colors.white,
//           //     fontSize: 16,
//           //     fontWeight: FontWeight.w800,
//           //     letterSpacing: 3,
//           //   ),
//           // ),
//           const SizedBox(height: 4),
//           const Text(
//             'HSE FIELD CHECK PERFORMA',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1,
//             ),
//           ),
//           const SizedBox(height: 2),
//           // Text(
//           //   'Multan Electric Power Company',
//           //   style: TextStyle(
//           //     color: Colors.white.withOpacity(0.8),
//           //     fontSize: 11,
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionCard({required String title, required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade100,
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 16,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF002997),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField(
//       TextEditingController ctrl,
//       String label,
//       IconData icon, {
//         int? maxLines = 1,
//         bool readOnly = false,
//       }) {
//     return TextFormField(
//       controller: ctrl,
//       maxLines: maxLines,
//       readOnly: readOnly,
//       style: TextStyle(
//         fontSize: 14,
//         color: readOnly ? Colors.grey.shade700 : Colors.black87,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//         prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
//         filled: true,
//         fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(
//             color: readOnly ? Colors.grey.shade300 : const Color(0xFF002997),
//             width: readOnly ? 1 : 1.5,
//           ),
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: (maxLines == null || maxLines > 1) ? 12 : 0,
//         ),
//         isDense: true,
//       ),
//     );
//   }
//
//   Widget _buildChecklistRow(
//       HseFieldCheckController controller,
//       int index,
//       dynamic row,
//       ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Sr. No
//           SizedBox(
//             width: 30,
//             child: Text(
//               '${row.srNo}',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13,
//                 color: Color(0xFF002997),
//               ),
//             ),
//           ),
//           // Description + Observation field
//           Expanded(
//             flex: 3,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   row.description,
//                   style: const TextStyle(fontSize: 13, color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 TextFormField(
//                   initialValue: row.observations,
//                   onChanged: (v) => controller.setObservation(index, v),
//                   style: const TextStyle(fontSize: 12),
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: InputDecoration(
//                     hintText: 'Observation...',
//                     hintStyle: TextStyle(
//                       fontSize: 11,
//                       color: Colors.grey.shade400,
//                     ),
//                     isDense: true,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 6,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: Colors.grey.shade300),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: const BorderSide(color: Color(0xFF002997)),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey.shade50,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           // Yes / No / NA buttons
//           SizedBox(
//             width: 110,
//             child: Obx(() {
//               final response = controller.checklistRows[index].response;
//               return Column(
//                 children: ['Yes', 'No', 'NA'].map((opt) {
//                   final isSelected = response == opt;
//                   Color selectedColor;
//                   if (opt == 'Yes')
//                     selectedColor = Colors.green.shade600;
//                   else if (opt == 'No')
//                     selectedColor = Colors.red.shade600;
//                   else
//                     selectedColor = Colors.orange.shade600;
//
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 3),
//                     child: GestureDetector(
//                       onTap: () => controller.setResponse(index, opt),
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(vertical: 4),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? selectedColor.withOpacity(0.15)
//                               : Colors.grey.shade100,
//                           borderRadius: BorderRadius.circular(5),
//                           border: Border.all(
//                             color: isSelected
//                                 ? selectedColor
//                                 : Colors.grey.shade300,
//                             width: isSelected ? 1.5 : 1,
//                           ),
//                         ),
//                         child: Text(
//                           opt,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: isSelected
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                             color: isSelected
//                                 ? selectedColor
//                                 : Colors.grey.shade600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNonComplianceRow(HseFieldCheckController controller, int index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Sr. No
//           SizedBox(
//             width: 28,
//             child: Column(
//               children: [
//                 Text(
//                   '${index + 1}',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                     color: Colors.red.shade700,
//                   ),
//                 ),
//                 if (controller.nonComplianceRows.length > 1)
//                   IconButton(
//                     onPressed: () => controller.removeNonComplianceRow(index),
//                     icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 16),
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//               ],
//             ),
//           ),
//           // Description
//           Expanded(
//             child: TextFormField(
//               onChanged: (v) =>
//                   controller.setNonComplianceField(index, 'description', v),
//               style: const TextStyle(fontSize: 12),
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//               decoration: _ncInputDecoration('Description'),
//             ),
//           ),
//           const SizedBox(width: 4),
//           // Immediate Action
//           Expanded(
//             child: TextFormField(
//               onChanged: (v) =>
//                   controller.setNonComplianceField(index, 'immediateAction', v),
//               style: const TextStyle(fontSize: 12),
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//               decoration: _ncInputDecoration('Action Taken'),
//             ),
//           ),
//           const SizedBox(width: 4),
//           // Responsible Person
//           Expanded(
//             child: TextFormField(
//               onChanged: (v) => controller.setNonComplianceField(
//                 index,
//                 'responsiblePerson',
//                 v,
//               ),
//               style: const TextStyle(fontSize: 12),
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//               decoration: _ncInputDecoration('Responsible'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   InputDecoration _ncInputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
//       isDense: true,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(6),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(6),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(6),
//         borderSide: BorderSide(color: Colors.red.shade400),
//       ),
//       filled: true,
//       fillColor: Colors.grey.shade50,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/hse_field_check_controller.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';

class HseFieldCheckScreen extends StatefulWidget {
  const HseFieldCheckScreen({super.key});

  @override
  State<HseFieldCheckScreen> createState() => _HseFieldCheckScreenState();
}

class _HseFieldCheckScreenState extends State<HseFieldCheckScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage--);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HseFieldCheckController controller =
    Get.find<HseFieldCheckController>();

    return Scaffold(
      extendBody: true,
      body: MainLayout(
        title: 'HSE Field Check',
        child: Column(
          children: [
            // ── TITLE + STEP INDICATOR (always visible) ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  _buildTitle(),
                  const SizedBox(height: 10),
                  _buildStepIndicator(),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            // ── PAGE CONTENT ─────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPage1(controller),
                  _buildPage2(controller),
                  _buildPage3(controller),
                ],
              ),
            ),

            // ── BOTTOM NAVIGATION ────────────────────────────────────────
            _buildBottomNav(controller),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE 1 — Inspection Type, Inspection Details, Staff Information
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPage1(HseFieldCheckController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── INSPECTION TYPE ───────────────────────────────────────────
          _buildSectionCard(
            title: 'Inspection Type',
            icon: Icons.search_outlined,
            accentColor: const Color(0xFF002997),
            child: Obx(
                  () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Routine', 'Surprise', 'Follow-up'].map((type) {
                  final selected = controller.inspectionType.value == type;
                  return ChoiceChip(
                    label: Text(
                      type,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) => controller.inspectionType.value = type,
                    selectedColor: const Color(0xFF002997),
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF002997)
                          : Colors.grey.shade300,
                      width: selected ? 1.5 : 1,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── INSPECTION DETAILS ────────────────────────────────────────
          _buildSectionCard(
            title: 'Inspection Details',
            icon: Icons.info_outline,
            accentColor: const Color(0xFF002997),
            child: Column(
              children: [
                _buildTextField(
                  controller.locationCtrl,
                  'Location',
                  Icons.location_on_outlined,
                  maxLines: null,
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller.dateCtrl,
                        'Date of Inspection',
                        Icons.calendar_today_outlined,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller.timeCtrl,
                        'Time',
                        Icons.access_time_outlined,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller.circleDivCtrl,
                  'Circle / Division / Sub Division',
                  Icons.account_tree_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── STAFF INFORMATION ─────────────────────────────────────────
          _buildSectionCard(
            title: 'Staff Information',
            icon: Icons.group_outlined,
            accentColor: const Color(0xFF002997),
            child: Column(
              children: [
                _buildTextField(
                  controller.supervisorCtrl,
                  'Supervisor',
                  Icons.person_outlined,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller.staffDetailCtrl,
                  'Detail of Staff',
                  Icons.groups_outlined,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller.natureOfWorkCtrl,
                  'Nature of Work',
                  Icons.construction_outlined,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE 2 — HSE Checklist (increased font sizes)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPage2(HseFieldCheckController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'HSE Checklist',
            icon: Icons.checklist_outlined,
            accentColor: const Color(0xFF002997),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF002997),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          'Sr.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 115,
                        child: Text(
                          'Yes / No / NA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Checklist Rows
                Obx(
                      () => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.checklistRows.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final row = controller.checklistRows[index];
                      return _buildChecklistRow(controller, index, row);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE 3 — Non-Compliance, Observations, Forwarding, Submit
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPage3(HseFieldCheckController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── NON-COMPLIANCE REPORT ─────────────────────────────────────
          _buildSectionCard(
            title: 'Non-Compliance Report',
            icon: Icons.warning_amber_outlined,
            accentColor: Colors.red.shade700,
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          'Sr.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Immediate Action',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Responsible Person',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Non-Compliance Rows
                Obx(
                      () => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.nonComplianceRows.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, index) =>
                        _buildNonComplianceRow(controller, index),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: controller.addNonComplianceRow,
                    icon: Icon(Icons.add_circle_outline,
                        size: 20, color: Colors.red.shade700),
                    label: Text(
                      'Add Row',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── OBSERVATIONS & REMARKS ────────────────────────────────────
          _buildSectionCard(
            title: 'Observations & Remarks',
            icon: Icons.notes_outlined,
            accentColor: const Color(0xFF002997),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Add observations for each checklist item above, or general remarks below:',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller.remarksCtrl,
                  'Remarks (If Any)',
                  Icons.notes_outlined,
                  maxLines: 4,
                  fontSize: 15,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── FORWARDING DETAILS ────────────────────────────────────────
          _buildSectionCard(
            title: 'Forwarding Details',
            icon: Icons.send_outlined,
            accentColor: const Color(0xFF002997),
            child: Column(
              children: [
                _buildTextField(
                  controller.nameDesignationCtrl,
                  'Name / Designation',
                  Icons.badge_outlined,
                  fontSize: 15,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF002997).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF002997).withOpacity(0.25),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.send_outlined,
                        color: Color(0xFF002997),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Report forwarded to Director (HSE) MEPCO.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF002997),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── SUBMIT BUTTON ─────────────────────────────────────────────
          Obx(
                () => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002997),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Submit HSE Field Check',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF001f7a), Color(0xFF002997)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'HSE FIELD CHECK PERFORMA',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Basic Info', 'Checklist', 'Report & Submit'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentPage;
          final isDone = i < _currentPage;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isDone
                              ? Colors.green.shade500
                              : isActive
                              ? const Color(0xFF002997)
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          boxShadow: isActive
                              ? [
                            BoxShadow(
                              color: const Color(0xFF002997)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                              : [],
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check,
                              color: Colors.white, size: 17)
                              : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                              ? const Color(0xFF002997)
                              : Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: isDone
                            ? LinearGradient(colors: [
                          Colors.green.shade400,
                          Colors.green.shade300
                        ])
                            : null,
                        color: isDone ? null : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomNav(HseFieldCheckController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _prevPage,
                icon: const Icon(Icons.arrow_back_ios_new, size: 15),
                label: const Text(
                  'Previous',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF002997),
                  side: const BorderSide(color: Color(0xFF002997), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

          if (_currentPage > 0) const SizedBox(width: 12),

          // Next Button (only on pages 0 and 1)
          if (_currentPage < 2)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _nextPage,
                icon: const Text(
                  'Next',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                label: const Icon(Icons.arrow_forward_ios, size: 15),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002997),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color accentColor = const Color(0xFF002997),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        int? maxLines = 1,
        bool readOnly = false,
        double fontSize = 14,
      }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      readOnly: readOnly,
      style: TextStyle(
        fontSize: fontSize,
        color: readOnly ? Colors.grey.shade700 : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        TextStyle(color: Colors.grey.shade600, fontSize: fontSize - 1),
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: readOnly ? Colors.grey.shade300 : const Color(0xFF002997),
            width: readOnly ? 1 : 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: (maxLines == null || maxLines > 1) ? 14 : 0,
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildChecklistRow(
      HseFieldCheckController controller,
      int index,
      dynamic row,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sr. No
          SizedBox(
            width: 36,
            child: Text(
              '${row.srNo}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF002997),
              ),
            ),
          ),
          // Description + Observation
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: row.observations,
                  onChanged: (v) => controller.setObservation(index, v),
                  style: const TextStyle(fontSize: 13),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Add observation...',
                    hintStyle:
                    TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                      const BorderSide(color: Color(0xFF002997)),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Yes / No / NA
          SizedBox(
            width: 115,
            child: Obx(() {
              final response = controller.checklistRows[index].response;
              return Column(
                children: ['Yes', 'No', 'NA'].map((opt) {
                  final isSelected = response == opt;
                  Color selectedColor;
                  if (opt == 'Yes')
                    selectedColor = Colors.green.shade600;
                  else if (opt == 'No')
                    selectedColor = Colors.red.shade600;
                  else
                    selectedColor = Colors.orange.shade600;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GestureDetector(
                      onTap: () => controller.setResponse(index, opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withOpacity(0.12)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? selectedColor
                                : Colors.grey.shade300,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          opt,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? selectedColor
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNonComplianceRow(
      HseFieldCheckController controller, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sr. No + Delete
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Text(
                  '${index + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.red.shade700,
                  ),
                ),
                if (controller.nonComplianceRows.length > 1)
                  GestureDetector(
                    onTap: () => controller.removeNonComplianceRow(index),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(Icons.remove_circle_outline,
                          color: Colors.red.shade400, size: 18),
                    ),
                  ),
              ],
            ),
          ),
          // Description
          Expanded(
            child: TextFormField(
              onChanged: (v) =>
                  controller.setNonComplianceField(index, 'description', v),
              style: const TextStyle(fontSize: 13),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: _ncInputDecoration('Description'),
            ),
          ),
          const SizedBox(width: 6),
          // Immediate Action
          Expanded(
            child: TextFormField(
              onChanged: (v) => controller.setNonComplianceField(
                  index, 'immediateAction', v),
              style: const TextStyle(fontSize: 13),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: _ncInputDecoration('Action Taken'),
            ),
          ),
          const SizedBox(width: 6),
          // Responsible Person
          Expanded(
            child: TextFormField(
              onChanged: (v) => controller.setNonComplianceField(
                  index, 'responsiblePerson', v),
              style: const TextStyle(fontSize: 13),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: _ncInputDecoration('Responsible'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _ncInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}