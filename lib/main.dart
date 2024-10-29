import 'package:flutter/material.dart';
import 'package:prak8/screens/FavouritePage.dart';
import 'package:prak8/screens/ItemsPage.dart';
import 'package:prak8/screens/ProfilePage.dart';
import 'package:badges/badges.dart' as badges;
import 'package:prak8/screens/ShopCartPage.dart';
import 'package:prak8/api_service.dart';
import 'package:prak8/model/items.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.grey[800]!, // Добавлен оператор !, чтобы указать, что значение не null
          secondary: Colors.grey[600]!, // То же самое
        ),
        scaffoldBackgroundColor: Colors.white, // Фон приложения белый
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widgetOptions = [
      ItemsPage(navToShopCart: (i) => onTab(i)),
      FavoritePage(navToShopCart: (i) => onTab(i)),
      ShopCartPage(navToShopCart: (i) => onTab(i)),
      const ProfilePage()
    ];
  }

  void onTab(int i) {
    setState(() {
      selectedIndex = i;
    });
  }

  static List<Widget> widgetOptions = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200]!, // Исправлено
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Главная',
              backgroundColor: Colors.white), // Белый фон для кнопок
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Избранное',
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded),
              label: 'Корзина',
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
              backgroundColor: Colors.white)
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.grey[800]!, // Исправлено
        unselectedItemColor: Colors.grey[500]!, // Исправлено
        onTap: onTab,
      ),
    );
  }
}
