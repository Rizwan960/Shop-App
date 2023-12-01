import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/badge.dart';
import 'package:shop_app/provider/product_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';

import 'package:shop_app/widgets/products_grid.dart';

import '../provider/cart.dart';

enum FillterdOption {
  favorites,
  show,
}

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFav = false;
  var _isInIt = true;
  var _isLoaded = false;
  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoaded = true;
      });
      Provider.of<ProductsProvider>(context).fetchAndSetProduct().then((_) {
        setState(() {
          _isLoaded = false;
        });
      });
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Overview"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FillterdOption value) {
              setState(() {
                if (value == FillterdOption.favorites) {
                  _showOnlyFav = true;
                } else if (value == FillterdOption.show) {
                  _showOnlyFav = false;
                }
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FillterdOption.favorites,
                child: Text(
                  "Show Favroites",
                ),
              ),
              const PopupMenuItem(
                value: FillterdOption.show,
                child: Text(
                  "Show All",
                ),
              )
            ],
            icon: const Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) =>
                Badge(value: cart.getCountLenght.toString(), child: ch!),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routName);
              },
            ),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(showOnlyfac: _showOnlyFav),
    );
  }
}
