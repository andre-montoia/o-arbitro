import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ShareService {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  static Future<void> shareGameResult({
    required String gameName,
    required String result,
    String? score,
    Color? backgroundColor,
  }) async {
    final text = '''
🎮 O Árbitro - $gameName
$result
${score != null ? 'Pontuação: $score' : ''}

Jogue você também!
https://github.com/andre-montoia/o-arbitro
''';

    await Share.share(text, subject: 'O Árbitro - $gameName');
  }

  static Future<void> shareScreenshot({
    required Widget widget,
    required String gameName,
  }) async {
    try {
      final image = await _screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 100),
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/o_arbitro_share.png').create();
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Jogue O Árbitro! 🎮',
        subject: 'O Árbitro - $gameName',
      );
    } catch (e) {
      debugPrint('Error sharing screenshot: $e');
    }
  }

  static Future<void> shareToWhatsApp({
    required String message,
  }) async {
    final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(message)}';
    // In a real implementation, you'd use url_launcher to open WhatsApp
    await Share.share(message);
  }

  static Future<void> shareToInstagram({
    required String imagePath,
    String? caption,
  }) async {
    // Instagram sharing requires platform-specific implementation
    // This is a simplified version using share_plus
    await Share.shareXFiles(
      [XFile(imagePath)],
      text: caption ?? 'O Árbitro 🎮',
      subject: 'O Árbitro',
    );
  }
}
