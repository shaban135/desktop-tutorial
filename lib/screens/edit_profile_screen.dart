import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/constants/app_colors.dart';
import 'package:mepco_esafety_app/controllers/profile_controller.dart';
import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
import 'package:mepco_esafety_app/widgets/gradient_button.dart';
import 'package:mepco_esafety_app/widgets/loading_widget.dart';
import 'package:mepco_esafety_app/widgets/main_layout.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isUpdateDetailsSelected = true;

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingWidget());
        }
        return MainLayout(
          title: 'Edit Profile',
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildToggleButtons(),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: _isUpdateDetailsSelected
                        ? _buildDetailsForm(controller)
                        : _buildPasswordForm(controller),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      height: 41,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _isUpdateDetailsSelected ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: 350 / 2,
              height: 41,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1),
                    Color(0xFF002171),],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isUpdateDetailsSelected = true;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      "Update Details",
                      style: TextStyle(
                        color: _isUpdateDetailsSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isUpdateDetailsSelected = false;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      "Update Password",
                      style: TextStyle(
                        color: !_isUpdateDetailsSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
  }

  Widget _buildDetailsForm(ProfileController controller) {
    return Column(
      children: [
        _buildProfileImage(controller),
        const SizedBox(height: 24),
        CustomTextFormField(
          controller: controller.nameController,
          labelText: 'Name',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        Obx(() => DropdownButtonFormField<String>(
              initialValue: controller.gender.value == 'N/A' ? null : controller.gender.value,
              decoration: InputDecoration(
                labelText: 'Gender',
                labelStyle: const TextStyle(
                  color: Color(0xFFA1A1A1),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.wc_outlined),
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                  borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
                ),
              ),
              dropdownColor: Colors.white,
              items: ['male', 'female'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.capitalizeFirst!),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  controller.gender.value = newValue;
                }
              },
            )),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectDate(context, controller),
          child: AbsorbPointer(
            child: CustomTextFormField(
              controller: controller.dobController,
              labelText: 'Date of Birth',
              prefixIcon: Icons.calendar_today_outlined,
            ),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.phoneController,
          labelText: 'Phone',
          prefixIcon: Icons.phone_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.addressController,
          labelText: 'Address',
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.cnicController,
          labelText: 'CNIC',
          prefixIcon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.emailController,
          labelText: 'Email',
          prefixIcon: Icons.email_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.sapCodeController,
          labelText: 'SAP Code',
          prefixIcon: Icons.code_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.departmentController,
          labelText: 'Department',
          prefixIcon: Icons.business_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.designationController,
          labelText: 'Designation',
          prefixIcon: Icons.work_outline,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.regionController,
          labelText: 'Region',
          prefixIcon: Icons.map_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.circleController,
          labelText: 'Circle',
          prefixIcon: Icons.circle_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.divisionController,
          labelText: 'Division',
          prefixIcon: Icons.location_city_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.subDivisionController,
          labelText: 'Sub-Division',
          prefixIcon: Icons.holiday_village_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.feederController,
          labelText: 'Feeder',
          prefixIcon: Icons.electrical_services_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.isActiveController,
          labelText: 'Is Active',
          prefixIcon: Icons.check_circle_outline,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.dateOfJoiningController,
          labelText: 'Date of Joining',
          prefixIcon: Icons.date_range_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 24),
        GradientButton(
          text: 'Update Profile',
          onPressed: controller.updateProfile,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
      ],
    );
  }
  Future<void> _selectDate(BuildContext context, ProfileController controller) async {
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(controller.dobController.text);
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFED1C24), // selected date + header color
              onPrimary: Colors.white, // text color on selected date
              surface: Colors.white, // calendar background
              onSurface: Colors.black, // text color
            ),
            dialogBackgroundColor: const Color(0xFFF5F5F5), // background color of the dialog
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFED1C24), // 'OK' and 'CANCEL' button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      controller.dobController.text = formattedDate;
    }
  }
  Widget _buildPasswordForm(ProfileController controller) {
    return Column(
      children: [
        const SizedBox(height: 24),
        CustomTextFormField(
          controller: controller.currentPasswordController,
          labelText: 'Current Password',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.newPasswordController,
          labelText: 'New Password',
          prefixIcon: Icons.lock_open_outlined,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: controller.confirmPasswordController,
          labelText: 'Confirm New Password',
          prefixIcon: Icons.lock_open_outlined,
          obscureText: true,
        ),
        const SizedBox(height: 24),
        GradientButton(
          text: 'Update Password',
          onPressed: controller.updatePassword,
        ),
      ],
    );
  }

  Widget _buildProfileImage(ProfileController controller) {
    return Stack(
      children: [
        Obx(() {
          final imagePath = controller.imagePath.value;
          return ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: SizedBox(
              width: 100,
              height: 100,
              child: imagePath.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerWidget.circular(width: 100, height: 100),
                      errorWidget: (context, url, error) => const Icon(Icons.person, size: 40),
                    )
                  : imagePath.startsWith('assets')
                      ? const Icon(Icons.person, size: 40)
                      : Image.file(File(imagePath), fit: BoxFit.cover),
            ),
          );
        }),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF002171),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        )

      ],
    );
  }
}
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mepco_esafety_app/constants/app_colors.dart';
// import 'package:mepco_esafety_app/controllers/profile_controller.dart';
// import 'package:mepco_esafety_app/widgets/custom_text_form_field.dart';
// import 'package:mepco_esafety_app/widgets/gradient_button.dart';
// import 'package:mepco_esafety_app/widgets/loading_widget.dart';
// import 'package:mepco_esafety_app/widgets/main_layout.dart';
// import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   bool _isUpdateDetailsSelected = true;
//
//   @override
//   Widget build(BuildContext context) {
//     final ProfileController controller = Get.find();
//
//     const primaryColor = Color(0xFF0D47A1);
//     const backgroundColor = Color(0xFFF8F9FD);
//
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       resizeToAvoidBottomInset: false,
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: primaryColor.withOpacity(0.1),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: const LoadingWidget(),
//             ),
//           );
//         }
//         return MainLayout(
//           title: 'Edit Profile',
//           child: Column(
//             children: [
//               // Toggle buttons with padding
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//                 child: _buildToggleButtons(),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Scrollable content
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
//                   child: _isUpdateDetailsSelected
//                       ? _buildDetailsForm(controller)
//                       : _buildPasswordForm(controller),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildToggleButtons() {
//     const primaryColor = Color(0xFF0D47A1);
//     const primaryLight = Color(0xFF002171);
//
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(
//           color: primaryColor.withOpacity(0.15),
//           width: 1.5,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.08),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           AnimatedAlign(
//             alignment: _isUpdateDetailsSelected
//                 ? Alignment.centerLeft
//                 : Alignment.centerRight,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOutCubic,
//             child: FractionallySizedBox(
//               widthFactor: 0.5,
//               child: Container(
//                 margin: const EdgeInsets.all(3),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [primaryColor, primaryLight],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(22),
//                   boxShadow: [
//                     BoxShadow(
//                       color: primaryColor.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isUpdateDetailsSelected = true;
//                     });
//                   },
//                   child: Container(
//                     color: Colors.transparent,
//                     alignment: Alignment.center,
//                     child: AnimatedDefaultTextStyle(
//                       duration: const Duration(milliseconds: 200),
//                       style: TextStyle(
//                         color: _isUpdateDetailsSelected
//                             ? Colors.white
//                             : Colors.grey[700],
//                         fontWeight: _isUpdateDetailsSelected
//                             ? FontWeight.w700
//                             : FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                       child: const Text("Update Details"),
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isUpdateDetailsSelected = false;
//                     });
//                   },
//                   child: Container(
//                     color: Colors.transparent,
//                     alignment: Alignment.center,
//                     child: AnimatedDefaultTextStyle(
//                       duration: const Duration(milliseconds: 200),
//                       style: TextStyle(
//                         color: !_isUpdateDetailsSelected
//                             ? Colors.white
//                             : Colors.grey[700],
//                         fontWeight: !_isUpdateDetailsSelected
//                             ? FontWeight.w700
//                             : FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                       child: const Text("Update Password"),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailsForm(ProfileController controller) {
//     return Column(
//       children: [
//         const SizedBox(height: 8),
//
//         // Profile Image Card
//         Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF0D47A1).withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//                 spreadRadius: -5,
//               ),
//             ],
//           ),
//           child: Center(child: _buildProfileImage(controller)),
//         ),
//
//         const SizedBox(height: 24),
//
//         // Editable Fields Section
//         _buildSectionTitle('Personal Information'),
//         const SizedBox(height: 12),
//
//         CustomTextFormField(
//           controller: controller.nameController,
//           labelText: 'Name',
//           prefixIcon: Icons.person_outline_rounded,
//         ),
//         const SizedBox(height: 16),
//
//         Obx(() => DropdownButtonFormField<String>(
//           value: controller.gender.value == 'N/A' ? null : controller.gender.value,
//           decoration: InputDecoration(
//             labelText: 'Gender',
//             labelStyle: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 14,
//             ),
//             prefixIcon: const Icon(Icons.wc_outlined, size: 22),
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide(
//                 color: Colors.grey.withOpacity(0.2),
//                 width: 1.5,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(
//                 color: AppColors.primaryBlue,
//                 width: 2,
//               ),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//           ),
//           dropdownColor: Colors.white,
//           items: ['male', 'female'].map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value.capitalizeFirst!),
//             );
//           }).toList(),
//           onChanged: (newValue) {
//             if (newValue != null) {
//               controller.gender.value = newValue;
//             }
//           },
//         )),
//         const SizedBox(height: 16),
//
//         GestureDetector(
//           onTap: () => _selectDate(context, controller),
//           child: AbsorbPointer(
//             child: CustomTextFormField(
//               controller: controller.dobController,
//               labelText: 'Date of Birth',
//               prefixIcon: Icons.calendar_today_outlined,
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.phoneController,
//           labelText: 'Phone',
//           prefixIcon: Icons.phone_outlined,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.addressController,
//           labelText: 'Address',
//           prefixIcon: Icons.location_on_outlined,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.cnicController,
//           labelText: 'CNIC',
//           prefixIcon: Icons.credit_card_outlined,
//         ),
//
//         const SizedBox(height: 24),
//
//         // Read-only Fields Section
//         _buildSectionTitle('Employment Information'),
//         const SizedBox(height: 12),
//
//         CustomTextFormField(
//           controller: controller.emailController,
//           labelText: 'Email',
//           prefixIcon: Icons.email_outlined,
//           readOnly: true,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.sapCodeController,
//           labelText: 'SAP Code',
//           prefixIcon: Icons.qr_code_2_outlined,
//           readOnly: true,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.departmentController,
//           labelText: 'Department',
//           prefixIcon: Icons.business_outlined,
//           readOnly: true,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.designationController,
//           labelText: 'Designation',
//           prefixIcon: Icons.work_outline_rounded,
//           readOnly: true,
//         ),
//
//         const SizedBox(height: 24),
//
//         _buildSectionTitle('Location Details'),
//         const SizedBox(height: 12),
//
//         CustomTextFormField(
//           controller: controller.regionController,
//           labelText: 'Region',
//           prefixIcon: Icons.map_outlined,
//           readOnly: true,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.circleController,
//           labelText: 'Circle',
//           prefixIcon: Icons.adjust_outlined,
//           readOnly: true,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.divisionController,
//           labelText: 'Division',
//           prefixIcon: Icons.account_tree_outlined,
//           readOnly: true,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.subDivisionController,
//           labelText: 'Sub-Division',
//           prefixIcon: Icons.layers_outlined,
//           readOnly: true,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.feederController,
//           labelText: 'Feeder',
//           prefixIcon: Icons.electric_bolt_outlined,
//           readOnly: true,
//         ),
//
//         const SizedBox(height: 24),
//
//         _buildSectionTitle('Additional Information'),
//         const SizedBox(height: 12),
//
//         CustomTextFormField(
//           controller: controller.isActiveController,
//           labelText: 'Status',
//           prefixIcon: Icons.check_circle_outline_rounded,
//           readOnly: true,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.dateOfJoiningController,
//           labelText: 'Date of Joining',
//           prefixIcon: Icons.event_available_outlined,
//           readOnly: true,
//         ),
//
//         const SizedBox(height: 32),
//
//         GradientButton(
//           text: 'Update Profile',
//           onPressed: controller.updateProfile,
//         ),
//
//         const SizedBox(height: 20),
//       ],
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     const primaryColor = Color(0xFF0D47A1);
//
//     return Padding(
//       padding: const EdgeInsets.only(left: 4),
//       child: Row(
//         children: [
//           Container(
//             width: 4,
//             height: 20,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [primaryColor, Color(0xFF002171)],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//               letterSpacing: 0.3,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _selectDate(BuildContext context, ProfileController controller) async {
//     DateTime initialDate;
//     try {
//       initialDate = DateTime.parse(controller.dobController.text);
//     } catch (e) {
//       initialDate = DateTime.now();
//     }
//
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(1920),
//       lastDate: DateTime.now(),
//       builder: (BuildContext context, Widget? child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF0D47A1),
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black,
//             ),
//             dialogBackgroundColor: Colors.white,
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xFF0D47A1),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       String formattedDate =
//           '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
//       controller.dobController.text = formattedDate;
//     }
//   }
//
//   Widget _buildPasswordForm(ProfileController controller) {
//     return Column(
//       children: [
//         const SizedBox(height: 8),
//
//         Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF0D47A1).withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//                 spreadRadius: -5,
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Icon(
//                 Icons.lock_outline_rounded,
//                 size: 60,
//                 color: const Color(0xFF0D47A1).withOpacity(0.7),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Change Password',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Enter your current and new password',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//
//         const SizedBox(height: 24),
//
//         CustomTextFormField(
//           controller: controller.currentPasswordController,
//           labelText: 'Current Password',
//           prefixIcon: Icons.lock_outline_rounded,
//           obscureText: true,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.newPasswordController,
//           labelText: 'New Password',
//           prefixIcon: Icons.lock_open_outlined,
//           obscureText: true,
//         ),
//         const SizedBox(height: 16),
//
//         CustomTextFormField(
//           controller: controller.confirmPasswordController,
//           labelText: 'Confirm New Password',
//           prefixIcon: Icons.lock_reset_outlined,
//           obscureText: true,
//         ),
//
//         const SizedBox(height: 32),
//
//         GradientButton(
//           text: 'Update Password',
//           onPressed: controller.updatePassword,
//         ),
//
//         const SizedBox(height: 20),
//       ],
//     );
//   }
//
//   Widget _buildProfileImage(ProfileController controller) {
//     const primaryColor = Color(0xFF0D47A1);
//     const primaryLight = Color(0xFF002171);
//
//     return Stack(
//       children: [
//         // Outer glow ring
//         Container(
//           width: 110,
//           height: 110,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               colors: [
//                 primaryColor.withOpacity(0.2),
//                 primaryLight.withOpacity(0.15),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         // White ring
//         Positioned(
//           top: 3,
//           left: 3,
//           child: Container(
//             width: 104,
//             height: 104,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColor.withOpacity(0.2),
//                   blurRadius: 15,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         // Profile image
//         Positioned(
//           top: 5,
//           left: 5,
//           child: Obx(() {
//             final imagePath = controller.imagePath.value;
//             return ClipRRect(
//               borderRadius: BorderRadius.circular(50),
//               child: SizedBox(
//                 width: 100,
//                 height: 100,
//                 child: imagePath.isEmpty
//                     ? Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         primaryColor.withOpacity(0.7),
//                         primaryLight.withOpacity(0.5),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: const Icon(
//                     Icons.person_rounded,
//                     size: 50,
//                     color: Colors.white,
//                   ),
//                 )
//                     : imagePath.startsWith('http')
//                     ? CachedNetworkImage(
//                   imageUrl: imagePath,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => const ShimmerWidget.circular(
//                     width: 100,
//                     height: 100,
//                   ),
//                   errorWidget: (context, url, error) => Container(
//                     color: Colors.grey[200],
//                     child: const Icon(Icons.person, size: 40),
//                   ),
//                 )
//                     : imagePath.startsWith('assets')
//                     ? Image.asset(imagePath, fit: BoxFit.cover)
//                     : Image.file(File(imagePath), fit: BoxFit.cover),
//               ),
//             );
//           }),
//         ),
//         // Edit button
//         Positioned(
//           bottom: 2,
//           right: 2,
//           child: GestureDetector(
//             onTap: controller.pickImage,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: const LinearGradient(
//                   colors: [primaryColor, primaryLight],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: primaryColor.withOpacity(0.4),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.camera_alt_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }