import 'package:flutter/material.dart';
import 'package:web_dex/router/state/menu_state_interface.dart';

class DexState extends ChangeNotifier implements IResettableOnLogout {
  DexState()
      : _action = DexAction.none,
        _uuid = '';

  DexAction _action;
  String _uuid;

  set action(DexAction action) {
    if (_action == action) {
      return;
    }

    _action = action;
    notifyListeners();
  }

  void setDetailsAction(String uuid) {
    _uuid = uuid;
    _action = DexAction.tradingDetails;
    notifyListeners();
  }

  DexAction get action => _action;

  bool get isTradingDetails => _action == DexAction.tradingDetails;

  set uuid(String uuid) {
    _uuid = uuid;
    notifyListeners();
  }

  String get uuid => _uuid;

  @override
  void reset() {
    action = DexAction.none;
  }

  @override
  void resetOnLogOut() {
    action = DexAction.none;
  }
}

enum DexAction {
  tradingDetails,
  none,
}
