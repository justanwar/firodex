// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';

import '../../../run_integration_tests.dart';

File? _configFile;

void main() async {
  _configFile = await _findCoinsConfigFile();
  if (_configFile == null) {
    throw 'Coins config file not found';
  } else {
    print('Temporarily breaking $suspendedCoin electrum config'
        ' in \'${_configFile!.path}\' to test suspended state.');
  }

  final Map<String, dynamic> originalConfig = _readConfig();
  _breakConfig(originalConfig);

  Process.run(
    'flutter',
    [
      'drive',
      '--driver=test_driver/integration_test.dart',
      '--target=test_integration/tests/suspended_assets_test/suspended_assets_test.dart',
      '-d',
      'chrome',
      '--profile'
    ],
    runInShell: true,
  ).then((result) {
    stdout.write(result.stdout);
    _restoreConfig(originalConfig);
  }).catchError((dynamic e) {
    stdout.write(e);
    _restoreConfig(originalConfig);
    throw e;
  });
}

Map<String, dynamic> _readConfig() {
  Map<String, dynamic> json;

  try {
    final String jsonStr = _configFile!.readAsStringSync();
    json = jsonDecode(jsonStr);
  } catch (e) {
    print('Unable to load json from ${_configFile!.path}:\n$e');
    rethrow;
  }

  return json;
}

void _writeConfig(Map<String, dynamic> config) {
  final String spaces = ' ' * 4;
  final JsonEncoder encoder = JsonEncoder.withIndent(spaces);

  _configFile!.writeAsStringSync(encoder.convert(config));
}

void _breakConfig(Map<String, dynamic> config) {
  final Map<String, dynamic> broken = jsonDecode(jsonEncode(config));
  broken[suspendedCoin]['electrum'] = [
    {
      'url': 'broken.e1ectrum.net:10063',
      'ws_url': 'broken.e1ectrum.net:30063',
    }
  ];

  _writeConfig(broken);
}

void _restoreConfig(Map<String, dynamic> originalConfig) {
  _writeConfig(originalConfig);
}

// coins_config.json path contains version number, so can't be constant
Future<File?> _findCoinsConfigFile() async {
  final List<FileSystemEntity> assets =
      await Directory('assets').list().toList();

  for (FileSystemEntity entity in assets) {
    if (entity is! Directory) continue;

    final config = File(entity.path + '/config/coins_config.json');
    if (config.existsSync()) return config;
  }

  return null;
}
