import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/products.dart';

import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

import '../screens/user_product_edit_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> refreshProducts (context) async {
    await Provider.of<Products>(context, listen: false).getProducts(); 
  }

  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context); 
  
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(UserProductEditScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => refreshProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemBuilder: (_, index) {
              return Column(
                children: [
                  UserProductItem(
                    title: productsData.items[index].title,
                    imageUrl: productsData.items[index].imageUrl,
                    id: productsData.items[index].id,
                    deleteHandler: productsData.removeProduct,
                  ),
                  const Divider(),
                ],
              );
            },
            itemCount: productsData.items.length,
          ),
        ),
      ),
    );
  }
}
