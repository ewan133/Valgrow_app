import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/FBA.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/inventory_components/main_inventory_card.dart';
import 'package:valgrow_ui/components/general_components/searchbar.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/models/user_profile.dart';
import 'package:valgrow_ui/pages/inventory/item_details.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/services/database/inventory_database.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All"; // Default filter category
  final _inventoryDB = InventoryDatabase();
  List<String> categories = ["All"]; // Ensure "All" is always present
  UserProfile? user;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final provider = Provider.of<DatabaseProvider>(context, listen: false);
      user = provider.user;
      if (user == null) return;

      Set<String> categorySet =
          Set.from(await _inventoryDB.getUniqueCategories(user!.storeId));

      categorySet.addAll(["Canned Foods", "Noodles"]); // Add extra categories

      setState(() {
        categories = ["All", ...categorySet.toList()]; // Keep "All" first
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading categories: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(
        title: "Inventory",
        actionWidget: PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          itemBuilder: (context) => categories
              .map((category) => PopupMenuItem(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: MyText(
              text: "Filter",
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      floatingActionButton: MyFloatingActionButton(
        text: "Add Product",
        onPressed: () => Navigator.pushNamed(context, '/additem'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: MySearchbar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<DatabaseProvider>(
              builder: (context, inventoryProvider, child) {
                final items = inventoryProvider.items;
                final isLoading = inventoryProvider.isLoading;

                // Apply search and category filters
                final filteredItems = items.where((item) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      item.item_name.toLowerCase().contains(_searchQuery);
                  final matchesCategory = _selectedCategory == "All" ||
                      item.category == _selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                return isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredItems.isEmpty
                        ? const Center(
                            child: MyText(
                                text: "No items found",
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w400))
                        : ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ItemDetailsPage(item: item),
                                        ),
                                      );
                                    },
                                    child: MainInventoryCard(item: item)),
                              );
                            },
                          );
              },
            ),
          ),
        ],
      ),
    );
  }
}
