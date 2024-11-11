import 'package:flutter/material.dart';
import '../db.dart';

class ShopPage extends StatefulWidget {
  const ShopPage ({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {

  List<Map<String, dynamic>> printers = [];

  @override
  void initState() {
    super.initState();
    fetchPrinters(); // Fetch data on initialization
  }

  Future<void> fetchPrinters() async {
    var db = MongoDBService().db;
    await db.open();
    var collection = db.collection("ItemCluster");

    var result = await collection.find().toList(); // Fetch all printer data
    setState(() {
      printers = result; // Update printers with fetched data
    });
    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shop Page"),
      ),
      body: printers.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : GridView.builder(
              padding: EdgeInsets.all(6.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.75,
              ),
              itemCount: printers.length,
              itemBuilder: (context, index) {
                final printer = printers[index];
                return item(printer['name'], printer['imageURL'], printer['price']);
              },
            ),
    );
  }

  Container item(String name, String imageURL, String price) {
    return Container(
    padding: EdgeInsets.all(6.0),
    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          imageURL,
          height: 100.0,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 10.0),
        Text(
          name,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5.0),
        Text(
           '\$${price}',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
  }
}