import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/auth.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:shop_app/provider/product.dart';
import '../screens/product_description_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: IconButton(
              icon:
                  Icon(product.isFav ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                product.toggleFavStatus(authData.token, authData.userId);
              },
            ),
            title: Text(product.title),
            trailing: IconButton(
              icon: const Icon(Icons.shopping_basket),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                cart.addProduct(product.id!, product.title, product.price);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Item Added To Cart",
                    ),
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        cart.removeSingleItem(product.id!);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                    ProductDescriptionScreen.routName,
                    arguments: product.id);
              },
              child: Hero(
                tag: product.id.toString(),
                child: FadeInImage(
                  placeholder: AssetImage(""),
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
              )),
        ));
  }
}
