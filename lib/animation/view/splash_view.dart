import 'package:custom_dropdown_widget/animation/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => AnimatedPositioned(
              top: controller.animate.value ? 0 : -30,
              left: controller.animate.value ? 0 : -30,
              duration: const Duration(milliseconds: 1600),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1600),
                opacity: controller.animate.value ? 1 : 0,
                child: Image.asset("assets/quotes_background1.png"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
