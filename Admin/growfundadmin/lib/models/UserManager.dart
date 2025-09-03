

import '../API/API.dart';

class UserManager {
  List<Map<String, String>> allUsers = [];
  List<Map<String, String>> filteredUsers = [];

  Future<void> fetchUsers() async {
    final users = await ApiService.fetchUsers();
    allUsers = users;
    filteredUsers = List.from(users);
  }


  void filterUsers(String query) {
    filteredUsers = allUsers
        .where((user) =>
    user['name']!.toLowerCase().contains(query.toLowerCase()) ||
        user['email']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}