import 'package:flutter/material.dart';
import '../presentation/progress_analytics/progress_analytics.dart';
import '../presentation/quit_timer/quit_timer.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/craving_management/craving_management.dart';
import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/settings_profile/settings_profile.dart';
import '../presentation/onboarding/onboarding_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String progressAnalytics = '/progress-analytics';
  static const String quitTimer = '/quit-timer';
  static const String splash = '/splash-screen';
  static const String cravingManagement = '/craving-management';
  static const String dashboardHome = '/dashboard-home';
  static const String settingsProfile = '/settings-profile';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    progressAnalytics: (context) => const ProgressAnalytics(),
    quitTimer: (context) => const QuitTimer(),
    splash: (context) => const SplashScreen(),
    cravingManagement: (context) => const CravingManagement(),
    dashboardHome: (context) => const DashboardHome(),
    settingsProfile: (context) => const SettingsProfile(),
  };
}
