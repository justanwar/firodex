import 'package:flutter/material.dart';

class TrendPercentageText extends StatelessWidget {
  const TrendPercentageText({
    super.key,
    required this.investmentReturnPercentage,
  });

  final double investmentReturnPercentage;

  @override
  Widget build(BuildContext context) {
    final iconTextColor = investmentReturnPercentage > 0
        ? Colors.green
        : investmentReturnPercentage == 0
            ? Theme.of(context).disabledColor
            : Theme.of(context).colorScheme.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          investmentReturnPercentage > 0
              ? Icons.trending_up
              : (investmentReturnPercentage == 0)
                  ? Icons.trending_flat
                  : Icons.trending_down,
          color: iconTextColor,
        ),
        const SizedBox(width: 2),
        Text(
          '${(investmentReturnPercentage).toStringAsFixed(2)}%',
          style: (Theme.of(context).textTheme.bodyLarge ??
                  const TextStyle(
                    fontSize: 12,
                  ))
              .copyWith(color: iconTextColor),
        ),
      ],
    );
  }
}
