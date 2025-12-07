import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/app_export.dart';
import '../../services/local_data_service.dart';
import './widgets/breathing_logo_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _loadingProgress = 0.0;
  bool _hasNetworkTimeout = false;
  bool _reduceMotion = false;
  String _loadingMessage = 'Inicializando...';
  final LocalDataService _dataService = LocalDataService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppTheme.lightTheme.colorScheme.primary,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Step 1: Check network connectivity (with timeout)
      await _checkConnectivity();
      _updateProgress(0.25, 'Verificando conexión...');

      // Step 2: Load user preferences
      await _loadUserPreferences();
      _updateProgress(0.5, 'Cargando preferencias...');

      // Step 3: Initialize data service
      await _dataService.init();
      _updateProgress(0.75, 'Preparando aplicación...');

      // Step 4: Complete
      _updateProgress(1.0, 'Completado');

      // Wait for minimum splash duration
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate based on user state
      _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors gracefully
      _handleInitializationError(e);
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final dynamic result = await Connectivity()
          .checkConnectivity()
          .timeout(const Duration(seconds: 5));

      bool noConnection = true;
      if (result is List<ConnectivityResult>) {
        noConnection = result.isEmpty ||
            result.every((r) => r == ConnectivityResult.none);
      } else if (result is ConnectivityResult) {
        noConnection = result == ConnectivityResult.none;
      }

      if (noConnection) {
        setState(() {
          _hasNetworkTimeout = true;
        });
      }
    } on TimeoutException {
      setState(() {
        _hasNetworkTimeout = true;
      });
    } catch (e) {
      setState(() {
        _hasNetworkTimeout = true;
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool? reduceMotion = prefs.getBool('reduceMotion');
      
      if (reduceMotion != null) {
        setState(() {
          _reduceMotion = reduceMotion;
        });
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  void _updateProgress(double progress, String message) {
    if (mounted) {
      setState(() {
        _loadingProgress = progress;
        _loadingMessage = message;
      });
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Check if user has completed onboarding
    final bool hasCompletedOnboarding = await _dataService.hasCompletedOnboarding();

    // Determine navigation path
    String nextRoute;

    if (!hasCompletedOnboarding) {
      // New users see onboarding
      nextRoute = '/onboarding';
    } else {
      // Returning users go to dashboard
      nextRoute = '/dashboard-home';
    }

    // Navigate with replacement
    if (mounted) {
      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  void _handleInitializationError(dynamic error) {
    debugPrint('Initialization error: $error');

    // Show error state or navigate to offline mode
    if (mounted) {
      setState(() {
        _loadingProgress = 1.0;
        _loadingMessage = 'Error de inicialización';
      });

      // Navigate to onboarding after error delay (safer fallback)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            const GradientBackgroundWidget(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Breathing logo animation
                  BreathingLogoWidget(
                    reduceMotion: _reduceMotion,
                  ),

                  SizedBox(height: 8.h),

                  // App title
                  Text(
                    'SmokeTracker',
                    style:
                        AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // Subtitle
                  Text(
                    'Tu compañero para una vida sin humo',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12.h),

                  // Loading indicator
                  LoadingIndicatorWidget(
                    progress: _loadingProgress,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _loadingMessage,
                    style: AppTheme.lightTheme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Network timeout indicator
            if (_hasNetworkTimeout)
              Positioned(
                bottom: 8.h,
                left: 4.w,
                right: 4.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'wifi_off',
                        color: Colors.white,
                        size: 5.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Modo sin conexión activado',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}