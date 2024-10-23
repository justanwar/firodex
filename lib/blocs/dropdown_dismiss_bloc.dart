import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/bridge_form/bridge_bloc.dart';
import 'package:web_dex/bloc/bridge_form/bridge_event.dart';
import 'package:web_dex/bloc/taker_form/taker_bloc.dart';
import 'package:web_dex/bloc/taker_form/taker_event.dart';

import 'blocs.dart';

class DropdownDismissBloc {
  final dropdownDismissController = StreamController<bool>.broadcast();
  StreamSink<bool> get _inDropdownDismiss => dropdownDismissController.sink;
  Stream<bool> get outDropdownDismiss => dropdownDismissController.stream;

  void runDropdownDismiss({BuildContext? context}) {
    if (context != null) {
      // Taker form
      context.read<TakerBloc>().add(TakerCoinSelectorOpen(false));
      context.read<TakerBloc>().add(TakerOrderSelectorOpen(false));

      // Maker form
      makerFormBloc.showSellCoinSelect = false;
      makerFormBloc.showBuyCoinSelect = false;

      // Bridge form
      context.read<BridgeBloc>().add(const BridgeShowTickerDropdown(false));
      context.read<BridgeBloc>().add(const BridgeShowSourceDropdown(false));
      context.read<BridgeBloc>().add(const BridgeShowTargetDropdown(false));
    }

    // In case there's need to make it available in a stream for future use
    _inDropdownDismiss.add(true);
    Future.delayed(const Duration(seconds: 1))
        .then((_) => _inDropdownDismiss.add(false));
  }

  void dispose() {
    dropdownDismissController.close();
  }
}
