import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';

/// A reusable text form field widget with customizable validation modes.
///
/// This widget provides several validation modes to control when validation
/// errors are shown. It also allows customization of its appearance and behavior.
///
/// The supported validation modes are:
/// - `aggressive`: Validate on every input change.
/// - `passive`: Validate on focus loss and form submission.
/// - `lazy`: Validate only on form submission.
/// - `eager`: Validate on focus loss and subsequent input changes.
///
/// The `UiTextFormField` can be customized using various parameters such as
/// `hintText`, `controller`, `inputFormatters`, `textInputAction`, and more.
class UiTextFormField extends StatefulWidget {
  const UiTextFormField({
    super.key,
    this.initialValue,
    this.hintText,
    this.controller,
    this.inputFormatters,
    this.textInputAction,
    this.style,
    this.hintTextStyle,
    this.inputContentPadding,
    this.keyboardType,
    this.validator,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.errorMaxLines,
    this.enableInteractiveSelection = true,
    this.autocorrect = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.enabled = true,
    this.focusNode,
    this.onFocus,
    this.fillColor,
    this.onFieldSubmitted,
    this.onChanged,
    this.suffix,
    this.maxLength,
    this.maxLengthEnforcement,
    this.counterText,
    this.labelStyle,
    this.enabledBorder,
    this.focusedBorder,
    this.errorStyle,
    this.validationMode = InputValidationMode.eager,
  });

  final String? initialValue;
  final String? hintText;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final TextStyle? hintTextStyle;
  final TextStyle? labelStyle;
  final TextInputType? keyboardType;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? errorMaxLines;
  final bool obscureText;
  final bool autocorrect;
  final bool enabled;
  final bool enableInteractiveSelection;
  final bool autofocus;
  final bool readOnly;
  final EdgeInsets? inputContentPadding;
  final FocusNode? focusNode;
  final void Function(FocusNode)? onFocus;
  final Color? fillColor;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final String? counterText;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final TextStyle? errorStyle;
  final InputValidationMode validationMode;

  @override
  State<UiTextFormField> createState() => _UiTextFormFieldState();
}

class _UiTextFormFieldState extends State<UiTextFormField> {
  String? _hintText;
  String? _errorText;
  String? _displayedErrorText;
  FocusNode _focusNode = FocusNode();
  bool _hasFocusExitedOnce = false;
  bool _shouldValidate = false;

  @override
  void initState() {
    super.initState();
    _hintText = widget.hintText;
    _errorText = widget.errorText;
    _displayedErrorText = widget.errorText;

    if (_errorText?.isNotEmpty == true ||
        widget.validationMode == InputValidationMode.aggressive) {
      _hasFocusExitedOnce = true;
      _shouldValidate = true;
    }
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    }

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant UiTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _errorText = widget.errorText;
        _displayedErrorText = widget.errorText;
        if (_errorText?.isNotEmpty == true) {
          _hasFocusExitedOnce = true;
          _shouldValidate = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  /// Handles the focus change events.
  void _handleFocusChange() {
    setState(() {
      _hintText = _focusNode.hasFocus ? null : widget.hintText;
      if (widget.onFocus != null) {
        widget.onFocus!(_focusNode);
      }
      if (!_focusNode.hasFocus) {
        if (!_hasFocusExitedOnce) {
          _hasFocusExitedOnce = true;
        }
        if (widget.validationMode == InputValidationMode.eager ||
            widget.validationMode == InputValidationMode.lazy) {
          _shouldValidate = true;
          _performValidation();
        }
      }
      if (_focusNode.hasFocus &&
          widget.validationMode == InputValidationMode.aggressive) {
        _shouldValidate = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetStyle = widget.style;
    var style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
    if (widgetStyle != null) {
      style = style.merge(widgetStyle);
    }

    final TextStyle? hintTextStyle = Theme.of(context)
        .inputDecorationTheme
        .hintStyle
        ?.merge(widget.hintTextStyle);

    final TextStyle? labelStyle = Theme.of(context)
        .inputDecorationTheme
        .labelStyle
        ?.merge(widget.labelStyle);

    final TextStyle? errorStyle = Theme.of(context)
        .inputDecorationTheme
        .errorStyle
        ?.merge(widget.errorStyle);

    return TextFormField(
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      initialValue: widget.initialValue,
      controller: widget.controller,
      inputFormatters: widget.inputFormatters,
      validator: (value) => _performValidation(value),
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        if (_shouldValidate) {
          _performValidation(value);
        }
      },
      onFieldSubmitted: widget.onFieldSubmitted,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      textInputAction: widget.textInputAction,
      style: style,
      autovalidateMode: _shouldValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      focusNode: _focusNode,
      enabled: widget.enabled,
      decoration: InputDecoration(
        fillColor: widget.fillColor,
        hintText: _hintText,
        hintStyle: hintTextStyle,
        contentPadding: widget.inputContentPadding,
        counterText: widget.counterText,
        labelText: widget.hintText,
        labelStyle:
            _hintText != null && !_hasValue ? hintTextStyle : labelStyle,
        errorText: _displayedErrorText,
        errorStyle: errorStyle,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        errorMaxLines: widget.errorMaxLines,
        suffix: widget.suffix,
        enabledBorder: widget.enabledBorder,
        focusedBorder: widget.focusedBorder,
      ),
    );
  }

  /// Checks if the field has a value.
  bool get _hasValue =>
      (widget.controller?.text.isNotEmpty ?? false) ||
      (widget.initialValue?.isNotEmpty ?? false);

  /// Performs validation based on the validator function and updates error state.
  String? _performValidation([String? value]) {
    final error = widget.validator?.call(value ?? widget.controller?.text) ??
        widget.errorText;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _errorText = error;
          _displayedErrorText =
              _hasFocusExitedOnce || _focusNode.hasFocus ? _errorText : null;
        });
      }
    });
    return error;
  }
}
