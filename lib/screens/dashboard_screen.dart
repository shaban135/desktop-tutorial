//
//
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// import 'package:mepco_esafety_app/controllers/home_controller.dart';
// import 'package:mepco_esafety_app/controllers/notifications_controller.dart';
// import 'package:mepco_esafety_app/controllers/profile_controller.dart';
// import 'package:mepco_esafety_app/routes/app_routes.dart';
// import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
// import 'package:mepco_esafety_app/widgets/custom_bottom_app_bar.dart';
// import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:mepco_esafety_app/constants/api_constants.dart';
// import 'package:mepco_esafety_app/constants/storage_keys.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final HomeController controller = Get.put(HomeController());
//     final ProfileController profileController = Get.find();
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       extendBody: true,
//       body: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: SystemUiOverlayStyle.light.copyWith(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.light,
//         ),
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return _buildShimmerEffect();
//           }
//           return RefreshIndicator(
//             onRefresh: () async {
//               await controller.fetchDashboard();
//               await controller.fetchWhatsNew();
//             },
//             color: const Color(0xFF2563EB),
//             child: CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 // Custom App Bar with Profile Info
//                 _buildCustomAppBar(context, profileController),
//
//                 // 🆕 WHAT'S NEW SECTION
//                 _buildWhatsNewSection(controller),
//
//                 // STATIC SUMMARY SECTION (No Sliding)
//                 SliverToBoxAdapter(
//                   child: Transform.translate(
//                     offset: const Offset(0, 15),
//                     child: _buildStaticSummarySection(controller),
//                   ),
//                 ),
//
//                 // 🆕 SWIPEABLE INSIGHTS CARDS (Trends, SLA, Performance)
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 30),
//                     child: _buildInsightsCarousel(controller),
//                   ),
//                 ),
//
//                 // 🆕 SEARCH BAR
//                 // SliverToBoxAdapter(
//                 //   child: Padding(
//                 //     padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//                 //     child: _buildSearchBar(controller),
//                 //   ),
//                 // ),
//
//                 // Quick Actions
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
//                     child: _buildQuickActions(controller),
//                   ),
//                 ),
//
//                 // Recent PTWs Header with View Toggle
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Recent PTWs',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1E293B),
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             // 🆕 GRID/LIST TOGGLE
//                             Obx(() => IconButton(
//                               icon: Icon(
//                                 controller.isGridView.value
//                                     ? Icons.view_list_rounded
//                                     : Icons.grid_view_rounded,
//                                 size: 20,
//                               ),
//                               onPressed: controller.toggleViewMode,
//                               color: const Color(0xFF2563EB),
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             )),
//                             const SizedBox(width: 8),
//                             TextButton(
//                               onPressed: () => Get.toNamed(AppRoutes.ptwList),
//                               style: TextButton.styleFrom(
//                                 foregroundColor: const Color(0xFF2563EB),
//                                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                               ),
//                               child: const Text(
//                                 'View All',
//                                 style: TextStyle(fontSize: 13),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Recent PTWs (Grid or List view)
//                 Obx(() => controller.isGridView.value
//                     ? _buildRecentPtwsGrid(controller)
//                     : _buildRecentPtwsList(controller)),
//
//                 // Bottom Padding
//                 const SliverToBoxAdapter(
//                   child: SizedBox(height: 100),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//       bottomNavigationBar: Obx(() => CustomBottomAppBar(
//         selectedIndex: controller.selectedIndex.value,
//         onItemTapped: controller.onItemTapped,
//       )),
//     );
//   }
//
//   // 🆕 WHAT'S NEW SECTION
//   Widget _buildWhatsNewSection(HomeController controller) {
//     return SliverToBoxAdapter(
//       child: Obx(() {
//         final activities = controller.recentActivities;
//         if (activities.isEmpty && !controller.showWhatsNew.value) {
//           return const SizedBox.shrink();
//         }
//
//         return Padding(
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 8),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFF3B82F6).withOpacity(0.08),
//                   const Color(0xFF8B5CF6).withOpacity(0.08),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: const Color(0xFF3B82F6).withOpacity(0.2),
//                 width: 1.5,
//               ),
//             ),
//             child: Column(
//               children: [
//                 // Header
//                 Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () => controller.toggleWhatsNew(),
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(14),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
//                               ),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: const Icon(
//                               Icons.auto_awesome_rounded,
//                               color: Colors.white,
//                               size: 18,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'What\'s New',
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF1E293B),
//                                   ),
//                                 ),
//                                 Text(
//                                   'Recent updates & reminders',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Color(0xFF64748B),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (activities.isNotEmpty)
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF3B82F6),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 '${activities.length}',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           const SizedBox(width: 8),
//                           Icon(
//                             controller.showWhatsNew.value
//                                 ? Icons.keyboard_arrow_up_rounded
//                                 : Icons.keyboard_arrow_down_rounded,
//                             color: const Color(0xFF64748B),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Expandable Content
//                 if (controller.showWhatsNew.value) ...[
//                   const Divider(height: 1),
//                   if (activities.isEmpty)
//                     Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.check_circle_outline_rounded,
//                             size: 40,
//                             color: Colors.grey[400],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'You\'re all caught up!',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   else
//                     ListView.separated(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       padding: const EdgeInsets.all(8),
//                       itemCount: activities.length > 5 ? 5 : activities.length,
//                       separatorBuilder: (_, __) => const SizedBox(height: 6),
//                       itemBuilder: (context, index) {
//                         final activity = activities[index];
//                         return _buildActivityItem(activity, controller);
//                       },
//                     ),
//                 ],
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildActivityItem(ActivityItem activity, HomeController controller) {
//     return Dismissible(
//       key: Key(activity.timestamp.toString()),
//       direction: DismissDirection.endToStart,
//       onDismissed: (_) => controller.dismissActivity(activity),
//       background: Container(
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 16),
//         decoration: BoxDecoration(
//           color: Colors.red.shade400,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Icon(Icons.delete_outline, color: Colors.white),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             if (activity.ptwId != null) {
//               // Navigate to PTW detail
//               Get.toNamed(
//                 AppRoutes.ptwReviewSdo,
//                 arguments: {
//                   'ptw_id': activity.ptwId,
//                   'user_role': controller.currentUserRole.value
//                 },
//               );
//             }
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.7),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: activity.color.withOpacity(0.2),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: activity.color.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     activity.icon,
//                     color: activity.color,
//                     size: 18,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         activity.title,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1E293B),
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         activity.description,
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.grey[600],
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _formatTimestamp(activity.timestamp),
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (activity.actionLabel != null)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: activity.color,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       activity.actionLabel!,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);
//
//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
//     }
//   }
//
//   // 🆕 SWIPEABLE INSIGHTS CAROUSEL (3 cards: Trends, SLA, Performance)
//   Widget _buildInsightsCarousel(HomeController controller) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           SizedBox(
//             height: 200,
//             child: PageView(
//               onPageChanged: (index) {
//                 controller.currentInsightIndex.value = index;
//               },
//               children: [
//                 _buildTrendsCard(controller),
//                 _buildSLACard(controller),
//                 _buildPerformanceCard(controller),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           // Page Indicators (3 dots)
//           Obx(() => Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(
//               3, // Only 3 cards now
//                   (index) => Container(
//                 width: controller.currentInsightIndex.value == index ? 24 : 8,
//                 height: 8,
//                 margin: const EdgeInsets.symmetric(horizontal: 4),
//                 decoration: BoxDecoration(
//                   color: controller.currentInsightIndex.value == index
//                       ? const Color(0xFF3B82F6)
//                       : Colors.grey[300],
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//           )),
//         ],
//       ),
//     );
//   }
//
//   // ✅ STATIC SUMMARY SECTION (Original stats with filter)
//   Widget _buildStaticSummarySection(HomeController controller) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             // Modern Filter Section
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     const Color(0xFF3B82F6).withOpacity(0.08),
//                     const Color(0xFF2563EB).withOpacity(0.04),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                   color: const Color(0xFF3B82F6).withOpacity(0.15),
//                   width: 1.5,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF3B82F6).withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(
//                       Icons.filter_alt_rounded,
//                       size: 12,
//                       color: Color(0xFF3B82F6),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Obx(() => Text(
//                           _getFilterLabel(controller.selectedFilterType.value),
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1E293B),
//                           ),
//                         )),
//                         Obx(() {
//                           if (controller.selectedFilterType.value == 'custom_range' &&
//                               controller.startDate.value != null &&
//                               controller.endDate.value != null) {
//                             final start = controller.startDate.value!;
//                             final end = controller.endDate.value!;
//                             return Padding(
//                               padding: const EdgeInsets.only(top: 2),
//                               child: Text(
//                                 '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.grey[600],
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             );
//                           }
//                           return const SizedBox.shrink();
//                         }),
//                       ],
//                     ),
//                   ),
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () => _showFilterBottomSheet(controller),
//                       borderRadius: BorderRadius.circular(8),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
//                           ),
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0xFF3B82F6).withOpacity(0.3),
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Filter',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             SizedBox(width: 4),
//                             Icon(
//                               Icons.keyboard_arrow_down_rounded,
//                               size: 14,
//                               color: Colors.white,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // Stats Row with enhanced design
//             Row(
//               children: [
//                 Obx(() => _buildStatItem(
//                   controller.totalPtws.value,
//                   'Total PTWs',
//                   Icons.description_rounded,
//                   const Color(0xFF3B82F6),
//                 )),
//                 const SizedBox(width: 10),
//                 Obx(() => _buildStatItem(
//                   controller.activePtws.value,
//                   'Active PTWs',
//                   Icons.pending_actions_rounded,
//                   const Color(0xFFF59E0B),
//                 )),
//                 const SizedBox(width: 10),
//                 Obx(() => _buildStatItem(
//                   controller.closedPtws.value,
//                   'Completed',
//                   Icons.check_circle_rounded,
//                   const Color(0xFF10B981),
//                 )),
//                 const SizedBox(width: 10),
//                 Obx(() => _buildStatItem(
//                   controller.cancelledPtws.value,
//                   'Cancelled',
//                   Icons.cancel_rounded,
//                   const Color(0xFFEF4444),
//                 )),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Trends Card with Chart
//   Widget _buildTrendsCard(HomeController controller) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.trending_up_rounded,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Weekly Trends',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: Obx(() {
//               final trendData = controller.weeklyTrends;
//               if (trendData.isEmpty) {
//                 return Center(
//                   child: Text(
//                     'No trend data available',
//                     style: TextStyle(color: Colors.grey[500], fontSize: 12),
//                   ),
//                 );
//               }
//               return LineChart(
//                 LineChartData(
//                   gridData: FlGridData(show: false),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     rightTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     topTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) {
//                           const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//                           if (value.toInt() >= 0 && value.toInt() < days.length) {
//                             return Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: Text(
//                                 days[value.toInt()],
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Color(0xFF64748B),
//                                 ),
//                               ),
//                             );
//                           }
//                           return const SizedBox();
//                         },
//                       ),
//                     ),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: trendData,
//                       isCurved: true,
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
//                       ),
//                       barWidth: 3,
//                       isStrokeCapRound: true,
//                       dotData: FlDotData(show: true),
//                       belowBarData: BarAreaData(
//                         show: true,
//                         gradient: LinearGradient(
//                           colors: [
//                             const Color(0xFF8B5CF6).withOpacity(0.3),
//                             const Color(0xFF8B5CF6).withOpacity(0.0),
//                           ],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 🆕 SLA MONITOR CARD
//   Widget _buildSLACard(HomeController controller) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF10B981), Color(0xFF059669)],
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.access_time_rounded,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'SLA Monitor',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Obx(() {
//             final slaData = controller.slaMetrics;
//             return Column(
//               children: [
//                 _buildSLAMetricRow(
//                   'On Time',
//                   slaData['on_time'] ?? 0,
//                   slaData['total'] ?? 0,
//                   Colors.green,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildSLAMetricRow(
//                   'At Risk',
//                   slaData['at_risk'] ?? 0,
//                   slaData['total'] ?? 0,
//                   Colors.orange,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildSLAMetricRow(
//                   'Breached',
//                   slaData['breached'] ?? 0,
//                   slaData['total'] ?? 0,
//                   Colors.red,
//                 ),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSLAMetricRow(String label, int count, int total, Color color) {
//     final percentage = total > 0 ? (count / total * 100) : 0.0;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF64748B),
//               ),
//             ),
//             Text(
//               '$count / $total',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: LinearProgressIndicator(
//             value: total > 0 ? count / total : 0,
//             backgroundColor: Colors.grey[200],
//             valueColor: AlwaysStoppedAnimation<Color>(color),
//             minHeight: 8,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Performance Card
//   Widget _buildPerformanceCard(HomeController controller) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.analytics_rounded,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Performance',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Obx(() {
//             final perf = controller.performanceMetrics;
//             return Row(
//               children: [
//                 Expanded(
//                   child: _buildPerformanceMetric(
//                     'Completion Rate',
//                     '${perf['completion_rate'] ?? 0}%',
//                     Icons.check_circle_outline,
//                     const Color(0xFF10B981),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildPerformanceMetric(
//                     'Avg. Time',
//                     '${perf['avg_time'] ?? 0}h',
//                     Icons.schedule_rounded,
//                     const Color(0xFF3B82F6),
//                   ),
//                 ),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPerformanceMetric(
//       String label,
//       String value,
//       IconData icon,
//       Color color,
//       ) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             color.withOpacity(0.1),
//             color.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: color.withOpacity(0.2),
//         ),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 10,
//               color: color.withOpacity(0.8),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 🆕 SEARCH BAR
//   Widget _buildSearchBar(HomeController controller) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TextField(
//         onChanged: controller.searchPTWs,
//         decoration: InputDecoration(
//           hintText: 'Search PTWs by ID, feeder, location...',
//           hintStyle: TextStyle(
//             fontSize: 13,
//             color: Colors.grey[400],
//           ),
//           prefixIcon: const Icon(
//             Icons.search_rounded,
//             color: Color(0xFF64748B),
//             size: 20,
//           ),
//           suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
//               ? IconButton(
//             icon: const Icon(Icons.clear, size: 18),
//             onPressed: controller.clearSearch,
//           )
//               : const SizedBox()),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 14,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Keep existing methods (buildCustomAppBar, buildQuickActions, etc.)
//   Widget _buildCustomAppBar(BuildContext context, ProfileController controller) {
//     final notificationController = Get.find<NotificationsController>();
//     return SliverAppBar(
//       expandedHeight: 180,
//       floating: false,
//       pinned: true,
//       elevation: 0,
//       backgroundColor: const Color(0xFF1835A1),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 16, top: 12),
//           child: GestureDetector(
//             onTap: () {
//               Get.toNamed(AppRoutes.notifications);
//               notificationController.fetchNotifications();
//             },
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   height: 42,
//                   width: 42,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white24, width: 2),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF1835A1).withOpacity(0.7),
//                         blurRadius: 2,
//                       ),
//                     ],
//                   ),
//                   child: const Center(
//                     child: Icon(
//                       Icons.notifications_none_rounded,
//                       color: Colors.white,
//                       size: 22,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   right: -4,
//                   top: -4,
//                   child: Obx(() {
//                     final count = notificationController.unreadCount.value;
//                     if (count == 0) return const SizedBox.shrink();
//                     return Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         color: Colors.redAccent,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.35),
//                             blurRadius: 6,
//                             offset: const Offset(2, 2),
//                           ),
//                         ],
//                       ),
//                       child: Text(
//                         '$count',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ],
//             ),
//           ),
//         )
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0x1E4D7BFF), Color(0xFF768BD3)],
//             ),
//           ),
//           child: Stack(
//             children: [
//               CustomPaint(
//                 painter: GridPatternPainter(),
//                 child: Container(),
//               ),
//               SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 35),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Obx(() {
//                             final imagePath = controller.imagePath.value;
//                             return Container(
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.white, width: 2.5),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.15),
//                                     blurRadius: 10,
//                                     spreadRadius: 1,
//                                   ),
//                                 ],
//                               ),
//                               child: ClipOval(
//                                 child: Container(
//                                   width: 65,
//                                   height: 65,
//                                   color: Colors.white,
//                                   child: imagePath.isEmpty
//                                       ? const Icon(Icons.person, size: 40)
//                                       : imagePath.startsWith('http')
//                                       ? CachedNetworkImage(
//                                     imageUrl: imagePath,
//                                     fit: BoxFit.cover,
//                                     placeholder: (context, url) =>
//                                     const ShimmerWidget.circular(
//                                         width: 65, height: 65),
//                                     errorWidget: (context, url, error) =>
//                                     const Icon(Icons.person, size: 40),
//                                   )
//                                       : imagePath.startsWith('assets')
//                                       ? const Icon(Icons.person, size: 40)
//                                       : Image.file(File(imagePath),
//                                       fit: BoxFit.cover),
//                                 ),
//                               ),
//                             );
//                           }),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Obx(() => Text(
//                                   controller.name.value,
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     height: 1.2,
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 )),
//                                 const SizedBox(height: 6),
//                                 _buildInfoRow('Designation', controller.designation.value),
//                                 _buildInfoRow('SAP Code', controller.sapCode.value),
//                                 _buildInfoRow('Circle', controller.circle.value),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildInfoRow('Division', controller.division.value),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: _buildInfoRow('Sub-Division', controller.subDivision.value),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 3),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label: ',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 11,
//               color: Colors.white.withOpacity(0.9),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 11, color: Colors.white),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatItem(String count, String label, IconData icon, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               color.withOpacity(0.12),
//               color.withOpacity(0.06),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.2), width: 1),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: color, size: 20),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               count,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 9,
//                 color: color.withOpacity(0.8),
//                 fontWeight: FontWeight.w600,
//                 height: 1.2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getFilterLabel(String filterType) {
//     switch (filterType) {
//       case 'last_week':
//         return 'Last Week';
//       case 'last_month':
//         return 'Last Month';
//       case 'last_3_months':
//         return 'Last 3 Months';
//       case 'last_6_months':
//         return 'Last 6 Months';
//       case 'custom_range':
//         return 'Custom Range';
//       case 'all_times':
//       default:
//         return 'All Time';
//     }
//   }
//
//   void _showFilterBottomSheet(HomeController controller) {
//     Get.bottomSheet(
//       Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(28),
//             topRight: Radius.circular(28),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(
//                           Icons.tune_rounded,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Filter Statistics',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1E293B),
//                               ),
//                             ),
//                             Text(
//                               'Select time period',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Color(0xFF64748B),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => Get.back(),
//                         icon: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(Icons.close, size: 18),
//                         ),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   _buildFilterOption(
//                     controller,
//                     'All Time',
//                     'Show all statistics',
//                     'all_times',
//                     Icons.all_inclusive_rounded,
//                   ),
//                   _buildFilterOption(
//                     controller,
//                     'Last Week',
//                     'Past 7 days',
//                     'last_week',
//                     Icons.calendar_view_week_rounded,
//                   ),
//                   _buildFilterOption(
//                     controller,
//                     'Last Month',
//                     'Past 30 days',
//                     'last_month',
//                     Icons.calendar_view_month_rounded,
//                   ),
//                   _buildFilterOption(
//                     controller,
//                     'Last 3 Months',
//                     'Past 90 days',
//                     'last_3_months',
//                     Icons.date_range_rounded,
//                   ),
//                   _buildFilterOption(
//                     controller,
//                     'Last 6 Months',
//                     'Past 180 days',
//                     'last_6_months',
//                     Icons.event_note_rounded,
//                   ),
//                   _buildFilterOption(
//                     controller,
//                     'Custom Range',
//                     'Pick your dates',
//                     'custom_range',
//                     Icons.calendar_today_rounded,
//                     isCustom: true,
//                   ),
//                   const SizedBox(height: 16),
//                   Obx(() {
//                     if (controller.selectedFilterType.value != 'all_times') {
//                       return SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             controller.resetFilter();
//                             Get.back();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.grey[100],
//                             foregroundColor: Colors.grey[700],
//                             elevation: 0,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.refresh_rounded, size: 18, color: Colors.grey[700]),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 'Reset to All Time',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   }),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     );
//   }
//
//   Widget _buildFilterOption(
//       HomeController controller,
//       String title,
//       String subtitle,
//       String value,
//       IconData icon, {
//         bool isCustom = false,
//       }) {
//     return Obx(() {
//       final isSelected = controller.selectedFilterType.value == value;
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 10),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: () async {
//               if (isCustom) {
//                 await _showCustomDatePicker(controller);
//               } else {
//                 controller.applyFilter(value);
//                 Get.back();
//               }
//             },
//             borderRadius: BorderRadius.circular(14),
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: isSelected
//                     ? LinearGradient(
//                   colors: [
//                     const Color(0xFF3B82F6).withOpacity(0.1),
//                     const Color(0xFF2563EB).withOpacity(0.05),
//                   ],
//                 )
//                     : null,
//                 color: isSelected ? null : Colors.grey[50],
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                   color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade200,
//                   width: isSelected ? 2 : 1.5,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       gradient: isSelected
//                           ? const LinearGradient(
//                         colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
//                       )
//                           : null,
//                       color: isSelected ? null : Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isSelected ? Colors.transparent : Colors.grey.shade300,
//                       ),
//                     ),
//                     child: Icon(
//                       icon,
//                       color: isSelected ? Colors.white : Colors.grey[600],
//                       size: 22,
//                     ),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             color: isSelected ? const Color(0xFF1E293B) : Colors.grey[800],
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           subtitle,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: isSelected ? Colors.grey[700] : Colors.grey[500],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (isSelected)
//                     Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
//                         ),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.check_rounded,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                     )
//                   else
//                     Container(
//                       width: 28,
//                       height: 28,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.grey.shade300, width: 2),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
//
//   Future<void> _showCustomDatePicker(HomeController controller) async {
//     DateTime? tempStartDate = controller.startDate.value;
//     DateTime? tempEndDate = controller.endDate.value;
//
//     final result = await Get.dialog<Map<String, DateTime?>>(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(
//                           Icons.date_range_rounded,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Custom Date Range',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1E293B),
//                               ),
//                             ),
//                             Text(
//                               'Select start and end dates',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Color(0xFF64748B),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: tempStartDate ?? DateTime.now(),
//                           firstDate: DateTime(2020),
//                           lastDate: DateTime.now(),
//                           builder: (context, child) {
//                             return Theme(
//                               data: Theme.of(context).copyWith(
//                                 colorScheme: const ColorScheme.light(
//                                   primary: Color(0xFF3B82F6),
//                                   onPrimary: Colors.white,
//                                   surface: Colors.white,
//                                 ),
//                               ),
//                               child: child!,
//                             );
//                           },
//                         );
//                         if (picked != null) {
//                           setState(() {
//                             tempStartDate = picked;
//                           });
//                         }
//                       },
//                       borderRadius: BorderRadius.circular(14),
//                       child: Container(
//                         padding: const EdgeInsets.all(18),
//                         decoration: BoxDecoration(
//                           gradient: tempStartDate != null
//                               ? LinearGradient(
//                             colors: [
//                               const Color(0xFF3B82F6).withOpacity(0.1),
//                               const Color(0xFF2563EB).withOpacity(0.05),
//                             ],
//                           )
//                               : null,
//                           color: tempStartDate != null ? null : Colors.grey[50],
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             color: tempStartDate != null
//                                 ? const Color(0xFF3B82F6)
//                                 : Colors.grey.shade300,
//                             width: tempStartDate != null ? 2 : 1.5,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: tempStartDate != null
//                                     ? const Color(0xFF3B82F6)
//                                     : Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Icon(
//                                 Icons.calendar_today_rounded,
//                                 size: 18,
//                                 color: tempStartDate != null ? Colors.white : Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(width: 14),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Start Date',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     tempStartDate != null
//                                         ? '${tempStartDate!.day}/${tempStartDate!.month}/${tempStartDate!.year}'
//                                         : 'Select start date',
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                       color: tempStartDate != null
//                                           ? const Color(0xFF1E293B)
//                                           : Colors.grey[400],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Icon(
//                               Icons.arrow_forward_ios_rounded,
//                               size: 16,
//                               color: tempStartDate != null
//                                   ? const Color(0xFF3B82F6)
//                                   : Colors.grey[400],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: tempEndDate ?? DateTime.now(),
//                           firstDate: tempStartDate ?? DateTime(2020),
//                           lastDate: DateTime.now(),
//                           builder: (context, child) {
//                             return Theme(
//                               data: Theme.of(context).copyWith(
//                                 colorScheme: const ColorScheme.light(
//                                   primary: Color(0xFF3B82F6),
//                                   onPrimary: Colors.white,
//                                   surface: Colors.white,
//                                 ),
//                               ),
//                               child: child!,
//                             );
//                           },
//                         );
//                         if (picked != null) {
//                           setState(() {
//                             tempEndDate = picked;
//                           });
//                         }
//                       },
//                       borderRadius: BorderRadius.circular(14),
//                       child: Container(
//                         padding: const EdgeInsets.all(18),
//                         decoration: BoxDecoration(
//                           gradient: tempEndDate != null
//                               ? LinearGradient(
//                             colors: [
//                               const Color(0xFF3B82F6).withOpacity(0.1),
//                               const Color(0xFF2563EB).withOpacity(0.05),
//                             ],
//                           )
//                               : null,
//                           color: tempEndDate != null ? null : Colors.grey[50],
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             color: tempEndDate != null
//                                 ? const Color(0xFF3B82F6)
//                                 : Colors.grey.shade300,
//                             width: tempEndDate != null ? 2 : 1.5,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color:
//                                 tempEndDate != null ? const Color(0xFF3B82F6) : Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Icon(
//                                 Icons.event_rounded,
//                                 size: 18,
//                                 color: tempEndDate != null ? Colors.white : Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(width: 14),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'End Date',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     tempEndDate != null
//                                         ? '${tempEndDate!.day}/${tempEndDate!.month}/${tempEndDate!.year}'
//                                         : 'Select end date',
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                       color: tempEndDate != null
//                                           ? const Color(0xFF1E293B)
//                                           : Colors.grey[400],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Icon(
//                               Icons.arrow_forward_ios_rounded,
//                               size: 16,
//                               color:
//                               tempEndDate != null ? const Color(0xFF3B82F6) : Colors.grey[400],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextButton(
//                           onPressed: () => Get.back(),
//                           style: TextButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             backgroundColor: Colors.grey[100],
//                           ),
//                           child: Text(
//                             'Cancel',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
//                             ),
//                             borderRadius: BorderRadius.circular(14),
//                             boxShadow: tempStartDate != null && tempEndDate != null
//                                 ? [
//                               BoxShadow(
//                                 color: const Color(0xFF3B82F6).withOpacity(0.3),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ]
//                                 : [],
//                           ),
//                           child: ElevatedButton(
//                             onPressed: tempStartDate != null && tempEndDate != null
//                                 ? () {
//                               Get.back(result: {
//                                 'start': tempStartDate,
//                                 'end': tempEndDate,
//                               });
//                             }
//                                 : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               disabledBackgroundColor: Colors.grey[300],
//                               disabledForegroundColor: Colors.grey[500],
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                             ),
//                             child: const Text(
//                               'Apply Filter',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//
//     if (result != null && result['start'] != null && result['end'] != null) {
//       Get.back();
//       controller.applyFilter('custom_range', start: result['start'], end: result['end']);
//     }
//   }
//
//   Widget _buildQuickActions(HomeController controller) {
//     return Obx(() {
//       return SizedBox(
//         height: 100,
//         child: Row(
//           children: [
//             if (controller.canCreatePtw())
//               Expanded(
//                 child: _buildActionButton(
//                   label: 'New Work',
//                   icon: Icons.add_circle_outline,
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
//                   ),
//                   onTap: () async {
//                     bool serviceEnabled;
//                     LocationPermission permission;
//
//                     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//                     if (!serviceEnabled) {
//                       await Geolocator.openLocationSettings();
//                       return;
//                     }
//
//                     permission = await Geolocator.checkPermission();
//                     if (permission == LocationPermission.denied) {
//                       permission = await Geolocator.requestPermission();
//                       if (permission == LocationPermission.denied) {
//                         SnackbarHelper.showError(
//                           title: 'Permission Denied',
//                           message: 'Location permission is required to create a PTW.',
//                         );
//                         return;
//                       }
//                     }
//
//                     if (permission == LocationPermission.deniedForever) {
//                       SnackbarHelper.showError(
//                         title: 'Permission Denied',
//                         message:
//                         'Location permissions are permanently denied. Please enable them in settings.',
//                       );
//                       return;
//                     }
//
//                     await _checkPtwContextBeforeCreate();
//                   },
//                 ),
//               ),
//             if (controller.canCreatePtw()) const SizedBox(width: 12),
//             Expanded(
//               child: _buildActionButton(
//                 label: 'View All Works',
//                 icon: Icons.grid_view_rounded,
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF64748B), Color(0xFF475569)],
//                 ),
//                 onTap: () => Get.toNamed(AppRoutes.ptwList),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
//
//   Future<void> _checkPtwContextBeforeCreate() async {
//     Get.dialog(
//       WillPopScope(
//         onWillPop: () async => false,
//         child: const Center(
//           child: Card(
//             margin: EdgeInsets.all(32),
//             child: Padding(
//               padding: EdgeInsets.all(24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text(
//                     'Validating...',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       barrierDismissible: false,
//     );
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(StorageKeys.authToken);
//
//       if (token == null) {
//         Get.back();
//         SnackbarHelper.showError(
//           title: 'Auth Error',
//           message: 'Authentication token not found. Please login again.',
//         );
//         return;
//       }
//
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/api/v1/ptw/context'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       Get.back();
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body)['data'];
//
//         final sdoData = data['sdo'];
//         if (sdoData == null) {
//           SnackbarHelper.showError(
//             title: 'SDO Not Found',
//             message: 'No SDO found for this sub-division. Please contact admin.',
//           );
//           return;
//         }
//
//         final primaryFeeders = data['primary_feeders'] as List? ?? [];
//         if (primaryFeeders.isEmpty) {
//           SnackbarHelper.showError(
//             title: 'No Feeders',
//             message: 'No feeders found for your sub-division. Please contact admin.',
//           );
//           return;
//         }
//
//         final result = await Get.toNamed(
//           AppRoutes.createPtwScreen,
//           arguments: {'mode': 'create'},
//         );
//
//         if (result == true) {
//           final homeController = Get.find<HomeController>();
//           homeController.fetchDashboard();
//         }
//       } else if (response.statusCode == 404) {
//         final errorData = json.decode(response.body);
//         final errorMessage = errorData['message'] ?? 'No SDO found for this sub-division';
//
//         SnackbarHelper.showError(
//           title: 'SDO Not Found',
//           message: errorMessage,
//         );
//       } else {
//         SnackbarHelper.showError(
//           title: 'Validation Failed',
//           message: 'Failed to validate PTW context. Please try again.',
//         );
//       }
//     } catch (e) {
//       Get.back();
//       SnackbarHelper.showError(
//         title: 'Error',
//         message: 'Failed to validate: $e',
//       );
//     }
//   }
//
//   Widget _buildActionButton({
//     required String label,
//     required IconData icon,
//     required Gradient gradient,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       height: 48,
//       decoration: BoxDecoration(
//         gradient: gradient,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: Colors.white, size: 18),
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 🆕 GRID VIEW
//   Widget _buildRecentPtwsGrid(HomeController controller) {
//     return Obx(() {
//       final recent = controller.ptwList.length > 6 ? controller.ptwList.sublist(0, 6) : controller.ptwList;
//
//       if (recent.isEmpty) {
//         return SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFF1F5F9),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.folder_open_outlined,
//                       size: 40,
//                       color: Colors.grey[400],
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'No Recent PTWs',
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Your recent PTWs will appear here',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[500],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }
//
//       final screenWidth = MediaQuery.of(Get.context!).size.width;
//       final crossAxisCount = screenWidth < 360 ? 1 : 2;
//
//       return SliverPadding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         sliver: SliverGrid(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxisCount,
//             mainAxisExtent: 160,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//           ),
//           delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//               final ptw = recent[index];
//               return _buildPtwCard(
//                 id: ptw.id,
//                 ptwId: ptw.ptwId,
//                 status: ptw.status,
//                 feeder: ptw.feeder,
//                 date: ptw.date,
//                 dueTime: ptw.dueTime.toString(),
//                 userRole: controller.currentUserRole.value,
//               );
//             },
//             childCount: recent.length,
//           ),
//         ),
//       );
//     });
//   }
//
//   // 🆕 LIST VIEW
//   Widget _buildRecentPtwsList(HomeController controller) {
//     return Obx(() {
//       final recent = controller.ptwList.length > 6 ? controller.ptwList.sublist(0, 6) : controller.ptwList;
//
//       if (recent.isEmpty) {
//         return SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFF1F5F9),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.folder_open_outlined,
//                       size: 40,
//                       color: Colors.grey[400],
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'No Recent PTWs',
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Your recent PTWs will appear here',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[500],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }
//
//       return SliverPadding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         sliver: SliverList(
//           delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//               final ptw = recent[index];
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: _buildPtwListCard(
//                   id: ptw.id,
//                   ptwId: ptw.ptwId,
//                   status: ptw.status,
//                   feeder: ptw.feeder,
//                   date: ptw.date,
//                   dueTime: ptw.dueTime.toString(),
//                   userRole: controller.currentUserRole.value,
//                 ),
//               );
//             },
//             childCount: recent.length,
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _buildPtwCard({
//     required int? id,
//     required String ptwId,
//     required String status,
//     required String feeder,
//     required String date,
//     required String? dueTime,
//     required String userRole,
//   }) {
//     final statusText = PtwHelper.getStatusText(status);
//     final statusColor = PtwHelper.getStatusColor(status);
//
//     return GestureDetector(
//       onTap: () {
//         if (id != null) {
//           Get.toNamed(
//             AppRoutes.ptwReviewSdo,
//             arguments: {'ptw_id': id, 'user_role': userRole},
//           );
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: Colors.grey.shade300),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               ptwId,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1E40AF),
//               ),
//             ),
//             const SizedBox(height: 6),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                 color: statusColor.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 statusText,
//                 style: TextStyle(
//                   color: statusColor,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Feeder: $feeder',
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Colors.black54,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 3),
//             Text(
//               date,
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Colors.black54,
//               ),
//             ),
//             const SizedBox(height: 6),
//             if (status.toUpperCase() == 'IN_EXECUTION' &&
//                 dueTime != null &&
//                 dueTime.isNotEmpty &&
//                 dueTime != 'null')
//               DueCountdown(dueTime: dueTime),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPtwListCard({
//     required int? id,
//     required String ptwId,
//     required String status,
//     required String feeder,
//     required String date,
//     required String? dueTime,
//     required String userRole,
//   }) {
//     final statusText = PtwHelper.getStatusText(status);
//     final statusColor = PtwHelper.getStatusColor(status);
//
//     return GestureDetector(
//       onTap: () {
//         if (id != null) {
//           Get.toNamed(
//             AppRoutes.ptwReviewSdo,
//             arguments: {'ptw_id': id, 'user_role': userRole},
//           );
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: Colors.grey.shade300),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: statusColor.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Icons.description_rounded,
//                 color: statusColor,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     ptwId,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1E40AF),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: statusColor.withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           statusText,
//                           style: TextStyle(
//                             color: statusColor,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         date,
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Feeder: $feeder',
//                     style: const TextStyle(
//                       fontSize: 11,
//                       color: Colors.black54,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             if (status.toUpperCase() == 'IN_EXECUTION' &&
//                 dueTime != null &&
//                 dueTime.isNotEmpty &&
//                 dueTime != 'null')
//               DueCountdown(dueTime: dueTime),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildShimmerEffect() {
//     return CustomScrollView(
//       slivers: [
//         SliverAppBar(
//           expandedHeight: 180,
//           floating: false,
//           pinned: true,
//           backgroundColor: const Color(0xFF1F5AC1),
//           flexibleSpace: FlexibleSpaceBar(
//             background: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFF1F5AC1),
//                     Color(0xFF97A9EC),
//                   ],
//                 ),
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 20, 16, 35),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Row(
//                         children: [
//                           const ShimmerWidget.circular(width: 65, height: 65),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: const [
//                                 ShimmerWidget.rectangular(height: 16, width: 150),
//                                 SizedBox(height: 6),
//                                 ShimmerWidget.rectangular(height: 12, width: 120),
//                                 SizedBox(height: 4),
//                                 ShimmerWidget.rectangular(height: 12, width: 100),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SliverToBoxAdapter(
//           child: Transform.translate(
//             offset: const Offset(0, 8),
//             child: const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: ShimmerWidget.rectangular(height: 100),
//             ),
//           ),
//         ),
//         SliverPadding(
//           padding: const EdgeInsets.all(16),
//           sliver: SliverGrid(
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               mainAxisExtent: 160,
//             ),
//             delegate: SliverChildBuilderDelegate(
//                   (context, index) => const ShimmerWidget.rectangular(height: 160),
//               childCount: 4,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // Grid Pattern Painter (keep existing)
// class GridPatternPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.08)
//       ..strokeWidth = 1.0
//       ..style = PaintingStyle.stroke;
//
//     const double gridSize = 30.0;
//
//     for (double i = 0; i < size.width; i += gridSize) {
//       canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
//     }
//
//     for (double i = 0; i < size.height; i += gridSize) {
//       canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
// import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

// import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/controllers/dashboard_controller.dart';
import 'package:mepco_esafety_app/controllers/notifications_controller.dart';
import 'package:mepco_esafety_app/controllers/profile_controller.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';
import 'package:mepco_esafety_app/widgets/custom_bottom_app_bar.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final ProfileController profileController = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBody: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerEffect();
          }
          return RefreshIndicator(
            onRefresh: () async => await controller.fetchDashboard(),
            color: const Color(0xFF2563EB),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar with Full Profile Info
                _buildCustomAppBar(context, profileController),

                // Stats Section
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, 15),
                    child: _buildStatsSection(controller),
                  ),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: _buildQuickActions(controller),
                  ),
                ),

                // HSE Field Check Card
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                //     child: _buildHseFieldCheckCard(),
                //   ),
                // ),

                // Recent PTWs Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent PTWs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.ptwList),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent PTWs Grid (2 columns like original)
                _buildRecentPtwsGrid(controller),

                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(
            () => CustomBottomAppBar(
          selectedIndex: controller.selectedIndex.value,
          onItemTapped: controller.onItemTapped,
        ),
      ),
    );
  }

  Widget _buildHseFieldCheckCard() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.hseFieldCheck),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF002997), Color(0xFF1835A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF002997).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(08),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.health_and_safety_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HSE Field Check',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Submit Field Inspection Performa',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(
      BuildContext context,
      ProfileController controller,
      ) {
    final notificationController = Get.find<NotificationsController>();
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1835A1),

      /// ---------- SIMPLE PROFILE ICON (TOP RIGHT) ----------
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 12),
          child: GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.notifications);
              notificationController.refreshNotifications();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // color: Color(0xFF2341B8).withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white24, // White outline
                      width: 2, // Thickness of the border
                    ),

                    /// NEUMORPHISM SHADOWS
                    boxShadow: [
                      // BoxShadow(
                      //   color: Colors.black.withOpacity(0.60),
                      //   blurRadius: 3,
                      //   // offset: Offset(3, 3),
                      // ),
                      BoxShadow(
                        color: Color(0xFF1835A1).withValues(alpha: 0.7),
                        blurRadius: 2,
                        // offset: Offset(-0.5, -0.5),
                      ),
                    ],
                  ),

                  child: const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),

                /// BADGE
                Positioned(
                  right: -4,
                  top: -4,
                  child: Obx(() {
                    final count = notificationController.unreadCount.value;
                    if (count == 0) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x1E4D7BFF), Color(0xFF768BD3)],
            ),
          ),
          child: Stack(
            children: [
              CustomPaint(painter: GridPatternPainter(), child: Container()),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /// Profile Image + Name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            final imagePath = controller.imagePath.value;
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Container(
                                  width: 65,
                                  height: 65,
                                  color: Colors.white,
                                  child: imagePath.isEmpty
                                      ? const Icon(Icons.person, size: 40)
                                      : imagePath.startsWith('http')
                                      ? CachedNetworkImage(
                                    imageUrl: imagePath,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                    const ShimmerWidget.circular(
                                      width: 65,
                                      height: 65,
                                    ),
                                    errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.person,
                                      size: 40,
                                    ),
                                  )
                                      : imagePath.startsWith('assets')
                                      ? const Icon(Icons.person, size: 40)
                                      : Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                      () => Text(
                                    controller.name.value,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildInfoRow(
                                  'Designation',
                                  controller.designation.value,
                                ),
                                _buildInfoRow(
                                  'SAP Code',
                                  controller.sapCode.value,
                                ),
                                _buildInfoRow(
                                  'Circle',
                                  controller.circle.value,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// Division + Sub Division
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              'Division',
                              controller.division.value,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoRow(
                              'Sub-Division',
                              controller.subDivision.value,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modern Filter Section
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.08),
                    const Color(0xFF2563EB).withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.filter_alt_rounded,
                      size: 12,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                              () => Text(
                            _getFilterLabel(
                              controller.selectedFilterType.value,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Obx(() {
                          if (controller.selectedFilterType.value ==
                              'custom_range' &&
                              controller.startDate.value != null &&
                              controller.endDate.value != null) {
                            final start = controller.startDate.value!;
                            final end = controller.endDate.value!;
                            return Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showFilterBottomSheet(controller),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Stats Row with enhanced design
            Row(
              children: [
                Obx(
                      () => _buildStatItem(
                    controller.totalPtws.value,
                    'Total PTWs',
                    Icons.description_rounded,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                      () => _buildStatItem(
                    controller.activePtws.value,
                    'Active PTWs',
                    Icons.pending_actions_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                      () => _buildStatItem(
                    controller.closedPtws.value,
                    'Completed',
                    Icons.check_circle_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                      () => _buildStatItem(
                    controller.cancelledPtws.value,
                    'Cancelled',
                    Icons.cancel_rounded,
                    const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String count,
      String label,
      IconData icon,
      Color color,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get filter label
  String _getFilterLabel(String filterType) {
    switch (filterType) {
      case 'last_week':
        return 'Last Week';
      case 'last_month':
        return 'Last Month';
      case 'last_3_months':
        return 'Last 3 Months';
      case 'last_6_months':
        return 'Last 6 Months';
      case 'custom_range':
        return 'Custom Range';
      case 'all_times':
      default:
        return 'All Time';
    }
  }

  // Modern Bottom sheet for filter options
  void _showFilterBottomSheet(HomeController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter Statistics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'Select time period',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildFilterOption(
                    controller,
                    'All Time',
                    'Show all statistics',
                    'all_times',
                    Icons.all_inclusive_rounded,
                  ),
                  _buildFilterOption(
                    controller,
                    'Last Week',
                    'Past 7 days',
                    'last_week',
                    Icons.calendar_view_week_rounded,
                  ),
                  _buildFilterOption(
                    controller,
                    'Last Month',
                    'Past 30 days',
                    'last_month',
                    Icons.calendar_view_month_rounded,
                  ),
                  _buildFilterOption(
                    controller,
                    'Last 3 Months',
                    'Past 90 days',
                    'last_3_months',
                    Icons.date_range_rounded,
                  ),
                  _buildFilterOption(
                    controller,
                    'Last 6 Months',
                    'Past 180 days',
                    'last_6_months',
                    Icons.event_note_rounded,
                  ),
                  _buildFilterOption(
                    controller,
                    'Custom Range',
                    'Pick your dates',
                    'custom_range',
                    Icons.calendar_today_rounded,
                    isCustom: true,
                  ),

                  const SizedBox(height: 16),

                  // Reset button
                  Obx(() {
                    if (controller.selectedFilterType.value != 'all_times') {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.resetFilter();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey[700],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Reset to All Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildFilterOption(
      HomeController controller,
      String title,
      String subtitle,
      String value,
      IconData icon, {
        bool isCustom = false,
      }) {
    return Obx(() {
      final isSelected = controller.selectedFilterType.value == value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (isCustom) {
                await _showCustomDatePicker(controller);
              } else {
                controller.applyFilter(value);
                Get.back();
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    const Color(0xFF2563EB).withValues(alpha: 0.05),
                  ],
                )
                    : null,
                color: isSelected ? null : Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF1E293B)
                                : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.grey[700]
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  else
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // FIXED: Custom Date Picker with proper date handling
  Future<void> _showCustomDatePicker(HomeController controller) async {
    // Use controller's existing dates or initialize as null
    DateTime? tempStartDate = controller.startDate.value;
    DateTime? tempEndDate = controller.endDate.value;

    final result = await Get.dialog<Map<String, DateTime?>>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.date_range_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Custom Date Range',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'Select start and end dates',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Start Date
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempStartDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF3B82F6),
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            tempStartDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: tempStartDate != null
                              ? LinearGradient(
                            colors: [
                              const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.1),
                              const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.05),
                            ],
                          )
                              : null,
                          color: tempStartDate != null ? null : Colors.grey[50],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: tempStartDate != null
                                ? const Color(0xFF3B82F6)
                                : Colors.grey.shade300,
                            width: tempStartDate != null ? 2 : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: tempStartDate != null
                                    ? const Color(0xFF3B82F6)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: tempStartDate != null
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tempStartDate != null
                                        ? '${tempStartDate!.day}/${tempStartDate!.month}/${tempStartDate!.year}'
                                        : 'Select start date',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: tempStartDate != null
                                          ? const Color(0xFF1E293B)
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: tempStartDate != null
                                  ? const Color(0xFF3B82F6)
                                  : Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // End Date
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempEndDate ?? DateTime.now(),
                          firstDate: tempStartDate ?? DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF3B82F6),
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            tempEndDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: tempEndDate != null
                              ? LinearGradient(
                            colors: [
                              const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.1),
                              const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.05),
                            ],
                          )
                              : null,
                          color: tempEndDate != null ? null : Colors.grey[50],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: tempEndDate != null
                                ? const Color(0xFF3B82F6)
                                : Colors.grey.shade300,
                            width: tempEndDate != null ? 2 : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: tempEndDate != null
                                    ? const Color(0xFF3B82F6)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.event_rounded,
                                size: 18,
                                color: tempEndDate != null
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tempEndDate != null
                                        ? '${tempEndDate!.day}/${tempEndDate!.month}/${tempEndDate!.year}'
                                        : 'Select end date',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: tempEndDate != null
                                          ? const Color(0xFF1E293B)
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: tempEndDate != null
                                  ? const Color(0xFF3B82F6)
                                  : Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: Colors.grey[100],
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow:
                            tempStartDate != null && tempEndDate != null
                                ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                                : [],
                          ),
                          child: ElevatedButton(
                            onPressed:
                            tempStartDate != null && tempEndDate != null
                                ? () {
                              // Return the selected dates
                              Get.back(
                                result: {
                                  'start': tempStartDate,
                                  'end': tempEndDate,
                                },
                              );
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.grey[500],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Apply Filter',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // If user selected dates, apply the filter
    if (result != null && result['start'] != null && result['end'] != null) {
      Get.back(); // Close bottom sheet
      controller.applyFilter(
        'custom_range',
        start: result['start'],
        end: result['end'],
      );
    }
  }

  Widget _buildQuickActions(HomeController controller) {
    return Obx(() {
      return SizedBox(
        height: 100,
        child: Row(
          children: [
            if (controller.canCreatePtw())
              Expanded(
                child: _buildActionButton(
                  label: 'New Work',
                  icon: Icons.add_circle_outline,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                  onTap: () async {
                    // ✅ STEP 1: Check location permissions first
                    bool serviceEnabled;
                    LocationPermission permission;

                    serviceEnabled =
                    await Geolocator.isLocationServiceEnabled();
                    if (!serviceEnabled) {
                      await Geolocator.openLocationSettings();
                      return;
                    }

                    permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied) {
                        SnackbarHelper.showError(
                          title: 'Permission Denied',
                          message:
                          'Location permission is required to create a PTW.',
                        );
                        return;
                      }
                    }

                    if (permission == LocationPermission.deniedForever) {
                      SnackbarHelper.showError(
                        title: 'Permission Denied',
                        message:
                        'Location permissions are permanently denied. Please enable them in settings.',
                      );
                      return;
                    }

                    // ✅ STEP 2: Pre-check PTW context (SDO + feeders + team members)
                    await _checkPtwContextBeforeCreate();
                  },
                ),
              ),
            if (controller.canCreatePtw()) const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                label: 'View All Works',
                icon: Icons.grid_view_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF64748B), Color(0xFF475569)],
                ),
                onTap: () => Get.toNamed(AppRoutes.ptwList),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ✅ NEW METHOD: Pre-check context before opening form
  Future<void> _checkPtwContextBeforeCreate() async {
    // Show loading dialog
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: const Center(
          child: Card(
            margin: EdgeInsets.all(32),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Validating...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        Get.back(); // Close loading
        SnackbarHelper.showError(
          title: 'Auth Error',
          message: 'Authentication token not found. Please login again.',
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/ptw/context'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Get.back(); // Close loading dialog

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        // ✅ Check SDO
        final sdoData = data['sdo'];
        if (sdoData == null) {
          SnackbarHelper.showError(
            title: 'SDO Not Found',
            message:
            'No SDO found for this sub-division. Please contact admin.',
          );
          return; // ❌ Don't open form
        }

        // ✅ Check primary feeders
        final primaryFeeders = data['primary_feeders'] as List? ?? [];
        if (primaryFeeders.isEmpty) {
          SnackbarHelper.showError(
            title: 'No Feeders',
            message:
            'No feeders found for your sub-division. Please contact admin.',
          );
          return; // ❌ Don't open form
        }

        // ✅ All good - open the form
        final result = await Get.toNamed(
          AppRoutes.createPtwScreen,
          arguments: {'mode': 'create'},
        );

        if (result == true) {
          final homeController = Get.find<HomeController>();
          homeController.fetchDashboard();
        }
      } else if (response.statusCode == 404) {
        // SDO not found (backend returned 404)
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'No SDO found for this sub-division';

        SnackbarHelper.showError(title: 'SDO Not Found', message: errorMessage);
      } else {
        // Other API errors
        SnackbarHelper.showError(
          title: 'Validation Failed',
          message: 'Failed to validate PTW context. Please try again.',
        );
      }
    } catch (e) {
      Get.back(); // Close loading if still open
      SnackbarHelper.showError(
        title: 'Error',
        message: 'Failed to validate: $e',
      );
    }
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPtwsGrid(HomeController controller) {
    return Obx(() {
      final recent = controller.ptwList.length > 6
          ? controller.ptwList.sublist(0, 6)
          : controller.ptwList;

      if (recent.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.folder_open_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Recent PTWs',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your recent PTWs will appear here',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final screenWidth = MediaQuery.of(Get.context!).size.width;
      final crossAxisCount = screenWidth < 360 ? 1 : 2;

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 160,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final ptw = recent[index];
            return _buildPtwCard(
              id: ptw.id,
              ptwId: ptw.ptwId,
              status: ptw.status,
              feeder: ptw.feeder,
              date: ptw.date,
              dueTime: ptw.dueTime.toString(),
              userRole: controller.currentUserRole.value,
            );
          }, childCount: recent.length),
        ),
      );
    });
  }

  Widget _buildPtwCard({
    required int? id,
    required String ptwId,
    required String status,
    required String feeder,
    required String date,
    required String? dueTime,
    required String userRole,
  }) {
    final statusText = PtwHelper.getStatusText(status);
    final statusColor = PtwHelper.getStatusColor(status);

    return GestureDetector(
      onTap: () {
        if (id != null) {
          Get.toNamed(
            AppRoutes.ptwReviewSdo,
            arguments: {'ptw_id': id, 'user_role': userRole},
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ptwId,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E40AF),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Feeder: $feeder',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              date,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            if (status.toUpperCase() == 'IN_EXECUTION' &&
                dueTime != null &&
                dueTime.isNotEmpty &&
                dueTime != 'null')
              DueCountdown(dueTime: dueTime),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFF1F5AC1),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1F5AC1), Color(0xFF97A9EC)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const ShimmerWidget.circular(width: 65, height: 65),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                ShimmerWidget.rectangular(
                                  height: 16,
                                  width: 150,
                                ),
                                SizedBox(height: 6),
                                ShimmerWidget.rectangular(
                                  height: 12,
                                  width: 120,
                                ),
                                SizedBox(height: 4),
                                ShimmerWidget.rectangular(
                                  height: 12,
                                  width: 100,
                                ),
                              ],
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
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const ShimmerWidget.rectangular(height: 100),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 160,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) => const ShimmerWidget.rectangular(height: 160),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}

// Grid Pattern Painter for Background
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSize = 30.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
