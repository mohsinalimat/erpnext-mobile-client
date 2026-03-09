import 'package:device_preview/device_preview.dart';
import 'src/app/app.dart';
import 'src/core/app_preview.dart';
import 'src/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  runApp(
    DevicePreview(
      enabled: AppPreview.enabled,
      builder: (_) => const ErpnextStockMobileApp(),
    ),
  );
}
