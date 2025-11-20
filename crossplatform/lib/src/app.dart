import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scada_crossplatform/src/screens/dashboard_screen.dart';
import 'package:scada_crossplatform/src/theme/app_theme.dart';

class ScadaApp extends ConsumerWidget {
  const ScadaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformTheme = _getPlatformTheme(context);
    
    return MaterialApp(
      title: _getAppTitle(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Always use dark theme for SCADA
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
      // Platform-specific navigation
      navigatorKey: _getNavigatorKey(),
    );
  }

  String _getAppTitle() {
    if (kIsWeb) return 'SCADA System - Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'SCADA System - Android';
      case TargetPlatform.iOS:
        return 'SCADA System - iOS';
      case TargetPlatform.windows:
        return 'SCADA System - Windows';
      case TargetPlatform.linux:
        return 'SCADA System - Linux';
      case TargetPlatform.macOS:
        return 'SCADA System - macOS';
      default:
        return 'SCADA System';
    }
  }

  ThemeData _getPlatformTheme(BuildContext context) {
    // Platform-specific theme adjustments
    final baseTheme = Theme.of(context);
    
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return baseTheme.copyWith(
        platform: TargetPlatform.windows,
      );
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return baseTheme.copyWith(
        platform: TargetPlatform.macOS,
      );
    }
    
    return baseTheme;
  }

  GlobalKey<NavigatorState>? _getNavigatorKey() {
    // For desktop apps, we might want a different navigation structure
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || 
                    defaultTargetPlatform == TargetPlatform.linux || 
                    defaultTargetPlatform == TargetPlatform.macOS)) {
      return GlobalKey<NavigatorState>();
    }
    return null;
  }
}