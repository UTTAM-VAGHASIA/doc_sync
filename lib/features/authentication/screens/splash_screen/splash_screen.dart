import 'package:doc_sync/features/authentication/controllers/splash_controller.dart';
import 'package:doc_sync/features/authentication/screens/splash_screen/widgets/logo_widget.dart';
import 'package:doc_sync/features/authentication/screens/splash_screen/widgets/water_droplet.dart';
import 'package:doc_sync/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'widgets/animated_text_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashController = Get.find<SplashController>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    // Start the animation and initialization process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      splashController.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Obx(
          () => Stack(
            children: [
              // Background
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: splashController.backgroundColor.value,
                curve: Curves.easeInOut,
              ),

              // Ripple effect
              Visibility(
                visible: splashController.showRipple.value,
                child: Center(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: Container(
                      width: splashController.rippleSize.value,
                      height: splashController.rippleSize.value,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A5781),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),

              // Water Droplet
              Visibility(
                visible: splashController.showDroplet.value,
                child: Positioned(
                  top: splashController.dropletPosition.value,
                  left: MediaQuery.of(context).size.width / 2 - 40,
                  child: Transform.scale(
                    scale: 1.0,
                    child: WaterDroplet(
                      size: 80,
                      color: const Color(0xFF2A5781),
                    ),
                  ),
                ),
              ),

              // Logo
              Visibility(
                visible: splashController.showLogo.value,
                child: Align(
                  alignment: const Alignment(0, -0.15),
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: splashController.logoOffset.value,
                    ),
                    width: splashController.logoSize.value,
                    height: splashController.logoSize.value,
                    child: const LogoWidget(imgPath: AppImages.darkAppLogo),
                  ),
                ),
              ),

              // App Name
              Visibility(
                visible: splashController.showText.value,
                child: const Align(
                  alignment: Alignment(0, 0.2),
                  child: Padding(
                    padding: EdgeInsets.only(top: 110),
                    child: AnimatedTextLoader(),
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
