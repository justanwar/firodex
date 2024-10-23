import 'package:app_theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';

const double _hiddenSearchFieldWidth = 38;
const double _normalSearchFieldWidth = 150;

class WalletManagerSearchField extends StatefulWidget {
  const WalletManagerSearchField({required this.onChange});
  final Function(String) onChange;

  @override
  State<WalletManagerSearchField> createState() =>
      _WalletManagerSearchFieldState();
}

class _WalletManagerSearchFieldState extends State<WalletManagerSearchField> {
  double _searchFieldWidth = _normalSearchFieldWidth;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    _searchController.addListener(_onChange);
    if (isMobile) {
      _changeSearchFieldWidth(false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: BoxConstraints.tightFor(
        width: _searchFieldWidth,
        height: isMobile ? _hiddenSearchFieldWidth : 30,
      ),
      child: UiTextFormField(
        key: const Key('wallet-page-search-field'),
        controller: _searchController,
        autocorrect: false,
        onFocus: (FocusNode node) {
          _searchController.text = _searchController.text.trim();
          if (!isMobile) return;
          _changeSearchFieldWidth(node.hasFocus);
        },
        textInputAction: TextInputAction.none,
        enableInteractiveSelection: true,
        prefixIcon: Icon(
          Icons.search,
          size: isMobile ? 25 : 18,
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(40)],
        hintText: LocaleKeys.searchAssets.tr(),
        hintTextStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
            height: 1.3),
        inputContentPadding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
        maxLines: 1,
        style: const TextStyle(fontSize: 12),
        fillColor: _searchFieldColor,
      ),
    );
  }

  void _changeSearchFieldWidth(bool hasFocus) {
    if (hasFocus) {
      setState(() => _searchFieldWidth = _normalSearchFieldWidth);
    } else if (_searchController.text.isEmpty) {
      setState(() => _searchFieldWidth = _hiddenSearchFieldWidth);
    }
  }

  void _onChange() {
    widget.onChange(_searchController.text.trim());
  }

  Color? get _searchFieldColor {
    return isMobile ? theme.custom.searchFieldMobile : null;
  }
}
