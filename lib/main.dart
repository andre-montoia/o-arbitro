import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'navigation/app_router.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('🚨 UI ERROR: ${details.exception}\n${details.stack}');
    return Material(
      color: Colors.red.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            '🚨 Erro na tela:\n${details.exception}\n\n${details.stack}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  };
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('🚨 FlutterError: ${details.exception}');
  };
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
