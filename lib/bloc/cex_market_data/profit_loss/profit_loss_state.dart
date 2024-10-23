part of 'profit_loss_bloc.dart';

sealed class ProfitLossState extends Equatable {
  const ProfitLossState({required this.selectedPeriod});

  final Duration selectedPeriod;

  @override
  List<Object> get props => [selectedPeriod];
}

final class ProfitLossInitial extends ProfitLossState {
  const ProfitLossInitial() : super(selectedPeriod: const Duration(hours: 1));
}

final class PortfolioProfitLossChartLoadInProgress extends ProfitLossState {
  const PortfolioProfitLossChartLoadInProgress({required super.selectedPeriod});
}

final class PortfolioProfitLossChartLoadSuccess extends ProfitLossState {
  const PortfolioProfitLossChartLoadSuccess({
    required this.profitLossChart,
    required this.totalValue,
    required this.percentageIncrease,
    required this.coins,
    required this.fiatCurrency,
    required this.walletId,
    required super.selectedPeriod,
  });

  final List<Point<double>> profitLossChart;
  final double totalValue;
  final double percentageIncrease;
  final List<Coin> coins;
  final String fiatCurrency;
  final String walletId;

  @override
  List<Object> get props => [
        profitLossChart,
        totalValue,
        percentageIncrease,
        coins,
        fiatCurrency,
        selectedPeriod,
        walletId,
      ];
}

final class ProfitLossLoadFailure extends ProfitLossState {
  const ProfitLossLoadFailure({
    required this.error,
    required super.selectedPeriod,
  });

  final BaseError error;

  @override
  List<Object> get props => [error, selectedPeriod];
}

final class PortfolioProfitLossChartUnsupported extends ProfitLossState {
  const PortfolioProfitLossChartUnsupported({required super.selectedPeriod});
}
