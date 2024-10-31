import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/views/common/page_header/back_button_desktop.dart';
import 'package:web_dex/views/common/page_header/back_button_mobile.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.onBackButtonPressed,
    this.backText,
    this.actions,
    this.widgetTitle,
  });

  final String title;
  final VoidCallback? onBackButtonPressed;
  final String? backText;
  final List<Widget>? actions;
  final Widget? widgetTitle;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _MobileHeader(
        onBackButtonPressed: onBackButtonPressed,
        title: title,
        actions: actions,
        widgetTitle: widgetTitle,
      );
    }
    return _DesktopHeader(
      onBackButtonPressed: onBackButtonPressed,
      title: title,
      backText: backText,
      actions: actions,
      widgetTitle: widgetTitle,
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({
    required this.onBackButtonPressed,
    required this.title,
    this.actions,
    this.widgetTitle,
  });

  final String title;
  final VoidCallback? onBackButtonPressed;
  final List<Widget>? actions;
  final Widget? widgetTitle;

  @override
  Widget build(BuildContext context) {
    final Widget? widget = widgetTitle;
    return AppBar(
      elevation: 0,
      backgroundColor: theme.custom.noColor,
      leadingWidth: 30,
      leading: onBackButtonPressed == null
          ? null
          : BackButtonMobile(onPressed: onBackButtonPressed!),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
          ),
          if (widget != null) widget,
        ],
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({
    required this.title,
    this.onBackButtonPressed,
    this.backText,
    this.actions,
    this.widgetTitle,
  });

  final String title;
  final VoidCallback? onBackButtonPressed;
  final String? backText;
  final List<Widget>? actions;
  final Widget? widgetTitle;

  @override
  Widget build(BuildContext context) {
    final widget = widgetTitle;
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            onBackButtonPressed == null
                ? const SizedBox()
                : BackButtonDesktop(
                    text: backText ?? '',
                    onPressed: onBackButtonPressed!,
                  ),
            if (actions != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
          ],
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
                if (widget != null) widget,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
