import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/ptw_list_controller.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
import '../utils/snackbar_helper.dart';

class PtwListScreen extends StatelessWidget {
  const PtwListScreen({super.key});

  static const Map<String, String?> _topFilterToStatus = {
    'All': null,
    'Execution': 'IN_EXECUTION',
    'Approved': 'XEN_APPROVED_TO_PDC',
    'Submitted': 'SUBMITTED',
    'Draft': 'DRAFT',
  };

  static final List<Map<String, String>> _statusOptions = [
    {'code': '', 'label': 'All'},
    {'code': 'DRAFT', 'label': PtwHelper.getStatusText('DRAFT')},
    {'code': 'SUBMITTED', 'label': PtwHelper.getStatusText('SUBMITTED')},
    {'code': 'SDO_RETURNED', 'label': PtwHelper.getStatusText('SDO_RETURNED')},
    {'code': 'SDO_CANCELLED', 'label': PtwHelper.getStatusText('SDO_CANCELLED')},
    {'code': 'SDO_FORWARDED_TO_XEN', 'label': PtwHelper.getStatusText('SDO_FORWARDED_TO_XEN')},
    {'code': 'XEN_RETURNED_TO_SDO', 'label': PtwHelper.getStatusText('XEN_RETURNED_TO_SDO')},
    {'code': 'XEN_REJECTED', 'label': PtwHelper.getStatusText('XEN_REJECTED')},
    {'code': 'XEN_APPROVED_TO_PDC', 'label': PtwHelper.getStatusText('XEN_APPROVED_TO_PDC')},
    {'code': 'PDC_DELEGATED_TO_GRID', 'label': PtwHelper.getStatusText('PDC_DELEGATED_TO_GRID')},
    {'code': 'GRID_PRECHECKS_DONE', 'label': PtwHelper.getStatusText('GRID_PRECHECKS_DONE')},
    {'code': 'PTW_ISSUED', 'label': PtwHelper.getStatusText('PTW_ISSUED')},
    {'code': 'IN_EXECUTION', 'label': PtwHelper.getStatusText('IN_EXECUTION')},
    {'code': 'COMPLETION_SUBMITTED', 'label': PtwHelper.getStatusText('COMPLETION_SUBMITTED')},
    {'code': 'CANCELLATION_APPROVED_BY_SDO', 'label': PtwHelper.getStatusText('CANCELLATION_APPROVED_BY_SDO')},
    {'code': 'GRID_RESTORED_AND_CLOSED', 'label': PtwHelper.getStatusText('GRID_RESTORED_AND_CLOSED')},
    {'code': 'CANCELLATION_REQUESTED_BY_LS', 'label': PtwHelper.getStatusText('CANCELLATION_REQUESTED_BY_LS')},
    {'code': 'GRID_CANCELLATION_CONFIRMED_AND_CLOSED', 'label': PtwHelper.getStatusText('GRID_CANCELLATION_CONFIRMED_AND_CLOSED')},
  ];

