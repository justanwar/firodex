import 'package:flutter/material.dart';
import 'dart:async';

import 'package:komodo_ui_kit/src/images/coin_icon.dart';

class CoinSelectItem {
  CoinSelectItem({
    required this.name,
    required this.coinId,
    this.leading,
    this.trailing,
  });

  final String name;
  final String coinId;
  final Widget? trailing;
  final Widget? leading;
}

class CryptoSearchDelegate extends SearchDelegate<CoinSelectItem?> {
  CryptoSearchDelegate(this.items);

  final Iterable<CoinSelectItem> items;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return CoinListTile(
          item: item,
          onTap: () => close(context, item),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return CoinListTile(
          item: item,
          onTap: () => query = item.name,
        );
      },
    );
  }
}

class CoinListTile extends StatelessWidget {
  const CoinListTile({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  final CoinSelectItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: item.leading ?? CoinIcon.ofSymbol(item.coinId),
      title: Text(item.name),
      trailing: item.trailing,
      onTap: onTap,
    );
  }
}

Future<CoinSelectItem?> showCoinSearch(
  BuildContext context, {
  required List<String> coins,
  CoinSelectItem Function(String coinId)? customCoinItemBuilder,
}) async {
  final isMobile = MediaQuery.of(context).size.width < 600;

  final items = coins.map(
    (coin) =>
        customCoinItemBuilder?.call(coin) ?? _defaultCoinItemBuilder(coin),
  );

  if (isMobile) {
    return await showSearch<CoinSelectItem?>(
      context: context,
      delegate: CryptoSearchDelegate(items),
    );
  } else {
    return await showDropdownSearch(context, items);
  }
}

CoinSelectItem _defaultCoinItemBuilder(String coin) {
  return CoinSelectItem(
    name: coin,
    coinId: coin,
    leading: CoinIcon.ofSymbol(coin),
  );
}

OverlayEntry? _overlayEntry;
Completer<CoinSelectItem?>? _completer;

Future<CoinSelectItem?> showDropdownSearch(
  BuildContext context,
  Iterable<CoinSelectItem> items,
) async {
  final renderBox = context.findRenderObject() as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);

  void clearOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _completer = null;
  }

  void onItemSelected(CoinSelectItem? item) {
    _completer?.complete(item);
    clearOverlay();
  }

  clearOverlay();

  _completer = Completer<CoinSelectItem?>();
  _overlayEntry = OverlayEntry(
    builder: (context) {
      return GestureDetector(
        onTap: () => onItemSelected(null),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + renderBox.size.height,
              width: 300,
              child: _DropdownSearch(
                items: items,
                onSelected: onItemSelected,
              ),
            ),
          ],
        ),
      );
    },
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Overlay.of(context).insert(_overlayEntry!);
  });

  return _completer!.future;
}

class _DropdownSearch extends StatefulWidget {
  final Iterable<CoinSelectItem> items;
  final ValueChanged<CoinSelectItem?> onSelected;

  const _DropdownSearch({required this.items, required this.onSelected});

  @override
  State<_DropdownSearch> createState() => __DropdownSearchState();
}

class __DropdownSearchState extends State<_DropdownSearch> {
  late Iterable<CoinSelectItem> filteredItems;
  String query = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      query = newQuery;
      filteredItems = widget.items.where(
        (item) => item.name.toLowerCase().contains(query.toLowerCase()),
      );
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 300,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                focusNode: _focusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: updateSearchQuery,
              ),
            ),
            Flexible(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems.elementAt(index);
                  return CoinListTile(
                    item: item,
                    onTap: () => widget.onSelected(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoinDropdown extends StatefulWidget {
  final List<CoinSelectItem> items;
  final Function(CoinSelectItem) onItemSelected;

  const CoinDropdown({
    super.key,
    required this.items,
    required this.onItemSelected,
  });

  @override
  State<CoinDropdown> createState() => _CoinDropdownState();
}

class _CoinDropdownState extends State<CoinDropdown> {
  CoinSelectItem? selectedItem;

  void _showSearch(BuildContext context) async {
    final selected = await showCoinSearch(
      context,
      coins: widget.items.map((e) => e.coinId).toList(),
      customCoinItemBuilder: (coinId) {
        return widget.items.firstWhere((e) => e.coinId == coinId);
      },
    );
    if (selected != null) {
      setState(() {
        selectedItem = selected;
      });
      widget.onItemSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSearch(context),
      child: InputDecorator(
        isEmpty: selectedItem == null,
        decoration: const InputDecoration(
          hintText: 'Select a Coin',
          border: OutlineInputBorder(),
        ),
        child: selectedItem == null
            ? null
            : Row(
                children: [
                  Text(selectedItem!.name),
                  const Spacer(),
                  selectedItem?.trailing ?? const SizedBox(),
                ],
              ),
      ),
    );
  }
}

// Example usage

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       CoinSelectItem(
//         name: "KMD",
//         coinId: "KMD",
//         trailing: const Text('+2.9%', style: TextStyle(color: Colors.green)),
//       ),
//       CoinSelectItem(
//         name: "SecondLive",
//         coinId: "SL",
//         trailing: const Text('+322.9%', style: TextStyle(color: Colors.green)),
//       ),
//       CoinSelectItem(
//         name: "KiloEx",
//         coinId: "KE",
//         trailing: const Text('-2.09%', style: TextStyle(color: Colors.red)),
//       ),
//       CoinSelectItem(
//         name: "Native",
//         coinId: "NT",
//         trailing: const Text('+225.9%', style: TextStyle(color: Colors.green)),
//       ),
//       CoinSelectItem(
//         name: "XY Finance",
//         coinId: "XY",
//         trailing: const Text('+62.9%', style: TextStyle(color: Colors.green)),
//       ),
//       CoinSelectItem(
//         name: "KMD",
//         coinId: "KMD",
//         trailing: const Text('+2.9%', style: TextStyle(color: Colors.green)),
//       ),
//     ];

//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Crypto Selector')),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: CoinDropdown(
//             items: items,
//             onItemSelected: (item) {
//               // Handle item selection
//               print('Selected item: ${item.name}');
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
