import 'package:web_dex/model/authorize_mode.dart';
import 'package:web_dex/model/hw_wallet/init_trezor.dart';

abstract class TrezorInitEvent {
  const TrezorInitEvent();
}

class TrezorInitUpdateAuthMode extends TrezorInitEvent {
  const TrezorInitUpdateAuthMode(this.authMode);
  final AuthorizeMode authMode;
}

class TrezorInit extends TrezorInitEvent {
  const TrezorInit();
}

class TrezorInitReset extends TrezorInitEvent {
  const TrezorInitReset();
}

class TrezorInitSubscribeStatus extends TrezorInitEvent {
  const TrezorInitSubscribeStatus();
}

class TrezorInitUpdateStatus extends TrezorInitEvent {
  const TrezorInitUpdateStatus();
}

class TrezorInitSuccess extends TrezorInitEvent {
  const TrezorInitSuccess(this.details);

  final TrezorDeviceDetails details;
}

class TrezorInitSendPin extends TrezorInitEvent {
  const TrezorInitSendPin(this.pin);
  final String pin;
}

class TrezorInitSendPassphrase extends TrezorInitEvent {
  const TrezorInitSendPassphrase(this.passphrase);
  final String passphrase;
}
