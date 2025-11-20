import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scada_crossplatform/src/navigation/app_navigator.dart';
import 'package:scada_crossplatform/src/screens/dashboard_screen.dart';
import 'package:scada_crossplatform/src/screens/tags_screen.dart';
import 'package:scada_crossplatform/src/screens/alarms_screen.dart';
import 'package:scada_crossplatform/src/screens/pipeline_objects_screen.dart';
import 'package:scada_crossplatform/src/theme/app_theme.dart';

class ScadaApp extends ConsumerWidget {
  const ScadaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: _getAppTitle(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.navigatorKey,
      onGenerateRoute: _generateRoute,
      initialRoute: RouteConstants.dashboard,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Hide keyboard when tapping outside of text fields
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild?.unfocus();
            }
          },
          child: child,
        );
      },
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.dashboard:
        return _buildRoute(settings, const DashboardScreen());
      case RouteConstants.tags:
        return _buildRoute(settings, const TagsScreen());
      case RouteConstants.alarms:
        return _buildRoute(settings, const AlarmsScreen());
      case RouteConstants.objects:
        return _buildRoute(settings, const PipelineObjectsScreen());
      default:
        return _buildRoute(
          settings,
          Scaffold(
            appBar: AppBar(title: const Text('Страница не найдена')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '404',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Страница "${settings.name}" не найдена',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => AppNavigator.toDashboard(),
                    child: const Text('На главную'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  PageRoute _buildRoute(RouteSettings settings, Widget screen) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageRoute(
        settings: settings,
        builder: (context) => screen,
      );
    } else {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => screen,
      );
    }
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
}

class RouteConstants {
  static const String dashboard = '/';
  static const String tags = '/tags';
  static const String alarms = '/alarms';
  static const String objects = '/objects';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String splash = '/splash';
  static const String tagDetails = '/tag-details';
  static const String alarmDetails = '/alarm-details';
  static const String objectDetails = '/object-details';
}