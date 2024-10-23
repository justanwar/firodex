import 'package:flutter/material.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/model/trade_preimage.dart';
import 'package:web_dex/views/dex/simple/form/exchange_info/total_fees.dart';

class MakerFormTotalFees extends StatelessWidget {
  const MakerFormTotalFees({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TradePreimage?>(
        initialData: makerFormBloc.preimage,
        stream: makerFormBloc.outPreimage,
        builder: (context, snapshot) {
          return TotalFees(preimage: snapshot.data);
        });
  }
}
