import 'package:flutter/material.dart';

class DividedButton extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? childPadding;
  final VoidCallback? onPressed;

  const DividedButton({
    required this.children,
    this.childPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style:
          (Theme.of(context).segmentedButtonTheme.style ?? const ButtonStyle())
              .copyWith(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.labelMedium,
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context)
                  .segmentedButtonTheme
                  .style
                  ?.backgroundColor
                  ?.resolve({WidgetState.focused}) ??
              Theme.of(context).colorScheme.surface,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            Padding(
              padding: childPadding!,
              child: children[i],
            ),
            if (i < children.length - 1)
              const SizedBox(
                height: 32,
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  indent: 2,
                  endIndent: 2,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
