import '../core/theme/app_theme.dart';
import 'app_router.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

class ErpnextStockMobileApp extends StatelessWidget {
  const ErpnextStockMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Stock Mobile',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.light(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
        overscroll: false,
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.login,
    );
  }
}
