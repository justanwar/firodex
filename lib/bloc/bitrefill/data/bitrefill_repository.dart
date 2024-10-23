import 'dart:async';

import 'package:web_dex/bloc/bitrefill/data/bitrefill_provider.dart';
import 'package:web_dex/bloc/bitrefill/data/bitrefill_purchase_watcher.dart';
import 'package:web_dex/bloc/bitrefill/models/bitrefill_payment_intent_event.dart';

class BitrefillRepository {
  final BitrefillPurchaseWatcher _bitrefillPurchaseWatcher =
      BitrefillPurchaseWatcher();
  final BitrefillProvider _bitrefillProvider = BitrefillProvider();

  Stream<BitrefillPaymentIntentEvent> watchPaymentIntent() {
    return _bitrefillPurchaseWatcher.watchPaymentIntent();
  }

  /// Returns the supported coins for Bitrefill.
  List<String> get bitrefillSupportedCoins =>
      _bitrefillProvider.supportedCoinAbbrs;

  /// Returns the embedded Bitrefill url.
  String embeddedBitrefillUrl({String? coinAbbr, String? refundAddress}) {
    return _bitrefillProvider.embeddedBitrefillUrl(
      coinAbbr: coinAbbr,
      refundAddress: refundAddress,
    );
  }
}
