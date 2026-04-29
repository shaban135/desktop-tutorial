// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mepco_esafety_app/controllers/profile_controller.dart';
// import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';
//
// class ProfileHeader extends StatelessWidget {
//   const ProfileHeader({
//     super.key,
//     required this.controller,
//   });
//
//   final ProfileController controller;
//
//   @override
//   Widget build(BuildContext context) {
//     const primaryColor = Color(0xFF0D47A1);
//     const primaryLight = Color(0xFF002171);
//     const accentColor = Color(0xFFD32F2F);
//
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             primaryColor.withOpacity(0.03),
//             primaryLight.withOpacity(0.02),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Column(
//         children: [
//           // Enhanced Profile Image with Multiple Layers
//           Obx(() {
//             final imagePath = controller.imagePath.value;
//
//             return Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Outer glow ring
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         primaryColor.withOpacity(0.2),
//                         primaryLight.withOpacity(0.15),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                 ),
//                 // Middle ring
//                 Container(
//                   width: 112,
//                   height: 112,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: primaryColor.withOpacity(0.2),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Inner profile image
//                 Container(
//                   width: 104,
//                   height: 104,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         primaryColor.withOpacity(0.8),
//                         primaryLight.withOpacity(0.6),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: ClipOval(
//                     child: imagePath.isEmpty
//                         ? Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             primaryColor.withOpacity(0.7),
//                             primaryLight.withOpacity(0.5),
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.person_rounded,
//                         size: 55,
//                         color: Colors.white,
//                       ),
//                     )
//                         : imagePath.startsWith('http')
//                         ? CachedNetworkImage(
//                       imageUrl: imagePath,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => const ShimmerWidget.circular(
//                         width: 104,
//                         height: 104,
//                       ),
//                       errorWidget: (context, url, error) => Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.grey.shade300,
//                               Colors.grey.shade200,
//                             ],
//                           ),
//                         ),
//                         child: const Icon(
//                           Icons.person_rounded,
//                           size: 55,
//                           color: Colors.white,
//                         ),
//                       ),
//                     )
//                         : imagePath.startsWith('assets')
//                         ? Image.asset(imagePath, fit: BoxFit.cover)
//                         : Image.file(File(imagePath), fit: BoxFit.cover),
//                   ),
//                 ),
//                 // Online status indicator (optional - can be controlled via controller)
//                 Positioned(
//                   bottom: 4,
//                   right: 4,
//                   child: Container(
//                     width: 18,
//                     height: 18,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF4CAF50),
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.white,
//                         width: 3,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF4CAF50).withOpacity(0.5),
//                           blurRadius: 8,
//                           spreadRadius: 1,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }),
//
//           const SizedBox(height: 18),
//
//           // Name with enhanced styling
//           Obx(() => Text(
//             controller.name.value,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//               letterSpacing: 0.3,
//               height: 1.2,
//             ),
//           )),
//
//           const SizedBox(height: 6),
//
//           // Title/Designation with badge style
//           Obx(() => Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   primaryColor.withOpacity(0.1),
//                   primaryLight.withOpacity(0.08),
//                 ],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: primaryColor.withOpacity(0.15),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.work_outline_rounded,
//                   size: 16,
//                   color: primaryColor.withOpacity(0.8),
//                 ),
//                 const SizedBox(width: 6),
//                 Flexible(
//                   child: Text(
//                     controller.title.value,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: primaryColor.withOpacity(0.85),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.2,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           )),
//
//           const SizedBox(height: 16),
//
//           // Stats or Quick Info Row (Optional - can be customized)
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildStatItem(Icons.calendar_today_rounded, 'Active', primaryColor),
//               Container(
//                 width: 1,
//                 height: 30,
//                 margin: const EdgeInsets.symmetric(horizontal: 20),
//                 color: Colors.grey.withOpacity(0.2),
//               ),
//               _buildStatItem(Icons.verified_user_rounded, 'Verified', primaryColor),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatItem(IconData icon, String label, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             size: 16,
//             color: color,
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: color.withOpacity(0.8),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/profile_controller.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.controller,
  });

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D47A1);
    const primaryLight = Color(0xFF002171);
    const accentColor = Color(0xFFD32F2F);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Enhanced Profile Image with Multiple Layers
          Obx(() {
            final imagePath = controller.imagePath.value;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.5),
                        primaryLight.withOpacity(0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Middle ring
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
                // Inner profile image
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.8),
                        primaryLight.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipOval(
                    child: imagePath.isEmpty
                        ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.7),
                            primaryLight.withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 55,
                        color: Colors.white,
                      ),
                    )
                        : imagePath.startsWith('http')
                        ? CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerWidget.circular(
                        width: 104,
                        height: 104,
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade200,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 55,
                          color: Colors.white,
                        ),
                      ),
                    )
                        : imagePath.startsWith('assets')
                        ? Image.asset(imagePath, fit: BoxFit.cover)
                        : Image.file(File(imagePath), fit: BoxFit.cover),
                  ),
                ),
                // Online status indicator (optional - can be controlled via controller)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 18),

          // Name with enhanced styling
          Obx(() => Text(
            controller.name.value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
              letterSpacing: 0.3,
              height: 1.2,
            ),
          )),

          const SizedBox(height: 6),

          // Title/Designation with badge style
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryLight.withOpacity(0.08),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: 16,
                  color: primaryColor.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    controller.title.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryColor.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: 16),

          // Stats or Quick Info Row (Optional - can be customized)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(Icons.calendar_today_rounded, 'Active', primaryColor),
              Container(
                width: 1,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.grey.withOpacity(0.2),
              ),
              _buildStatItem(Icons.verified_user_rounded, 'Verified', primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}