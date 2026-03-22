// lib/core/navigation/navigation_helper.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {
  NavigationHelper._();

  static final NavigationHelper instance = NavigationHelper._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Get context safely
  BuildContext? get _context => navigatorKey.currentContext;

  // Check if navigation is possible
  bool get canNavigate => _context != null;

  // Navigate to named route
  void goToNamed(String name, {Map<String, String>? params, Object? extra}) {
    if (!canNavigate) return;
    _context!.goNamed(name, pathParameters: params ?? {}, extra: extra);
  }

  // Push named route
  void pushNamed(String name, {Map<String, String>? params, Object? extra}) {
    if (!canNavigate) return;
    _context!.pushNamed(name, pathParameters: params ?? {}, extra: extra);
  }

  // Go to path
  void go(String path, {Object? extra}) {
    if (!canNavigate) return;
    _context!.go(path, extra: extra);
  }

  // Push path
  void push(String path, {Object? extra}) {
    if (!canNavigate) return;
    _context!.push(path, extra: extra);
  }

  // Pop current route
  void pop<T>([T? result]) {
    if (!canNavigate) return;
    if (_context!.canPop()) {
      _context!.pop(result);
    }
  }

  // Replace current route
  void replaceNamed(String name, {Map<String, String>? params, Object? extra}) {
    if (!canNavigate) return;
    _context!.replaceNamed(name, pathParameters: params ?? {}, extra: extra);
  }

  // Check if can pop
  bool get canPop => _context?.canPop() ?? false;

  // Pop until specific route
  void popUntil(String routeName) {
    if (!canNavigate) return;
    _context!.go(routeName);
  }

  // Show dialog
  Future<T?> showDialogHelper<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    if (!canNavigate) return Future.value(null);
    return showDialog<T>(
      context: _context!,
      barrierDismissible: barrierDismissible,
      builder: (_) => child,
    );
  }

  // Show bottom sheet
  Future<T?> showBottomSheetHelper<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    if (!canNavigate) return Future.value(null);
    return showModalBottomSheet<T>(
      context: _context!,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (_) => child,
    );
  }

  // Show snackbar
  void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    if (!canNavigate) return;
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
    );
  }

  // Show success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    );
  }
}

// Shorter alias for convenience
final nav = NavigationHelper.instance;