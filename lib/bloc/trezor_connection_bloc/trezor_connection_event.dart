import 'package:web_dex/model/hw_wallet/trezor_connection_status.dart';

abstract class TrezorConnectionEvent {
  const TrezorConnectionEvent();
}

class TrezorConnectionStatusChange extends TrezorConnectionEvent {
  const TrezorConnectionStatusChange({required this.status});
  final TrezorConnectionStatus status;
}
