import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

class CexPrice extends Equatable {
  const CexPrice({
    required this.ticker,
    required this.price,
    this.lastUpdated,
    this.priceProvider,
    this.change24h,
    this.changeProvider,
    this.volume24h,
    this.volumeProvider,
  });

  final String ticker;
  final double price;
  final DateTime? lastUpdated;
  final CexDataProvider? priceProvider;
  final double? volume24h;
  final CexDataProvider? volumeProvider;
  final double? change24h;
  final CexDataProvider? changeProvider;

  @override
  String toString() {
    return 'CexPrice(ticker: $ticker, price: $price)';
  }

  @override
  List<Object?> get props => [
        ticker,
        price,
        lastUpdated,
        priceProvider,
        volume24h,
        volumeProvider,
        change24h,
        changeProvider,
      ];
}

enum CexDataProvider {
  binance,
  coingecko,
  coinpaprika,
  nomics,
  unknown,
}

CexDataProvider cexDataProvider(String string) {
  return CexDataProvider.values
          .firstWhereOrNull((e) => e.toString().split('.').last == string) ??
      CexDataProvider.unknown;
}
