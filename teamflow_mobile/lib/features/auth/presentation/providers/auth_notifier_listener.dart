import 'package:flutter/foundation.dart';
import 'auth_state_notifier.dart';

class AuthNotifierListener extends ChangeNotifier {
  final AuthStateNotifier authNotifier;

  AuthNotifierListener(this.authNotifier) {
    authNotifier.addListener((state) => notifyListeners());
  }
}
