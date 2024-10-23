import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/shared/ui/ui_primary_button.dart';

class FaucetButton extends StatelessWidget {
  const FaucetButton({
    Key? key,
    required this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return UiPrimaryButton(
      key: const Key('coin-details-faucet-button'),
      height: isMobile ? 52 : 40,
      textStyle: themeData.textTheme.labelLarge
          ?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      backgroundColor: themeData.colorScheme.tertiary,
      text: LocaleKeys.faucet.tr(),
      prefix: const Padding(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.local_drink_rounded, color: Colors.blue),
      ),
      onPressed: !enabled ? null : onPressed,
    );
  }
}
