import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState get currentState => navigatorKey.currentState!;

  // Basic Navigation Methods
  static Future<T?> push<T>(Route<T> route) {
    return currentState.push(route);
  }

  static Future<T?> pushNamed<T>(
    String routeName, {
    Object? arguments,
  }) {
    return currentState.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T>(
    String routeName, {
    Object? arguments,
  }) {
    return currentState.pushReplacementNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return currentState.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  static void pop<T>([T? result]) {
    if (currentState.canPop()) {
      currentState.pop(result);
    }
  }

  static bool get canPop => currentState.canPop();

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    currentState.popUntil(predicate);
  }

  static void popToRoot() {
    currentState.popUntil((route) => route.isFirst);
  }

  // Custom Navigation Methods for SCADA App
  static Future<void> toDashboard() async {
    await pushNamedAndRemoveUntil('/dashboard', (route) => false);
  }

  static Future<void> toTags() async {
    await pushNamed('/tags');
  }

  static Future<void> toAlarms() async {
    await pushNamed('/alarms');
  }

  static Future<void> toObjects() async {
    await pushNamed('/objects');
  }

  static Future<void> toSettings() async {
    await pushNamed('/settings');
  }

  static Future<void> toTagDetails(int tagId) async {
    await pushNamed('/tag-details', arguments: {'tagId': tagId});
  }

  static Future<void> toAlarmDetails(int alarmId) async {
    await pushNamed('/alarm-details', arguments: {'alarmId': alarmId});
  }

  static Future<void> toObjectDetails(String objectName) async {
    await pushNamed('/object-details', arguments: {'objectName': objectName});
  }

  // Dialog Navigation
  static Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    return showDialog<T>(
      context: currentState.context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
    );
  }

  static Future<T?> showBottomSheet<T>({
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    bool enableDrag = true,
    bool isDismissible = true,
    bool useRootNavigator = false,
    bool isScrollControlled = false,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
  }) {
    return showModalBottomSheet<T>(
      context: currentState.context,
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      isScrollControlled: isScrollControlled,
      routeSettings: routeSettings,
      transitionAnimationController: transitionAnimationController,
    );
  }

  // SnackBar and Toast-like functionality
  static void showSnackBar({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
  }) {
    ScaffoldMessenger.of(currentState.context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: behavior,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  static void showErrorSnackBar(String message) {
    showSnackBar(
      message: message,
      duration: const Duration(seconds: 6),
    );
  }

  static void showSuccessSnackBar(String message) {
    showSnackBar(
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  // Confirmation Dialogs
  static Future<bool> showConfirmationDialog({
    required String title,
    required String content,
    String confirmText = 'Да',
    String cancelText = 'Отмена',
    bool barrierDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );

    return result ?? false;
  }

  // Loading Dialogs
  static void showLoadingDialog({String message = 'Загрузка...'}) {
    showDialog(
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16.0),
              Text(message),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoadingDialog() {
    pop();
  }

  // Platform-aware navigation
  static Future<T?> adaptivePush<T>(Widget page) {
    return push<T>(Platform.isIOS || Platform.isMacOS
        ? CupertinoPageRoute(builder: (context) => page)
        : MaterialPageRoute(builder: (context) => page));
  }

  // Deep linking support
  static Future<void> handleDeepLink(Uri uri) async {
    final path = uri.path;
    final queryParameters = uri.queryParameters;

    switch (path) {
      case '/tags':
        await toTags();
        break;
      case '/alarms':
        await toAlarms();
        break;
      case '/objects':
        await toObjects();
        break;
      case '/tag':
        final tagId = int.tryParse(queryParameters['id'] ?? '');
        if (tagId != null) {
          await toTagDetails(tagId);
        }
        break;
      case '/alarm':
        final alarmId = int.tryParse(queryParameters['id'] ?? '');
        if (alarmId != null) {
          await toAlarmDetails(alarmId);
        }
        break;
      default:
        await toDashboard();
    }
  }

  // Navigation history
  static List<Route<dynamic>> get navigationHistory =>
      currentState.widget.pages ?? [];

  static String get currentRoute {
    final route = ModalRoute.of(currentState.context);
    return route?.settings.name ?? '';
  }

  // Navigation analytics
  static void logNavigation(String from, String to) {
    // In a real app, you would log to your analytics service
    debugPrint('Navigation: $from -> $to');
  }

  // Navigation guards
  static bool canNavigateTo(String route) {
    // Add your navigation guards here
    // For example, check authentication, permissions, etc.
    return true;
  }

  // Route generation
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // This would typically be handled by your router
    // For now, return a simple placeholder
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(settings.name ?? 'Unknown')),
        body: Center(child: Text('Route: ${settings.name}')),
      ),
    );
  }
}

// Extension for BuildContext to simplify navigation
extension NavigationExtension on BuildContext {
  Future<T?> push<T>(Route<T> route) => Navigator.of(this).push(route);

  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);

  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushReplacementNamed<T>(routeName, arguments: arguments);

  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  bool get canPop => Navigator.of(this).canPop();

  void popUntil(bool Function(Route<dynamic>) predicate) =>
      Navigator.of(this).popUntil(predicate);

  Future<T?> pushNamedAndRemoveUntil<T>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) =>
      Navigator.of(this).pushNamedAndRemoveUntil<T>(
        newRouteName,
        predicate,
        arguments: arguments,
      );

  // Quick navigation methods for SCADA app
  Future<void> toDashboard() => AppNavigator.toDashboard();
  Future<void> toTags() => AppNavigator.toTags();
  Future<void> toAlarms() => AppNavigator.toAlarms();
  Future<void> toObjects() => AppNavigator.toObjects();
  Future<void> toSettings() => AppNavigator.toSettings();

  // Dialog shortcuts
  Future<T?> showAppDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) =>
      AppNavigator.showDialog<T>(
        builder: builder,
        barrierDismissible: barrierDismissible,
      );

  Future<bool> showConfirmation({
    required String title,
    required String content,
    String confirmText = 'Да',
    String cancelText = 'Отмена',
  }) =>
      AppNavigator.showConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      );

  void showSnackBar({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      AppNavigator.showSnackBar(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      );

  void showError(String message) => AppNavigator.showErrorSnackBar(message);
  void showSuccess(String message) => AppNavigator.showSuccessSnackBar(message);
}

// Platform detection (simplified)
class Platform {
  static bool get isIOS => false; // Would use dart:io in real app
  static bool get isAndroid => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isWeb => identical(0, 0.0); // Hacky way to detect web
}