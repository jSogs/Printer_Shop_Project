import 'package:mongo_dart/mongo_dart.dart';

class Order {
  final ObjectId userId;
  final List<dynamic> cart;
  final double price;
  final String address;
  final String deliveryMethod;
  final String date;

  Order(
      {required this.userId,
      required this.cart,
      required this.price,
      required this.address,
      required this.deliveryMethod,
      required this.date});
}
