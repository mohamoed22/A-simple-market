import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import 'helpers/castem_rout.dart';
import 'screens/splashScreen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
                auth.token,
                auth.userid,
                previousProducts == null ? [] : previousProducts.items,
              ),
              create: (context) => Products('', '', []),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) =>Orders('',[],'') ,
          update: (ctx, auth, previousOrders) => Orders(
                auth.token,
                previousOrders == null ? [] : previousOrders.orders, auth.userid
              ),
            
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
              title: 'MyShop',
              theme: ThemeData(
                primarySwatch: Colors.blueGrey,
                // ignore: deprecated_member_use
                hintColor: Colors.deepOrange,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android:CustomPageTransitionBuilder(),
                  TargetPlatform.iOS:CustomPageTransitionBuilder()
                })
              ),
              // ignore: unrelated_type_equality_checks
              home: auth.isAuth != null ? const ProductsOverviewScreen() : FutureBuilder(future: auth.tryAutoLogin(),builder:(ctx,authResultSnapshot)=> authResultSnapshot == ConnectionState.waiting?const SplashScreen(): const AuthScreen()),
              routes: {
                ProductDetailScreen.routeName: (ctx) =>const ProductDetailScreen(),
                CartScreen.routeName: (ctx) => const CartScreen(),
                OrdersScreen.routeName: (ctx) => const OrdersScreen(),
                UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
                EditProductScreen.routeName: (ctx) => const EditProductScreen(),
              },
            ),
      ),
    );
  }
}
