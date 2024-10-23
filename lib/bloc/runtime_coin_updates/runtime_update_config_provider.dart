import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:komodo_coin_updates/komodo_coin_updates.dart';

class RuntimeUpdateConfigProvider {
  RuntimeUpdateConfigProvider({
    this.configFilePath = 'app_build/build_config.json',
  });

  final String configFilePath;

  /// Fetches the runtime update config from the repository.
  /// Returns a [RuntimeUpdateConfig] object.
  /// Throws an [Exception] if the request fails.
  Future<RuntimeUpdateConfig> getRuntimeUpdateConfig() async {
    final config = jsonDecode(await rootBundle.loadString(configFilePath))
        as Map<String, dynamic>;
    return RuntimeUpdateConfig.fromJson(config['coins']);
  }
}
