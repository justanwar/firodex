import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/views/wallet/coin_details/coin_details_info/address_select.dart';
import 'package:web_dex/views/wallet/coin_details/receive/request_address_button.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';

class ReceiveAddressTrezor extends StatelessWidget {
  const ReceiveAddressTrezor({
    Key? key,
    required this.coin,
    required this.onChanged,
    required this.selectedAddress,
  }) : super(key: key);

  final Coin coin;
  final Function(String) onChanged;
  final String? selectedAddress;

  @override
  Widget build(BuildContext context) {
    final String? selectedAddress = this.selectedAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedAddress == null)
          Text(
            LocaleKeys.trezorNoAddresses.tr(),
            style: theme.currentGlobal.textTheme.bodySmall,
          )
        else
          Row(
            children: [
              Flexible(
                child: _BuildSelect(
                  key: Key('trezor-receive-select-${coin.abbr}'),
                  coin: coin,
                  address: selectedAddress,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 4),
              _buildCopyButton(context)
            ],
          ),
        _buildRequestButton(),
      ],
    );
  }

  Widget _buildRequestButton() {
    return RequestAddressButton(
      coin,
      onSuccess: (String newAddress) {
        onChanged(newAddress);
      },
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          copyToClipBoard(context, selectedAddress!);
        },
        borderRadius: BorderRadius.circular(20),
        child: UiTooltip(
          message: LocaleKeys.copyToClipboard.tr(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.copy,
              size: 16,
              color: theme.currentGlobal.textTheme.bodySmall?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildSelect extends StatefulWidget {
  const _BuildSelect({
    super.key,
    required this.coin,
    required this.address,
    required this.onChanged,
  });

  final Coin coin;
  final String address;
  final Function(String) onChanged;

  @override
  State<_BuildSelect> createState() => __BuildSelectState();
}

class __BuildSelectState extends State<_BuildSelect> {
  final GlobalKey _globalKey = GlobalKey();
  RenderBox? _renderBox;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _renderBox = _globalKey.currentContext?.findRenderObject() as RenderBox;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _globalKey,
      child: AddressSelect(
        coin: widget.coin,
        addresses: widget.coin.accounts?.first.addresses,
        selectedAddress: widget.address,
        onChanged: widget.onChanged,
        maxHeight: 200,
        maxWidth: _renderBox?.size.width,
      ),
    );
  }
}
