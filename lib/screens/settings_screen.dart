import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/profile_controller.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/profile_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    const primaryColor = Color(0xFF0D47A1);
    const primaryLight = Color(0xFF002171);
    const backgroundColor = Color(0xFFF8F9FD);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: MainLayout(
        title: 'Account Settings',
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Profile Header with Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: ProfileHeader(controller: controller),
              ),

              const SizedBox(height: 24),

              // Section Title
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // Menu Items Card Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildModernMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Profile',
                      subtitle: 'View your profile details',
                      onTap: () => Get.toNamed(AppRoutes.profile),
                      primaryColor: primaryColor,
                      isFirst: true,
                    ),
                    _buildMenuDivider(),
                    _buildModernMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      subtitle: 'Update your information',
                      onTap: () => Get.toNamed(AppRoutes.editProfile),
                      primaryColor: primaryColor,
                    ),
                    _buildMenuDivider(),
                    _buildModernMenuItem(
                      icon: Icons.list_alt_rounded,
                      title: 'PTW List',
                      subtitle: 'View permit to work records',
                      onTap: () => Get.toNamed(AppRoutes.ptwList),
                      primaryColor: primaryColor,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              // Biometric Section (if supported)
              Obx(() {
                if (controller.isBiometricSupported.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'Security',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: _buildBiometricToggle(controller, primaryColor, primaryLight),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),

              SizedBox(height: MediaQuery.of(context).size.height * 0.08),

              // Logout Section
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Account Actions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              Obx(() => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD32F2F).withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD32F2F).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: controller.isLoading.value ? null : () {
                      _showLogoutDialog(context, controller);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              controller.isLoading.value ? Icons.hourglass_empty_rounded : Icons.logout_rounded,
                              size: 22,
                              color: const Color(0xFFD32F2F),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.isLoading.value ? 'Logging out...' : 'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: controller.isLoading.value ? Colors.grey : const Color(0xFFD32F2F),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  controller.isLoading.value ? 'Please wait...' : 'Sign out of your account',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!controller.isLoading.value)
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          if (controller.isLoading.value)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFD32F2F).withOpacity(0.7),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primaryColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.12),
                      primaryColor.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricToggle(ProfileController controller, Color primaryColor, Color primaryLight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.12),
                  primaryLight.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              size: 22,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biometric Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Face/Fingerprint Authentication',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Obx(() => Container(
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(20),
            //   boxShadow: controller.isBiometricEnabled.value
            //       ? [
            //     BoxShadow(
            //       color: primaryColor.withOpacity(0.3),
            //       blurRadius: 8,
            //       offset: const Offset(0, 2),
            //     ),
            //   ]
            //       : null,
            // ),
            child: Transform.scale(
              scale: 0.85,
              child: Switch(
                value: controller.isBiometricEnabled.value,
                onChanged: (value) => controller.toggleBiometric(value),
                activeColor: primaryColor,
                activeTrackColor: primaryColor.withOpacity(0.3),
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey[200],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 68),
      height: 1,
      color: Colors.grey.withOpacity(0.1),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    const primaryColor = Color(0xFF0D47A1);
    const accentColor = Color(0xFFD32F2F);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from your account?',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mepco_esafety_app/controllers/profile_controller.dart';
// import 'package:mepco_esafety_app/routes/app_routes.dart';
// import 'package:mepco_esafety_app/widgets/main_layout.dart';
// import 'package:mepco_esafety_app/widgets/profile_header.dart';
//
// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final ProfileController controller = Get.find();
//     return Scaffold(
//       body: MainLayout(
//         title: 'Menu',
//         child: ListView(
//           children: [
//             ProfileHeader(controller: controller),
//             const SizedBox(height: 20),
//             const Divider(thickness: 1, indent: 20, endIndent: 20),
//             ListTile(
//                 leading: const Icon(Icons.person, color: Color(0xFF0D38AC)),
//                 title: const Text('Profile'),
//                 onTap: () {
//                   Get.toNamed(AppRoutes.profile);
//                 }),
//             ListTile(
//                 leading: const Icon(Icons.edit, color: Color(0xFF0D38AC)),
//                 title: const Text('Edit Profile'),
//                 onTap: () {
//                   Get.toNamed(AppRoutes.editProfile);
//                 }),
//             ListTile(
//                 leading: const Icon(Icons.list, color: Color(0xFF0D38AC)),
//                 title: const Text('PTW List'),
//                 onTap: () {
//                   Get.toNamed(AppRoutes.ptwList);
//                 }),
//
//             Obx(() {
//               if (controller.isBiometricSupported.value) {
//                 return ListTile(
//                   leading: const Icon(Icons.fingerprint, color: Color(0xFF0D38AC)),
//                   title: const Text('Biometric Login'),
//                   subtitle: const Text('Enable Face/Fingerprint Authentication'),
//                   trailing: SwitchTheme(
//                     data: SwitchThemeData(
//                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       thumbColor: WidgetStateProperty.all(const Color(0xFF0D38AC)),
//                     ),
//                     child: Transform.scale(
//                       scale: 0.8,
//                       child: Switch(
//                         value: controller.isBiometricEnabled.value,
//                         onChanged: (value) => controller.toggleBiometric(value),
//                         activeColor: const Color(0xFF0D38AC),
//                       ),
//                     ),
//                   ),
//                 );
//               } else {
//                 return const SizedBox.shrink();
//               }
//             }),
//
//             SizedBox(height: MediaQuery.of(context).size.height * 0.15),
//             const Divider(
//               thickness: 1,
//               indent: 20,
//               endIndent: 20,
//               color: Color(0xffefe8e8),
//             ),
//             Obx(() => ListTile(
//               leading: const Icon(Icons.logout, color:Color(0xFF0D38AC)),
//               title: Text(
//                 controller.isLoading.value ? 'Logging out...' : 'Logout',
//                 style: TextStyle(
//                   color: controller.isLoading.value ? Colors.grey : Colors.black,
//                 ),
//               ),
//               onTap: controller.isLoading.value ? null : () {
//                 controller.logout();
//               },
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }
