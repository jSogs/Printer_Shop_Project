import 'package:flutter/material.dart';
import '/pages/cart.dart';
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

  final GlobalKey<ShopPageState> shopPageKey = GlobalKey<ShopPageState>();

  static const List<String> pageTitles = ["Home", "Profile"];

  Set<String> selectedTypes = {}; // Track selected filter types

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
          ShopPage(key: shopPageKey), // pass key to be able to call function from ShopPage
          ProfilePage(),
        ];

    return Scaffold(
      appBar: _appBar(),
      body: pages[currentPageIndex],
      bottomNavigationBar: _navBar(),
      endDrawer: _buildDrawer(),
    );
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
        currentPageIndex == 0 ? Builder(
          // filter icon
          builder: (context) => IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // Open the drawer using the context from Builder
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ) : const SizedBox(),

        // shopping icon
        IconButton(
          icon: const Badge(
            backgroundColor: Color.fromARGB(255, 175, 128, 197),
            child: Icon(Icons.shopping_cart),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
          },
        )
      ],
    );
  }

  //Navigation Bar at the bottom
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

   // drawer for filters feature, home & setting button
   Widget _buildDrawer() {
    List<String> printerTypes = ['Inkjet', 'Laser', 'Dot Matrix', 'Fax', 'Copier', 'Scanner', 'Full Color', 'Black & White'];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Filters', style: TextStyle(color: Colors.white)),
          ),

          // Printer type filters
          ...printerTypes.map((type) {
            return CheckboxListTile(
              title: Text(type),
              value: selectedTypes.contains(type),
              onChanged: (bool? isChecked) {
                setState(() {
                  if (isChecked == true) {
                    selectedTypes.add(type);
                  } else {
                    selectedTypes.remove(type);
                  }

                  // Debugging: Print selected types
                  print("Selected types after change: $selectedTypes");

                  // Notify ShopPage to apply the selected filters
                  shopPageKey.currentState?.updateFilters(selectedTypes);
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
