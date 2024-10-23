import 'package:web_dex/router/parsers/base_route_parser.dart';
import 'package:web_dex/router/routes.dart';
import 'package:web_dex/router/state/dex_state.dart';

class _DexRouteParser implements BaseRouteParser {
  const _DexRouteParser();
  @override
  AppRoutePath getRoutePath(Uri uri) {
    if (uri.pathSegments.length == 3) {
      if (uri.pathSegments[1] == 'trading_details' &&
          uri.pathSegments[2].isNotEmpty) {
        return DexRoutePath.swapDetails(
            DexAction.tradingDetails, uri.pathSegments[2]);
      }
    }

    return DexRoutePath.dex();
  }
}

const dexRouteParser = _DexRouteParser();
