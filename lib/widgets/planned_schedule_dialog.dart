import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/create_ptw_controller.dart';

class PlannedScheduleDialog extends StatelessWidget {
  final CreatePtwController controller;

  const PlannedScheduleDialog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Container(
          // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule Details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'شیڈول کی تفصیلات',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(result: false),
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Range Section
                      _buildSectionHeader('Date Range', 'تاریخ کی حد', Icons.date_range),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => _buildDateField(
                              context: context,
                              label: 'From Date',
                              // urduLabel: 'سے',
                              value: controller.scheduleFromDate.value,
                              onTap: () => _selectFromDate(context),
                              icon: Icons.today_rounded,
                            )),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.arrow_forward, size: 20, color: Colors.grey.shade600),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() => _buildDateField(
                              context: context,
                              label: 'To Date',
                              // urduLabel: 'تک',
                              value: controller.scheduleToDate.value,
                              onTap: () => _selectToDate(context),
                              icon: Icons.event_rounded,
                            )),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Days Counter & Set All Button
                      Obx(() {
                        if (controller.scheduleDates.isEmpty) {
                          return _buildEmptyState();
                        }

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.blue.shade200, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.calendar_month, color: Colors.blue.shade700, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${controller.scheduleDates.length} ${controller.scheduleDates.length == 1 ? 'Day' : 'Days'}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                          Text(
                                            'Selected',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: controller.setTimeToAll,
                                    icon: const Icon(Icons.copy_all_rounded, size: 13),
                                    label: const Text('Set to All'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D47A1),
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical:8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Time Schedule Section
                            _buildSectionHeader('Time Schedule', 'وقت کی ترتیب', Icons.schedule),
                            const SizedBox(height: 16),

                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.scheduleDates.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final date = controller.scheduleDates[index];
                                return Obx(() => _buildDateRow(context, index, date));
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 1,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: controller.saveSchedule,
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Save Schedule'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }

  Widget _buildSectionHeader(String english, String urdu, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              english,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            Text(
              urdu,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    // required String urduLabel,
    required DateTime? value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final bool hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasValue ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: hasValue ? const Color(0xFF0D47A1) : Colors.grey.shade300,
            width: hasValue ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasValue ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hasValue ? const Color(0xFF0D47A1) : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    value != null ? DateFormat('dd MMM yyyy').format(value) : 'Select date',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
                      color: hasValue ? const Color(0xFF0D47A1) : Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  icon,
                  size: 20,
                  color: hasValue ? const Color(0xFF0D47A1) : Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.date_range_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Dates Selected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select From and To dates above\nto create schedule',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, int index, DateTime date) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Day ${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormat('EEE, MMM dd, yyyy').format(date),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Time Fields
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  context: context,
                  label: 'Start Time',
                  // urduLabel: 'شروع وقت',
                  time: controller.scheduleStartTimes[index],
                  onTap: () => controller.selectScheduleTime(context, index, true),
                  icon: Icons.login_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  context: context,
                  label: 'End Time',
                  // urduLabel: 'اختتام وقت',
                  time: controller.scheduleEndTimes[index],
                  onTap: () => controller.selectScheduleTime(context, index, false),
                  icon: Icons.logout_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required BuildContext context,
    required String label,
    // required String urduLabel,
    required String time,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final bool hasValue = time.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: hasValue ? const Color(0xFFE3F2FD) : Colors.white,
          border: Border.all(
            color: hasValue ? const Color(0xFF0D47A1) : Colors.grey.shade300,
            width: hasValue ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: hasValue ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: hasValue ? const Color(0xFF0D47A1) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 4),
                // Text(
                //   urduLabel,
                //   style: TextStyle(
                //     fontSize: 9,
                //     color: Colors.grey.shade500,
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.isEmpty ? '--:--' : time,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
                    color: hasValue ? const Color(0xFF0D47A1) : Colors.grey.shade400,
                  ),
                ),
                Icon(
                  icon,
                  size: 18,
                  color: hasValue ? const Color(0xFF0D47A1) : Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.scheduleFromDate.value ?? today,
      firstDate: today,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.scheduleFromDate.value = picked;
      if (controller.scheduleToDate.value != null &&
          controller.scheduleToDate.value!.isBefore(picked)) {
        controller.scheduleToDate.value = null;
      }
      if (controller.scheduleToDate.value != null) {
        controller.generateScheduleDates();
      }
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    if (controller.scheduleFromDate.value == null) {
      Get.snackbar(
        'Validation',
        'Please select From date first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final DateTime fromDate = controller.scheduleFromDate.value!;
    final DateTime maxDate = fromDate.add(const Duration(days: 5));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.scheduleToDate.value ?? fromDate,
      firstDate: fromDate,
      lastDate: maxDate,
      selectableDayPredicate: (DateTime date) {
        final difference = date.difference(fromDate).inDays;
        return difference >= 0 && difference <= 5;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.scheduleToDate.value = picked;
      controller.generateScheduleDates();
    }
  }
}