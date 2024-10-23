enum InitTrezorStatus {
  ok,
  inProgress,
  userActionRequired,
  error,
  unknown;

  static InitTrezorStatus fromJson(String json) {
    switch (json) {
      case 'Ok':
        return InitTrezorStatus.ok;
      case 'InProgress':
        return InitTrezorStatus.inProgress;
      case 'UserActionRequired':
        return InitTrezorStatus.userActionRequired;
      case 'Error':
        return InitTrezorStatus.error;
      default:
        return InitTrezorStatus.unknown;
    }
  }
}
