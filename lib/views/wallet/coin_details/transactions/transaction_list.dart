import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/mm2/mm2_api/rpc/my_tx_history/transaction.dart';
import 'package:web_dex/views/wallet/coin_details/transactions/transaction_list_item.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({
    Key? key,
    required this.transactions,
    required this.isInProgress,
    required this.setTransaction,
    required this.coinAbbr,
  }) : super(key: key);
  final List<Transaction> transactions;
  final String coinAbbr;
  final bool isInProgress;
  final void Function(Transaction tx) setTransaction;

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
        ? const _EmptyList()
        : _List(
            transactions: transactions,
            isInProgress: isInProgress,
            coinAbbr: coinAbbr,
            setTransaction: setTransaction,
          );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.transactions,
    required this.isInProgress,
    required this.setTransaction,
    required this.coinAbbr,
  });
  final List<Transaction> transactions;
  final String coinAbbr;
  final bool isInProgress;
  final void Function(Transaction tx) setTransaction;

  @override
  Widget build(BuildContext context) {
    final hasTitle = transactions.isNotEmpty || !isMobile;
    final indexOffset = hasTitle ? 1 : 0;

    return SliverList(
      key: const Key('coin-details-transaction-list'),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                LocaleKeys.history.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            );
          }

          final adjustedIndex = index - indexOffset;

          if (adjustedIndex + 1 == transactions.length && isInProgress) {
            return const UiSpinnerList(height: 50);
          }

          final Transaction tx = transactions[adjustedIndex];
          return TransactionListRow(
            transaction: tx,
            coinAbbr: coinAbbr,
            setTransaction: setTransaction,
          );
        },
        childCount: transactions.length + indexOffset,
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context) {
    final double verticalPadding = isMobile ? 50 : 70;
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: verticalPadding),
          Text(
            LocaleKeys.noTransactionsTitle.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: isMobile ? 14 : 18,
                  color: theme.custom.noTransactionsTextColor,
                ),
          ),
          Text(
            LocaleKeys.noTransactionsDescription.tr(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: isMobile ? 12 : 14,
                  color: theme.custom.noTransactionsTextColor,
                ),
          ),
          SizedBox(height: verticalPadding),
        ],
      ),
    );
  }
}
