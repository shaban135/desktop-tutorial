import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/controllers/ptw_list_controller.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/widgets/custom_bottom_app_bar.dart';

class MainLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool showBottomAppBar;

  const MainLayout({
    super.key,
    required this.title,
    required this.child,
    this.showBackButton = true,
    this.actions,
    this.showBottomAppBar = false,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/loginbackground.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.showBackButton)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      print('🔙 Back button pressed'); // Debug line

                      final ctrl = Get.isRegistered<PtwListController>()
                          ? Get.find<PtwListController>()
                          : null;

                      // ❗ Clear filters instead of blocking back
                      if (ctrl != null &&
                          (ctrl.searchQuery.value.isNotEmpty ||
                              ctrl.selectedStatus.value.isNotEmpty ||
                              ctrl.fromDate.value.isNotEmpty ||
                              ctrl.toDate.value.isNotEmpty)) {
                        print('🔍 Clearing filters');
                        ctrl.clearFilters();
                        ctrl.fetchPtwList();
                        return;
                      }

                      // ✅ FIX: Use Navigator.pop instead of Get.back
                      if (Navigator.of(context).canPop()) {
                        print('✅ Popping with Navigator');
                        Navigator.of(context).pop();
                      } else {
                        print('🏠 Going to home');
                        Get.offAllNamed(AppRoutes.home);
                      }
                    },
                  )
                else
                  const SizedBox(width: 48), // Placeholder for balance

                Expanded(
                  child: Text(
                    // _animatedTitle,
                    widget.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: Colors.white, fontSize: 29),
                    overflow: TextOverflow.clip, // Use clip to avoid ellipsis,
                    softWrap: true,
                  ),
                ),

                if (widget.actions != null && widget.actions!.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: widget.actions!)
                else
                  const SizedBox(width: 48), // Placeholder for balance
              ],
            ),
          ),

          // Main Content Area
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.18),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 4.5),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0),
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomAppBar
          ? CustomBottomAppBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      )
          : null,
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mepco_esafety_app/controllers/ptw_list_controller.dart';
// import 'package:mepco_esafety_app/routes/app_routes.dart';
// import 'package:mepco_esafety_app/widgets/custom_bottom_app_bar.dart';
//
// class MainLayout extends StatefulWidget {
//   final String title;
//   final Widget child;
//   final bool showBackButton;
//   final List<Widget>? actions;
//   final bool showBottomAppBar;
//
//   const MainLayout({
//     super.key,
//     required this.title,
//     required this.child,
//     this.showBackButton = true,
//     this.actions,
//     this.showBottomAppBar = false,
//   });
//
//   @override
//   State<MainLayout> createState() => _MainLayoutState();
// }
//
// class _MainLayoutState extends State<MainLayout> {
//   int _selectedIndex = 0;
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/loginbackground.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Positioned(
//             top: 80,
//             left: 16,
//             right: 16,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 if (widget.showBackButton)
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//                     onPressed: () {
//                       final ctrl = Get.isRegistered<PtwListController>()
//                           ? Get.find<PtwListController>()
//                           : null;
//
//                       // ❗ Clear filters instead of blocking back
//                       if (ctrl != null &&
//                           (ctrl.searchQuery.value.isNotEmpty ||
//                               ctrl.selectedStatus.value.isNotEmpty ||
//                               ctrl.fromDate.value.isNotEmpty ||
//                               ctrl.toDate.value.isNotEmpty)) {
//                         ctrl.clearFilters();
//                         ctrl.fetchPtwList();
//                         return;
//                       }
//
//                       // ✔ BACK ALWAYS WORKS — even during loading
//                       if (Get.key.currentState?.canPop() ?? false) {
//                         Get.back();
//                       } else {
//                         Get.offAllNamed(AppRoutes.home);
//                       }
//                     },
//                   )
//                 else
//                   const SizedBox(width: 48), // Placeholder for balance
//
//                 Expanded(
//                   child: Text(
//                     // _animatedTitle,
//                     widget.title,
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context)
//                         .textTheme
//                         .displayLarge
//                         ?.copyWith(color: Colors.white, fontSize: 25),
//                     overflow: TextOverflow.clip, // Use clip to avoid ellipsis,
//                     softWrap: true,
//                   ),
//                 ),
//
//                 if (widget.actions != null && widget.actions!.isNotEmpty)
//                   Row(mainAxisSize: MainAxisSize.min, children: widget.actions!)
//                 else
//                   const SizedBox(width: 48), // Placeholder for balance
//               ],
//             ),
//           ),
//
//           // Main Content Area
//           Column(
//             children: [
//               SizedBox(height: MediaQuery.of(context).size.height * 0.18),
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.only(top: 4.5),
//                   width: double.infinity,
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(32.0),
//                       topRight: Radius.circular(32.0),
//                     ),
//                   ),
//                   child: widget.child,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       bottomNavigationBar: widget.showBottomAppBar
//           ? CustomBottomAppBar(
//               selectedIndex: _selectedIndex,
//               onItemTapped: _onItemTapped,
//             )
//           : null,
//     );
//   }
// }
// -------------without bottomappBar------------
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mepco_esafety_app/controllers/ptw_list_controller.dart';
// import 'package:mepco_esafety_app/routes/app_routes.dart';
//
// class MainLayout extends StatefulWidget {
//   final String title;
//   final Widget child;
//   final bool showBackButton;
//   final List<Widget>? actions;
//
//   const MainLayout({
//     super.key,
//     required this.title,
//     required this.child,
//     this.showBackButton = true,
//     this.actions,
//   });
//
//   @override
//   State<MainLayout> createState() => _MainLayoutState();
// }
//
// class _MainLayoutState extends State<MainLayout> {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/images/loginbackground.jpg'),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         Positioned(
//           top: 80,
//           left: 16,
//           right: 16,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               if (widget.showBackButton)
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//                   onPressed: () {
//                     final ctrl = Get.isRegistered<PtwListController>()
//                         ? Get.find<PtwListController>()
//                         : null;
//
//                     // ❗ Clear filters instead of blocking back
//                     if (ctrl != null &&
//                         (ctrl.searchQuery.value.isNotEmpty ||
//                             ctrl.selectedStatus.value.isNotEmpty ||
//                             ctrl.fromDate.value.isNotEmpty ||
//                             ctrl.toDate.value.isNotEmpty))
//                     {
//                       ctrl.clearFilters();
//                       ctrl.fetchPtwList();
//                       return;
//                     }
//
//                     // ✔ BACK ALWAYS WORKS — even during loading
//                     if (Get.key.currentState?.canPop() ?? false) {
//                       Get.back();
//                     } else {
//                       Get.offAllNamed(AppRoutes.home);
//                     }
//                   },
//
//                 )
//               else
//                 const SizedBox(width: 48), // Placeholder for balance
//
//               Expanded(
//                 child: Text(
//                   // _animatedTitle,
//                   widget.title,
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context)
//                       .textTheme
//                       .displayLarge
//                       ?.copyWith(color: Colors.white, fontSize: 25),
//                   overflow: TextOverflow.clip, // Use clip to avoid ellipsis,
//                   softWrap: true,
//                 ),
//               ),
//
//               if (widget.actions != null && widget.actions!.isNotEmpty)
//                 Row(mainAxisSize: MainAxisSize.min, children: widget.actions!)
//               else
//                 const SizedBox(width: 48), // Placeholder for balance
//             ],
//           ),
//         ),
//
//         // Main Content Area
//         Column(
//           children: [
//             SizedBox(height: MediaQuery.of(context).size.height * 0.18),
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.only(top: 4.5),
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(32.0),
//                     topRight: Radius.circular(32.0),
//                   ),
//                 ),
//                 child: widget.child,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

