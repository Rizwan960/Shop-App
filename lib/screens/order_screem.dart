import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/orders.dart' show Order;
import 'package:shop_app/widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatefulWidget {
  static const orderscreen = '/roderscreen';
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future? _ordersFuture;

  Future _obtainsOrderFuture() {
    return Provider.of<Order>(context, listen: false).fetchAndSetOrder();
  }

  @override
  void initState() {
    _ordersFuture = _obtainsOrderFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Orders"),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          future: _ordersFuture,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.error != null) {
              return const Center(
                child: Text("En Error Occured"),
              );
            } else {
              return Consumer<Order>(
                builder: ((context, ordersData, child) => ListView.builder(
                      itemCount: ordersData.orders.length,
                      itemBuilder: ((context, index) => OrderItem(
                            order: ordersData.orders[index],
                          )),
                    )),
              );
            }
          }),
        ));
  }
}
