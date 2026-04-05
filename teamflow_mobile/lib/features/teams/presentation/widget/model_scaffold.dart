import 'package:flutter/material.dart';

/// Shared backdrop + card wrapper for all modals.
class ModalScaffold extends StatelessWidget {
  final Widget child;
  const ModalScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}