import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/taker_form/taker_bloc.dart';
import 'package:web_dex/bloc/taker_form/taker_event.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/views/dex/simple/form/taker/taker_form_layout.dart';

class TakerForm extends StatefulWidget {
  const TakerForm({super.key});

  @override
  State<TakerForm> createState() => _TakerFormState();
}

class _TakerFormState extends State<TakerForm> {
  StreamSubscription<bool>? _coinsListener;

  @override
  void initState() {
    final takerBloc = context.read<TakerBloc>();
    takerBloc.add(TakerSetDefaults());
    takerBloc.add(TakerSetWalletIsReady(coinsBloc.loginActivationFinished));
    _coinsListener = coinsBloc.outLoginActivationFinished.listen((value) {
      takerBloc.add(TakerSetWalletIsReady(value));
    });

    super.initState();
  }

  @override
  void dispose() {
    _coinsListener?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const TakerFormLayout();
  }
}
