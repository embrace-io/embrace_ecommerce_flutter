import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'services/services.dart';
import 'utils/constants.dart';
import 'utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Embrace SDK is initialized on native side (iOS: AppDelegate.swift)
  // Add session properties for Flutter context
  await EmbraceService.shared.addSessionProperty(
    'platform',
    'flutter',
    permanent: true,
  );

  await EmbraceService.shared.addSessionProperty(
    'app_version',
    AppConstants.appVersion,
    permanent: true,
  );

  await EmbraceService.shared.logInfo('App started', properties: {
    'platform': 'flutter',
    'version': AppConstants.appVersion,
  });

  runApp(const EmbraceEcommerceApp());
}

class EmbraceEcommerceApp extends StatelessWidget {
  const EmbraceEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