  @override
  Widget build(BuildContext context) {
    final PtwListController controller = Get.find<PtwListController>();

    return WillPopScope(
      onWillPop: () async {
        if (controller.searchQuery.value.isNotEmpty ||
            controller.selectedStatus.value.isNotEmpty ||
            controller.fromDate.value.isNotEmpty ||
            controller.toDate.value.isNotEmpty) {
          controller.clearFilters();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: MainLayout(
          title: 'PTW List',
          child: Obx(() => _buildPtwList(controller)),
        ),
      ),
    );
  }

  Widget _buildPtwList(PtwListController controller) {
    return Column(
      children: [
        // Search and Filter Section - stays inside white container
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              _buildSearchBar(controller),
              const SizedBox(height: 8),
              _buildFilterChips(controller),
              const SizedBox(height: 4),
            ],
          ),
        ),

        // List Body with gray background
        Expanded(
          child: Container(
            color: const Color(0xFFF5F7FA),
            child: Obx(() {
              controller.isFetching.value;
              controller.hasMore.value;

              if (controller.isLoading.value && controller.ptwList.isEmpty) {
                return _buildShimmerEffect();
              }

              if (controller.ptwList.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  controller.page.value = 1;
                  await controller.fetchPtwList();
                },
                color: AppColors.primaryBlue,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.ptwList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.ptwList.length) {
                      return Obx(() {
                        if (controller.isFetching.value && controller.hasMore.value) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: LoadingWidget()),
                          );
                        } else if (!controller.hasMore.value && controller.ptwList.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                "That's all for now",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      });
                    }

                    final ptwData = controller.ptwList[index];
                    return _buildPtwCard(ptwData, controller, index, context);
                  },
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No PTW records found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(PtwListController controller) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search by PTW code, location...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey.shade600,
            size: 20,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: Colors.grey.shade600,
                size: 18,
              ),
              onPressed: () {
                controller.searchController.clear();
                controller.searchQuery.value = '';
                controller.page.value = 1;
                controller.fetchPtwList();
              },
            );
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: (value) {
          controller.searchDebounce?.cancel();
          controller.searchDebounce = Timer(const Duration(milliseconds: 350), () {
            controller.initialMode.value = false;
            controller.searchQuery.value = value.trim();
            controller.page.value = 1;
            controller.fetchPtwList(loadMore: false);
          });
        },
      ),
    );
  }

  Widget _buildFilterChips(PtwListController controller) {
    final filters = ['All', 'Execution', 'Approved', 'Submitted', 'Draft'];
    final currentCode = controller.selectedStatus.value;
    String? currentTopKey;

    _topFilterToStatus.forEach((label, code) {
      if ((code ?? '') == currentCode) currentTopKey = label;
    });

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final label = filters[index];
                final mappedCode = _topFilterToStatus[label];
                final bool isSelected = currentTopKey == label || (label == 'All' && currentCode.isEmpty);

                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                    width: 1,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  elevation: isSelected ? 1.5 : 0,
                  shadowColor: AppColors.primaryBlue.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onSelected: (_) {
                    controller.selectedStatus.value = mappedCode ?? '';
                    controller.page.value = 1;
                    controller.fetchPtwList();
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          elevation: 0,
          child: InkWell(
            onTap: () => _openAdvancedFilterSheet(Get.context!, controller),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPtwCard(
      Map<String, dynamic> data,
      PtwListController controller,
      int index,
      BuildContext context,
      ) {
    final rawStatus = data['current_status'].toString();
    final String statusLabel = _resolveStatusLabel(rawStatus, data);
    final Color statusColor = PtwHelper.getStatusColor(rawStatus);
    final String ptwCode = data['ptw_code']?.toString() ?? data['misc_code']?.toString() ?? 'N/A';

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'N/A';
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      } catch (_) {
        return dateStr;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            trailing: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Sr.# ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        data['ptw_code'] != null ? 'PTW: $ptwCode' : 'MISC: $ptwCode',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      icon: Icons.category_outlined,
                      title: 'Type',
                      value: data['type']?.toString() ?? 'N/A',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      icon: Icons.location_on_outlined,
                      title: 'Place of Work',
                      value: data['place_of_work']?.toString() ?? 'N/A',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      icon: Icons.power_settings_new_rounded,
                      title: 'Switch Off Time',
                      value: data['switch_off_time']?.toString() ?? 'N/A',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      icon: Icons.restore_rounded,
                      title: 'Restore Time',
                      value: data['restore_time']?.toString() ?? 'N/A',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      icon: Icons.schedule_outlined,
                      title: 'Due Time',
                      value: formatDate(data['due_time']?.toString()),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Created At',
                      value: formatDate(data['created_at']?.toString()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildActionButtons(data, controller),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveStatusLabel(String rawStatus, Map<String, dynamic> data) {
    return PtwHelper.getStatusText(rawStatus);
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> data, PtwListController controller) {
    final ptwId = data['id'];
    final role = controller.currentUserRole.value;

    Widget buildActionButton({
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap,
      bool isOutlined = false,
    }) {
      return Expanded(
        child: Material(
          color: isOutlined ? Colors.white : color,
          borderRadius: BorderRadius.circular(8),
          elevation: isOutlined ? 0 : 1.5,
          shadowColor: color.withOpacity(0.3),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isOutlined ? Border.all(color: color, width: 1.5) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isOutlined ? color : Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: isOutlined ? color : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final List<Widget> actionButtons = [];

    // Start PTW
    if (data['current_status'] == 'PDC_CONFIRMED' && role == 'LS') {
      actionButtons.add(
        buildActionButton(
          icon: Icons.play_circle_rounded,
          label: 'Start',
          color: Colors.green,
          onTap: () async {
            if (await _checkLocationPermission()) {
              if (ptwId != null) {
                Get.toNamed(AppRoutes.attachmentsSubmission, arguments: ptwId);
              }
            }
          },
        ),
      );
    }

    // Complete PTW
    if (data['current_status'] == 'IN_EXECUTION' && role == 'LS') {
      actionButtons.add(
        buildActionButton(
          icon: Icons.check_circle_rounded,
          label: 'Complete',
          color: Colors.orange,
          onTap: () async {
            if (await _checkLocationPermission()) {
              if (ptwId != null) {
                Get.toNamed(AppRoutes.ptwCompleted, arguments: ptwId);
              }
            }
          },
        ),
      );
    }

    // Close PTW
    if ((data['current_status'] == 'COMPLETION_SUBMITTED' ||
        data['current_status'] == 'CANCELLATION_APPROVED_BY_SDO') &&
        role == 'GRIDOPERATOR') {
      actionButtons.add(
        buildActionButton(
          icon: Icons.lock_clock_rounded,
          label: 'Close',
          color: Colors.blue,
          onTap: () {
            if (ptwId != null) {
              Get.toNamed(AppRoutes.ptwGridClose, arguments: ptwId);
            }
          },
        ),
      );
    }

    // Cancel PTW
    if (data['current_status'] == 'PDC_CONFIRMED' && role == 'LS') {
      actionButtons.add(
        buildActionButton(
          icon: Icons.cancel_outlined,
          label: 'Cancel',
          color: Colors.red.shade400,
          isOutlined: true,
          onTap: () {
            if (ptwId == null) return;
            Get.toNamed(
              AppRoutes.ptwCancelByLs,
              arguments: {'ptw_id': ptwId, 'user_role': role},
            );
          },
        ),
      );
    }

    // Edit PTW
    if (role == 'LS' &&
        (data['current_status'] == 'DRAFT' ||
            data['current_status'] == 'SDO_RETURNED' ||
            data['current_status'] == 'XEN_RETURNED_TO_LS' ||
            data['current_status'] == 'PDC_RETURNED_TO_LS')) {
      actionButtons.add(
        buildActionButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          color: Colors.amber.shade700,
          onTap: () {
            if (ptwId == null) return;
            Get.toNamed(
              AppRoutes.createPtwScreen,
              arguments: {'mode': 'edit', 'ptw_id': ptwId},
            );
          },
        ),
      );
    }

    // View button (always visible)
    actionButtons.add(
      buildActionButton(
        icon: Icons.visibility_outlined,
        label: 'View',
        color: Colors.blueGrey,
        isOutlined: true,
        onTap: () {
          if (ptwId == null) return;
          Get.toNamed(
            AppRoutes.ptwReviewSdo,
            arguments: {'ptw_id': ptwId, 'user_role': role},
          );
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data['current_status'] == 'IN_EXECUTION' && data['due_time'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: DueCountdown(dueTime: data['due_time']),
          ),
        Row(
          children: actionButtons
              .asMap()
              .entries
              .expand((entry) => [
            entry.value,
            if (entry.key < actionButtons.length - 1) const SizedBox(width: 6),
          ])
              .toList(),
        ),
      ],
    );
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        SnackbarHelper.showError(
          title: 'Permission Denied',
          message: 'Location permission is required.',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      SnackbarHelper.showError(
        title: 'Permission Denied',
        message: 'Please enable location permissions in settings.',
      );
      return false;
    }

    return true;
  }

  Widget _buildShimmerEffect() {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerWidget.rectangular(height: 20, width: 50),
                    ShimmerWidget.rectangular(height: 20, width: 90),
                  ],
                ),
                const SizedBox(height: 10),
                ShimmerWidget.rectangular(height: 18, width: 160),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openAdvancedFilterSheet(BuildContext context, PtwListController controller) {
    final DateFormat df = DateFormat('yyyy-MM-dd');

    String tempStatus = controller.selectedStatus.value;
    DateTime? tempFrom = controller.fromDate.value.isNotEmpty
        ? DateTime.tryParse(controller.fromDate.value)
        : null;
    DateTime? tempTo = controller.toDate.value.isNotEmpty
        ? DateTime.tryParse(controller.toDate.value)
        : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (ctx, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: StatefulBuilder(
                builder: (ctx, setModalState) {
                  return Column(
                    children: [
                      // Drag Handle
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 8,
                            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      color: AppColors.primaryBlue,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Status Filters",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (controller.selectedStatus.value.isNotEmpty ||
                                      controller.fromDate.value.isNotEmpty ||
                                      controller.toDate.value.isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        setModalState(() {
                                          tempStatus = '';
                                          tempFrom = null;
                                          tempTo = null;
                                        });
                                      },
                                      child: Text(
                                        'Clear All',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Status Section
                              Row(
                                children: [
                                  Icon(
                                    Icons.label_outline,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Filter by Status",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: PtwListScreen._statusOptions.map((opt) {
                                  final code = opt['code']!;
                                  final label = opt['label']!;
                                  final selected = tempStatus == code;

                                  return FilterChip(
                                    label: Text(label),
                                    selected: selected,
                                    selectedColor: AppColors.primaryBlue,
                                    backgroundColor: Colors.grey.shade100,
                                    side: BorderSide(
                                      color: selected
                                          ? AppColors.primaryBlue
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      color: selected ? Colors.white : Colors.grey.shade700,
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    onSelected: (_) {
                                      setModalState(() => tempStatus = code);
                                    },
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 28),

                              // Date Range Section
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Filter by Date Range",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _dateField(
                                      label: 'From Date',
                                      value: tempFrom != null ? df.format(tempFrom!) : '',
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: ctx,
                                          initialDate: tempFrom ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: AppColors.primaryBlue,
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (picked != null) {
                                          setModalState(() => tempFrom = picked);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _dateField(
                                      label: 'To Date',
                                      value: tempTo != null ? df.format(tempTo!) : '',
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: ctx,
                                          initialDate: tempTo ?? tempFrom ?? DateTime.now(),
                                          firstDate: tempFrom ?? DateTime(2000),
                                          lastDate: DateTime(2100),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: AppColors.primaryBlue,
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (picked != null) {
                                          setModalState(() => tempTo = picked);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Apply Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.applyFilters(
                                      status: tempStatus,
                                      from: tempFrom != null ? df.format(tempFrom!) : '',
                                      to: tempTo != null ? df.format(tempTo!) : '',
                                    );
                                    Navigator.pop(ctx);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Apply Filters",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final display = value.isEmpty ? label : value;
    final isPlaceholder = value.isEmpty;

    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: isPlaceholder ? Colors.grey.shade500 : AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  display,
                  style: TextStyle(
                    color: isPlaceholder ? Colors.grey.shade500 : Colors.black87,
                    fontSize: 14,
                    fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}