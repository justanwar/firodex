import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/mm2/mm2.dart';
import 'package:web_dex/mm2/rpc.dart';
import 'package:web_dex/mm2/rpc_native.dart';
import 'package:web_dex/services/logger/get_logger.dart';
import 'package:web_dex/services/native_channel.dart';

class MM2iOS extends MM2 implements MM2WithInit {
  final RPC _rpc = RPCNative();

  @override
  Future<void> start(String? passphrase) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filesPath = '${dir.path}/';
    final Map<String, dynamic> params = await MM2.generateStartParams(
      passphrase: passphrase,
      gui: 'web_dex iOs',
      userHome: filesPath,
      dbDir: filesPath,
    );

    final int errorCode = await nativeChannel.invokeMethod<dynamic>(
        'start', <String, String>{'params': jsonEncode(params)});

    await logger.write('MM2 start response: $errorCode');
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
    await _subscribeOnEvents();
  }

  Future<void> _subscribeOnEvents() async {
    nativeEventChannel.receiveBroadcastStream().listen((event) async {
      Map<String, dynamic> eventJson;
      try {
        eventJson = jsonDecode(event);
      } catch (e) {
        logger.write('Error decoding MM2 event: $e');
        return;
      }

      if (eventJson['type'] == 'log') {
        await logger.write(eventJson['message']);
      } else if (eventJson['type'] == 'app_did_become_active') {
        if (!await isLive()) await _restartMM2AndCoins();
      }
    });
  }

  Future<void> _restartMM2AndCoins() async {
    await nativeChannel.invokeMethod<dynamic>('restart');
    await coinsBloc.reactivateAll();
  }
}
