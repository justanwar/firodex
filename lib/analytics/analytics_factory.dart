import 'package:web_dex/analytics/analytics_events.dart';

/// Factory for creating analytics events
class AnalyticsEvents {
  const AnalyticsEvents._();

  /// E01: App launched / foregrounded
  static AppOpenedEventData appOpened({
    required String platform,
    required String appVersion,
  }) {
    return AppOpenedEventData(
      platform: platform,
      appVersion: appVersion,
    );
  }

  /// E02: Wallet setup flow begins
  static OnboardingStartedEventData onboardingStarted({
    required String method,
    String? referralSource,
  }) {
    return OnboardingStartedEventData(
      method: method,
      referralSource: referralSource,
    );
  }

  /// E03: New wallet generated
  static WalletCreatedEventData walletCreated({
    required String source,
    required String walletType,
  }) {
    return WalletCreatedEventData(
      source: source,
      walletType: walletType,
    );
  }

  /// E04: Existing wallet imported
  static WalletImportedEventData walletImported({
    required String source,
    required String importType,
    required String walletType,
  }) {
    return WalletImportedEventData(
      source: source,
      importType: importType,
      walletType: walletType,
    );
  }

  /// E05: Seed backup finished
  static BackupCompletedEventData backupCompleted({
    required int backupTime,
    required String method,
    required String walletType,
  }) {
    return BackupCompletedEventData(
      backupTime: backupTime,
      method: method,
      walletType: walletType,
    );
  }

  /// E06: Backup skipped / postponed
  static BackupSkippedEventData backupSkipped({
    required String stageSkipped,
    required String walletType,
  }) {
    return BackupSkippedEventData(
      stageSkipped: stageSkipped,
      walletType: walletType,
    );
  }

  /// E07: Portfolio overview opened
  static PortfolioViewedEventData portfolioViewed({
    required int totalCoins,
    required double totalValueUsd,
  }) {
    return PortfolioViewedEventData(
      totalCoins: totalCoins,
      totalValueUsd: totalValueUsd,
    );
  }

  /// E08: Growth chart opened
  static PortfolioGrowthViewedEventData portfolioGrowthViewed({
    required String period,
    required double growthPct,
  }) {
    return PortfolioGrowthViewedEventData(
      period: period,
      growthPct: growthPct,
    );
  }

  /// E09: P&L breakdown viewed
  static PortfolioPnlViewedEventData portfolioPnlViewed({
    required String timeframe,
    required double realizedPnl,
    required double unrealizedPnl,
  }) {
    return PortfolioPnlViewedEventData(
      timeframe: timeframe,
      realizedPnl: realizedPnl,
      unrealizedPnl: unrealizedPnl,
    );
  }

  /// E10: Custom token added
  static AssetAddedEventData assetAdded({
    required String assetSymbol,
    required String assetNetwork,
    required String walletType,
  }) {
    return AssetAddedEventData(
      assetSymbol: assetSymbol,
      assetNetwork: assetNetwork,
      walletType: walletType,
    );
  }

  /// E11: Asset detail viewed
  static AssetViewedEventData assetViewed({
    required String assetSymbol,
    required String assetNetwork,
    required String walletType,
  }) {
    return AssetViewedEventData(
      assetSymbol: assetSymbol,
      assetNetwork: assetNetwork,
      walletType: walletType,
    );
  }

  /// E12: Existing asset toggled on / made visible
  static AssetEnabledEventData assetEnabled({
    required String assetSymbol,
    required String assetNetwork,
    required String walletType,
  }) {
    return AssetEnabledEventData(
      assetSymbol: assetSymbol,
      assetNetwork: assetNetwork,
      walletType: walletType,
    );
  }

  /// E13: Token toggled off / hidden
  static AssetDisabledEventData assetDisabled({
    required String assetSymbol,
    required String assetNetwork,
    required String walletType,
  }) {
    return AssetDisabledEventData(
      assetSymbol: assetSymbol,
      assetNetwork: assetNetwork,
      walletType: walletType,
    );
  }

  /// E14: Send flow started
  static SendInitiatedEventData sendInitiated({
    required String assetSymbol,
    required String network,
    required double amount,
    required String walletType,
  }) {
    return SendInitiatedEventData(
      assetSymbol: assetSymbol,
      network: network,
      amount: amount,
      walletType: walletType,
    );
  }

  /// E15: On-chain send completed
  static SendSucceededEventData sendSucceeded({
    required String assetSymbol,
    required String network,
    required double amount,
    required String walletType,
  }) {
    return SendSucceededEventData(
      assetSymbol: assetSymbol,
      network: network,
      amount: amount,
      walletType: walletType,
    );
  }

  /// E16: Send failed / cancelled
  static SendFailedEventData sendFailed({
    required String assetSymbol,
    required String network,
    required String failReason,
    required String walletType,
  }) {
    return SendFailedEventData(
      assetSymbol: assetSymbol,
      network: network,
      failReason: failReason,
      walletType: walletType,
    );
  }

  /// E17: Swap order submitted
  static SwapInitiatedEventData swapInitiated({
    required String fromAsset,
    required String toAsset,
    required String networks,
    required String walletType,
  }) {
    return SwapInitiatedEventData(
      fromAsset: fromAsset,
      toAsset: toAsset,
      networks: networks,
      walletType: walletType,
    );
  }

  /// E18: Atomic swap succeeded
  static SwapSucceededEventData swapSucceeded({
    required String fromAsset,
    required String toAsset,
    required double amount,
    required double fee,
    required String walletType,
  }) {
    return SwapSucceededEventData(
      fromAsset: fromAsset,
      toAsset: toAsset,
      amount: amount,
      fee: fee,
      walletType: walletType,
    );
  }

  /// E19: Swap failed
  static SwapFailedEventData swapFailed({
    required String fromAsset,
    required String toAsset,
    required String failStage,
    required String walletType,
  }) {
    return SwapFailedEventData(
      fromAsset: fromAsset,
      toAsset: toAsset,
      failStage: failStage,
      walletType: walletType,
    );
  }

  /// E38: Fresh receive address derived
  static HdAddressGeneratedEventData hdAddressGenerated({
    required int accountIndex,
    required int addressIndex,
    required String assetSymbol,
  }) {
    return HdAddressGeneratedEventData(
      accountIndex: accountIndex,
      addressIndex: addressIndex,
      assetSymbol: assetSymbol,
    );
  }

  /// E40: Time until the top of the coins list crosses 50% of viewport
  static WalletListHalfViewportReachedEventData walletListHalfViewportReached({
    required int timeToHalfMs,
    required int walletSize,
  }) {
    return WalletListHalfViewportReachedEventData(
      timeToHalfMs: timeToHalfMs,
      walletSize: walletSize,
    );
  }

  /// E41: Coins config refresh completed on launch
  static CoinsDataUpdatedEventData coinsDataUpdated({
    required int coinsCount,
    required String updateSource,
    required int updateDurationMs,
  }) {
    return CoinsDataUpdatedEventData(
      coinsCount: coinsCount,
      updateSource: updateSource,
      updateDurationMs: updateDurationMs,
    );
  }

  /// E44: Delay from page open until interactive (Loading logo hidden)
  static PageInteractiveDelayEventData pageInteractiveDelay({
    required String pageName,
    required int interactiveDelayMs,
    required int spinnerTimeMs,
  }) {
    return PageInteractiveDelayEventData(
      pageName: pageName,
      interactiveDelayMs: interactiveDelayMs,
      spinnerTimeMs: spinnerTimeMs,
    );
  }
}
