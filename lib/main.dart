import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:printer_shop_app/login.dart';
import '/db.dart';
import './sign_up.dart';
import './login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDBService().connect();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
