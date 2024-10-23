import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/nft_receive/bloc/nft_receive_bloc.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/router/state/routing_state.dart';
import 'package:web_dex/views/common/page_header/page_header.dart';
import 'package:web_dex/views/nfts/nft_receive/common/nft_failure_page.dart';
import 'package:web_dex/views/nfts/nft_receive/desktop/nft_receive_desktop_view.dart';
import 'package:web_dex/views/nfts/nft_receive/mobile/nft_receive_mobile_view.dart';
import 'package:web_dex/views/settings/widgets/security_settings/seed_settings/backup_seed_notification.dart';

class NftReceiveView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return Stack(
      children: [
        SizedBox(
          height: 50,
          width: double.maxFinite,
          child: PageHeader(
            title: '',
            backText: LocaleKeys.collectibles.tr(),
            onBackButtonPressed: routingState.nftsState.reset,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: DexScrollbar(
            scrollController: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: BlocBuilder<NftReceiveBloc, NftReceiveState>(
                  builder: (context, state) {
                if (state is NftReceiveInitial) {
                  return const Center(child: UiSpinner());
                } else if (state is NftReceiveHasBackup) {
                  return const BackupNotification();
                } else if (state is NftReceiveFailure) {
                  return NftReceiveFailurePage(
                    message: state.message ??
                        LocaleKeys.pleaseTryActivateAssets.tr(),
                    onReload: () {
                      context
                          .read<NftReceiveBloc>()
                          .add(const NftReceiveEventRefresh());
                    },
                  );
                } else if (state is NftReceiveAddress) {
                  return isMobile
                      ? NftReceiveMobileView(
                          coin: state.coin,
                          currentAddress: state.address,
                          onAddressChanged: (value) => context
                              .read<NftReceiveBloc>()
                              .add(
                                NftReceiveEventChangedAddress(address: value),
                              ),
                        )
                      : NftReceiveDesktopView(
                          coin: state.coin,
                          currentAddress: state.address,
                          onAddressChanged: (value) => context
                              .read<NftReceiveBloc>()
                              .add(
                                NftReceiveEventChangedAddress(address: value),
                              ),
                        );
                }
                return const SizedBox();
              }),
            ),
          ),
        ),
      ],
    );
  }
}
