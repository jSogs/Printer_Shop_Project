import 'package:flutter/material.dart';
import '../models/order_card.dart';
import '/db.dart';

class ViewOrders  extends StatefulWidget{
  const ViewOrders({super.key});

  @override
  State<ViewOrders> createState() => _ViewOrdersState();
}

class _ViewOrdersState extends State<ViewOrders> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  Future<void> fetchOrders() async{
    var db = MongoDBService().db;
    var ordersCollection = db.collection('OrderCluster');

    try {
      var orderList = await ordersCollection.find().toList();
      setState(() {
        orders = orderList;
      });
      return;
    } catch (e) {
      print("Failed to retrieve orders: $e");
      return;
    }
  }
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    fetchOrders();
    setState(() {
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : orders.isEmpty
          ? const Center(
            child: Text(
              'There are no orders.',
              style: TextStyle(
                fontSize: 18, // Increase the font size
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.black, // Use a muted color
              )),
          )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return OrderCard(order: orders[index]);
              },
            ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'All Orders',
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
}