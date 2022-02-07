import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isLoading = false;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration.zero).then((value) async {
      await Provider.of<Orders>(context, listen:false).getAndSetOrders().then((value) {
        setState(() {
          isLoading = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: isLoading ? const Center(child: CircularProgressIndicator(),) : ListView.builder(
        itemBuilder: (ctx, index) {
          return OrderItemWidget(order: orders.getOrders[index]);
        },
        itemCount: orders.getOrders.length,
      ),
    );
  }
}
