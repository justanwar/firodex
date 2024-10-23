import 'package:web_dex/mm2/mm2_api/rpc/base.dart';
import 'package:web_dex/mm2/mm2_api/rpc/orderbook/orderbook_request.dart';
import 'package:web_dex/model/orderbook/orderbook.dart';

class OrderbookResponse
    implements ApiResponse<OrderbookRequest, Orderbook, String> {
  OrderbookResponse({required this.request, this.result, this.error});

  @override
  final OrderbookRequest request;
  @override
  final Orderbook? result;
  @override
  final String? error;
}
