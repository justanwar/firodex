import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_dex/services/file_loader/file_loader.dart';
import 'package:web_dex/services/file_loader/file_loader_native_desktop.dart';
import 'package:web_dex/services/file_loader/file_loader_web.dart';

import 'mobile/file_loader_native_android.dart';
import 'mobile/file_loader_native_ios.dart';

final FileLoader fileLoader = _getFileLoader();
FileLoader _getFileLoader() {
  if (kIsWeb) {
    return const FileLoaderWeb();
  }
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    return const FileLoaderNativeDesktop();
  }
  if (Platform.isAndroid) {
    return const FileLoaderNativeAndroid();
  }
  if (Platform.isIOS) {
    return const FileLoaderNativeIOS();
  }
  throw UnimplementedError();
}
