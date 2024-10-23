import 'dart:convert';

import 'package:http/http.dart';
import 'package:web_dex/mm2/mm2_api/rpc/errors.dart';
import 'package:web_dex/mm2/mm2_api/rpc/nft/get_nft_list/get_nft_list_req.dart';
import 'package:web_dex/mm2/mm2_api/rpc/nft/update_nft/update_nft_req.dart';
import 'package:web_dex/mm2/mm2_api/rpc/nft/refresh_nft_metadata/refresh_nft_metadata_req.dart';
import 'package:web_dex/mm2/mm2_api/rpc/nft/withdraw/withdraw_nft_request.dart';
import 'package:web_dex/mm2/rpc/nft_transaction/nft_transactions_request.dart';
import 'package:web_dex/model/nft.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/bloc/coins_bloc/coins_repo.dart';
import 'package:web_dex/shared/constants.dart';
import 'package:web_dex/shared/utils/utils.dart';

class Mm2ApiNft {
  Mm2ApiNft(this.call);

  final Future<dynamic> Function(dynamic) call;

  Future<Map<String, dynamic>> updateNftList(
      List<NftBlockchains> chains) async {
    try {
      final List<String> nftChains = await getActiveNftChains(chains);
      if (nftChains.isEmpty) {
        return {
          "error":
              "Please ensure an NFT chain is activated and patiently await while your NFTs are loaded."
        };
      }
      final UpdateNftRequest request = UpdateNftRequest(chains: nftChains);
      final dynamic rawResponse = await call(request);

      final Map<String, dynamic> json = jsonDecode(rawResponse);
      log(
        request.toJson().toString(),
        path: 'UpdateNftRequest',
      );
      log(
        rawResponse,
        path: 'UpdateNftResponse',
      );
      return json;
    } catch (e, s) {
      log(
        'Error updating nfts: ${e.toString()}',
        path: 'UpdateNftResponse',
        trace: s,
        isError: true,
      );
      throw TransportError(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> refreshNftMetadata(
      {required String chain,
      required String tokenAddress,
      required String tokenId}) async {
    try {
      final RefreshNftMetadataRequest request = RefreshNftMetadataRequest(
          chain: chain, tokenAddress: tokenAddress, tokenId: tokenId);
      final dynamic rawResponse = await call(request);

      final Map<String, dynamic> json = jsonDecode(rawResponse);

      return json;
    } catch (e) {
      log(e.toString(),
          path: 'Mm2ApiNft => RefreshNftMetadataRequest', isError: true);
      throw TransportError(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getNftList(List<NftBlockchains> chains) async {
    try {
      final List<String> nftChains = await getActiveNftChains(chains);
      if (nftChains.isEmpty) {
        return {
          "error":
              "Please ensure the NFT chain is activated and patiently await "
                  "while your NFTs are loaded."
        };
      }
      final GetNftListRequest request = GetNftListRequest(chains: nftChains);

      final dynamic rawResponse = await call(request);
      final Map<String, dynamic> json = jsonDecode(rawResponse);

      log(
        request.toJson().toString(),
        path: 'getActiveNftChains',
      );
      log(
        rawResponse,
        path: 'UpdateNftResponse',
      );

      return json;
    } catch (e) {
      log(e.toString(), path: 'Mm2ApiNft => getNftList', isError: true);
      throw TransportError(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> withdraw(WithdrawNftRequest request) async {
    try {
      final dynamic rawResponse = await call(request);
      final Map<String, dynamic> json = jsonDecode(rawResponse);

      return json;
    } catch (e) {
      log(e.toString(), path: 'Mm2ApiNft => withdraw', isError: true);
      throw TransportError(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getNftTxs(
      NftTransactionsRequest request, bool withAdditionalInfo) async {
    try {
      final String rawResponse = await call(request);
      final Map<String, dynamic> json = jsonDecode(rawResponse);
      if (withAdditionalInfo) {
        final jsonUpdated = await const ProxyApiNft().addDetailsToTx(json);
        return jsonUpdated;
      }
      return json;
    } catch (e) {
      log(e.toString(), path: 'Mm2ApiNft => getNftTransactions', isError: true);
      throw TransportError(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> getNftTxDetails(
      NftTxDetailsRequest request) async {
    try {
      final additionalTxInfo = await const ProxyApiNft()
          .getTxDetailsByHash(request.chain, request.txHash);
      return additionalTxInfo;
    } catch (e) {
      log(e.toString(), path: 'Mm2ApiNft => getNftTxDetails', isError: true);
      throw TransportError(message: e.toString());
    }
  }

  Future<List<String>> getActiveNftChains(List<NftBlockchains> chains) async {
    final List<Coin> knownCoins = await coinsRepo.getKnownCoins();
    // log(knownCoins.toString(), path: 'Mm2ApiNft => knownCoins', isError: true);
    final List<Coin> apiCoins = await coinsRepo.getEnabledCoins(knownCoins);
    // log(apiCoins.toString(), path: 'Mm2ApiNft => apiCoins', isError: true);
    final List<String> enabledCoins = apiCoins.map((c) => c.abbr).toList();
    log(enabledCoins.toString(),
        path: 'Mm2ApiNft => enabledCoins', isError: true);
    final List<String> nftCoins = chains.map((c) => c.coinAbbr()).toList();
    log(nftCoins.toString(), path: 'Mm2ApiNft => nftCoins', isError: true);
    final List<NftBlockchains> activeChains = chains
        .map((c) => c)
        .toList()
        .where((c) => enabledCoins.contains(c.coinAbbr()))
        .toList();
    log(activeChains.toString(),
        path: 'Mm2ApiNft => activeChains', isError: true);
    final List<String> nftChains =
        activeChains.map((c) => c.toApiRequest()).toList();
    log(nftChains.toString(), path: 'Mm2ApiNft => nftChains', isError: true);
    return nftChains;
  }
}

class ProxyApiNft {
  static const _errorBaseMessage = 'ProxyApiNft API: ';
  const ProxyApiNft();
  Future<Map<String, dynamic>> addDetailsToTx(Map<String, dynamic> json) async {
    final transactions = List<dynamic>.from(json['result']['transfer_history']);
    final listOfAdditionalData = transactions
        .map((tx) => {
              'blockchain': convertChainForProxy(tx['chain']),
              'tx_hash': tx['transaction_hash'],
            })
        .toList();

    final response = await Client().post(
      Uri.parse(txByHashUrl),
      body: jsonEncode(listOfAdditionalData),
    );
    final Map<String, dynamic> jsonBody = jsonDecode(response.body);
    json['result']['transfer_history'] = transactions.map((element) {
      final String? txHash = element['transaction_hash'];
      final tx = jsonBody[txHash];
      if (tx != null) {
        element['confirmations'] = tx['confirmations'];
        element['fee_details'] = tx['fee_details'];
      }
      return element;
    }).toList();

    return json;
  }

  Future<Map<String, dynamic>> getTxDetailsByHash(
    String blockchain,
    String txHash,
  ) async {
    final listOfAdditionalData = [
      {
        'blockchain': convertChainForProxy(blockchain),
        'tx_hash': txHash,
      }
    ];
    final body = jsonEncode(listOfAdditionalData);
    try {
      final response = await Client().post(
        Uri.parse(txByHashUrl),
        body: body,
      );
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      return jsonBody[txHash];
    } catch (e) {
      throw Exception(_errorBaseMessage + e.toString());
    }
  }

  String convertChainForProxy(String chain) {
    switch (chain) {
      case 'AVALANCHE':
        return 'avx';
      case 'BSC':
        return 'bnb';
      case 'ETH':
        return 'eth';
      case 'FANTOM':
        return 'ftm';
      case 'POLYGON':
        return 'plg';
    }

    throw UnimplementedError();
  }
}
