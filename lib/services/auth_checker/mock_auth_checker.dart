import 'package:web_dex/services/auth_checker/auth_checker.dart';

class MockAuthChecker implements AuthChecker {
  @override
  Future<bool> askConfirmLoginIfNeeded(String? walletEncryptedSeed) async {
    return true;
  }

  @override
  void removeSession(String? walletEncryptedSeed) {}

  @override
  void addSession(String walletEncryptedSeed) {}
}
