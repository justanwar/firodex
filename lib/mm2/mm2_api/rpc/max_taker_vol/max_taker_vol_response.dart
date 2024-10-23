class MaxTakerVolResponse {
  MaxTakerVolResponse({
    required this.coin,
    required this.result,
  });

  factory MaxTakerVolResponse.fromJson(Map<String, dynamic> json) =>
      MaxTakerVolResponse(
          coin: json['coin'] ?? '',
          result: MaxTakerVolumeResponseResult.fromJson(json['result']));
  final String coin;
  final MaxTakerVolumeResponseResult result;
}

class MaxTakerVolumeResponseResult {
  MaxTakerVolumeResponseResult({
    required this.numer,
    required this.denom,
  });
  factory MaxTakerVolumeResponseResult.fromJson(Map<String, dynamic> json) =>
      MaxTakerVolumeResponseResult(denom: json['denom'], numer: json['numer']);
  final String denom;
  final String numer;

  Map<String, String> toJson() => <String, String>{
        'denom': denom,
        'numer': numer,
      };
}
