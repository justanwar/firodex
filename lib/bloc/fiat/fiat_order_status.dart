// TODO: Differentiate between different error and in-progress statuses
enum FiatOrderStatus {
  /// User has not yet started the payment process
  pending,

  /// Payment has been submitted and is being processed
  inProgress,

  /// Payment has been completed successfully
  success,

  /// Payment has been cancelled, declined, expired or refunded
  failed;

  bool get isTerminal =>
      this == FiatOrderStatus.success || this == FiatOrderStatus.failed;
}
