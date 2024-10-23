import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/3p_api/faucet/faucet_response.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/views/common/page_header/page_header.dart';
import 'package:web_dex/views/common/pages/page_layout.dart';
import 'package:web_dex/views/wallet/coin_details/faucet/cubit/faucet_cubit.dart';
import 'package:web_dex/views/wallet/coin_details/faucet/cubit/faucet_state.dart';
import 'package:web_dex/views/wallet/coin_details/faucet/widgets/faucet_message.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';

class FaucetView extends StatelessWidget {
  const FaucetView({Key? key, required this.onBackButtonPressed})
      : super(key: key);

  final VoidCallback onBackButtonPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaucetCubit, FaucetState>(
      builder: (context, state) {
        if (state is FaucetInitial) {
          context.read<FaucetCubit>().callFaucet();
        }
        final scrollController = ScrollController();
        return PageLayout(
          header: PageHeader(
            title: title(state),
            backText: LocaleKeys.backToWallet.tr(),
            onBackButtonPressed: onBackButtonPressed,
          ),
          content: Flexible(
            child: DexScrollbar(
              scrollController: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: _StatesOfPage(
                  state: state,
                  onBackButtonPressed: onBackButtonPressed,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String title(FaucetState state) {
    if (state is FaucetSuccess) {
      return state.response.status.title;
    } else if (state is FaucetError) {
      return LocaleKeys.faucetFailureTitle.tr();
    } else if (state is FaucetLoading) {
      return LocaleKeys.faucetLoadingTitle.tr();
    } else if (state is FaucetInitial) {
      return LocaleKeys.faucetInitialTitle.tr();
    }
    return LocaleKeys.faucetFailureTitle.tr();
  }
}

class _StatesOfPage extends StatelessWidget {
  final FaucetState state;
  final VoidCallback onBackButtonPressed;
  const _StatesOfPage({required this.state, required this.onBackButtonPressed});

  @override
  Widget build(BuildContext context) {
    final localState = state;
    if (localState is FaucetLoading || localState is FaucetInitial) {
      return const _Loading();
    } else if (localState is FaucetSuccess) {
      final bool isDenied = localState.response.status == FaucetStatus.denied;
      return _FaucetResult(
        color: isDenied
            ? theme.custom.decreaseColor
            : theme.custom.headerFloatBoxColor,
        icon: isDenied ? Icons.close_rounded : Icons.check_rounded,
        message: localState.response.message,
        onBackButtonPressed: onBackButtonPressed,
      );
    } else if (localState is FaucetError) {
      return _FaucetResult(
        color: theme.custom.decreaseColor,
        icon: Icons.close_rounded,
        message: localState.message,
        onBackButtonPressed: onBackButtonPressed,
      );
    }

    return const SizedBox();
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 28),
        Center(child: UiSpinner()),
        SizedBox(height: 28),
      ],
    );
  }
}

class _FaucetResult extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;
  final VoidCallback onBackButtonPressed;

  const _FaucetResult({
    Key? key,
    required this.color,
    required this.icon,
    required this.message,
    required this.onBackButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 15.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: color, width: 4)),
            child: Icon(icon, size: 66, color: color),
          ),
        ),
        const SizedBox(height: 12),
        FaucetMessage(message),
        const SizedBox(height: 20),
        Center(
          child: UiPrimaryButton(
            text: LocaleKeys.close.tr(),
            width: 324,
            onPressed: onBackButtonPressed,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
