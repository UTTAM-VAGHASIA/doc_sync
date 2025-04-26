import 'dart:convert';
import 'dart:math' as math;
import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:doc_sync/features/authentication/controllers/user_controller.dart';
import 'package:doc_sync/features/authentication/models/user_model.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/api_constants.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/local_storage/storage_utility.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:doc_sync/utils/popups/organization_dialog.dart';
import 'package:doc_sync/utils/versioning/check_update.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  final userController = UserController.instance;
  late DashboardController dashboardController;
  String finalDestination = AppRoutes.login;

  // Observable properties for UI
  final backgroundColor = Colors.white.obs;
  final rippleSize = 0.0.obs;
  final dropletPosition = 0.0.obs;
  final showDroplet = true.obs;
  final showRipple = false.obs;
  final showLogo = false.obs;
  final showText = false.obs;
  final logoSize = 0.0.obs;
  final logoOffset = 0.0.obs;

  // Animation controllers
  late AnimationController dropletAnimController;
  late Animation<double> dropletAnimation;

  late AnimationController rippleAnimController;
  late Animation<double> rippleAnimation;

  late AnimationController logoAnimController;
  late Animation<double> logoSizeAnimation;
  late Animation<double> logoOffsetAnimation;

  late AnimationController letterAnimController;
  late Animation<double> letterAnimation;

  late AnimationController colorAnimController;
  late Animation<Color?> colorAnimation;

  // Animation properties
  final dropFallDuration = const Duration(milliseconds: 900);
  final rippleDuration = const Duration(milliseconds: 1200);
  final logoDuration = const Duration(milliseconds: 900);
  final letterVisibilityAnimationDuration = const Duration(milliseconds: 500);
  final backgroundColorChangeDuration = const Duration(milliseconds: 600);

  // Flags for controlling animation flow
  bool _animationsStarted = false;
  bool _initializationComplete = false;

  @override
  void onInit() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize the dashboard controller
    dashboardController = Get.put(DashboardController());

    super.onInit();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Droplet animation
    dropletAnimController = AnimationController(
      duration: dropFallDuration,
      vsync: this,
    );

    dropletAnimation = CurvedAnimation(
      parent: dropletAnimController,
      curve: Curves.fastEaseInToSlowEaseOut,
    );

    // Ripple animation
    rippleAnimController = AnimationController(
      duration: rippleDuration,
      vsync: this,
    );

    rippleAnimation = CurvedAnimation(
      parent: rippleAnimController,
      curve: Curves.easeOutQuart,
    );

    // Logo animations
    logoAnimController = AnimationController(
      duration: logoDuration,
      vsync: this,
    );

    logoSizeAnimation = Tween<double>(begin: 0.0, end: 240.0).animate(
      CurvedAnimation(
        parent: logoAnimController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    logoOffsetAnimation = Tween<double>(begin: 0.0, end: 60.0).animate(
      CurvedAnimation(
        parent: logoAnimController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Text animation
    letterAnimController = AnimationController(
      duration: letterVisibilityAnimationDuration,
      vsync: this,
    );

    letterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: letterAnimController, curve: Curves.easeOut),
    );

    // Color animation
    colorAnimController = AnimationController(
      duration: backgroundColorChangeDuration,
      vsync: this,
    );

    colorAnimation = ColorTween(
      begin: Colors.white,
      end: const Color(0xFF2A5781),
    ).animate(
      CurvedAnimation(parent: colorAnimController, curve: Curves.easeIn),
    );

    // Add listeners to animations
    dropletAnimation.addListener(_updateDropletPosition);
    rippleAnimation.addListener(_updateRippleSize);
    logoSizeAnimation.addListener(_updateLogoSize);
    logoOffsetAnimation.addListener(_updateLogoOffset);
    colorAnimation.addListener(_updateBackgroundColor);
  }

  // Animation update listeners
  void _updateDropletPosition() {
    // Map animation value (0-1) to screen position
    final screenHeight = Get.height;
    final startPos = -50.0;
    final endPos = (screenHeight / 2) - 40;
    dropletPosition.value =
        startPos + (endPos - startPos) * dropletAnimation.value;
  }

  void _updateRippleSize() {
    final screenDiagonal = math.sqrt(
      math.pow(Get.width, 2) + math.pow(Get.height, 2),
    );
    rippleSize.value = screenDiagonal * 1.2 * rippleAnimation.value;
  }

  void _updateLogoSize() {
    logoSize.value = logoSizeAnimation.value;
  }

  void _updateLogoOffset() {
    logoOffset.value = logoOffsetAnimation.value;
  }

  void _updateBackgroundColor() {
    backgroundColor.value = colorAnimation.value ?? Colors.white;
  }

  // Public methods

  /// Starts the splash screen animation sequence
  Future<void> startAnimation() async {
    if (_animationsStarted) return;
    _animationsStarted = true;

    // Reset animation state
    resetAnimations(showInitialDroplet: true);

    // // Sequence the animations
    await Future.delayed(const Duration(milliseconds: 300));

    // 1. Droplet falls
    dropletAnimController.forward();

    dropletAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 2. Ripple effect begins
        showDroplet.value = false;
        showRipple.value = true;
        rippleAnimController.forward();
      }
    });

    rippleAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 3. Background color changes
        colorAnimController.forward();

        // 4. Logo appears and moves
        showLogo.value = true;
        logoAnimController.forward();
        initializeApp();
      }
    });

    logoAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 5. Text appears
        showText.value = true;
        letterAnimController.repeat(reverse: true);
      }
    });
  }

  /// Perform any background initialization tasks here
  Future<void> initializeApp() async {
    if (_initializationComplete) return;

    if (!(await NetworkManager.instance.isConnected())) {
      RetryQueueManager.instance.addJob(initializeApp);
      AppLoaders.customToast(message: "Offline. Will retry when back online.");
      return;
    }

    // Check for new version for Android App
    if (GetPlatform.isAndroid && kReleaseMode) {
      await CheckUpdate.checkForUpdate();
    }

    if(await StorageUtility.instance().readData('organization') == null) {
      await OrganizationDialogService.showOrganizationDialog(isForced: true);
    } else {
      ApiConstants().changeOrganization(await StorageUtility.instance().readData('organization') ?? "");
    }


    await logInExistingUser();

    _initializationComplete = true;
  }

  Future<void> logInExistingUser() async {
    final user = await userController.getLoginCredentials();

    if (user.email != null && user.password != null) {
      final requestData = {
        'data': jsonEncode({"user_id": user.email, "password": user.password}),
      };

      final data = await AppHttpHelper().sendMultipartRequest(
        "login",
        method: "POST",
        fields: requestData,
      );

      if (data['success']) {
        User user = User.fromJson(data['data'][0]);
        userController.saveUserDetails(user);

        finalDestination = AppRoutes.dashboard;
        // The dashboard data will be fetched when the dashboard screen is loaded
      }
    } else {
      print("Login Not Successful, Navigating to Login Screen.");
    }
  }

  /// Complete the splash sequence and navigate forward
  Future<void> finishSplashAndNavigate() async {
    // Wait for both animation and initialization to complete
    while (!_initializationComplete || !_animationComplete()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await Future.delayed(Duration(milliseconds: 500));

    // Stop the letter animation for clean transition
    letterAnimController.reset();

    await Future.delayed(Duration(milliseconds: 300));

    // Navigate to the appropriate screen
    print("Navigating to $finalDestination");
    Get.offAllNamed(finalDestination);
  }

  /// Check if main animations have completed
  bool _animationComplete() {
    return rippleAnimController.isCompleted &&
        logoAnimController.isCompleted &&
        colorAnimController.isCompleted;
  }

  /// Reset all animations to initial state
  void resetAnimations({bool showInitialDroplet = true}) {
    // Reset controllers
    dropletAnimController.reset();
    rippleAnimController.reset();
    logoAnimController.reset();
    letterAnimController.reset();
    colorAnimController.reset();

    // Reset observables
    backgroundColor.value = Colors.white;
    rippleSize.value = 0.0;
    dropletPosition.value = -50.0;
    showDroplet.value = showInitialDroplet;
    showRipple.value = false;
    showLogo.value = false;
    showText.value = false;
    logoSize.value = 0.0;
    logoOffset.value = 0.0;

    // Reset flags
    _animationsStarted = false;
    _initializationComplete = false;
  }

  @override
  void onClose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    dropletAnimController.dispose();
    rippleAnimController.dispose();
    logoAnimController.dispose();
    letterAnimController.dispose();
    colorAnimController.dispose();
    super.onClose();
  }

  /// Combined method to start everything at once
  Future<void> start() async {
    // // Run animation and initialization in parallel
    // final animationFuture = startAnimation();
    // final initFuture = initializeApp();

    // // Wait for both to complete
    // await Future.wait([animationFuture, initFuture]);

    startAnimation();
    // Navigate when everything is ready
    await finishSplashAndNavigate();
  }
}
