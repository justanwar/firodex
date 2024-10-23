part of 'nft_main_bloc.dart';

abstract class NftMainEvent {
  const NftMainEvent();
}

class UpdateChainNftsEvent extends NftMainEvent {
  const UpdateChainNftsEvent();
}

class StopUpdateNftEvent extends NftMainEvent {
  const StopUpdateNftEvent();
}

class StartUpdateNftsEvent extends NftMainEvent {
  const StartUpdateNftsEvent();
}

class ResetNftPageEvent extends NftMainEvent {
  const ResetNftPageEvent();
}

class ChangeNftTabEvent extends NftMainEvent {
  const ChangeNftTabEvent(this.chain);
  final NftBlockchains chain;
}

class RefreshNFTsForChainEvent extends NftMainEvent {
  const RefreshNFTsForChainEvent(this.chain);
  final NftBlockchains chain;
}
