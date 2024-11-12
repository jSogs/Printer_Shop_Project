import 'package:flutter/material.dart';
import '/pages/profile.dart';
import '/pages/shop.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  // Top Bar
  AppBar _appBar() {
    return AppBar(
      title: Text(
        pageTitles[currentPageIndex],
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 2.0,
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
