import 'package:flutter/material.dart';
import 'package:rational/rational.dart';
import 'package:web_dex/blocs/blocs.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/model/orderbook/order.dart';
import 'package:web_dex/views/dex/orderbook/orderbook_view.dart';

class MakerFormOrderbook extends StatelessWidget {
  const MakerFormOrderbook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Coin?>(
      initialData: makerFormBloc.sellCoin,
      stream: makerFormBloc.outSellCoin,
      builder: (context, sellCoin) {
        return StreamBuilder<Coin?>(
          initialData: makerFormBloc.buyCoin,
          stream: makerFormBloc.outBuyCoin,
          builder: (context, buyCoin) {
            return StreamBuilder<Rational?>(
              initialData: makerFormBloc.price,
              stream: makerFormBloc.outPrice,
              builder: (context, price) {
                return _buildOrderbook(
                  base: sellCoin.data,
                  rel: buyCoin.data,
                  price: price.data,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderbook({
    required Coin? base,
    required Coin? rel,
    required Rational? price,
  }) {
    return OrderbookView(
      base: makerFormBloc.sellCoin,
      rel: makerFormBloc.buyCoin,
      myOrder: _getMyOrder(price),
      onAskClick: _onAskClick,
    );
  }

  Order? _getMyOrder(Rational? price) {
    final Coin? sellCoin = makerFormBloc.sellCoin;
    final Coin? buyCoin = makerFormBloc.buyCoin;
    final Rational? sellAmount = makerFormBloc.sellAmount;

    if (sellCoin == null) return null;
    if (buyCoin == null) return null;
    if (sellAmount == null || sellAmount == Rational.zero) return null;
    if (price == null || price == Rational.zero) return null;

    return Order(
      base: sellCoin.abbr,
      rel: buyCoin.abbr,
      maxVolume: sellAmount,
      price: price,
      direction: OrderDirection.ask,
      uuid: orderPreviewUuid,
    );
  }

  void _onAskClick(Order order) {
    if (makerFormBloc.sellAmount == null) makerFormBloc.setMaxSellAmount();
    makerFormBloc.setPriceValue(order.price.toDouble().toStringAsFixed(8));
  }
}
