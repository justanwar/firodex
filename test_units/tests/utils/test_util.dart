import 'package:web_dex/model/cex_price.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/coin_type.dart';

Coin setCoin(
    {double? usdPrice, double? change24h, String? coinAbbr, double? balance}) {
  final coin = Coin(
    abbr: coinAbbr ?? 'KMD',
    accounts: null,
    activeByDefault: true,
    bchdUrls: [],
    coingeckoId: "komodo",
    coinpaprikaId: "kmd-komodo",
    derivationPath: "m/44'/141'/0'",
    electrum: [],
    explorerUrl: "https://kmdexplorer.io/address/",
    explorerAddressUrl: "address/",
    explorerTxUrl: "tx/",
    fallbackSwapContract: null,
    isTestCoin: false,
    mode: CoinMode.standard,
    name: 'Komodo',
    nodes: [],
    priority: 30,
    protocolData: null,
    protocolType: 'UTXO',
    parentCoin: null,
    rpcUrls: [],
    state: CoinState.inactive,
    swapContractAddress: null,
    type: CoinType.smartChain,
    walletOnly: false,
    usdPrice: usdPrice != null
        ? CexPrice(
            price: usdPrice,
            change24h: change24h ?? 0.0,
            volume24h: 0.0,
            ticker: 'USD',
          )
        : null,
  );
  if (balance != null) {
    coin.balance = balance;
  }
  return coin;
}
