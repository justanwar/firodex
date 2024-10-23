import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';

class CoinsListHeader extends StatelessWidget {
  const CoinsListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isMobile
        ? const _CoinsListHeaderMobile()
        : const _CoinsListHeaderDesktop();
  }
}

class _CoinsListHeaderDesktop extends StatelessWidget {
  const _CoinsListHeaderDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 16, 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(LocaleKeys.asset.tr(), style: style),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(LocaleKeys.balance.tr(), style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(LocaleKeys.change24hRevert.tr(), style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(LocaleKeys.price.tr(), style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(LocaleKeys.trend.tr(), style: style),
          ),
        ],
      ),
    );
  }
}

class _CoinsListHeaderMobile extends StatelessWidget {
  const _CoinsListHeaderMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
