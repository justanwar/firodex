import 'dart:async';

import 'package:web_dex/mm2/mm2.dart';
import 'package:web_dex/model/authorize_mode.dart';
import 'package:web_dex/shared/utils/utils.dart';

class AuthRepository {
  AuthRepository();
  final StreamController<AuthorizeMode> _authController =
      StreamController<AuthorizeMode>.broadcast();
  Stream<AuthorizeMode> get authMode => _authController.stream;
  Future<void> logIn(AuthorizeMode mode, [String? seed]) async {
    await _startMM2(seed);
    await waitMM2StatusChange(MM2Status.rpcIsUp, mm2, waitingTime: 60000);
    setAuthMode(mode);
  }

  void setAuthMode(AuthorizeMode mode) {
    _authController.sink.add(mode);
  }

  Future<void> logOut() async {
    await mm2.stop();
    await waitMM2StatusChange(MM2Status.isNotRunningYet, mm2);
    setAuthMode(AuthorizeMode.noLogin);
  }

  Future<void> _startMM2(String? seed) async {
    try {
      await mm2.start(seed);
    } catch (e) {
      log('mm2 start error: ${e.toString()}');
      rethrow;
    }
  }
}

final AuthRepository authRepo = AuthRepository();
