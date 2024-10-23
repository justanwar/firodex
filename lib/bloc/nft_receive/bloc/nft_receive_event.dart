part of 'nft_receive_bloc.dart';

abstract class NftReceiveEvent extends Equatable {
  const NftReceiveEvent();

  @override
  List<Object> get props => [];
}

class NftReceiveEventInitial extends NftReceiveEvent {
  final NftBlockchains chain;
  const NftReceiveEventInitial({required this.chain});

  @override
  List<Object> get props => [chain];
}

class NftReceiveEventRefresh extends NftReceiveEvent {
  const NftReceiveEventRefresh();

  @override
  List<Object> get props => [];
}

class NftReceiveEventChangedAddress extends NftReceiveEvent {
  final String? address;
  const NftReceiveEventChangedAddress({required this.address});

  @override
  List<Object> get props => [address ?? ''];
}
