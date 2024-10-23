import 'package:equatable/equatable.dart';
import 'package:komodo_persistence_layer/komodo_persistence_layer.dart';
import 'package:web_dex/bloc/cex_market_data/charts.dart';
import 'package:web_dex/bloc/cex_market_data/models/graph_type.dart';

/// Cache for the portfolio growth graph data.
class GraphCache extends Equatable implements ObjectWithPrimaryKey<String> {
  /// Create a new instance of the cache.
  const GraphCache({
    required this.coinId,
    required this.fiatCoinId,
    required this.lastUpdated,
    required this.graph,
    required this.graphType,
    required this.walletId,
  });

  factory GraphCache.fromJson(Map<String, dynamic> json) {
    return GraphCache(
      coinId: json['coinId'],
      fiatCoinId: json['fiatCoinId'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      graph: List.from(json['portfolioGrowthGraphs']),
      graphType: json['graphType'],
      walletId: json['walletId'],
    );
  }

  static String getPrimaryKey(
    String coinId,
    String fiatCoinId,
    GraphType graphType,
    String walletId,
  ) =>
      '$coinId-$fiatCoinId-${graphType.name}-$walletId';

  /// The komodo coin abbreviation from the coins repository (e.g. BTC, etc.).
  final String coinId;

  /// The fiat coin abbreviation (e.g. USDT, etc.).
  final String fiatCoinId;

  /// The timestamp of the last update.
  final DateTime lastUpdated;

  /// The portfolio growth graph data.
  final ChartData graph;

  /// The type of the graph.
  final GraphType graphType;

  /// The wallet ID.
  final String walletId;

  Map<String, dynamic> toJson() {
    return {
      'coinId': coinId,
      'fiatCoinId': fiatCoinId,
      'lastUpdated': lastUpdated.toIso8601String(),
      'portfolioGrowthGraphs': graph,
      'graphType': graphType,
      'walletId': walletId,
    };
  }

  GraphCache copyWith({
    String? coinId,
    String? fiatCoinId,
    DateTime? lastUpdated,
    ChartData? portfolioGrowthGraphs,
    GraphType? graphType,
    String? walletId,
  }) {
    return GraphCache(
      coinId: coinId ?? this.coinId,
      fiatCoinId: fiatCoinId ?? this.fiatCoinId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      graph: portfolioGrowthGraphs ?? graph,
      graphType: graphType ?? this.graphType,
      walletId: walletId ?? this.walletId,
    );
  }

  @override
  List<Object?> get props => [
        coinId,
        fiatCoinId,
        lastUpdated,
        graph,
        graphType,
        walletId,
      ];

  @override
  String get primaryKey =>
      getPrimaryKey(coinId, fiatCoinId, graphType, walletId);
}
