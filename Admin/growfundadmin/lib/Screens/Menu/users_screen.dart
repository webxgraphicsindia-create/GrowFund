import 'dart:async';
import 'package:flutter/material.dart';

import '../../API/API.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> allUsers = [];
  List<Map<String, String>> filteredUsers = [];

  int _sortColumnIndex = 0;
  bool _isAscending = true;
  int _rowsPerPage = 10;
  int _currentPage = 0;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    //filteredUsers = List.from(allUsers);
  }

  void _fetchUsers() async {
    try {
      final users = await ApiService.fetchUsers();
      setState(() {
        allUsers = users;
        filteredUsers = List.from(allUsers);
      });
    } catch (e) {
      print("Error fetching users: $e");
      // You can also show a snackbar or error UI here
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredUsers = allUsers.where((user) {
          return user["name"]!.toLowerCase().contains(query.toLowerCase()) ||
              user["email"]!.toLowerCase().contains(query.toLowerCase()) ||
              user["phone"]!.toLowerCase().contains(query);
        }).toList();
        _currentPage = 0;
      });
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;

      filteredUsers.sort((a, b) {
        final valueA = a.values.elementAt(columnIndex);
        final valueB = b.values.elementAt(columnIndex);
        return ascending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int start = _currentPage * _rowsPerPage;
    int end = start + _rowsPerPage;
    List<Map<String, String>> paginatedUsers = filteredUsers.sublist(
      start,
      end > filteredUsers.length ? filteredUsers.length : end,
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Manage Users",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search by name, email, or phone",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortAscending: _isAscending,
                  sortColumnIndex: _sortColumnIndex,
                  columnSpacing: 100,
                  headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.indigo.shade50),
                  columns: [
                    DataColumn(label: _buildColumnText("Name"), onSort: _onSort),
                    DataColumn(label: _buildColumnText("Email"), onSort: _onSort),
                    DataColumn(label: _buildColumnText("Phone"), onSort: _onSort),
                    DataColumn(label: _buildColumnText("Role"), onSort: _onSort),
                    DataColumn(label: _buildColumnText("Status"), onSort: _onSort),
                    DataColumn(
                        label: _buildColumnText("Registered"), onSort: _onSort),
                    DataColumn(
                        label: _buildColumnText("Location"), onSort: _onSort),
                    DataColumn(
                        label: _buildColumnText("Department"), onSort: _onSort),
                    const DataColumn(
                        label: Text("Action",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: paginatedUsers.map((user) {
                    return DataRow(cells: [
                      DataCell(Text(user["name"]!)),
                      DataCell(Text(user["email"]!)),
                      DataCell(Text(user["phone"]!)),
                      DataCell(Text(user["role"]!)),
                      DataCell(Text(user["status"]!)),
                      DataCell(Text(user["registered"]!)),
                      DataCell(Text(user["location"]!)),
                      DataCell(Text(user["department"]!)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {},
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Page ${_currentPage + 1} of ${(filteredUsers.length / _rowsPerPage).ceil()}"),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: end < filteredUsers.length
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumnText(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
