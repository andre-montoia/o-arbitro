import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'navigation/app_router.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(const OArbitroApp());
}

class OArbitroApp extends StatelessWidget {
  const OArbitroApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'O Árbitro',
    theme: AppTheme.dark,
    debugShowCheckedModeBanner: false,
    home: const AppRouter(),
  );
}
