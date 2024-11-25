import 'package:flutter/material.dart';
import '/pages/checkout.dart';

import '../models/notifiers.dart';
import '/db.dart';
import '/models/item_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>{
  List<dynamic> cart = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getCart(); // Fetch data on initialization
    setState(() {
      isLoading = false;
    });
    cartNotifier.addListener(_updateCart);
  }

   @override
  void dispose() {
    // Remove the listener when the page is disposed
    cartNotifier.removeListener(_updateCart);
    super.dispose();
  }

  void _updateCart() {
    if (mounted) {
      setState(() {
        cart = cartNotifier.value;
      });
    }
  }
  
  Future<void> getCart() async{
    var db = MongoDBService().db;
    var usersCollection = db.collection('UserCluster');
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('unique_id') ?? "";
    try{
      var user = await usersCollection.findOne({"_id": mongo_dart.ObjectId.parse(userId)});
      if(user == null){
        print("User not found.");
        return;
      }
      setState(() {
        cart = user['cart'] ?? [];
      });
    } catch(e){
      print("Failed to get cart: $e");
      return;
    }
  }

  void removeFromCart(String itemId) async {
    var db = MongoDBService().db;
    var usersCollection = db.collection('UserCluster');
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('unique_id') ?? "";

    try {
      // Find the user
      var user = await usersCollection.findOne({"_id": mongo_dart.ObjectId.parse(userId)});
      if (user == null) {
        print("User not found.");
        return;
      }

      // Update the user's cart by removing the item with the given ID
      await usersCollection.updateOne(
        {"_id": mongo_dart.ObjectId.parse(userId)}, // Match the user by ID
        {
          "\$pull": {
            "cart": {"_id": mongo_dart.ObjectId.parse(itemId)} // Match item by ID in the cart
          }
        },
      );
      getCart();
      print("Item removed from cart successfully.");
    } catch (e) {
      print("Error removing item from cart: $e");
    }
  }

  void checkoutCart() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty!')),
      );
      return;
    }

    // Navigate to a checkout page or trigger further checkout actions here
    Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutPage(cart: cart)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _checkoutButton(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'Cart',
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

  Widget _body(){
    return isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : cart.isEmpty 
          ? const Center(
            child: Text(
              'Cart is empty',
              style: TextStyle(
                fontSize: 18, // Increase the font size
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.black, // Use a muted color
              )),
          )
          :ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: cart.length,
            itemBuilder: (context, index) {
              final item = cart[index];
              return cartItem(item);
            }
          );
  }

  Widget cartItem(var item) {
  return GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return ItemDetailModal(
            id: item['_id'],
            name: item['name'],
            imageURL: item['imageURL'],
            price: item['price'],
          );
        },
      );
    },
    child: Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(6.0),
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                item['imageURL'],
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity: ${item['quantity']}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Color: ',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.normal),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 2.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(item['color'].toInt()),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          width: 15,
                          height: 15,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                child: Text(
                  '\$${(double.parse(item['price']) * item['quantity']).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Remove Item"),
                    content: Text("Remove ${item['name']} from the cart?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          removeFromCart(item['_id'].oid); // Call the remove function
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("Yes"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("No"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
                color: Colors.transparent,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ),

      ],
    ),
  );
}


  Widget _checkoutButton(){
    return BottomAppBar(
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ElevatedButton(
            onPressed: checkoutCart,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // Full-width button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
  }
}