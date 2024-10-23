import 'package:web_dex/model/electrum.dart';

class ElectrumReq {
  ElectrumReq({
    this.mm2 = 1,
    required this.coin,
    required this.servers,
    this.swapContractAddress,
    this.fallbackSwapContract,
  });

  static const String method = 'electrum';
  final int mm2;
  final String coin;
  final List<Electrum> servers;
  final String? swapContractAddress;
  final String? fallbackSwapContract;
  late String userpass;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'coin': coin,
      'servers': servers.map((server) => server.toJson()).toList(),
      'userpass': userpass,
      'mm2': mm2,
      'tx_history': true,
      if (swapContractAddress != null)
        'swap_contract_address': swapContractAddress,
      if (fallbackSwapContract != null)
        'swap_contract_address': swapContractAddress,
    };
  }
}
