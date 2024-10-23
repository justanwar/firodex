import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_dex/mm2/mm2.dart';
import 'package:web_dex/mm2/rpc.dart';
import 'package:web_dex/mm2/rpc_native.dart';
import 'package:web_dex/services/logger/get_logger.dart';
import 'package:web_dex/services/native_channel.dart';

class MM2MacOs extends MM2 implements MM2WithInit {
  final RPC _rpc = RPCNative();

  @override
  Future<void> start(String? passphrase) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filesPath = '${dir.path}/';
    final Map<String, dynamic> params = await MM2.generateStartParams(
      passphrase: passphrase,
      gui: 'web_dex macOs',
      userHome: filesPath,
      dbDir: filesPath,
    );

    final int errorCode = await nativeChannel.invokeMethod<dynamic>(
        'start', <String, String>{'params': jsonEncode(params)});

    if (kDebugMode) {
      print('MM2 start response:$errorCode');
    }
  }

  @override
  Future<void> stop() async {
    final int errorCode = await nativeChannel.invokeMethod<dynamic>('stop');

    await logger.write('MM2 sop response: $errorCode');
  }

  @override
  Future<MM2Status> status() async {
    return MM2Status.fromInt(
        await nativeChannel.invokeMethod<dynamic>('status'));
  }

  @override
  Future<dynamic> call(dynamic reqStr) async {
    return await _rpc.call(MM2.prepareRequest(reqStr));
  }

  @override
  Future<void> init() async {
    await _subscribeOnLogs();
  }

  Future<void> _subscribeOnLogs() async {
    nativeEventChannel.receiveBroadcastStream().listen((log) async {
      if (log is String) {
        await logger.write(log);
      }
    });
  }
}
