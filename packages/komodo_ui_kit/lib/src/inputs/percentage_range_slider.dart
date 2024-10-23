import 'package:flutter/material.dart';
import 'package:komodo_ui_kit/src/inputs/range_slider_labelled.dart';

class PercentageRangeSlider extends StatelessWidget {
  const PercentageRangeSlider({
    super.key,
    required this.values,
    this.title,
    this.min = 0.0,
    this.max = 1.0,
    this.padding = const EdgeInsets.all(0),
    this.divisions,
    this.onChanged,
  });

  final Widget? title;
  final double min;
  final double max;
  final EdgeInsets padding;
  final int? divisions;
  final RangeValues values;
  final Function(RangeValues)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          if (title != null) title!,
          const SizedBox(height: 8),
          RangeSliderLabelled(
            values: values,
            divisions: divisions,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
