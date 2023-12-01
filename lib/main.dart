import 'package:flutter/material.dart';
import '../provider/auth.dart';
import './provider/orders.dart';
import './provider/cart.dart';
import './screens/splash_screen.dart';
import './screens/product_description_screen.dart';
import './screens/cart_screen.dart';
import './screens/user_product_screen.dart';
import './screens/order_screem.dart';
import './screens/edit_product_screen.dart';
import './screens/product_overview_screen.dart';
import './provider/product_provider.dart';
import 'package:provider/provider.dart';
import './screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            create: (ctxx) => ProductsProvider('', '', []),
            update: (ctx, auth, previousProduct) => auth.isAuth
                ? ProductsProvider(
                    auth.token,
                    auth.userId,
                    previousProduct == null ? [] : previousProduct.items,
                  )
                : previousProduct!,
          ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Order>(
            create: (ctxx) => Order('', '', []),
            update: (ctx, auth, previousOrder) => auth.isAuth
                ? Order(auth.token, auth.userId,
                    previousOrder == null ? [] : previousOrder.orders)
                : previousOrder!,
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Shop App',
            theme: ThemeData(
              primaryColor: Colors.grey,
              colorScheme:
                  ColorScheme.fromSwatch().copyWith(secondary: Colors.red),
              fontFamily: 'Lato',
            ),
            home: auth.isAuth
                ? const ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctxx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? const SplashScreen()
                            : const AuthScreen(),
                  ),
            // initialRoute: '/',
            routes: {
              ProductDescriptionScreen.routName: (context) =>
                  const ProductDescriptionScreen(),
              CartScreen.routName: ((context) => const CartScreen()),
              OrderScreen.orderscreen: (context) => const OrderScreen(),
              UserProductScreen.productitemrout: (context) =>
                  const UserProductScreen(),
              EditProductScreen.routname: (context) =>
                  const EditProductScreen(),
            },
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop App'),
      ),
      body: const Center(child: Text("My Shop App")),
    );
  }
}
