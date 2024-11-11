import 'package:flutter/material.dart';
import '/pages/profile.dart';
import '/pages/shop.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;  // Alias as mongo because some class use same function names



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  String userName = "";
  late MongoDBService mongoDBService;

  static const List<Widget> pages = [ShopPage(), ProfilePage()];
  static const List<String> pageTitles = ["Home", "Profile"];
  
  @override
  void initState() {
    super.initState();
    _initializeMongoDB();
  }

  // Initialize MongoDB connection asynchronously
  Future<void> _initializeMongoDB() async {
    mongoDBService = MongoDBService();
    await mongoDBService.connect(); // Ensure MongoDB is initialized
    _fetchUserDetails(); // Fetch user details after MongoDB initialization
  }

  // Function to get the unique ID from local storage
  Future<String?> getUniqueId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('unique_id'); // Returns null if the key does not exist
  }

  // Fetch user details from MongoDB using the unique ID
  Future<void> _fetchUserDetails() async {
    String? uniqueId = await getUniqueId();
    if (uniqueId != null) {
      var db = mongoDBService.db;
      var usersCollection = db.collection('UserCluster');
      
      try {
        // Check if the uniqueId is in the form of 'ObjectId("xxxxxx")' and extract the hex string
        String hexId = uniqueId.replaceAll('ObjectId("', '').replaceAll('")', '');

        // Convert the cleaned hex string into an ObjectId
        var objectId = mongo.ObjectId.fromHexString(hexId);

        var user = await usersCollection.findOne({
          '_id': objectId, // Use ObjectId for _id comparison
        });

        if (user != null) {
          setState(() {
            userName = user['name'] ?? "Unknown User";
          });
          print("User found: $userName");
        } else {
          print("User not found.");
        }
      } catch (e) {
        print("Error converting uniqueId to ObjectId: $e");
      }
    } else {
      print("Unique ID not found in SharedPreferences.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Center(
        child: Text(userName.isNotEmpty ? 'Hello, $userName' : 'Loading...'), // Display the user's name or a loading message
      ),
      bottomNavigationBar: _navBar(),
    );
  }


  // Top Bar
  AppBar _appBar() {
    return AppBar(
      title: Text(
        pageTitles[currentPageIndex],
        style: TextStyle(
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
