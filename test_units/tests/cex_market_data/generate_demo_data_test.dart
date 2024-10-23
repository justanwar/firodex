import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:web_dex/bloc/cex_market_data/mockup/generate_demo_data.dart';
import 'package:web_dex/bloc/cex_market_data/mockup/performance_mode.dart';

void testGenerateDemoData() {
  late DemoDataGenerator generator;
  late BinanceRepository binanceRepository;

  setUp(() {
    binanceRepository = BinanceRepository(
      binanceProvider: const BinanceProvider(),
    );
    generator = DemoDataGenerator(
      binanceRepository,
      randomSeed: 42,
    );
  });

  group('DemoDataGenerator', () {
    test('generateTransactions returns correct number of transactions',
        () async {
      final transactions =
          await generator.generateTransactions('KMD', PerformanceMode.good);
      expect(
        transactions.length,
        closeTo(generator.transactionsPerMode[PerformanceMode.good] ?? 0, 4),
      );
    });

    test('generateTransactions returns empty list for invalid coin', () async {
      final transactions = await generator.generateTransactions(
        'INVALID_COIN',
        PerformanceMode.good,
      );
      expect(transactions, isEmpty);
    });

    test('generateTransactions respects performance mode', () async {
      final goodTransactions =
          await generator.generateTransactions('KMD', PerformanceMode.good);
      final badTransactions =
          await generator.generateTransactions('KMD', PerformanceMode.veryBad);

      double goodBalance = generator.initialBalance;
      double badBalance = generator.initialBalance;

      for (var tx in goodTransactions) {
        goodBalance += double.parse(tx.myBalanceChange);
      }

      for (var tx in badTransactions) {
        badBalance += double.parse(tx.myBalanceChange);
      }

      expect(goodBalance, greaterThan(badBalance));
    });

    test('generateTransactions produces valid transaction objects', () async {
      final transactions =
          await generator.generateTransactions('KMD', PerformanceMode.mediocre);

      for (var tx in transactions) {
        expect(tx.coin, equals('KMD'));
        expect(tx.confirmations, inInclusiveRange(1, 3));
        expect(tx.feeDetails.coin, equals('USDT'));
        expect(tx.from, isNotEmpty);
        expect(tx.to, isNotEmpty);
        expect(tx.internalId, isNotEmpty);
        expect(tx.txHash, isNotEmpty);
        expect(double.tryParse(tx.myBalanceChange), isNotNull);
        expect(double.tryParse(tx.totalAmount), isNotNull);
      }
    });

    test('fetchOhlcData returns data for all specified coin pairs', () async {
      final ohlcData = await generator.fetchOhlcData();

      for (var coinPair in generator.coinPairs) {
        expect(ohlcData[coinPair], isNotNull);
        expect(ohlcData[coinPair]!, isNotEmpty);
      }
    });
  });
}
