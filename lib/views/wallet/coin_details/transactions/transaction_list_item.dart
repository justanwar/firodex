import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/transaction.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/ui/custom_tooltip.dart';
import 'package:web_dex/shared/utils/formatters.dart';

class TransactionListRow extends StatefulWidget {
  const TransactionListRow({
    Key? key,
    required this.transaction,
    required this.setTransaction,
    required this.coinAbbr,
  }) : super(key: key);

  final Transaction transaction;
  final String coinAbbr;
  final void Function(Transaction tx) setTransaction;

  @override
  State<TransactionListRow> createState() => _TransactionListRowState();
}

class _TransactionListRowState extends State<TransactionListRow> {
  IconData get _icon {
    return _isReceived ? Icons.arrow_circle_down : Icons.arrow_circle_up;
  }

  bool get _isReceived => widget.transaction.isReceived;

  String get _sign {
    return _isReceived ? '+' : '-';
  }

  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onFocusChange: (value) {
          setState(() {
            _hasFocus = value;
          });
        },
        hoverColor: Theme.of(context).primaryColor.withAlpha(20),
        child: Container(
            color: _hasFocus
                ? Theme.of(context).colorScheme.tertiary
                : Colors.transparent,
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: isMobile
                ? const EdgeInsets.fromLTRB(0, 12, 0, 12)
                : const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child:
                isMobile ? _buildMobileRow(context) : _buildNormalRow(context)),
        onTap: () => widget.setTransaction(widget.transaction),
      ),
    );
  }

  Widget _buildAmountChangesMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildUsdChanges(),
        _buildBalanceMobile(),
      ],
    );
  }

  Widget _buildBalanceChanges() {
    final String formatted =
        formatDexAmt(double.parse(widget.transaction.myBalanceChange).abs());

    return Row(
      children: [
        Icon(
          _icon,
          size: 16,
          color: _isReceived
              ? theme.custom.increaseColor
              : theme.custom.decreaseColor,
        ),
        const SizedBox(width: 4),
        Text(
          '${Coin.normalizeAbbr(widget.transaction.coin)} $formatted',
          style: TextStyle(
              color: _isReceived
                  ? theme.custom.increaseColor
                  : theme.custom.decreaseColor,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBalanceChangesMobile(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isReceived ? LocaleKeys.receive.tr() : LocaleKeys.send.tr(),
              style: TextStyle(
                  color: _isReceived
                      ? theme.custom.increaseColor
                      : theme.custom.decreaseColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              widget.transaction.formattedTime,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildBalanceMobile() {
    final String formatted =
        formatDexAmt(double.parse(widget.transaction.myBalanceChange).abs());

    return Text(
      '${Coin.normalizeAbbr(widget.transaction.coin)} $formatted',
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildMemoAndDate() {
    return Align(
      alignment: isMobile ? const Alignment(-1, 0) : const Alignment(1, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildMemo(),
          const SizedBox(width: 6),
          Text(
            widget.transaction.formattedTime,
            style: isMobile
                ? TextStyle(color: Colors.grey[400])
                : const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Icon(
                _isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                color: _isReceived
                    ? theme.custom.increaseColor
                    : theme.custom.decreaseColor,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceChangesMobile(context),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Align(
              alignment: const Alignment(1, 0),
              child: _buildAmountChangesMobile(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(width: 4),
        Expanded(
            flex: 4,
            child: Text(
              _isReceived ? LocaleKeys.receive.tr() : LocaleKeys.send.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            )),
        Expanded(flex: 4, child: _buildBalanceChanges()),
        Expanded(flex: 4, child: _buildUsdChanges()),
        Expanded(flex: 3, child: _buildMemoAndDate()),
      ],
    );
  }

  Widget _buildMemo() {
    final String? memo = widget.transaction.memo;
    if (memo == null || memo.isEmpty) return const SizedBox();

    return CustomTooltip(
        maxWidth: 200,
        tooltip: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${LocaleKeys.memo.tr()}:',
              style: theme.currentGlobal.textTheme.bodyLarge,
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Text(
                  memo,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
        child: Icon(
          Icons.note,
          size: 14,
          color: theme.currentGlobal.colorScheme.onSurface,
        ));
  }

  Widget _buildUsdChanges() {
    final double? usdChanges = coinsBloc.getUsdPriceByAmount(
      widget.transaction.myBalanceChange,
      widget.coinAbbr,
    );
    return Text(
      '$_sign \$${formatAmt((usdChanges ?? 0).abs())}',
      style: TextStyle(
          color: _isReceived
              ? theme.custom.increaseColor
              : theme.custom.decreaseColor,
          fontSize: 14,
          fontWeight: FontWeight.w500),
    );
  }
}
