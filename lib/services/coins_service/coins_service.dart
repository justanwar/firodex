import 'dart:async';

import 'package:web_dex/blocs/blocs.dart';

final coinsService = CoinsService();

class CoinsService {
  void init() {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _reEnableSuspended();
    });
  }

  Future<void> _reEnableSuspended() async {
    await coinsBloc.reActivateSuspended();
  }
}
