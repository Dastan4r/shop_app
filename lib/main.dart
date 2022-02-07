import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:core';

import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/user_product_edit_screen.dart';
import './screens/auth_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders_provider.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
           ChangeNotifierProvider.value(
            value: AuthProvider(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, Orders>(
            create: (_) => Orders(),
            update: (ctx, auth, prevState) => Orders()..update(auth.token)
          ),
          ChangeNotifierProxyProvider<AuthProvider, Products>(
            create: (_) => Products(),
            update: (ctx, auth, prevState) => Products()..update(auth.token)
          ),
        ],
        child: Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            return MaterialApp(
              title: 'MyShop',
              theme: ThemeData(
                primarySwatch: Colors.teal,
                fontFamily: 'Lato',
              ),
              home: auth.isAuthenticated ? ProductsOverviewScreen() : AuthScreen(),
              routes: {
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrdersScreen.routeName: (ctx) => OrdersScreen(),
                UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                UserProductEditScreen.routeName: (ctx) => UserProductEditScreen(),
              },
            );
          },
        ));
  }
}
