import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/services/biometric_service.dart';
import 'package:mepco_esafety_app/services/version_check_service.dart';
import 'package:mepco_esafety_app/widgets/update_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeSplashScreen extends StatefulWidget {
  const WelcomeSplashScreen({super.key});

  @override
  State<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends State<WelcomeSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  String _currentVersion = '';
  String _currentBuildNumber = '';
  double _loadingProgress = 0.0;
  String _loadingText = 'Initializing Security Protocols...';

  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _logoRotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();
    _logoController.forward();

    // Simulate loading progress
    _simulateLoading();

    // Start initialization after animations
    Timer(const Duration(milliseconds: 3500), () {
      _initializeApp();
    });
  }

  void _simulateLoading() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _loadingProgress += 0.022;
        if (_loadingProgress >= 1.0) {
          _loadingProgress = 1.0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _initializeApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
      _currentBuildNumber = packageInfo.buildNumber;
    });
    try {
      // Step 1: Check for updates
      setState(() {
        _loadingText = 'Checking for updates...';
      });

      await _checkForUpdates();

      // Step 2: Check login status
      setState(() {
        _loadingText = 'Loading...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      _checkLoginStatus();
    } catch (e) {
      print('Initialization error: $e');
      _checkLoginStatus(); // Continue anyway
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      print('🔍 Checking for app updates...');

      final versionCheck = await VersionCheckService.checkVersion();

      if (versionCheck == null) {
        print('⚠️ Version check failed, continuing anyway');
        return;
      }

      print('✅ Version check complete');
      print('Needs update: ${versionCheck.needsUpdate}');
      print('Force update: ${versionCheck.forceUpdate}');
      print('Can continue: ${versionCheck.canContinue}');

      if (versionCheck.needsUpdate) {
        // Show update dialog
        await Get.dialog(
          UpdateDialog(versionCheck: versionCheck),
          barrierDismissible: !versionCheck.forceUpdate,
        );

        // If force update and user somehow dismissed, check again
        if (versionCheck.forceUpdate && !versionCheck.canContinue) {
          print('⚠️ Force update required, checking again...');
          return _checkForUpdates();
        }
      }
    } catch (e) {
      print('❌ Update check error: $e');
      // Continue anyway on error - don't block app usage
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.authToken);
    final isBiometricEnabled = prefs.getBool(StorageKeys.isBiometricEnabled) ?? false;

    if (token != null && token.isNotEmpty) {
      if (isBiometricEnabled) {
        setState(() {
          _loadingText = 'Authenticating...';
        });
        
        bool authenticated = await _biometricService.authenticate();
        
        if (authenticated) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          // If biometric fails or is cancelled, go to login screen
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        // Biometric is not enabled, redirect to login screen as requested
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated Background with Parallax Effect
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: 1.15),
            duration: const Duration(seconds: 12),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Image.asset(
                  'assets/images/welcomebg1.jpg',
                  fit: BoxFit.cover,
                ),
              );
            },
          ),

          // Animated Gradient Overlay
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4 * _fadeAnimation.value),
                      Colors.black.withOpacity(0.6 * _fadeAnimation.value),
                      Colors.black.withOpacity(0.85 * _fadeAnimation.value),
                    ],
                  ),
                ),
              );
            },
          ),

          // Particle Effect Overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_shimmerAnimation.value),
                );
              },
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Animated Logo with 4-Part Join Effect
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _fadeAnimation,
                    _scaleAnimation,
                    _logoRotateAnimation,
                    _pulseAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 60,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: Stack(
                              children: [
                                // Top-Left Part
                                _buildLogoPart(
                                  alignment: Alignment.topLeft,
                                  xOffset: -80 * (1 - _scaleAnimation.value),
                                  yOffset: -80 * (1 - _scaleAnimation.value),
                                  rotation: -0.3 * (1 - _logoRotateAnimation.value),
                                ),
                                // Top-Right Part
                                _buildLogoPart(
                                  alignment: Alignment.topRight,
                                  xOffset: 80 * (1 - _scaleAnimation.value),
                                  yOffset: -80 * (1 - _scaleAnimation.value),
                                  rotation: 0.3 * (1 - _logoRotateAnimation.value),
                                ),
                                // Bottom-Left Part
                                _buildLogoPart(
                                  alignment: Alignment.bottomLeft,
                                  xOffset: -80 * (1 - _scaleAnimation.value),
                                  yOffset: 80 * (1 - _scaleAnimation.value),
                                  rotation: 0.3 * (1 - _logoRotateAnimation.value),
                                ),
                                // Bottom-Right Part
                                _buildLogoPart(
                                  alignment: Alignment.bottomRight,
                                  xOffset: 80 * (1 - _scaleAnimation.value),
                                  yOffset: 80 * (1 - _scaleAnimation.value),
                                  rotation: -0.3 * (1 - _logoRotateAnimation.value),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 1),

                // Animated Text Section
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            children: [
                              // Main Title with Shimmer Effect
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: const [
                                      Colors.white,
                                      Color(0xFFE0E0E0),
                                      Colors.white,
                                    ],
                                    stops: [
                                      _shimmerAnimation.value - 0.3,
                                      _shimmerAnimation.value,
                                      _shimmerAnimation.value + 0.3,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: DefaultTextStyle(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        offset: Offset(0, 2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        'MEPCO E-Safety',
                                        speed: const Duration(milliseconds: 130),
                                      ),
                                    ],
                                    isRepeatingAnimation: false,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Urdu Title with Fade
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.easeIn,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: const Text(
                                      'میپکو ای-سیفٹی',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Fixture',
                                        shadows: [
                                          Shadow(
                                            color: Colors.black45,
                                            offset: Offset(0, 2),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 28),

                              // Subtitle Section
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Digital PTW & Safety Compliance'
                                          .toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.95),
                                        letterSpacing: 2.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'ڈیجیٹل پی ٹی ڈبلیو اور سیفٹی کمپلائنس',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Feature Indicators (Secure, Fast, Smart)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureBadge('Secure', Icons.security_rounded),
                      const SizedBox(width: 8),
                      _buildFeatureBadge('Fast', Icons.flash_on_rounded),
                      const SizedBox(width: 8),
                      _buildFeatureBadge('Smart', Icons.psychology_rounded),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Loader Animation with Progress Bar
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Lottie Animation
                      SizedBox(
                        height: 70,
                        child: Lottie.asset(
                          'assets/animations/loader4.json',
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Progress Bar
                      Container(
                        width: 200,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 200 * _loadingProgress,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFF60A5FA),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    const Color(0xFF3B82F6).withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Loading Status Text
                      Text(
                        _loadingText,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Footer Text with Pulse
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF3B82F6).withOpacity(
                                        0.3 * (_pulseAnimation.value - 1.0) * 6),
                                    const Color(0xFF60A5FA).withOpacity(
                                        0.3 * (_pulseAnimation.value - 1.0) * 6),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/icon/mepco_icon.png',
                                height: 30,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Powered by MEPCO',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF3B82F6).withOpacity(
                                        0.3 * (_pulseAnimation.value - 1.0) * 6),
                                    const Color(0xFF60A5FA).withOpacity(
                                        0.3 * (_pulseAnimation.value - 1.0) * 6),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/icon/hrpsp_icon2.png',
                                height: 30,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Design and Developed by HRPSP',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Version $_currentVersion+$_currentBuildNumber',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 9,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String label, IconData icon) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6)
                    .withOpacity(0.1 * (_pulseAnimation.value - 1.0) * 6),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoPart({
    required Alignment alignment,
    required double xOffset,
    required double yOffset,
    required double rotation,
  }) {
    return Transform.translate(
      offset: Offset(xOffset, yOffset),
      child: Transform.rotate(
        angle: rotation,
        child: ClipRect(
          clipper: LogoPartClipper(alignment),
          child: Image.asset(
            'assets/icon/icon.png',
            width: 160,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// Custom Clipper for Logo Parts
class LogoPartClipper extends CustomClipper<Rect> {
  final Alignment alignment;

  LogoPartClipper(this.alignment);

  @override
  Rect getClip(Size size) {
    final width = size.width / 2;
    final height = size.height / 2;

    if (alignment == Alignment.topLeft) {
      return Rect.fromLTWH(0, 0, width, height);
    } else if (alignment == Alignment.topRight) {
      return Rect.fromLTWH(width, 0, width, height);
    } else if (alignment == Alignment.bottomLeft) {
      return Rect.fromLTWH(0, height, width, height);
    } else {
      // bottomRight
      return Rect.fromLTWH(width, height, width, height);
    }
  }

  @override
  bool shouldReclip(LogoPartClipper oldClipper) => false;
}

// Custom Painter for Particle Effect
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i + (animationValue * 20);      final y = (size.height / 20) * i - (animationValue * 30);

      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        2 + (i % 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
