import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';

class FiatPaymentMethod extends StatefulWidget {
  final String? fiatAmount;
  final Map<String, dynamic> paymentMethodData;
  final Map<String, dynamic>? selectedPaymentMethod;
  final Function(Map<String, dynamic>) onSelect;

  const FiatPaymentMethod({
    required this.fiatAmount,
    required this.paymentMethodData,
    required this.selectedPaymentMethod,
    required this.onSelect,
    super.key,
  });

  @override
  FiatPaymentMethodState createState() => FiatPaymentMethodState();
}

class FiatPaymentMethodState extends State<FiatPaymentMethod> {
  @override
  Widget build(BuildContext context) {
    bool isSelected = widget.selectedPaymentMethod != null &&
        widget.selectedPaymentMethod!['id'] == widget.paymentMethodData['id'];

    final priceInfo = widget.paymentMethodData['price_info'];

    final relativePercent =
        widget.paymentMethodData['relative_percent'] as double?;

    final isBestOffer = relativePercent == null;

    return InkWell(
      onTap: () {
        widget.onSelect(widget.paymentMethodData);
      },
      borderRadius: BorderRadius.circular(8),
      child: Card(
        margin: const EdgeInsets.all(0),
        color: Theme.of(context).colorScheme.onSurface,
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: Theme.of(context)
                  .primaryColor
                  .withOpacity(isSelected ? 1 : 0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 32, child: providerLogo),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.paymentMethodData['name']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.paymentMethodData['provider_id'],
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (priceInfo != null)
                  isBestOffer
                      ? Chip(
                          label: Text(LocaleKeys.bestOffer.tr()),
                          backgroundColor: Colors.green,
                        )
                      : Text(
                          '${(relativePercent * 100).toStringAsFixed(2)}%',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get providerLogo {
    final assetPath =
        widget.paymentMethodData['provider_icon_asset_path'] as String;

    //TODO: Additional validation that the asset exists

    return SvgPicture.asset(assetPath, fit: BoxFit.contain);
  }
}
