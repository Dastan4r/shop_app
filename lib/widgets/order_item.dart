import 'package:flutter/material.dart';
import 'dart:math';

import 'package:intl/intl.dart';

import '../providers/orders_provider.dart' show OrderItem;

class OrderItemWidget extends StatefulWidget {
  final OrderItem order;

  OrderItemWidget({required this.order});

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.price}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
            ),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              icon: Icon(
                expanded ? Icons.expand_more : Icons.expand_less,
              ),
            ),
          ),
          if (expanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              height: min(widget.order.products.length * 20 + 10, 100),
              child: ListView.builder(
                itemBuilder: (ctx, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.order.products[index].title),
                      Text('\$${widget.order.products[index].price}'),
                      Text(widget.order.products[index].quantity.toString()),
                    ],
                  );
                },
                itemCount: widget.order.products.length,
              ),
            )
        ],
      ),
    );
  }
}
