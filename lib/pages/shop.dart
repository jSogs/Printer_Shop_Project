import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import '/models/item_details.dart';
import '../db.dart';

class ShopPage extends StatefulWidget {
  const ShopPage ({super.key});

  @override
  State<ShopPage> createState() => ShopPageState();
}

class ShopPageState extends State<ShopPage> {

  List<Map<String, dynamic>> allPrinters = [];
  List<Map<String, dynamic>> filteredPrinters = []; // Filtered data to display
  Set<String> activeFilters = {}; // Selected printer types

  @override
  void initState() {
    super.initState();
    fetchPrinters(); // Fetch data on initialization
    updateFilters(activeFilters);
  }

  // Fetch printers from the MongoDB database
  Future<void> fetchPrinters() async {
    var db = MongoDBService().db;
    var collection = db.collection("ItemCluster");

    // Fetch all printers first, without any filters
    var result = await collection.find().toList();

    setState(() {
      allPrinters = result; // Store all printers
      filteredPrinters = List.from(allPrinters); // Initially show all printers
    });

    print("All Printers: $allPrinters");  // Debug: Print all printers

    _applyFilters(); // Apply filters after loading the data
  }

  // Update filters when user selects/deselects filter types
  void updateFilters(Set<String> selectedFilters) {
    setState(() {
      activeFilters = selectedFilters;
    });

    print("Selected filters: $selectedFilters");  // Debug: Log selected filters

    _applyFilters(); // Apply filters whenever the selected filters change
  }

  // Apply the active filters to the list of printers
  void _applyFilters() {
    print("Active Filters: $activeFilters");  // Debug: Log active filters
    if (activeFilters.isEmpty) {
      // No filters, show all printers
      setState(() {
        filteredPrinters = List.from(allPrinters); // Show all printers
      });
    } else {
      // Apply filters based on activeFilters
      setState(() {
        filteredPrinters = allPrinters.where((printer) {
          // Check if the printer type matches any of the selected filters
          bool matchesAllFilters = true;

          if (activeFilters.contains('Inkjet') && printer['type'] != 'Inkjet') {
            matchesAllFilters = false;
          }
          if (activeFilters.contains('Laser') && printer['type'] != 'Laser') {
            matchesAllFilters = false;
          }
          if (activeFilters.contains('Dot Matrix') && printer['type'] != 'Dot Matrix') {
            matchesAllFilters = false;
          }
          if (activeFilters.contains('Fax') && printer['fax'] != true) {
            matchesAllFilters = false;
          }
          if (activeFilters.contains('Copier') && printer['copier'] != true) {
            matchesAllFilters = false;
          }
          if (activeFilters.contains('Scanner') && printer['scanner'] != true) {
            matchesAllFilters = false;
          }
          if (activeFilters.contains('Full Color') && printer['bothColor'] != true) {
            matchesAllFilters = false;
          }
          if (activeFilters.contains('Black & White') && printer['bothColor'] != false) {
            matchesAllFilters = false;
          }
          return matchesAllFilters;
        }).toList();
      });
    }
    print("Filtered Printers: $filteredPrinters");  // Debug: Print filtered printers
  }

  @override
  Widget build(BuildContext context) {
    return filteredPrinters.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : GridView.builder(
              padding: const EdgeInsets.all(6.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredPrinters.length,
              itemBuilder: (context, index) {
                final printer = filteredPrinters[index];

                // Generate description for each printer
                String description = printer['type'];
                if(printer['fax'] == true){
                    description += ', Fax';
                }
                if(printer['copier'] == true){
                    description += ', Copier';
                }
                if(printer['scanner'] == true){
                    description += ', Scanner';
                }
                if(printer['bothColor'] == true){
                    description += ', Full-Color';
                }
                if(printer['scanner'] == true){
                    description += ', Black and White';
                }

                return item(printer['_id'], printer['name'], printer['imageURL'], printer['price'], description);
              },
            );
  }

  Widget item(mongo_dart.ObjectId id, String name, String imageURL, String price, String description) {
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
            Text(
              description,
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