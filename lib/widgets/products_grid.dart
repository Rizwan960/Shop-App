import 'package:flutter/material.dart';
import 'package:shop_app/provider/product_provider.dart';
import 'package:shop_app/widgets/product_item.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyfac;
  const ProductsGrid({Key? key, required this.showOnlyfac}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductsProvider>(context, listen: false);
    final product = showOnlyfac ? productData.favoriteItems : productData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: product.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
          value: product[i], child: const ProductItem()),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15),
    );
  }
}
