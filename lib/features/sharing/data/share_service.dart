import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareScoreCardImage({
    required Uint8List imageBytes,
    required String scenarioTitle,
    required int overallScore,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/speechmaster_scorecard.png');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text:
          'I scored $overallScore/100 on "$scenarioTitle" with SpeechMaster! '
          'Practice your speaking skills with AI.',
    );
  }

  static Future<void> shareStreakMilestone({
    required int streak,
  }) async {
    await Share.share(
      "I've been practicing my speaking skills for $streak days straight "
      'with SpeechMaster! Try it out.',
    );
  }
}
