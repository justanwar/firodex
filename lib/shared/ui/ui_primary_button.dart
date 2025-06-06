import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';

@Deprecated('Use UiPrimaryButton from komodo_ui_kit instead')
class UiPrimaryButton extends StatelessWidget {
  @Deprecated('Use UiPrimaryButton from komodo_ui_kit instead')
  const UiPrimaryButton({
    Key? key,
    this.buttonKey,
    this.text = '',
    this.width = double.infinity,
    this.height = 48.0,
    this.backgroundColor,
    this.textStyle,
    this.prefix,
    this.border,
    required this.onPressed,
    this.focusNode,
    this.shadowColor,
    this.child,
  }) : super(key: key);

  final String text;
  final TextStyle? textStyle;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Widget? prefix;
  final Key? buttonKey;
  final BoxBorder? border;
  final void Function()? onPressed;
  final FocusNode? focusNode;
  final Color? shadowColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: onPressed == null,
      child: Opacity(
        opacity: onPressed == null ? 0.4 : 1,
        child: Container(
          constraints: BoxConstraints.tightFor(width: width, height: height),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            border: border,
          ),
          child: _Button(
            focusNode: focusNode,
            onPressed: onPressed,
            buttonKey: buttonKey,
            shadowColor: shadowColor,
            backgroundColor: backgroundColor,
            text: text,
            textStyle: textStyle,
            prefix: prefix,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Button extends StatefulWidget {
  final FocusNode? focusNode;
  final void Function()? onPressed;
  final Key? buttonKey;
  final Color? shadowColor;
  final Color? backgroundColor;
  final Widget? child;
  final String text;
  final TextStyle? textStyle;
  final Widget? prefix;
  const _Button({
    Key? key,
    this.focusNode,
    this.onPressed,
    this.buttonKey,
    this.shadowColor,
    this.backgroundColor,
    this.child,
    required this.text,
    this.textStyle,
    this.prefix,
  }) : super(key: key);

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  bool _hasFocus = false;

  _ButtonState();
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      focusNode: widget.focusNode,
      onFocusChange: (value) {
        setState(() {
          _hasFocus = value;
        });
      },
      onPressed: widget.onPressed ?? () {},
      key: widget.buttonKey,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        shadowColor: _hasFocus
            ? widget.shadowColor ?? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        elevation: 1,
        backgroundColor: _backgroundColor,
        foregroundColor:
            ThemeData.estimateBrightnessForColor(_backgroundColor) ==
                    Brightness.dark
                ? theme.global.light.colorScheme.onSurface
                : Theme.of(context).colorScheme.secondary,
      ),
      child: widget.child ??
          _ButtonChild(
            text: widget.text,
            textStyle: widget.textStyle,
            prefix: widget.prefix,
          ),
    );
  }

  Color get _backgroundColor {
    return widget.backgroundColor ?? Theme.of(context).colorScheme.primary;
  }
}

class _ButtonChild extends StatelessWidget {
  final Widget? prefix;
  final String text;
  final TextStyle? textStyle;
  const _ButtonChild({
    Key? key,
    required this.text,
    this.prefix,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: theme.custom.defaultGradientButtonTextColor,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefix != null) prefix!,
        Text(text, style: textStyle ?? textStyle),
      ],
    );
  }
}
