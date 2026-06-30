import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamflow_mobile/core/di/injection.dart';
import 'package:teamflow_mobile/core/services/diagnostics_service.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDI();
  DiagnosticsService.markStartupComplete();
  runApp(const ProviderScope(child: MyApp()));
}
