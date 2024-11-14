import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/pages/profile.dart';
import '/pages/shop.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int cartSize = 0;
  int currentPageIndex = 0;
  static const List<Widget> pages = [ShopPage(), ProfilePage()];
  static const List<String> pageTitles = ["Home", "Profile"];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: pages[currentPageIndex],
      bottomNavigationBar: _navBar(),
    );
  }

  Future<int> getCartSize() async{
    final prefs = await SharedPreferences.getInstance();
    setState((){
      cartSize = prefs.getInt('cart_size') ?? 0;
    });
    return cartSize;
  }
  // Top Bar
  AppBar _appBar() {
    return AppBar(
      title: Text(
        pageTitles[currentPageIndex],
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 2.0,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.sort),
          tooltip: 'Show Snackbar',
          onPressed: () {
          },
        ),
        IconButton(
          icon: const Badge(
            backgroundColor: Color.fromARGB(255, 175, 128, 197),
            child: Icon(Icons.shopping_cart),
          ),
          onPressed: () {},
        )
      ],
    );
  }

  //Navigation Bar
  NavigationBar _navBar(){
    const List<Widget> destinations = [
      NavigationDestination(
        selectedIcon: Icon(Icons.home),
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      NavigationDestination(
        selectedIcon: Icon(Icons.account_circle),
        icon: Icon(Icons.account_circle_outlined),
        label: 'Profile',
      ),
    ];

    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      selectedIndex: currentPageIndex,
      destinations: destinations,
    );
  }
}
