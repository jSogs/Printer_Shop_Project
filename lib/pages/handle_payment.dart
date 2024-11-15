import 'package:flutter/material.dart';
import '/db.dart';
import '/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import '../models/order.dart';

class PaymentPage extends StatefulWidget {
  final Order order;

  const PaymentPage({super.key, required this.order});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String pageText = "Executing order and handling payment...";

  @override
  void initState() {
    super.initState();

    // Set up the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Fade in and out in 1 second
      vsync: this,
    )..repeat(reverse: true); // Repeat animation indefinitely

    // Set up a tween animation for opacity
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    handleOrder();
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the animation controller
    super.dispose();
  }

  Future<void> handleOrder() async{
    await Future.delayed(const Duration(seconds: 2)); // add small delay

    var db = MongoDBService().db;
    var usersCollection = db.collection('UserCluster');
    var orderCollection = db.collection('OrderCluster');
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('unique_id') ?? "";
    try {
      var user = await usersCollection
          .findOne({"_id": mongo_dart.ObjectId.parse(userId)});
      if (user == null) {
        print("User not found.");
        return;
      }
      var result = await orderCollection.insertOne({
          'user_id': widget.order.userId,
          'cart': widget.order.cart,
          'price': widget.order.price,
          'address': widget.order.address,
          'deliveryMethod': widget.order.deliveryMethod,
          'date': widget.order.date,
        }); //add to orders
      user['cart'] = []; //Clear cart
      List<dynamic> orders = user['orders'] ?? [];
      orders.add(result.id.oid);
      user['orders'] = orders; // add order to user profile
      await usersCollection.replaceOne({"_id":mongo_dart.ObjectId.parse(userId)}, user);
      setState(() {
        pageText = 'Order successful';
      });
    } catch (e) {
      print("Failed to add item to cart: $e");
      return;
    }
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.payment,
                size: 50,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              Text(
                pageText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
