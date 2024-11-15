import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import 'package:printer_project/db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>{
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  Future<void> fetchOrders() async{
    var db = MongoDBService().db;
    var ordersCollection = db.collection('OrderCluster');
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('unique_id') ?? "";

    try {
      var orderList = await ordersCollection.find(mongo_dart.where.eq('user_id',mongo_dart.ObjectId.parse(userId))).toList();
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
              'You have no previous orders',
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
        'Orders',
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
