import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/product_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

class UserProduct extends StatelessWidget {
  final String title;
  final String id;
  final String imageUrl;

  const UserProduct({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 8,
      child: ListTile(
        leading: CircleAvatar(
          //backgroundImage: NetworkImage(imageUrl),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routname, arguments: id);
              },
              icon: const Icon(Icons.edit),
              color: Colors.black,
            ),
            IconButton(
              onPressed: () {
                Provider.of<ProductsProvider>(context, listen: false)
                    .deleteProduct(id);
              },
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          ]),
        ),
      ),
    );
  }
}
