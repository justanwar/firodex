import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:web_dex/dispatchers/popup_dispatcher.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';

import 'package:web_dex/shared/widgets/disclaimer/disclaimer.dart';
import 'package:web_dex/shared/widgets/disclaimer/eula.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';

class EulaTosCheckboxes extends StatefulWidget {
  const EulaTosCheckboxes(
      {Key? key, this.isChecked = false, required this.onCheck})
      : super(key: key);

  final bool isChecked;
  final void Function(bool) onCheck;

  @override
  State<EulaTosCheckboxes> createState() => _EulaTosCheckboxesState();
}

class _EulaTosCheckboxesState extends State<EulaTosCheckboxes> {
  bool _checkBoxEULA = false;
  bool _checkBoxTOC = false;
  PopupDispatcher? _eulaPopupManager;
  PopupDispatcher? _disclaimerPopupManager;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UiCheckbox(
              checkboxKey: const Key('checkbox-eula'),
              value: _checkBoxEULA,
              onChanged: (bool? value) {
                setState(() {
                  _checkBoxEULA = !_checkBoxEULA;
                });
                _onCheck();
              },
            ),
            const SizedBox(width: 5),
            Text(LocaleKeys.accept.tr(), style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            InkWell(
              onTap: _showEula,
              child: Text(LocaleKeys.disclaimerAcceptEulaCheckbox.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      decoration: TextDecoration.underline)),
            )
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            UiCheckbox(
              checkboxKey: const Key('checkbox-toc'),
              value: _checkBoxTOC,
              onChanged: (bool? value) {
                setState(() {
                  _checkBoxTOC = !_checkBoxTOC;
                  _onCheck();
                });
              },
            ),
            const SizedBox(width: 5),
            Text(LocaleKeys.accept.tr(), style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            InkWell(
              onTap: _showDisclaimer,
              child: Text(
                  LocaleKeys.disclaimerAcceptTermsAndConditionsCheckbox.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      decoration: TextDecoration.underline)),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          LocaleKeys.disclaimerAcceptDescription.tr(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  void initState() {
    _checkBoxEULA = widget.isChecked;
    _checkBoxTOC = widget.isChecked;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _disclaimerPopupManager = PopupDispatcher(
          context: context,
          popupContent: Disclaimer(
            onClose: () {
              _disclaimerPopupManager?.close();
            },
          ));
      _eulaPopupManager = PopupDispatcher(
          context: context,
          popupContent: Eula(
            onClose: () {
              _eulaPopupManager?.close();
            },
          ));
    });
    super.initState();
  }

  void _onCheck() {
    widget.onCheck(_checkBoxEULA && _checkBoxTOC);
  }

  void _showDisclaimer() {
    _disclaimerPopupManager?.show();
  }

  void _showEula() {
    _eulaPopupManager?.show();
  }
}
