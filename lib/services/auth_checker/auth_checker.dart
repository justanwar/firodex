abstract class AuthChecker {
  Future<bool> askConfirmLoginIfNeeded(String walletEncryptedSeed);
  void addSession(String walletEncryptedSeed);
  void removeSession(String walletEncryptedSeed);
}
