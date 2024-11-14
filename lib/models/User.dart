import '/models/printer.dart';

class User {
  final String name;
  final String email;
  final String password;
  final List<Printer> cart;
  User({required this.name, required this.email, required this.password, required this.cart});
}