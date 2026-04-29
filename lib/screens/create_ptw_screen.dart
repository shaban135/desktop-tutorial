import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/create_ptw_controller.dart';

import 'package:mepco_esafety_app/widgets/bottom_navigation_buttons.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
import 'package:mepco_esafety_app/widgets/upload_button.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mepco_esafety_app/widgets/geo_fencing_section.dart';

class CreatePtwScreen extends StatelessWidget {
  const CreatePtwScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final bool isEdit = args['mode'] == 'edit';
    final int? ptwId = args['ptw_id'];

    final CreatePtwController controller = Get.put(
      CreatePtwController(isEdit: isEdit, ptwId: ptwId),
    );

    // Show popup only when creating new PTW (not in edit mode)
    if (!isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPtwTypeSelectionDialog(context, controller);
      });
    }

    return Scaffold(
      extendBody: true,
      body: MainLayout(
        title: isEdit
            ? 'Edit Permit To Work \n کام کرنے کا اجازت نامہ '
            : 'Create Permit To Work \n کام کرنے کا اجازت نامہ ',
        child: Obx(() {
          if (controller.isFetchingContext.value) {
            return _buildShimmerLoading();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 50),
            children: [
              _buildFieldWithTitle(
                'Date',
                'تاریخ',
                GestureDetector(
                  onTap: () => controller.selectDate(context),
                  child: AbsorbPointer(
                    child: CustomTextFormField(
                      controller: controller.dateController,
                      labelText: 'dd/mm/yyyy',
                      suffixIcon: Icons.calendar_today_outlined,
                      readOnly: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFieldWithTitle(
                'Sub Division',
                'سب ڈویژن',
                CustomTextFormField(
                  controller: controller.subDivisionController,
                  labelText: '',
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 16),
              _buildBilingualText('Routine / Emergency', 'معمول / ایمرجنسی'),
              _buildRoutineEmergencySelector(controller),

              // NEW: MISC Section with Reference Number and PTW Required
              Obx(() {
                if (controller.selectedOption.value == RoutineEmergency.MISC) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: _buildMiscDropdown(controller),
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        final misc = (controller.selectedMiscOption.value ?? '')
                            .trim();
                        final title = misc.isEmpty
                            ? 'Reference Number'
                            : '$misc Number';
                        final urduTitle = misc.isEmpty
                            ? 'حوالہ نمبر'
                            : '$misc نمبر';

                        return _buildFieldWithTitle(
                          title,
                          urduTitle,
                          CustomTextFormField(
                            controller: controller.referenceNumberController,
                            labelText: misc.isEmpty
                                ? 'Enter reference number'
                                : 'Enter $misc number',
                          ),
                        );
                      }),

                      const SizedBox(height: 16),
                      _buildFieldWithTitle(
                        'PTW Required',
                        'پی ٹی ڈبلیو ضروری ہے',
                        _buildPtwRequiredRadioSelector(controller),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),

              // Wrap all remaining fields in Obx to hide when PTW not required
              Obx(() {
                // Show all fields if not MISC or if PTW is required
                final shouldShowFields =
                    controller.selectedOption.value != RoutineEmergency.MISC ||
                        controller.isPtwRequired.value;

                if (!shouldShowFields) {
                  return Column(
                    children: [
                      _buildFieldWithTitle(
                        'Feeder/line Details',
                        ' فیڈر/لائن کی تفصیلات',
                        Obx(() =>  _buildNoPrimaryFeederDropdown(context, controller),),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldWithTitle(
                        'Asset identification (pole/tower/transformer/overhead line/cable, etc.)',
                        'اثاثہ شناخت کھمبا/ٹاور/ٹرانسفارمر/اوورہیڈ لائن/کیبل وغیرہ',
                        Obx(() {
                          if (controller.isFetchingTransformers.value) {
                            return const ShimmerWidget.rectangular(height: 56);
                          }
                          return DropdownButtonFormField<int>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Select an asset',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEAEAEA),
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEAEAEA),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            initialValue: controller.selectedTransformerId.value,
                            items: controller.transformers.map((transformer) {
                              return DropdownMenuItem<int>(
                                value: transformer.id,
                                child: Text(
                                  '${transformer.transformerId}, ${transformer.address}',
                                  style: TextStyle(fontSize: 14),
                                  overflow: TextOverflow.clip,
                                ),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              controller.selectedTransformerId.value = newValue;
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldWithTitle(
                        'Place of Work',
                        'کام کی جگہ',
                        CustomTextFormField(
                          controller: controller.placeOfWorkController,
                          labelText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldWithTitle(
                        'Team member',
                        'ٹیم کے ارکان',
                        MultiSelectDialogField<TeamMember>(
                          items: controller.teamMembers
                              .map(
                                (member) => MultiSelectItem<TeamMember>(
                              member,
                              member.name,
                            ),
                          )
                              .toList(),
                          listType: MultiSelectListType.CHIP,
                          onConfirm: (values) {
                            controller.selectedTeamMemberIds.value = values
                                .map((e) => e.id)
                                .toList();
                          },
                          buttonText: const Text('Select team members'),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEAEAEA),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          initialValue: controller.teamMembers
                              .where(
                                (m) => controller.selectedTeamMemberIds.contains(
                              m.id,
                            ),
                          )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldWithTitle(
                        'Description / Scope of Work',
                        'کام کی تفصیل (اسکوپ)',
                        CustomTextFormField(
                          controller: controller.descriptionController,
                          labelText: '',
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildFieldWithTitle(
                      'Feeder/line to be switched off *',
                      'کون سا فیڈر/لائن بند کی جائے گی؟',
                      Obx(() => _buildCircuitSelector(context, controller)),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldWithTitle(
                      'Asset identification (pole/tower/transformer/overhead line/cable, etc.)',
                      'اثاثہ شناخت کھمبا/ٹاور/ٹرانسفارمر/اوورہیڈ لائن/کیبل وغیرہ',
                      Obx(() {
                        if (controller.isFetchingTransformers.value) {
                          return const ShimmerWidget.rectangular(height: 56);
                        }
                        return DropdownButtonFormField<int>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Select an asset',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFEAEAEA),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFEAEAEA),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2,
                              ),
                            ),
                          ),
                          initialValue: controller.selectedTransformerId.value,
                          items: controller.transformers.map((transformer) {
                            return DropdownMenuItem<int>(
                              value: transformer.id,
                              child: Text(
                                '${transformer.transformerId}, ${transformer.address}',
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.clip,
                              ),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            controller.selectedTransformerId.value = newValue;
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 16),
                    Obx(() {
                      if (controller.selectedOption.value ==
                          RoutineEmergency.PLANNED) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFieldWithTitle(
                                  'Switch-off Time',
                                  'بجلی بند کرنے کا وقت',
                                  GestureDetector(
                                    onTap: () => controller.selectTime(
                                      context,
                                      controller.switchOffTimeController,
                                    ),
                                    child: AbsorbPointer(
                                      child: CustomTextFormField(
                                        controller:
                                        controller.switchOffTimeController,
                                        labelText: '-- : --',
                                        suffixIcon: Icons.access_time,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFieldWithTitle(
                                  'Restore Time',
                                  'بحالی بجلی ka وقت',
                                  GestureDetector(
                                    onTap: () => controller.selectTime(
                                      context,
                                      controller.restoreTimeController,
                                    ),
                                    child: AbsorbPointer(
                                      child: CustomTextFormField(
                                        controller:
                                        controller.restoreTimeController,
                                        labelText: '-- : --',
                                        suffixIcon: Icons.access_time,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFieldWithTitle(
                            'Estimated Duration Min',
                            'تخمینی مدت منٹ',
                            CustomTextFormField(
                              controller:
                              controller.estimatedDurationMinController,
                              labelText: '',
                              readOnly: true,
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    _buildFieldWithTitle(
                      'Feeder In-charge',
                      'فیڈر انچارج',
                      CustomTextFormField(
                        controller: controller.feederInchargeController,
                        labelText: '',
                        readOnly: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldWithTitle(
                      'Place of Work',
                      'کام کی جگہ',
                      CustomTextFormField(
                        controller: controller.placeOfWorkController,
                        labelText: '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    GeoFencingSection(
                      isFetchingLocation: controller.isFetchingLocation,
                      currentLocation: controller.currentLocation,
                      onMapCreated: (GoogleMapController mapController) {
                        controller.googleMapController = mapController;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFieldWithTitle(
                      'Team member',
                      'ٹیم کے ارکان',
                      MultiSelectDialogField<TeamMember>(
                        items: controller.teamMembers
                            .map(
                              (member) => MultiSelectItem<TeamMember>(
                            member,
                            member.name,
                          ),
                        )
                            .toList(),
                        listType: MultiSelectListType.CHIP,
                        onConfirm: (values) {
                          controller.selectedTeamMemberIds.value = values
                              .map((e) => e.id)
                              .toList();
                        },
                        buttonText: const Text('Select team members'),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFEAEAEA),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        initialValue: controller.teamMembers
                            .where(
                              (m) => controller.selectedTeamMemberIds.contains(
                            m.id,
                          ),
                        )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldWithTitle(
                      'Description / Scope of Work',
                      'کام کی تفصیل (اسکوپ)',
                      CustomTextFormField(
                        controller: controller.descriptionController,
                        labelText: '',
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldWithTitle(
                      'Safety arrangements (barricading, earthing, etc.)',
                      'حفاظتی انتظامات (بیریکیڈنگ، ارتھنگ وغیرہ)',
                      CustomTextFormField(
                        controller: controller.safetyArrangementsController,
                        labelText: '',
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildAttachmentsSection(controller),
                    const SizedBox(height: 20),
                  ],
                );
              }),
              const SizedBox(height: 20),
              // Bottom Navigation Buttons with dynamic text
              Obx(() {
                final isMiscWithoutPtw =
                    controller.selectedOption.value == RoutineEmergency.MISC &&
                        !controller.isPtwRequired.value;

                return BottomNavigationButtons(
                  onBackPressed: controller.isSubmitting.value
                      ? null
                      : () => Get.back(),
                  onNextPressed: controller.isSubmitting.value
                      ? null
                      : controller.submitPtw,
                  isSubmitting: controller.isSubmitting.value,
                  nextText: isMiscWithoutPtw ? 'Forward to SDO' : 'Next',
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  // NEW METHOD: Show PTW Type Selection Dialog
  void _showPtwTypeSelectionDialog(BuildContext context, CreatePtwController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0C3495), Color(0xFF002171)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Select PTW Type',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C3495),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'پی ٹی ڈبلیو کی قسم منتخب کریں',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // PLANNED Button
                  _buildTypeSelectionButton(
                    context: context,
                    controller: controller,
                    title: 'PLANNED',
                    subtitle: 'Scheduled work with prior arrangement',
                    urduSubtitle: 'منصوبہ بند کام',
                    icon: Icons.calendar_today_rounded,
                    gradientColors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                    onTap: () {
                      controller.selectedOption.value = RoutineEmergency.PLANNED;
                      Get.back();
                      Future.delayed(const Duration(milliseconds: 200), () {
                        controller.showPlannedScheduleDialog(context);
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  // EMERGENCY Button
                  _buildTypeSelectionButton(
                    context: context,
                    controller: controller,
                    title: 'EMERGENCY',
                    subtitle: 'Urgent unplanned work required',
                    urduSubtitle: 'فوری ایمرجنسی کام',
                    icon: Icons.flash_on_rounded,
                    gradientColors: [Color(0xFFD32F2F), Color(0xFFC62828)],
                    onTap: () {
                      controller.selectedOption.value = RoutineEmergency.EMERGENCY;
                      Get.back();
                    },
                  ),

                  const SizedBox(height: 14),

                  // MISC Button
                  _buildTypeSelectionButton(
                    context: context,
                    controller: controller,
                    title: 'MISC',
                    subtitle: 'Other types of work orders',
                    urduSubtitle: 'دیگر اقسام کے کام',
                    icon: Icons.category_rounded,
                    gradientColors: [Color(0xFFF57C00), Color(0xFFEF6C00)],
                    onTap: () {
                      controller.selectedOption.value = RoutineEmergency.MISC;
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // NEW METHOD: Build Professional Type Selection Button
  Widget _buildTypeSelectionButton({
    required BuildContext context,
    required CreatePtwController controller,
    required String title,
    required String subtitle,
    required String urduSubtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: gradientColors[0].withOpacity(0.2),
        highlightColor: gradientColors[0].withOpacity(0.1),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientColors[0].withOpacity(0.08),
                gradientColors[1].withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: gradientColors[0].withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Icon Container with Gradient
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),

                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: gradientColors[1],
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        urduSubtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gradientColors[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: gradientColors[0],
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        _buildShimmerField(),
        const SizedBox(height: 16),
        _buildShimmerField(),
        const SizedBox(height: 16),
        _buildShimmerField(),
        const SizedBox(height: 16),
        _buildShimmerField(),
        const SizedBox(height: 16),
        _buildShimmerField(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildShimmerField()),
            const SizedBox(width: 16),
            Expanded(child: _buildShimmerField()),
          ],
        ),
        const SizedBox(height: 16),
        _buildShimmerField(),
        const SizedBox(height: 16),
        _buildShimmerField(),
        const SizedBox(height: 16),
        _buildShimmerField(),
        const SizedBox(height: 16),
        const ShimmerWidget.rectangular(height: 150),
        const SizedBox(height: 16),
        _buildShimmerField(),
      ],
    );
  }

  Widget _buildShimmerField() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerWidget.rectangular(height: 16, width: 150),
        SizedBox(height: 8),
        ShimmerWidget.rectangular(height: 12, width: 100),
        SizedBox(height: 8),
        ShimmerWidget.rectangular(height: 56),
      ],
    );
  }

  Widget _buildBilingualText(String english, String urdu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            english,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(urdu, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFieldWithTitle(String title, String urduTitle, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildBilingualText(title, urduTitle), field],
    );
  }

  Widget _buildRoutineEmergencySelector(CreatePtwController controller) {
    return Obx(
          () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSmallRadioButton(
            'PLANNED',
            RoutineEmergency.PLANNED,
            controller,
            onTap: () {
              controller.selectedOption.value = RoutineEmergency.PLANNED;
              Future.delayed(const Duration(milliseconds: 100), () {
                controller.showPlannedScheduleDialog(Get.context!);
              });
            },
          ),
          _buildSmallRadioButton(
            'EMERGENCY',
            RoutineEmergency.EMERGENCY,
            controller,
          ),
          _buildSmallRadioButton('MISC', RoutineEmergency.MISC, controller),
        ],
      ),
    );
  }

  Widget _buildCircuitSelector(
      BuildContext context,
      CreatePtwController controller,
      ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircuitRadioButton(
              'Single Circuit',
              CircuitType.SINGLE,
              controller,
            ),
            _buildCircuitRadioButton(
              'Multi Circuit',
              CircuitType.MULTI,
              controller,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (controller.selectedCircuitType.value == CircuitType.SINGLE ||
            controller.selectedCircuitType.value == CircuitType.MULTI)
          _buildPrimaryFeederDropdown(context, controller),
        const SizedBox(height: 16),
        if (controller.selectedCircuitType.value == CircuitType.MULTI)
          _buildSecondaryFeederMultiSelect(context, controller),
      ],
    );
  }

  Widget _buildPtwRequiredRadioSelector(CreatePtwController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPtwRequiredRadioButton('Yes', true, controller),
        _buildPtwRequiredRadioButton('No', false, controller),
      ],
    );
  }

  Widget _buildPtwRequiredRadioButton(
      String text,
      bool value,
      CreatePtwController controller,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Obx(
                () => Radio<bool>(
              value: value,
              groupValue: controller.isPtwRequired.value,
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  controller.isPtwRequired.value = newValue;
                }
              },
              activeColor: Color(0xFF0C3495),
            ),
          ),
        ),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildNoPrimaryFeederDropdown(
      BuildContext context,
      CreatePtwController controller,
      ) {
    return DropdownSearch<int>(
      popupProps: PopupProps.bottomSheet(
        showSearchBox: true,
        constraints: BoxConstraints(maxHeight: Get.height * 0.82),
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search Primary Feeder...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        bottomSheetProps: const BottomSheetProps(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
          ),
        ),
      ),

      items: controller.primaryFeeders.map((f) => f.id).toList(),

      itemAsString: (id) {
        final feeder = controller.primaryFeeders.firstWhere((f) => f.id == id);
        return "${feeder.name} - ${feeder.code}";
      },

      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Select the Feeder/Line",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
        ),
      ),

      selectedItem: controller.selectedFeederId.value,

      onChanged: (value) {
        controller.selectedFeederId.value = value;
        if (value != null) {
          controller.fetchTransformers(value);
        }
      },
    );
  }

  Widget _buildPrimaryFeederDropdown(
      BuildContext context,
      CreatePtwController controller,
      ) {
    return DropdownSearch<int>(
      popupProps: PopupProps.bottomSheet(
        showSearchBox: true,
        constraints: BoxConstraints(maxHeight: Get.height * 0.82),
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search Primary Feeder...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        bottomSheetProps: const BottomSheetProps(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
          ),
        ),
      ),

      items: controller.primaryFeeders.map((f) => f.id).toList(),

      itemAsString: (id) {
        final feeder = controller.primaryFeeders.firstWhere((f) => f.id == id);
        return "${feeder.name} - ${feeder.code}";
      },

      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Feeder to apply PTW",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
        ),
      ),

      selectedItem: controller.selectedFeederId.value,

      onChanged: (value) {
        controller.selectedFeederId.value = value;
        if (value != null) {
          controller.fetchTransformers(value);
        }
      },
    );
  }

  Widget _buildSecondaryFeederMultiSelect(
      BuildContext context,
      CreatePtwController controller,
      ) {
    return DropdownSearch<Feeder>.multiSelection(
      items: controller.secondaryFeeders,

      itemAsString: (f) => "${f.name} (${f.code})",

      popupProps: PopupPropsMultiSelection.bottomSheet(
        showSearchBox: true,
        showSelectedItems: false,
        constraints: BoxConstraints(maxHeight: Get.height * 0.82),
        bottomSheetProps: const BottomSheetProps(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
          ),
        ),

        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search Secondary feeders...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.search),
          ),
        ),

        itemBuilder: (context, item, isSelected) {
          return ListTile(title: Text("${item.name} (${item.code})"));
        },
      ),

      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Feeders for Safety Purpose",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(color: Color(0xFFEAEAEA), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(color: Color(0xFFEAEAEA), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),

      selectedItems: controller.secondaryFeeders
          .where((f) => controller.selectedSecondaryFeederIds.contains(f.id))
          .toList(),

      onChanged: (selectedFeeders) {
        controller.selectedSecondaryFeederIds.value = selectedFeeders
            .map((f) => f.id)
            .toList();
      },
    );
  }

  Widget _buildCircuitRadioButton(
      String text,
      CircuitType value,
      CreatePtwController controller,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Radio<CircuitType>(
            value: value,
            groupValue: controller.selectedCircuitType.value,
            onChanged: (CircuitType? newValue) {
              if (newValue != null) {
                controller.selectedCircuitType.value = newValue;
              }
            },
            activeColor: Color(0xFF0C3495),
          ),
        ),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildSmallRadioButton(
      String text,
      RoutineEmergency value,
      CreatePtwController controller, {
        VoidCallback? onTap,
      }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Radio<RoutineEmergency>(
            value: value,
            groupValue: controller.selectedOption.value,
            onChanged: (RoutineEmergency? newValue) {
              if (newValue != null) {
                if (onTap != null) {
                  onTap();
                } else {
                  controller.selectedOption.value = newValue;
                }
              }
            },
            activeColor: Color(0xFF0C3495),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (onTap != null) {
              onTap();
            } else {
              controller.selectedOption.value = value;
            }
          },
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildMiscDropdown(CreatePtwController controller) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Select MISC Type',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: const BorderSide(color: Color(0xFFEAEAEA), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      value: controller.selectedMiscOption.value,
      items: controller.miscOptions.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (String? newValue) {
        controller.selectedMiscOption.value = newValue;
      },
      dropdownColor: Colors.white,
    );
  }

  Widget _buildAttachmentsSection(CreatePtwController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Attachments (Mandatory)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text('  |  '),
            Text('منسلکات (لازمی)', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 16),
        _buildUploadItem(
          'Site snaps before work',
          'کام سے پہلے سائٹ کی تصاویر',
          controller,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildUploadItem(
      String title,
      String subtitle,
      CreatePtwController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UploadButton(onPressed: () => controller.pickImages()),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        Obx(() {
          final localPhotos = controller.sitePhotos;
          final existing = controller.existingEvidences;

          if (localPhotos.isEmpty && existing.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ...existing.map(
                      (ev) => _buildExistingImagePreview(ev, controller),
                ),
                ...localPhotos.map(
                      (photo) => _buildImagePreview(
                    photo,
                        () => controller.removeImage(photo),
                  ),
                ),
              ],
            ),
          );
        }),
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
                  colors: [Color(0xFF0D47A1), Color(0xFF002171)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingImagePreview(
      ExistingEvidence ev,
      CreatePtwController controller,
      ) {
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
                      child: Image.network(ev.url, fit: BoxFit.contain),
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
            child: Image.network(
              ev.url,
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
            onTap: () {
              controller.removeExistingEvidence(ev.id);
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF002171)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
