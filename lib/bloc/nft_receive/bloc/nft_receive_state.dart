part of 'nft_receive_bloc.dart';

abstract class NftReceiveState extends Equatable {
  const NftReceiveState();

  @override
  List<Object> get props => [];
}

class NftReceiveInitial extends NftReceiveState {}

class NftReceiveHasBackup extends NftReceiveState {}

class NftReceiveAddress extends NftReceiveState {
  final Coin coin;
  final String? address;

  const NftReceiveAddress({
    required this.coin,
    required this.address,
  });

  NftReceiveAddress copyWith({
    Coin? coin,
    String? address,
  }) {
    return NftReceiveAddress(
      coin: coin ?? this.coin,
      address: address ?? this.address,
    );
  }

  @override
  List<Object> get props => [address ?? '', coin];
}

class NftReceiveFailure extends NftReceiveState {
  final String? message;

  const NftReceiveFailure({this.message});
}
