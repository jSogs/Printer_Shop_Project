import 'package:flutter/material.dart';
import '/db.dart';

class EditPrinters extends StatefulWidget {
  const EditPrinters({super.key});

  @override
  State<EditPrinters> createState() => _EditPrintersState();
}

class _EditPrintersState extends State<EditPrinters> {
  List<dynamic> printers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPrinters();
  }

  Future<void> fetchPrinters() async {
    setState(() {
      isLoading = true;
    });

    var db = MongoDBService().db;
    var itemsCollection = db.collection('ItemCluster');
    try {
      var printerList = await itemsCollection.find().toList();
      setState(() {
        printers = printerList ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("Failed to fetch printers: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> savePrinter(Map<String, dynamic> printerData, {bool isEditing = false}) async {
    var db = MongoDBService().db;
    var itemsCollection = db.collection('ItemCluster');

    try {
      if (isEditing) {
        // Update printer in database
        await itemsCollection.updateOne(
          {'_id': printerData['_id']},
          {
            '\$set': {
              'name': printerData['name'],
              'quantity': printerData['quantity'],
              'price': printerData['price'],
              'fax': printerData['fax'],
              'scanner': printerData['scanner'],
              'copier': printerData['copier'],
              'bothColor': printerData['bothColor'],
              'type': printerData['type'],
            }
          },
        );
      } else {
        // Insert new printer in database
        printerData['imageURL'] = "https://cdn-icons-png.freepik.com/512/8426/8426469.png";
        await itemsCollection.insertOne(printerData);
      }
      await fetchPrinters();
    } catch (e) {
      print("Failed to save printer: $e");
    }
  }

  void showPrinterModal({Map<String, dynamic>? printer}) {
    final isEditing = printer != null;

    // Controllers for text fields
    final nameController = TextEditingController(text: printer?['name'] ?? '');
    final quantityController = TextEditingController(text: printer?['quantity']?.toString() ?? '');
    final priceController = TextEditingController(text: printer?['price']?.toString() ?? '');
    final typeController = TextEditingController(text: printer?['type']?.toString() ?? '');

    // Initial values for boolean switches
    bool fax = printer?['fax'] ?? false;
    bool scanner = printer?['scanner'] ?? false;
    bool copier = printer?['copier'] ?? false;
    bool colored = printer?['bothColor'] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // Use StatefulBuilder to manage the switch states
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing ? 'Edit Printer' : 'Add Printer',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    const SizedBox(height: 10),
                    // Boolean Switch for Fax
                    SwitchListTile(
                      value: fax,
                      onChanged: (value) {
                        setModalState(() {
                          fax = value;
                        });
                      },
                      title: const Text('Fax'),
                    ),
                    // Boolean Switch for Scanner
                    SwitchListTile(
                      value: scanner,
                      onChanged: (value) {
                        setModalState(() {
                          scanner = value;
                        });
                      },
                      title: const Text('Scanner'),
                    ),
                    // Boolean Switch for Copier
                    SwitchListTile(
                      value: copier,
                      onChanged: (value) {
                        setModalState(() {
                          copier = value;
                        });
                      },
                      title: const Text('Copier'),
                    ),
                    // Boolean Switch for Colored
                    SwitchListTile(
                      value: colored,
                      onChanged: (value) {
                        setModalState(() {
                          colored = value;
                        });
                      },
                      title: const Text('Colored'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final printerData = {
                          '_id': isEditing ? printer['_id'] : null, // Keep _id for editing
                          'name': nameController.text,
                          'quantity': int.tryParse(quantityController.text) ?? 0,
                          'price': priceController.text=="" ? "0.0" : priceController.text,
                          'fax': fax,
                          'scanner': scanner,
                          'copier': copier,
                          'bothColor': colored,
                          'type': typeController,
                        };

                        savePrinter(printerData, isEditing: isEditing);
                        Navigator.pop(context); // Close modal
                      },
                      child: Text(isEditing ? 'Save Changes' : 'Add Printer'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showPrinterModal(),
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'Printer Lineup',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 2.0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _body() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : printers.isEmpty
            ? const Center(
                child: Text(
                  'No printers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: printers.length,
                itemBuilder: (context, index) {
                  final printer = printers[index];
                  return printerItem(printer);
                },
              );
  }

  Widget printerItem(Map<String, dynamic> printer) {
    return GestureDetector(
      onTap: () => showPrinterModal(printer: printer),
      child: Card(
        child: ListTile(
          title: Text(printer['name']),
          subtitle: Text('Quantity: ${printer['quantity']}'),
          trailing: Text('\$${printer['price']}'),
        ),
      ),
    );
  }
}
