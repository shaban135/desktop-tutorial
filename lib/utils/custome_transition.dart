import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BottomCustomTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    // Slide from bottom
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.20),  // slight bottom offset
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic, // smooth & modern
    ));

    // Gentle scale-in
    final scale = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    ));

    // Fade-in
    final fade = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(
          scale: scale,
          child: child,
        ),
      ),
    );
  }
}


