import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import 'notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db.dart';

class ItemDetailModal extends StatefulWidget {
  final mongo_dart.ObjectId id;
  final String name;
  final String imageURL;
  final String price;

  const ItemDetailModal({
    super.key,
    required this.id,
    required this.name,
    required this.imageURL,
    required this.price,
  });

  @override
  _ItemDetailModalState createState() => _ItemDetailModalState();
}

class _ItemDetailModalState extends State<ItemDetailModal> {
  int quantity = 1;
  final List<Color> availableColors = [Colors.black, Colors.grey, Colors.white, Colors.blue];
  Color? selectedColor;
  

  Future<bool> addToCart() async{
    var db = MongoDBService().db;
    var usersCollection = db.collection('UserCluster');
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('unique_id') ?? "";
    try{
      var user = await usersCollection.findOne({"_id": mongo_dart.ObjectId.parse(userId)});
      if(user == null){
        print("User not found.");
        return false;
      }
      List<dynamic> cart = user['cart'] ?? [];
      for(int i=0; i<cart.length; i++){
        if(cart[i]['_id'] == widget.id && cart[i]['color']==selectedColor?.value){
          cart.removeAt(i);
        }
      }
      print("${widget.id} ${widget.name} ${widget.price} ${selectedColor.toString()} $quantity");
      cart.add({
        '_id': widget.id,
        'name': widget.name,
        'price': widget.price,
        'color': selectedColor?.value ?? Colors.black.value,
        'quantity': quantity,
        'imageURL': widget.imageURL,
      });
      await usersCollection.updateOne(
        {"_id": mongo_dart.ObjectId.parse(userId)},
        mongo_dart.modify.set("cart", cart),
      );
      await prefs.setInt('cart_size',cart.length);
      // Update cart in the notifier and notify listeners
      cartNotifier.value = cart;
      cartNotifier.notifyListeners(); // Notifies `CartPage` to refresh

      print("Item added to cart successfully.");
      return true;
    } catch(e){
      print("Failed to add item to cart: $e");
      return false;
    }
  }
  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,  // Truncate if it overflows
                ),
              ),
              const SizedBox(width: 8),  // Add some spacing
              Text(
                '\$${widget.price}',
                style: const TextStyle(fontSize: 20, color: Colors.grey),
                overflow: TextOverflow.ellipsis,  // Optional: Truncate if price is too long
              ),
            ],
          ),
          const SizedBox(height: 16),
          Image.network(
            widget.imageURL,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: decrementQuantity,
                icon: const Icon(Icons.remove),
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: incrementQuantity,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Available Colors:",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(width: 10),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: availableColors.map<Widget>((color){
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: selectedColor == color ? const Color.fromARGB(255, 173, 7, 223) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          width: 30,
                          height: 30,
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Add to cart logic
                await addToCart();
                print("Added $quantity of ${widget.name} to cart.");
                Navigator.pop(context); // Close modal after adding to cart
              },
              child: const Text("Add to Cart"),
            ),
          ),
        ],
      ),
    );
  }
}
