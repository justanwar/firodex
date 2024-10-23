import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_dex/services/logger/logger.dart';
import 'package:web_dex/services/logger/mock_logger.dart';
import 'package:web_dex/services/logger/universal_logger.dart';
import 'package:web_dex/services/platform_info/plaftorm_info.dart';

final LoggerInterface logger = _getLogger();
LoggerInterface _getLogger() {
  final platformInfo = PlatformInfo.getInstance();

  if (kIsWeb ||
      Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isLinux ||
      Platform.isAndroid ||
      Platform.isIOS) {
    return UniversalLogger(platformInfo: platformInfo);
  }

  return const MockLogger();
}
