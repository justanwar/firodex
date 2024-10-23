enum TrezorProgressStatus {
  initializing,
  waitingForTrezorToConnect,
  waitingForUserToConfirmPubkey,
  waitingForUserToConfirmSigning,
  followHwDeviceInstructions,
  unknown;

  static TrezorProgressStatus fromJson(String json) {
    switch (json) {
      case 'Initializing':
        return TrezorProgressStatus.initializing;
      case 'WaitingForTrezorToConnect':
        return TrezorProgressStatus.waitingForTrezorToConnect;
      case 'WaitingForUserToConfirmPubkey':
        return TrezorProgressStatus.waitingForUserToConfirmPubkey;
      case 'WaitingForUserToConfirmSigning':
        return TrezorProgressStatus.waitingForUserToConfirmSigning;
      case 'FollowHwDeviceInstructions':
        return TrezorProgressStatus.followHwDeviceInstructions;
      default:
        return TrezorProgressStatus.unknown;
    }
  }
}
