import 'package:flutter/foundation.dart';

class Electrum {
  Electrum({
    required this.url,
    required this.protocol,
    required this.disableCertVerification,
  });

  factory Electrum.fromJson(Map<String, dynamic> json) {
    return Electrum(
      url: kIsWeb ? json['ws_url'] : json['url'],
      protocol: kIsWeb ? 'WSS' : (json['protocol'] ?? 'TCP'),
      disableCertVerification: json['disable_cert_verification'] ?? false,
    );
  }

  final String url;
  final String protocol;
  final bool disableCertVerification;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'protocol': protocol,
      'disable_cert_verification': disableCertVerification,
    };
  }
}
