// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/cart.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    Key? key,
    required this.title,
    required this.price,
    required this.id,
    required this.productId,
    required this.quantity,
  }) : super(key: key);
  final String title;
  final String productId;
  final int price;
  final int quantity;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Are You Sure?"),
            content: const Text("Do You Want To Remove The Item From Cart?"),
            actions: [
              TextButton(
                onPressed: () => {
                  Navigator.of(ctx).pop(false),
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => {
                  Navigator.of(ctx).pop(true),
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) =>
          {Provider.of<Cart>(context, listen: false).removeCartItem(productId)},
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FittedBox(
                      child: Text(
                    'Rs.$price',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ))),
            ),
            title: Text(title),
            subtitle: Text('Total: Rs.${price * quantity}'),
            trailing: Text("Quantity: x$quantity"),
          ),
        ),
      ),
    );
  }
}
