import 'package:flutter/material.dart';
import '/db.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;

class ViewUsers extends StatefulWidget {
  const ViewUsers({super.key});

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  Future<void> fetchUsers() async {
    var db = MongoDBService().db;
    var usersCollection = db.collection('UserCluster'); // Replace with your actual collection name

    try {
      var userList = await usersCollection.find().toList();
      setState(() {
        users = userList;
        isLoading = false;
      });
    } catch (e) {
      print("Failed to retrieve users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser(String id) async {
    var db = MongoDBService().db;
    var usersCollection = db.collection('UserCluster');

    try {
      await usersCollection.remove({'_id': mongo_dart.ObjectId.parse(id)});
      fetchUsers();
    } catch (e) {
      print("Failed to delete user: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : users.isEmpty
              ? const Center(
                  child: Text(
                    'No users available.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserCard(
                      user: user,
                      onDelete: () => deleteUser(user['_id'].oid),
                    );
                  },
                ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'All Users',
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

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onDelete;

  const UserCard({required this.user, required this.onDelete, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = user['name'] ?? "No Name"; // Add name
    final email = user['email'] ?? "No Email"; // Email remains the same

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ), // Display the name in bold
        subtitle: Text(email, style: const TextStyle(fontSize: 14)), // Email as subtitle
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
