import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import '/models/item_details.dart';
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
    var collection = db.collection("ItemCluster");

    var result = await collection.find().toList(); // Fetch all printer data
    setState(() {
      printers = result; // Update printers with fetched data
    });
  }

  @override
  Widget build(BuildContext context) {
    return printers.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : GridView.builder(
              padding: const EdgeInsets.all(6.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.75,
              ),
              itemCount: printers.length,
              itemBuilder: (context, index) {
                final printer = printers[index];
                return item(printer['_id'], printer['name'], printer['imageURL'], printer['price']);
              },
            );
  }

  Widget item(mongo_dart.ObjectId id, String name, String imageURL, String price) {
    return GestureDetector(
      onTap:() {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
            return ItemDetailModal(
              id: id,
              name: name,
              imageURL: imageURL,
              price: price,
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 7.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 0),
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
            const SizedBox(height: 10.0),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            Text(
              '\$$price',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}