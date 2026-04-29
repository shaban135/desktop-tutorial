import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(

      child: SizedBox(
          height: 80,
          width: 80,
          child: Lottie.asset('assets/animations/loader.json')),
    );
  }
}
