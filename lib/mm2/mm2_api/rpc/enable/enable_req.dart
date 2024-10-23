import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/electrum.dart';

class EnableEthWithTokensRequest implements BaseRequest {
  EnableEthWithTokensRequest({
    required this.coin,
    required this.nodes,
    required this.swapContractAddress,
    required this.fallbackSwapContract,
    this.tokens = const [],
  });

  final String coin;
  final List<CoinNode> nodes;
  final String? swapContractAddress;
  final String? fallbackSwapContract;
  final List<String> tokens;

  @override
  final String method = 'enable_eth_with_tokens';
  @override
  late String userpass;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userpass': userpass,
      'mmrpc': '2.0',
      'method': method,
      'params': {
        'ticker': coin,
        'nodes': nodes.map<Map<String, dynamic>>((n) => n.toJson()).toList(),
        'swap_contract_address': swapContractAddress,
        if (fallbackSwapContract != null)
          'fallback_swap_contract': fallbackSwapContract,
        'erc20_tokens_requests':
            tokens.map((t) => <String, dynamic>{'ticker': t}).toList(),
      },
      'id': 0,
    };
  }
}

class EnableErc20Request implements BaseRequest {
  EnableErc20Request({required this.ticker});
  final String ticker;
  @override
  late String userpass;
  @override
  final String method = 'enable_erc20';

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mmrpc': '2.0',
      'userpass': userpass,
      'method': method,
      'params': {
        'ticker': ticker,
        'activation_params': <String, dynamic>{},
      },
      'id': 0
    };
  }
}

class EnableBchWithTokens implements BaseRequest {
  EnableBchWithTokens({
    required this.ticker,
    required this.urls,
    required this.servers,
  });
  final String ticker;
  final List<String> urls;
  final List<Electrum> servers;
  @override
  late String userpass;
  @override
  String get method => 'enable_bch_with_tokens';

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mmrpc': '2.0',
      'userpass': userpass,
      'method': method,
      'params': {
        'ticker': ticker,
        'allow_slp_unsafe_conf': false,
        'bchd_urls': urls,
        'mode': {
          'rpc': 'Electrum',
          'rpc_data': {
            'servers': servers.map((server) => server.toJson()).toList(),
          }
        },
        'tx_history': true,
        'slp_tokens_requests': <dynamic>[],
      }
    };
  }
}

class EnableSlp implements BaseRequest {
  EnableSlp({required this.ticker});

  final String ticker;
  @override
  late String userpass;
  @override
  String get method => 'enable_slp';

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mmrpc': '2.0',
      'userpass': userpass,
      'method': method,
      'params': {'ticker': ticker, 'activation_params': <String, dynamic>{}}
    };
  }
}
