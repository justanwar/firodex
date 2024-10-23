import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/dispatchers/popup_dispatcher.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/wallet.dart';
import 'package:web_dex/shared/widgets/auto_scroll_text.dart';

class SettingsResetActivatedCoins extends StatefulWidget {
  const SettingsResetActivatedCoins({Key? key}) : super(key: key);

  @override
  State<SettingsResetActivatedCoins> createState() =>
      _SettingsResetActivatedCoinsState();
}

class _SettingsResetActivatedCoinsState
    extends State<SettingsResetActivatedCoins> {
  @override
  Widget build(BuildContext context) {
    return UiBorderButton(
      height: 32,
      borderWidth: 1,
      borderColor: theme.custom.specificButtonBorderColor,
      backgroundColor: theme.custom.specificButtonBackgroundColor,
      fontWeight: FontWeight.w500,
      text: LocaleKeys.debugSettingsResetActivatedCoins.tr(),
      icon: Icon(
        Icons.restart_alt,
        color: Theme.of(context).textTheme.bodyMedium?.color,
        size: 18,
      ),
      onPressed: _showResetPopup,
    );
  }

  void _showResetPopup() async {
    await walletsBloc.fetchSavedWallets();
    PopupDispatcher popupDispatcher = _createPopupDispatcher();
    popupDispatcher.show();
  }

  PopupDispatcher _createPopupDispatcher() {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return PopupDispatcher(
      borderColor: theme.custom.specificButtonBorderColor,
      barrierColor: isMobile ? Theme.of(context).colorScheme.onSurface : null,
      width: 320,
      popupContent: walletsBloc.wallets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  LocaleKeys.noWalletsAvailable.tr(),
                  style: textStyle,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(children: [
                Text(
                  LocaleKeys.selectWalletToReset.tr(),
                  style: textStyle,
                ),
                const SizedBox(height: 8),
                ...List.generate(walletsBloc.wallets.length, (index) {
                  return ListTile(
                    title: AutoScrollText(
                      text: walletsBloc.wallets[index].name,
                      style: textStyle,
                    ),
                    onTap: () =>
                        _showConfirmationDialog(walletsBloc.wallets[index]),
                  );
                }),
              ]),
            ),
    );
  }

  Future<void> _showConfirmationDialog(Wallet wallet) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.resetWalletTitle.tr()),
        content: SizedBox(
          width: 500,
          child: Text(
            LocaleKeys.resetWalletContent.tr(args: [wallet.name]),
          ),
        ),
        actions: [
          TextButton(
            child: Text(LocaleKeys.cancel.tr()),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          TextButton(
            child: Text(LocaleKeys.reset.tr()),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (result == true) {
      await _resetSpecificWallet(wallet);
    }
  }

  Future<void> _resetSpecificWallet(Wallet wallet) async {
    await walletsBloc.resetSpecificWallet(wallet);

    if (!mounted) return;

    // Show Dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.resetCompleteTitle.tr()),
        content: Text(LocaleKeys.resetCompleteContent.tr(args: [wallet.name])),
        actions: [
          TextButton(
            child: Text(LocaleKeys.ok.tr()),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}
