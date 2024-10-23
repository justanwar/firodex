import 'package:web_dex/mm2/mm2_api/rpc/base.dart';

class ConvertAddressRequest implements BaseRequest {
  ConvertAddressRequest({
    required this.from,
    required this.coin,
    required this.isErc,
  });

  @override
  final String method = 'convertaddress';
  @override
  late String userpass;

  final String from;
  final String coin;
  final bool isErc;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
      'from': from,
      'coin': coin,
      'to_address_format': {
        'format': isErc ? 'mixedcase' : 'cashaddress',
        if (coin == 'BCH') 'network': 'bitcoincash',
      }
    };
  }
}
