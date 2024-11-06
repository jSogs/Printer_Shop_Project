import 'package:mongo_dart/mongo_dart.dart';

class MongoDBService {
  static final MongoDBService _instance = MongoDBService._internal();
  factory MongoDBService() => _instance;

  MongoDBService._internal();

  final String _connectionUrl = "mongodb+srv://julianasogwa96:b4GKGZ7yV4j4n76m@usercluster.x4ns7.mongodb.net/";
  late Db _db;

  Future<void> connect() async {
    try {
      _db = await Db.create(_connectionUrl);
      await _db.open();
      print("Connected to MongoDB");
    } catch (e) {
      print("Error connecting to MongoDB: $e");
    }
  }

  Db get db => _db;

  Future<void> close() async {
    await _db.close();
  }
}
