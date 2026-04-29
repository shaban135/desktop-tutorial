// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mepco_esafety_app/controllers/profile_controller.dart';
// import 'package:mepco_esafety_app/routes/app_routes.dart';
// import 'package:mepco_esafety_app/widgets/custom_bottom_app_bar.dart';
// import 'package:mepco_esafety_app/widgets/main_layout.dart';
// import 'package:mepco_esafety_app/widgets/profile_header.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../constants/storage_keys.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//   Future<void> _handleProfileTap() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userDataString = prefs.getString(StorageKeys.userData);
//
//     if (userDataString != null) {
//       final userData = jsonDecode(userDataString);
//       final List<dynamic> permissions = userData['permissions'] ?? [];
//
//       if (permissions.contains('users.update.self')) {
//         Get.toNamed(AppRoutes.editProfile);
//       } else {
//         Get.snackbar(
//           'Permission Denied',
//           'You do not have permission to view this page.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } else {
//       Get.snackbar('Error', 'User data not found.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ProfileController controller = Get.find();
//     final int selectedIndex = 4;
//
//     void onItemTapped(int index) {
//       if (index != 4) {
//         Get.back();
//       }
//     }
//
//     return Scaffold(
//       extendBody: true,
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return MainLayout(
//           showBottomAppBar: true,
//           title: 'Employee Profile',
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.edit_outlined, color: Colors.white),
//               onPressed: () {
//                 _handleProfileTap();
//               },
//             ),
//           ],
//           child: ListView(
//             padding: const EdgeInsets.all(24.0),
//             children: [
//               ProfileHeader(controller: controller),
//               const SizedBox(height: 24),
//               _buildPersonalInfoCard(context, controller),
//               const SizedBox(height: 16),
//               _buildEmploymentCard(context, controller),
//               const SizedBox(height: 16),
//               _buildPostingCard(context, controller),
//               const SizedBox(height: 80),
//             ],
//           ),
//         );
//       }),
//       // bottomNavigationBar: CustomBottomAppBar(
//       //   selectedIndex: selectedIndex,
//       //   onItemTapped: onItemTapped,
//       // ),
//     );
//   }
//
//   Widget _buildPersonalInfoCard(BuildContext context, ProfileController controller) {
//     return Card(
//       elevation: 2,
//       color: Colors.white,
//       shadowColor: Colors.black12,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: const BorderSide(color: Color(0xFFEAEAEA), width: 1.0),
//       ),
//       child: Theme(
//         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//         child: Obx(() => ExpansionTile(
//           initiallyExpanded: true,
//           title: Text(controller.name.value, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   _buildDetailRow('Name', controller.name.value),
//                   _buildDetailRow('Date of Birth', controller.dob.value),
//                   _buildDetailRow('Phone', controller.phone.value),
//                   _buildDetailRow('Address', controller.address.value),
//                   _buildDetailRow('CNIC', controller.cnic.value),
//                 ],
//               ),
//             ),
//           ],
//         )),
//       ),
//     );
//   }
//
//   Widget _buildEmploymentCard(BuildContext context, ProfileController controller) {
//     return Card(
//       elevation: 2,
//       color: Colors.white,
//       shadowColor: Colors.black12,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: const BorderSide(color: Color(0xFFEAEAEA), width: 1.0),
//       ),
//       child: Theme(
//         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//         child: Obx(() => ExpansionTile(
//           initiallyExpanded: true,
//           title: const Text('Employment', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   _buildDetailRow('SAP Code', controller.sapCode.value),
//                   _buildDetailRow('Department', controller.department.value),
//                   _buildDetailRow('Date of Joining', controller.dateOfJoining.value),
//                   _buildDetailRow('Email', controller.email.value),
//                 ],
//               ),
//             ),
//           ],
//         )),
//       ),
//     );
//   }
//
//   Widget _buildPostingCard(BuildContext context, ProfileController controller) {
//     return Card(
//       elevation: 2,
//       color: Colors.white,
//       shadowColor: Colors.black12,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: const BorderSide(color: Color(0xFFEAEAEA), width: 1.0),
//       ),
//       child: Theme(
//         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//         child: Obx(() => ExpansionTile(
//           initiallyExpanded: true,
//           title: const Text('Posting', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   _buildDetailRow('Designation', controller.designation.value),
//                   _buildDetailRow('Region', controller.region.value),
//                   _buildDetailRow('Circle', controller.circle.value),
//                   _buildDetailRow('Division', controller.division.value),
//                   _buildDetailRow('Sub-Division', controller.subDivision.value),
//                   _buildDetailRow('Effective From', controller.effectiveFrom.value),
//                   _buildDetailRow('Effective To', controller.effectiveTo.value),
//                   _buildDetailRow('Feeder', controller.feeder.value),
//                 ],
//               ),
//             ),
//           ],
//         )),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
//           Expanded(
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               style: const TextStyle(color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/profile_controller.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/profile_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isPersonalInfoExpanded = true;
  bool isEmploymentExpanded = true;
  bool isPostingExpanded = true;

  Future<void> _handleProfileTap() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(StorageKeys.userData);

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      final List<dynamic> permissions = userData['permissions'] ?? [];

      if (permissions.contains('users.update.self')) {
        Get.toNamed(AppRoutes.editProfile);
      } else {
        Get.snackbar(
          'Permission Denied',
          'You do not have permission to view this page.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
          borderRadius: 10,
          icon: const Icon(Icons.lock_outline, color: Colors.white),
        );
      }
    } else {
      Get.snackbar('Error', 'User data not found.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    // App Theme Colors
    const primaryColor = Color(0xFF0D47A1);
    const primaryLight = Color(0xFF002171);
    const accentColor = Color(0xFFD32F2F);
    const backgroundColor = Color(0xFFF8F9FD);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading Profile...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        return MainLayout(
          showBottomAppBar: true,
          title: 'Employee Profile',
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                onPressed: _handleProfileTap,
              ),
            ),
          ],
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              children: [
                // Enhanced Profile Header with Glassmorphism Effect
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: ProfileHeader(controller: controller),
                ),
                const SizedBox(height: 32),

                // Personal Information - Collapsible
                _buildCollapsibleSection(
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  primaryColor: primaryColor,
                  lightColor: primaryLight,
                  isExpanded: isPersonalInfoExpanded,
                  onToggle: () => setState(() => isPersonalInfoExpanded = !isPersonalInfoExpanded),
                  content: _buildPersonalInfoCard(context, controller, primaryColor, primaryLight),
                ),

                const SizedBox(height: 20),

                // Employment Details - Collapsible
                _buildCollapsibleSection(
                  title: 'Employment Details',
                  icon: Icons.work_outline,
                  primaryColor: primaryColor,
                  lightColor: primaryLight,
                  isExpanded: isEmploymentExpanded,
                  onToggle: () => setState(() => isEmploymentExpanded = !isEmploymentExpanded),
                  content: _buildEmploymentCard(context, controller, primaryColor, primaryLight),
                ),

                const SizedBox(height: 20),

                // Posting & Assignment - Collapsible
                _buildCollapsibleSection(
                  title: 'Posting & Assignment',
                  icon: Icons.location_on_outlined,
                  primaryColor: primaryColor,
                  lightColor: primaryLight,
                  isExpanded: isPostingExpanded,
                  onToggle: () => setState(() => isPostingExpanded = !isPostingExpanded),
                  content: _buildPostingCard(context, controller, primaryColor, primaryLight),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required Color primaryColor,
    required Color lightColor,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Column(
      children: [
        // Section Header - Clickable
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.95),
                  lightColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Collapsible Content
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Padding(
            padding: const EdgeInsets.only(top: 16),
            child: content,
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context, ProfileController controller, Color primaryColor, Color lightColor) {
    return _buildEnhancedBaseCard(
      primaryColor: primaryColor,
      lightColor: lightColor,
      child: Column(
        children: [
          _buildEnhancedDetailRow(Icons.badge_outlined, 'Name', controller.name.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.cake_outlined, 'Date of Birth', controller.dob.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.phone_android_outlined, 'Phone', controller.phone.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.home_outlined, 'Address', controller.address.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.fingerprint_outlined, 'CNIC', controller.cnic.value, primaryColor, lightColor),
        ],
      ),
    );
  }

  Widget _buildEmploymentCard(BuildContext context, ProfileController controller, Color primaryColor, Color lightColor) {
    return _buildEnhancedBaseCard(
      primaryColor: primaryColor,
      lightColor: lightColor,
      child: Column(
        children: [
          _buildEnhancedDetailRow(Icons.qr_code_2_outlined, 'SAP Code', controller.sapCode.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.business_outlined, 'Department', controller.department.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.calendar_today_outlined, 'Date of Joining', controller.dateOfJoining.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.email_outlined, 'Email', controller.email.value, primaryColor, lightColor),
        ],
      ),
    );
  }

  Widget _buildPostingCard(BuildContext context, ProfileController controller, Color primaryColor, Color lightColor) {
    return _buildEnhancedBaseCard(
      primaryColor: primaryColor,
      lightColor: lightColor,
      child: Column(
        children: [
          _buildEnhancedDetailRow(Icons.assignment_ind_outlined, 'Designation', controller.designation.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.map_outlined, 'Region', controller.region.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.adjust_outlined, 'Circle', controller.circle.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.account_tree_outlined, 'Division', controller.division.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.layers_outlined, 'Sub-Division', controller.subDivision.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.event_available_outlined, 'Effective From', controller.effectiveFrom.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.event_busy_outlined, 'Effective To', controller.effectiveTo.value, primaryColor, lightColor),
          _buildModernDivider(),
          _buildEnhancedDetailRow(Icons.electric_bolt_outlined, 'Feeder', controller.feeder.value, primaryColor, lightColor),
        ],
      ),
    );
  }

  Widget _buildEnhancedBaseCard({
    required Widget child,
    required Color primaryColor,
    required Color lightColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        child: child,
      ),
    );
  }

  Widget _buildEnhancedDetailRow(IconData icon, String title, String value, Color primaryColor, Color lightColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.12),
                  lightColor.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: primaryColor),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? 'Not Available' : value,
                  style: const TextStyle(
                    fontSize: 15.5,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 60, right: 0),
      height: 1,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.12),
      ),
    );
  }
}
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mepco_esafety_app/controllers/profile_controller.dart';
// import 'package:mepco_esafety_app/routes/app_routes.dart';
// import 'package:mepco_esafety_app/widgets/main_layout.dart';
// import 'package:mepco_esafety_app/widgets/profile_header.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../constants/storage_keys.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   Future<void> _handleProfileTap() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userDataString = prefs.getString(StorageKeys.userData);
//
//     if (userDataString != null) {
//       final userData = jsonDecode(userDataString);
//       final List<dynamic> permissions = userData['permissions'] ?? [];
//
//       if (permissions.contains('users.update.self')) {
//         Get.toNamed(AppRoutes.editProfile);
//       } else {
//         Get.snackbar(
//           'Permission Denied',
//           'You do not have permission to view this page.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.redAccent,
//           colorText: Colors.white,
//           margin: const EdgeInsets.all(15),
//           borderRadius: 10,
//           icon: const Icon(Icons.lock_outline, color: Colors.white),
//         );
//       }
//     } else {
//       Get.snackbar('Error', 'User data not found.', snackPosition: SnackPosition.BOTTOM);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ProfileController controller = Get.find();
//
//     // Enhanced Theme Colors with Gradients
//     const primaryColor = Color(0xFF1A237E);
//     const primaryLight = Color(0xFF534BAE);
//     const accentColor = Color(0xFFD32F2F);
//     const backgroundColor = Color(0xFFF8F9FD);
//
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       extendBody: true,
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: primaryColor.withOpacity(0.2),
//                         blurRadius: 20,
//                         spreadRadius: 5,
//                       ),
//                     ],
//                   ),
//                   child: const CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
//                     strokeWidth: 3,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Loading Profile...',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//         return MainLayout(
//           showBottomAppBar: true,
//           title: 'Employee Profile',
//           actions: [
//             Container(
//               margin: const EdgeInsets.only(right: 8),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: IconButton(
//                 icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
//                 onPressed: _handleProfileTap,
//               ),
//             ),
//           ],
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
//             child: Column(
//               children: [
//                 // Enhanced Profile Header with Glassmorphism Effect
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(24),
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.white,
//                         Colors.white.withOpacity(0.95),
//                       ],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: primaryColor.withOpacity(0.15),
//                         blurRadius: 30,
//                         offset: const Offset(0, 12),
//                         spreadRadius: -8,
//                       ),
//                     ],
//                   ),
//                   child: ProfileHeader(controller: controller),
//                 ),
//                 const SizedBox(height: 32),
//
//                 // Info Sections with Animated Cards
//                 _buildEnhancedSectionTitle('Personal Information', Icons.person_outline, primaryColor, primaryLight),
//                 const SizedBox(height: 16),
//                 _buildPersonalInfoCard(context, controller, primaryColor, primaryLight),
//
//                 const SizedBox(height: 28),
//                 _buildEnhancedSectionTitle('Employment Details', Icons.work_outline, primaryColor, primaryLight),
//                 const SizedBox(height: 16),
//                 _buildEmploymentCard(context, controller, primaryColor, primaryLight),
//
//                 const SizedBox(height: 28),
//                 _buildEnhancedSectionTitle('Posting & Assignment', Icons.location_on_outlined, primaryColor, primaryLight),
//                 const SizedBox(height: 16),
//                 _buildPostingCard(context, controller, primaryColor, primaryLight),
//
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildEnhancedSectionTitle(String title, IconData icon, Color primaryColor, Color lightColor) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color(0xFF0D47A1),
//             Color(0xFF002171),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.25),
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.25),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, size: 22, color: Colors.white),
//           ),
//           const SizedBox(width: 14),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               letterSpacing: 0.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPersonalInfoCard(BuildContext context, ProfileController controller, Color primaryColor, Color lightColor) {
//     return _buildEnhancedBaseCard(
//       primaryColor: primaryColor,
//       lightColor: lightColor,
//       child: Column(
//         children: [
//           _buildEnhancedDetailRow(Icons.badge_outlined, 'Name', controller.name.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.cake_outlined, 'Date of Birth', controller.dob.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.phone_android_outlined, 'Phone', controller.phone.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.home_outlined, 'Address', controller.address.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.fingerprint_outlined, 'CNIC', controller.cnic.value, primaryColor, lightColor),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmploymentCard(BuildContext context, ProfileController controller, Color primaryColor, Color lightColor) {
//     return _buildEnhancedBaseCard(
//       primaryColor: primaryColor,
//       lightColor: lightColor,
//       child: Column(
//         children: [
//           _buildEnhancedDetailRow(Icons.qr_code_2_outlined, 'SAP Code', controller.sapCode.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.business_outlined, 'Department', controller.department.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.calendar_today_outlined, 'Date of Joining', controller.dateOfJoining.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.email_outlined, 'Email', controller.email.value, primaryColor, lightColor),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPostingCard(BuildContext context, ProfileController controller, Color primaryColor, Color lightColor) {
//     return _buildEnhancedBaseCard(
//       primaryColor: primaryColor,
//       lightColor: lightColor,
//       child: Column(
//         children: [
//           _buildEnhancedDetailRow(Icons.assignment_ind_outlined, 'Designation', controller.designation.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.map_outlined, 'Region', controller.region.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.adjust_outlined, 'Circle', controller.circle.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.account_tree_outlined, 'Division', controller.division.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.layers_outlined, 'Sub-Division', controller.subDivision.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.event_available_outlined, 'Effective From', controller.effectiveFrom.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.event_busy_outlined, 'Effective To', controller.effectiveTo.value, primaryColor, lightColor),
//           _buildModernDivider(),
//           _buildEnhancedDetailRow(Icons.electric_bolt_outlined, 'Feeder', controller.feeder.value, primaryColor, lightColor),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEnhancedBaseCard({
//     required Widget child,
//     required Color primaryColor,
//     required Color lightColor,
//   }) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.12),
//             blurRadius: 25,
//             offset: const Offset(0, 10),
//             spreadRadius: -5,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
//         child: child,
//       ),
//     );
//   }
//
//   Widget _buildEnhancedDetailRow(IconData icon, String title, String value, Color primaryColor, Color lightColor) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 14.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(11),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   primaryColor.withOpacity(0.12),
//                   lightColor.withOpacity(0.08),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(14),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColor.withOpacity(0.15),
//                   blurRadius: 8,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Icon(icon, size: 22, color: primaryColor),
//           ),
//           const SizedBox(width: 18),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 12.5,
//                     color: Colors.grey[500],
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   value.isEmpty ? 'Not Available' : value,
//                   style: const TextStyle(
//                     fontSize: 15.5,
//                     color: Color(0xFF2C3E50),
//                     fontWeight: FontWeight.w700,
//                     height: 1.3,
//                   ),
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildModernDivider() {
//     return Container(
//       margin: const EdgeInsets.only(left: 60, right: 0),
//       height: 1,
//       decoration: BoxDecoration(
//         color: Colors.grey.withOpacity(0.12),
//       ),
//     );
//   }
// }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mepco_esafety_app/controllers/profile_controller.dart';
// import 'package:mepco_esafety_app/routes/app_routes.dart';
// import 'package:mepco_esafety_app/widgets/main_layout.dart';
// import 'package:mepco_esafety_app/widgets/profile_header.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../constants/storage_keys.dart';
//
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});
//
//   Future<void> _handleProfileTap() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userDataString = prefs.getString(StorageKeys.userData);
//
//     if (userDataString != null) {
//       final userData = jsonDecode(userDataString);
//       final List<dynamic> permissions = userData['permissions'] ?? [];
//
//       if (permissions.contains('users.update.self')) {
//         Get.toNamed(AppRoutes.editProfile);
//       } else {
//         Get.snackbar(
//           'Permission Denied',
//           'You do not have permission to view this page.',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.redAccent,
//           colorText: Colors.white,
//           margin: const EdgeInsets.all(15),
//           borderRadius: 10,
//           icon: const Icon(Icons.lock_outline, color: Colors.white),
//         );
//       }
//     } else {
//       Get.snackbar('Error', 'User data not found.', snackPosition: SnackPosition.BOTTOM);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ProfileController controller = Get.find();
//
//     // Define Theme Colors
//     const primaryColor = Color(0xFF1A237E); // Professional Deep Blue
//     const accentColor = Color(0xFFD32F2F);  // Professional Red
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       extendBody: true,
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
//             ),
//           );
//         }
//         return MainLayout(
//           showBottomAppBar: true,
//           title: 'Employee Profile',
//           actions: [
//             Container(
//               margin: const EdgeInsets.only(right: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: IconButton(
//                 icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
//                 onPressed: _handleProfileTap,
//               ),
//             ),
//           ],
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
//             child: Column(
//               children: [
//                 // Profile Header with subtle shadow
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 15,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: ProfileHeader(controller: controller),
//                 ),
//                 const SizedBox(height: 25),
//
//                 // Info Sections
//                 _buildSectionTitle('Personal Information', Icons.person_outline, primaryColor),
//                 _buildPersonalInfoCard(context, controller, primaryColor),
//
//                 const SizedBox(height: 20),
//                 _buildSectionTitle('Employment Details', Icons.work_outline, primaryColor),
//                 _buildEmploymentCard(context, controller, primaryColor),
//
//                 const SizedBox(height: 20),
//                 _buildSectionTitle('Posting & Assignment', Icons.location_on_outlined, primaryColor),
//                 _buildPostingCard(context, controller, primaryColor),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildSectionTitle(String title, IconData icon, Color color) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 4, bottom: 12),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: color),
//           const SizedBox(width: 8),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: color.withOpacity(0.8),
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPersonalInfoCard(BuildContext context, ProfileController controller, Color themeColor) {
//     return _buildBaseCard(
//       child: Column(
//         children: [
//           _buildDetailRow(Icons.badge_outlined, 'Name', controller.name.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.cake_outlined, 'Date of Birth', controller.dob.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.phone_android_outlined, 'Phone', controller.phone.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.home_outlined, 'Address', controller.address.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.fingerprint_outlined, 'CNIC', controller.cnic.value),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmploymentCard(BuildContext context, ProfileController controller, Color themeColor) {
//     return _buildBaseCard(
//       child: Column(
//         children: [
//           _buildDetailRow(Icons.qr_code_2_outlined, 'SAP Code', controller.sapCode.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.business_outlined, 'Department', controller.department.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.calendar_today_outlined, 'Date of Joining', controller.dateOfJoining.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.email_outlined, 'Email', controller.email.value),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPostingCard(BuildContext context, ProfileController controller, Color themeColor) {
//     return _buildBaseCard(
//       child: Column(
//         children: [
//           _buildDetailRow(Icons.assignment_ind_outlined, 'Designation', controller.designation.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.map_outlined, 'Region', controller.region.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.adjust_outlined, 'Circle', controller.circle.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.account_tree_outlined, 'Division', controller.division.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.layers_outlined, 'Sub-Division', controller.subDivision.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.event_available_outlined, 'Effective From', controller.effectiveFrom.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.event_busy_outlined, 'Effective To', controller.effectiveTo.value),
//           _buildDivider(),
//           _buildDetailRow(Icons.electric_bolt_outlined, 'Feeder', controller.feeder.value),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBaseCard({required Widget child}) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.withOpacity(0.1)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: child,
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(IconData icon, String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF0F2F8),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, size: 18, color: const Color(0xFF1A237E)),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value.isEmpty ? 'N/A' : value,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDivider() {
//     return Divider(
//       height: 1,
//       thickness: 1,
//       color: Colors.grey.withOpacity(0.05),
//       indent: 50,
//     );
//   }
// }
